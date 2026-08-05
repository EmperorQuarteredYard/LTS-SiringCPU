`include "define.vh"
module RAM#(
    parameter MAX_WAIT_CYCLE = 3,//1-31
    parameter MAX_TASK_CYCLE = 15
)(
    input clk,
    input rst,
    output [31:0] o32_simulate,
    //外部 SRAM 物理接口
    inout  [31:0] RAM_data,      // 双向数据总线：读时由SRAM驱动，写时由本模块驱动
    output [19:0] RAM_addr,      // 字地址输出（物理地址右移2位后的低20位，按4字节对齐）
    output [ 3:0] RAM_be_n,      // 字节写使能掩码（低有效）：[3]对应bit31:24, [0]对应bit7:0
    output        RAM_ce_n,      // 芯片片选（低有效）：为0时选中SRAM进行访问
    output        RAM_oe_n,      // 输出使能（低有效）：为0时SRAM将数据输出到RAM_data总线
    output        RAM_we_n,      // 写使能（低有效）：为0时SRAM从RAM_data总线锁存数据

    //  上游请求通道（其他模块 -> RAM控制器）
    input         requ_valid,    // 请求有效标志：高电平时表示当前请求有效
    input  [19:0] requ_addr,     // 请求访问的目标字地址（已省略最低2位）
    input         requ_type,     // 请求操作类型：0=读操作，1=写操作
    input  [31:0] requ_wdata,    // 写操作时携带的待写入数据（读操作时忽略）
    input  [ 3:0] requ_wstrb,    // 写操作时的字节选通掩码（高有效）：对应wdata的哪些字节要写入
    input         requ_exdat,    // 请求携带的外部异常/扩展状态（如非对齐、特权级错误等）
    output        requ_ready,    // 请求握手的“就绪”信号：高表示当前控制器空闲，可接收新请求

    //  下游响应通道（RAM控制器 -> 其他模块）
    output        resp_valid,    // 响应有效标志：高电平时表示下游可以接收当前响应数据
    output [31:0] resp_rdata,    // 读操作返回的数据（写操作时无意义或置0）
    output        resp_exdat,    // 响应携带的异常/扩展状态（透传自requ_exdat或读异常标志）
    input         resp_ready     // 下游接收端的“就绪”信号：高表示CPU已准备好接收响应数据
);

`ifdef RAM_BEHAVIOR_ASYN

reg [ 4:0] wait_cycle;
reg [ 4:0] task_cycle;
reg [ 1:0] reg_cntrs ;
reg [19:0] reg_addr  ;
reg [31:0] reg_data  ;
reg [ 3:0] reg_wstrb ;
reg        reg_exdat ;
reg        reg_entype;
reg [31:0] reg_rdata ;
reg        reg_valid ;

wire [ 1:0] wire_cntrs;
wire [19:0] wire_addr ;
wire [31:0] wire_data ;
wire [ 3:0] wire_wstrb;
wire        wire_exdat;
wire [ 1:0] nxt_stage ;
wire        wire_we_n;//注意！这里已经是取反了的
wire        wire_re_n;
wire        wire_valid;

assign wire_cntrs  = reg_cntrs ;
assign wire_addr   = reg_addr  ;
assign wire_data   = reg_data  ;
assign wire_wstrb  = reg_wstrb ;
assign wire_exdat  = reg_exdat ;
assign wire_we_n   =~reg_entype;
assign wire_re_n   = reg_entype;
assign wire_valid  = reg_valid;

wire requ_handshake;
wire resp_handshake;

assign requ_handshake = requ_ready & requ_valid;
assign resp_handshake = resp_ready & resp_valid;

assign RAM_be_n    =~wire_wstrb;
assign RAM_addr    = wire_addr;
assign RAM_data    = wire_we_n?32'bz:wire_data;
assign RAM_addr    = wire_addr;
assign RAM_oe_n    = wire_re_n;
assign RAM_we_n    = wire_we_n;
assign RAM_ce_n    =~wire_valid;
assign resp_rdata  = resp_valid? 32'bz:(RAM_data&{{8{wire_wstrb[3]}},{8{wire_wstrb[2]}},{8{wire_wstrb[1]}},{8{wire_wstrb[0]}}});
assign resp_valid = wait_cycle == 0 & (requ_addr == wire_addr);
assign resp_exdat = wire_exdat;
assign requ_ready = ((wait_cycle == 0)&resp_handshake)|~wire_valid|(task_cycle == 0);


always @(posedge clk) begin
    if (rst) begin
        // 同步复位，清空状态和计数器
        reg_cntrs  <= 2'b00;
        reg_addr   <= 20'b0;
        reg_data   <= 32'b0;
        reg_wstrb  <= 4'hf;
        reg_exdat  <= 1'b0;
        reg_rdata  <= 32'b0;
        reg_entype <= 1'b0;
        reg_valid  <= 1'b0;
        task_cycle <= MAX_TASK_CYCLE;
        wait_cycle <= 4'b0;
    end 
    else begin
        if(wait_cycle!=0)wait_cycle <= wait_cycle - 1;
        if(wait_cycle!=0)task_cycle <= task_cycle - 1;
        if (requ_handshake) begin
            wait_cycle<= MAX_WAIT_CYCLE&{5{~requ_type}};
            task_cycle<= MAX_TASK_CYCLE;
            reg_valid <= 1'b1;
            reg_addr  <= requ_addr;
            reg_data  <= requ_wdata;
            reg_wstrb <= requ_wstrb;
            reg_exdat <= requ_exdat;
            reg_entype<= requ_type;
        end
        // 读访问的最后一个周期采样RAM数据
    end
end

`ifdef RAM_BEHAVIOR_SYNC
wire //这里不要改！看到这里报错了说明你在define.vh中同时开启了同步、异步RAM的定义
wire all_are_exist;
`endif
`else
`ifdef RAM_BEHAVIOR_SYNC
assign RAM_data = requ_type?requ_wdata:32'bz;
assign RAM_addr = requ_addr;
assign RAM_be_n = ~requ_wstrb;
assign RAM_ce_n =~requ_valid;
assign RAM_oe_n = requ_type;
assign RAM_we_n = ~requ_type;
assign requ_ready = 1'b1;
assign resp_valid = 1'b1;
assign resp_rdata = requ_type?32'bz:RAM_data;
assign resp_exdat = requ_exdat;

assign o32_simulate = {32{requ_type}};
`else
wire //这里不要改！看到这里报错了说明你在define.vh中同时关闭了同步、异步RAM的定义
wire all_not_exist;
`endif


`endif

endmodule
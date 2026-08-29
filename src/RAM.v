`include "define.vh"
module RAM#(
    parameter MAX_WAIT_CYCLE = 3,//1-31，只在启用异步RAM时有效
    parameter MAX_KEEP_CYCLE = 4 //这里是在等待完成后保持信号周期数
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
//此时使用异步RAM模型
//非对齐内存访问应当在总线中增加，但是目前并不需要做
reg         r01_requ_ready;
reg         r01_resp_allow;
reg         r01_reg_valid;
reg  [19:0] r20_requ_addr;
reg         r01_requ_type;
reg  [31:0] r32_requ_wdata;
reg  [ 3:0] r04_requ_wstrb;
reg         r01_requ_exdat;
reg         r01_tran_allow;//transaction,需要内存总线事务
reg         r01_tran_stage;

wire [19:0] w20_requ_addr;
wire        w01_requ_type;
wire [31:0] w32_requ_wdata;
wire [ 3:0] w04_requ_wstrb;
wire        w01_requ_exdat;
wire        w01_reg_valid;

assign w20_requ_addr  = r20_requ_addr;
assign w01_requ_type  = r01_requ_type;
assign w32_requ_wdata = r32_requ_wdata;
assign w04_requ_wstrb = r04_requ_wstrb;
assign w01_requ_exdat = r01_requ_exdat;
assign w01_reg_valid  = r01_reg_valid;

reg [4:0] r05_wait_count;
reg [4:0] r05_keep_count;

wire w01_requ_handshake;
wire w01_resp_handshake;

assign w01_requ_handshake = requ_valid & requ_ready;
assign w01_resp_handshake = resp_valid & resp_ready;
assign requ_ready = r01_requ_ready;
assign resp_valid = (r05_wait_count == 5'b0) & r01_resp_allow;

assign RAM_data = w01_requ_type?w32_requ_wdata:32'bz;
assign RAM_addr = w20_requ_addr;
assign RAM_be_n = ~w04_requ_wstrb;
assign RAM_ce_n = ~w01_reg_valid;
assign RAM_oe_n = w01_requ_type;
assign RAM_we_n = ~w01_requ_type;

assign resp_rdata = (w01_requ_type&~w01_requ_exdat)?32'b0:{
    {8{w04_requ_wstrb[3]}}&RAM_data[31:24],
    {8{w04_requ_wstrb[2]}}&RAM_data[23:16],
    {8{w04_requ_wstrb[1]}}&RAM_data[15: 8],
    {8{w04_requ_wstrb[0]}}&RAM_data[ 7: 0]};
assign resp_exdat = w01_requ_exdat;

always @(posedge clk) begin
    if(rst)begin
        r01_resp_allow <=  1'b0;
        r01_requ_ready <=  1'b1;
        r20_requ_addr  <= 20'b0;
        r01_requ_type  <=  1'b0;
        r32_requ_wdata <= 32'b0;
        r04_requ_wstrb <=  4'b0;
        r01_requ_exdat <=  1'b0;
        r01_reg_valid  <=  1'b0;
        r05_wait_count <=  1'b0;
        r05_keep_count <=  1'b0;
    end
    else begin
        if(w01_requ_handshake)begin
            r01_requ_ready <= 1'b0;
            r20_requ_addr  <= requ_addr;
            r01_requ_type  <= requ_type;
            r32_requ_wdata <= requ_wdata;
            r04_requ_wstrb <= requ_wstrb;
            r01_requ_exdat <= requ_exdat;
            r05_wait_count <= MAX_WAIT_CYCLE;
            r05_keep_count <= requ_type?5'b0:MAX_KEEP_CYCLE;
            r01_reg_valid  <= 1'b1;
            r01_resp_allow <= 1'b1;
        end
        else begin
            if(w01_resp_handshake|(r05_keep_count == 5'b0))begin
                r01_reg_valid  <=  1'b0;
                r01_requ_ready <=  1'b1;
                r01_resp_allow <=  1'b0;
                r01_requ_exdat <=  1'b0;
                r20_requ_addr  <= 20'b0;
                r01_requ_type  <=  1'b0;
                r32_requ_wdata <= 32'b0;
                r04_requ_wstrb <=  4'b0;
            end
            if (r05_wait_count != 5'b0) r05_wait_count <= r05_wait_count - 5'b1;
            else if (r05_keep_count != 5'b0) r05_keep_count <= r05_keep_count - 5'b1;
        end
    end

end
`ifdef RAM_BEHAVIOR_SYNC
这里不要改！看到这里报错了说明你在define.vh中同时开启了同步、异步RAM的定义
wire SYNC_ASYC_ENVIRONMENT_MUTIDIFINE;
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
assign resp_rdata = (requ_type&~resp_exdat)?32'b0:{
    {8{requ_wstrb[3]}}&RAM_data[31:24],
    {8{requ_wstrb[2]}}&RAM_data[23:16],
    {8{requ_wstrb[1]}}&RAM_data[15: 8],
    {8{requ_wstrb[0]}}&RAM_data[ 7: 0]};
assign resp_exdat = requ_exdat|(requ_addr[1:0]!=2'b00);

assign o32_simulate = {32{requ_type}};
`else
这里不要改！看到这里报错了说明你在define.vh中同时关闭了同步、异步RAM的定义
wire SYNC_ASYC_ENVIRONMENT_NOTFOUND;
`endif


`endif

endmodule
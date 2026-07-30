module RAM(
    input         clk,
    input         rst,

    // RAM硬件信号交互
    inout  [31:0] RAM_data,               // 双向数据总线
    output [19:0] RAM_addr,               // 地址（低20位）
    output [ 3:0] RAM_be_n,               // 字节使能（低有效）
    output        RAM_ce_n,               // 片选（低有效）
    output        RAM_oe_n,               // 输出使能（低有效）
    output        RAM_we_n,               // 写使能（低有效）

    input         requ_valid,
    input  [19:0] requ_addr,
    input         requ_type,              // 0读 1写
    input  [31:0] requ_wdata,
    input  [ 3:0] requ_wstrb,
    input         requ_exdat,
    output        requ_ready,

    output        resp_valid,
    output [31:0] resp_rdata,
    output        resp_exdat,
    input         resp_ready
);

localparam Tcyc = 4;  // SRAM访问等待周期数（可调）

// 内部寄存器
reg  [19:0] reg_addr;
reg  [31:0]                reg_data;
reg  [ 3:0]                reg_wstrb;
reg                        reg_exdat;

reg  [ 1:0] reg_state;    // 00空闲 01写 10读响应 11读
reg  [ 1:0] reg_cntrs;    // 等待计数器

wire [31:0] read_data = RAM_data;   // 读数据直接来自双向总线

wire        end_cycle = (reg_cntrs == 0);
wire [ 1:0] nxt_state_1 = reg_state & {1'b1, ~end_cycle};

wire        resp_valid_w = (nxt_state_1 == 2'b10) & !rst;
wire        resp_shake   = resp_valid_w & resp_ready;
wire [ 1:0] nxt_state_2 = nxt_state_1 & {~resp_shake, 1'b1};

wire        requ_ready_w = (nxt_state_2 == 2'b00) & !rst;
wire        requ_shake   = requ_valid & requ_ready_w;
wire [ 1:0] nxt_state_3 = (nxt_state_2 | {requ_shake & ~requ_type, requ_shake}) & {2{~rst}};

// 计数器更新逻辑
wire        cntr_ram_en = requ_shake;
wire        cntr_m1_en  = (reg_cntrs != 2'b0);
wire [ 1:0] nxt_cntrs = {2{cntr_ram_en}} & (Tcyc[1:0] - 2'b1)
                      | {2{cntr_m1_en}}  & (reg_cntrs - 2'b1);
// SRAM控制信号输出（组合逻辑）
assign RAM_addr = reg_addr;
assign RAM_be_n = ~reg_wstrb;                     // 低有效
assign RAM_ce_n = ~reg_state[0] || rst;           // 非空闲时选中
assign RAM_oe_n = ~reg_state[1];                  // 读或读响应态使能输出
assign RAM_we_n =  reg_state[1];                  // 读时写无效，写时写有效

// 三态数据总线：仅在写状态（01）驱动写数据，其他时刻高阻
assign RAM_data = (reg_state == 2'b01) ? reg_data : 32'bz;

// 响应输出
assign resp_valid = resp_valid_w;
assign resp_rdata = {32{~reg_state[0]}} & reg_data
                  | {32{ reg_state[0]}} & read_data;
assign resp_exdat = reg_exdat;
assign requ_ready = requ_ready_w;

// 时序逻辑：状态、计数器及数据锁存
always @(posedge clk) begin
    if (rst) begin
        // 同步复位，清空状态和计数器
        reg_state  <= 2'b00;
        reg_cntrs  <= 2'b00;
        // 数据寄存器不清零，但建议初始化（可选）
        reg_addr   <= {RAM_ADDR_LENGTH{1'b0}};
        reg_data   <= 32'b0;
        reg_wstrb  <= 4'b0;
        reg_exdat  <= 1'b0;
    end else begin
        reg_state <= nxt_state_3;
        reg_cntrs <= nxt_cntrs;
        // 新请求握手时锁存输入
        if (requ_shake) begin
            reg_addr  <= requ_addr;
            reg_data  <= requ_wdata;
            reg_wstrb <= requ_wstrb;
            reg_exdat <= requ_exdat;
        end
        // 读访问的最后一个周期采样RAM数据
        else if (reg_state == 2'b11 && end_cycle) begin
            reg_data <= read_data;
        end
    end
end

endmodule
module RAM
(
    input         clk,            // clock input
    input         rst,            // BTN6 manual reset button, active high, with debouncing, press to 1

    // BaseRAM signals
    input  [31:0] ram_rdat,  // RAM read  data
	output [31:0] ram_wdat,  // RAM write data
    output [19:0] ram_addr,  // RAM address
    output [ 3:0] ram_be_n,  // RAM byte enable, low active. If byte enable is not used, keep 0
    output        ram_ce_n,  // RAM chip enable, low active
    output        ram_oe_n,  // RAM read enable, low active
    output        ram_we_n,  // RAM write enable, low active

	input         requ_valid,       // Request valid
    input  [19:0] requ_addr,        // Request address
    input         requ_type,        // Request type (0 for read, 1 for write)
    input  [31:0] requ_wdata,       // Request write data
    input  [ 3:0] requ_wstrb,       // Request write strobe
    input         requ_exdat,       // Request exclusive access
    output        requ_ready,       // Request ready

    output        resp_valid,      // Response valid
    output [31:0] resp_rdata,      // Response read data
    output        resp_exdat,      // Response exclusive access
    input         resp_ready       // Response ready
);

localparam Tcyc = 4;

//实际地址共有22位，[21:20]是00代表是baseRAM、01代表是extRAM、11代表是UART，[19:0]是实际地址
//0x1f000000是串口地址，0x1f000005是串口状态地址。
reg  [19:0] reg_addr ;    //寄存器地址
reg  [31:0] reg_data ;    //寄存器数据
reg  [ 3:0] reg_wstrb;    //寄存器写字节使能
reg         reg_exdat;    //寄存器外部数据

reg  [ 1:0] reg_state;    //状态机状态, 00为空闲，01为写，10为读写回，11为读；
reg  [ 1:0] reg_cntrs;    //计数器，记录RAM访存周期数

wire [31:0] read_data;
wire        end_cycle;    //RAM访存周期结束标志
wire [ 1:0] nxt_state_1;  //状态机第一状态，如果当前是读或者写并且计数器到0，那么分别切换到空闲或者读写回。
wire        resp_shake;   //resp握手
wire [ 1:0] nxt_state_2;  //状态机第二状态，如果当前读写回并且响应手成功，那么切换回空闲。
wire        requ_shake;   //requ握手
wire [ 1:0] nxt_state_3;  //状态机第三状态，如果当前空闲并且请求握手成功，那么切换到写或者读；但是如果重置那么切换到空闲。
wire        cntr_ram_en;
wire        cntr_m1_en;
wire [ 1:0] nxt_cntrs;

assign ram_wdat  =  reg_data;
assign ram_addr  =  reg_addr[19: 0];
assign ram_be_n  = ~reg_wstrb; //低有效
assign ram_ce_n  = ~reg_state[0] || rst;
assign ram_oe_n  = ~reg_state[1];
assign ram_we_n  =  reg_state[1];
assign read_data =  ram_rdat;
assign     end_cycle = (reg_cntrs == 0);
assign   nxt_state_1 =  reg_state & {1'b1, ~end_cycle};
assign   resp_valid  = (nxt_state_1 == 2'b10) & !rst;
assign   resp_rdata  = {32{~reg_state[0]}} & reg_data
					 | {32{ reg_state[0]}} & read_data;
assign   resp_exdat  =  reg_exdat;
assign   resp_shake  =  resp_valid & resp_ready;
assign   nxt_state_2 =  nxt_state_1 & {~resp_shake, 1'b1};
assign   requ_ready  = (nxt_state_2 == 2'b00) & !rst;
assign   requ_shake  =  requ_valid & requ_ready;
assign   nxt_state_3 = (nxt_state_2 | {requ_shake & ~requ_type, requ_shake}) & {2{~rst}};
assign   cntr_ram_en = requ_shake;
assign   cntr_m1_en  = reg_cntrs != 2'b0;
assign nxt_cntrs = {2{cntr_ram_en}} & (Tcyc[1:0] - 2'b1)
                 | {2{cntr_m1_en}}  & (reg_cntrs - 2'b1); //根据cntr_ram_en和cntr_m1_en更新计数器

always @(posedge clk)
begin
	reg_state <= nxt_state_3;	
	reg_cntrs <= nxt_cntrs;

	if(requ_shake)
	begin
		reg_addr  <= requ_addr;
		reg_data  <= requ_wdata;
		reg_wstrb <= requ_wstrb;
		reg_exdat <= requ_exdat;
	end
	else if(reg_state == 2'b11 && end_cycle)
	begin
		reg_data  <= read_data;
	end
end

endmodule
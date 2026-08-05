`timescale 1ns/1ps

module RAM_tb;

reg clk;
reg rst;
wire [31:0] RAM_data;
reg [19:0] RAM_addr;
reg [ 3:0] RAM_be_n;
reg        RAM_ce_n;
reg        RAM_oe_n;
reg        RAM_we_n;
reg        requ_valid;
reg [19:0] requ_addr;
reg        requ_type;
reg [31:0] requ_wdata;
reg [ 3:0] requ_wstrb;
reg        requ_exdat;
reg        requ_ready;
reg        resp_valid;
reg [31:0] resp_rdata;
reg        resp_exdat;
reg        resp_ready;

reg  [31:0] RAM_data_drv;
reg         RAM_data_oe; 
assign RAM_data = RAM_data_oe ? RAM_data_drv : 32'hz;

RAM u_RAM(
    .clk(clk),
    .rst(rst),
    .RAM_data(RAM_data),
    .RAM_addr(RAM_addr),
    .RAM_be_n(RAM_be_n),
    .RAM_ce_n(RAM_ce_n),
    .RAM_oe_n(RAM_oe_n),
    .RAM_we_n(RAM_we_n),
    .requ_valid(requ_valid),
    .requ_addr(requ_addr),
    .requ_type(requ_type),
    .requ_wdata(requ_wdata),
    .requ_wstrb(requ_wstrb),
    .requ_exdat(requ_exdat),
    .requ_ready(requ_ready),
    .resp_valid(resp_valid),
    .resp_rdata(resp_rdata),
    .resp_exdat(resp_exdat),
    .resp_ready(resp_ready)
);
always #10 clk = ~clk;
initial begin
    rst = 0;
    clk = 0;
    resp_ready = 0;
    requ_valid = 0;
    requ_addr = 0;
    requ_type = 0;
    requ_wdata = 0;
    requ_wstrb = 0;
    requ_exdat = 0;
    RAM_data_oe  = 0;          // 默认释放总线
    RAM_data_drv = 0;
    #20
    rst = 1;
    #20
    rst = 0;
    #20
    requ_valid = 1;
    requ_addr = 32'h12345678;
    
end



endmodule
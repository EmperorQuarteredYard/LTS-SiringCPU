module IFU(
    input clk,
    input rst,

    output [31:0] o32_simulate,
    output        o01_simulate,

    output        IFU_IDU_valid,
    output [31:0] IFU_IDU_pc,
    output [31:0] IFU_IDU_inst,
    output [ 1:0] IFU_IDU_id,
    input         IDU_IFU_ready,

    input         ISU_IFU_PCmis,
    input  [31:0] ISU_IFU_PCnew,

    output        IFU_RAM_valid,
    output [31:0] IFU_RAM_raddr,
    input         RAM_IFU_ready,

    input         RAM_IFU_valid,
    input  [31:0] RAM_IFU_rdata,
    output        IFU_RAM_ready
);
wire [31:0] PC;
wire [ 1:0] PCid;
wire IFU_IDU_handshake;
wire [31:0] inst;
wire        valid;

assign o32_simulate = PC;
assign o01_simulate = rst;

PCU PCU(
    .clk(clk),
    .rst(rst),

    .PC( PC),
    .inst(inst),
    .IFU_IDU_handshake(IFU_IDU_handshake),
    .PCid(PCid),

    .PCmis(ISU_IFU_PCmis),
    .PCnew(ISU_IFU_PCnew)
);
ICU ICU
(
	.clk(clk),
	.rst(rst),

	.IFU_RAM_valid(IFU_RAM_valid),
	.IFU_RAM_raddr(IFU_RAM_raddr),
	.RAM_IFU_ready(RAM_IFU_ready),
	.RAM_IFU_valid(RAM_IFU_valid),
	.RAM_IFU_rdata(RAM_IFU_rdata),
	.IFU_RAM_ready(IFU_RAM_ready),
    // .o_cac_hit(),
    // .state(),

	.PC   (PC),
	.inst (inst),
	.valid(valid)
);
assign IFU_IDU_valid = valid && !rst;
assign IFU_IDU_pc    = PC;
assign IFU_IDU_inst  = inst;
assign IFU_IDU_id    = PCid;
assign IFU_IDU_handshake = IFU_IDU_valid && IDU_IFU_ready;
endmodule
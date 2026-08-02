`include "define.vh"
module TOP(
    input clk,
    input rstn,
    // BASE SRAM
    output [19:0] BASERAM_a,
    inout  [31:0] BASERAM_dq,
    output        BASERAM_oe_n,
    output        BASERAM_we_n,
    output        BASERAM_ce_n,
    output [3:0]  BASERAM_be_n,
    `ifdef ENVIRONMENT_SIMULATE
    output [31:0] o32_simulate,
    output [16:0] o16_simulate,
    output        o01_simulate,
    `endif

    // EXT SRAM
    output [19:0] EXTRAM_a,
    inout  [31:0] EXTRAM_dq,
    output        EXTRAM_oe_n,
    output        EXTRAM_we_n,
    output        EXTRAM_ce_n,
    output [3:0]  EXTRAM_be_n


);
wire rst;
assign rst = ~rstn;

wire        IFU_IDU_valid;
wire [31:0] IFU_IDU_pc;
wire [31:0] IFU_IDU_inst;
wire [ 1:0] IFU_IDU_id;
wire        ISU_IFU_PCmis;
wire [31:0] ISU_IFU_PCnew;
wire        IFU_RAM_valid;
wire [31:0] IFU_RAM_raddr;
wire        RAM_IFU_ready;
wire        RAM_IFU_valid;
wire [31:0] RAM_IFU_rdata;
wire        IFU_RAM_ready;

wire        IDU_IFU_ready; //IDU ISU有效信号
wire [31:0] IDU_ISU_PCnew;
wire        IDU_ISU_PCmis;
wire        IDU_EXU_valid;
wire [31:0] IDU_EXU_rs1;
wire [31:0] IDU_EXU_rs2;
wire [ 3:0] IDU_EXU_ope;
wire [ 4:0] IDU_EXU_rd;
wire [31:0] IDU_EXU_wdata;
wire [10:0] IDU_EXU_func;//这里描述得到的结果是什么含义，0-0-0-0-0-0-0-0-st-ld-alu运算

wire [ 4:0] IDU_GPR_rj;
wire [ 4:0] IDU_GPR_rk;
wire [ 4:0] IDU_GPR_rd;
wire [31:0] GPR_IDU_rj;
wire [31:0] GPR_IDU_rk;
wire [31:0] GPR_IDU_rd;//IDU通过ISU访问GPR；GPR的读行为不需要经过一拍
wire        ISU_IDU_ready;  //ISU IDU准备好信号
wire        EXU_ISU_valid;
wire [ 4:0] EXU_ISU_rd;
wire [31:0] EXU_ISU_res;
wire        MEM_st_en;
wire        MEM_ld_en;
wire        ISU_wb_en;
wire        ISU_EXU_ready;

wire        EXU_IDU_ready;

wire [31:0] EXU_MEM_addr;
wire        EXU_MEM_valid;
wire        MEM_EXU_ready;
wire [ 4:0] EXU_MEM_rd;
wire [31:0] EXU_MEM_wdata;

wire        MEM_ISU_valid;
wire [31:0] MEM_ISU_data;
wire [ 4:0] MEM_ISU_rd;
wire        ISU_MEM_ready;

MEM MEM(
    .clk(clk),
    .rst(rst),
    .EXU_MEM_valid(EXU_MEM_valid),
    .EXU_MEM_wen(MEM_st_en),
    .EXU_MEM_ren(MEM_ld_en),
    .EXU_MEM_wdata(EXU_MEM_wdata),
    .EXU_MEM_addr(EXU_MEM_addr),
    .EXU_MEM_rd(EXU_MEM_rd),
    .MEM_EXU_ready(MEM_EXU_ready),
    .MEM_ISU_valid(MEM_ISU_valid),
    .MEM_ISU_data(MEM_ISU_data),
    .MEM_ISU_rd(MEM_ISU_rd),
    .ISU_MEM_ready(ISU_MEM_ready),
    .IFU_MEM_valid(IFU_RAM_valid),
    .IFU_MEM_en(1'b1),//因为不知道写什么就干脆一直使能了
    .IFU_RAM_raddr(IFU_RAM_raddr),
    .RAM_IFU_rdata(RAM_IFU_rdata),
    .MEM_IFU_ready(RAM_IFU_ready),
    .MEM_IFU_finish(RAM_IFU_valid),
    .BASERAM_a(BASERAM_a),
    .BASERAM_dq(BASERAM_dq),
    .BASERAM_oe_n(BASERAM_oe_n),
    .BASERAM_we_n(BASERAM_we_n),
    .BASERAM_ce_n(BASERAM_ce_n),
    .BASERAM_be_n(BASERAM_be_n),
    .EXTRAM_a(EXTRAM_a),
    .EXTRAM_dq(EXTRAM_dq),
    .EXTRAM_oe_n(EXTRAM_oe_n),
    .EXTRAM_we_n(EXTRAM_we_n),
    .EXTRAM_ce_n(EXTRAM_ce_n),
    .EXTRAM_be_n(EXTRAM_be_n)
);
IFU IFU(
    .clk(clk),
    .rst(rst),
    // .o32_simulate(o32_simulate),
    // .o01_simulate(o01_simulate),
    .IFU_IDU_valid(IFU_IDU_valid),
    .IFU_IDU_pc(IFU_IDU_pc),
    .IFU_IDU_inst(IFU_IDU_inst),
    .IFU_IDU_id(IFU_IDU_id),
    .IDU_IFU_ready(IDU_IFU_ready),
    .ISU_IFU_PCmis(ISU_IFU_PCmis),
    .ISU_IFU_PCnew(ISU_IFU_PCnew),
    .IFU_RAM_valid(IFU_RAM_valid),
    .IFU_RAM_raddr(IFU_RAM_raddr),
    .RAM_IFU_ready(RAM_IFU_ready),
    .RAM_IFU_valid(RAM_IFU_valid),
    .RAM_IFU_rdata(RAM_IFU_rdata),
    .IFU_RAM_ready(IFU_RAM_ready)
);

IDU IDU(
    .clk(clk),
    .rst(rst),

    .IFU_IDU_valid(IFU_IDU_valid),
    .IFU_IDU_pc(IFU_IDU_pc),
    .IFU_IDU_inst(IFU_IDU_inst),
    .IFU_IDU_id(IFU_IDU_id),
    .IDU_IFU_ready(IDU_IFU_ready),
    .IDU_ISU_valid(IDU_ISU_valid),
    .IDU_GPR_rj(IDU_GPR_rj),
    .IDU_GPR_rk(IDU_GPR_rk),
    .IDU_GPR_rd(IDU_GPR_rd),
    .GPR_IDU_rj(GPR_IDU_rj),
    .GPR_IDU_rk(GPR_IDU_rk),
    .GPR_IDU_rd(GPR_IDU_rd),
    .IDU_ISU_PCnew(IDU_ISU_PCnew),
    .IDU_ISU_PCmis(IDU_ISU_PCmis),
    .ISU_IDU_ready(ISU_IDU_ready),
    .IDU_EXU_valid(IDU_EXU_valid),
    .IDU_EXU_rs1(IDU_EXU_rs1),
    .IDU_EXU_rs2(IDU_EXU_rs2),
    .IDU_EXU_ope(IDU_EXU_ope),
    .IDU_EXU_rd(IDU_EXU_rd),
    .IDU_EXU_func(IDU_EXU_func),
    .IDU_EXU_wdata(IDU_EXU_wdata),
    .EXU_IDU_ready(EXU_IDU_ready)
);

EXU EXU(
    .clk(clk),
    .rst(rst),

    .IDU_EXU_valid(IDU_EXU_valid),
    .IDU_EXU_rs1(IDU_EXU_rs1),
    .IDU_EXU_rs2(IDU_EXU_rs2),
    .IDU_EXU_ope(IDU_EXU_ope),
    .IDU_EXU_rd(IDU_EXU_rd),
    .IDU_EXU_func(IDU_EXU_func),
    .IDU_EXU_wdata(IDU_EXU_wdata),
    .EXU_IDU_ready(EXU_IDU_ready),

    .EXU_MEM_valid(EXU_MEM_valid),
    .EXU_MEM_addr(EXU_MEM_addr),
    .EXU_MEM_wdata(EXU_MEM_wdata),
    .EXU_MEM_rd(EXU_MEM_rd),
    .MEM_st_en(MEM_st_en),
    .MEM_ld_en(MEM_ld_en),
    .MEM_EXU_ready(MEM_EXU_ready),
    
    .EXU_ISU_valid(EXU_ISU_valid),
    .EXU_ISU_rd(EXU_ISU_rd),
    .EXU_ISU_res(EXU_ISU_res),
    .ISU_wb_en(ISU_wb_en),
    .ISU_EXU_ready(ISU_EXU_ready)

);

ISU ISU(
    .clk(clk),
    .rst(rst),

	.IDU_ISU_valid(IDU_ISU_valid), //IDU ISU有效信号    
    .IDU_GPR_rj(IDU_GPR_rj),
    .IDU_GPR_rk(IDU_GPR_rk),
    .IDU_GPR_rd(IDU_GPR_rd),
    .GPR_IDU_rj(GPR_IDU_rj),
    .GPR_IDU_rk(GPR_IDU_rk),
    .GPR_IDU_rd(GPR_IDU_rd),//IDU通过ISU访问GPR；GPR的读行为不需要经过一拍
	.IDU_ISU_PCnew(IDU_ISU_PCnew),
	.IDU_ISU_PCmis(IDU_ISU_PCmis),
	.ISU_IDU_ready(ISU_IDU_ready),  //ISU IDU准备好信号
    .ISU_IFU_PCmis(ISU_IFU_PCmis),
    .ISU_IFU_PCnew(ISU_IFU_PCnew),
    .MEM_ISU_valid(MEM_ISU_valid),
    .MEM_ISU_data(MEM_ISU_data),
    .MEM_ISU_rd(MEM_ISU_rd),
    .ISU_MEM_ready(ISU_MEM_ready),
    .EXU_ISU_valid(EXU_ISU_valid),
    .EXU_ISU_rd(EXU_ISU_rd),
    .EXU_ISU_res(EXU_ISU_res),
    .MEM_ld_en(MEM_ld_en),
    .ISU_wb_en(ISU_wb_en),
    .ISU_EXU_ready(ISU_EXU_ready)
);

// UART_window UART_window (
//     .clka (clk       ),
//     .wea  (ram_wen   ),
//     .addra(ram_addr  ),
//     .dina (ram_wdata ),
//     .douta(ram_rdata ) 
// );
`ifdef ENVIRONMENT_SIMULATE
assign o32_simulate = IFU_IDU_inst;
// assign o01_simulate = IFU_IDU_valid & IDU_IFU_ready;
assign o16_simulate = {2'b00,IFU_IDU_valid,IDU_IFU_ready,
2'b00,IDU_EXU_valid,IDU_IFU_ready,
2'b00,EXU_MEM_valid,MEM_EXU_ready,
2'b00,MEM_ISU_valid,ISU_MEM_ready
};

`endif

endmodule
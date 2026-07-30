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

    // EXT SRAM
    output [19:0] EXTRAM_a,
    inout  [31:0] EXTRAM_dq,
    output        EXTRAM_oe_n,
    output        EXTRAM_we_n,
    output        EXTRAM_ce_n,
    output [3:0]  EXTRAM_be_n

);
wire rst;
assign rstn = ~ rst;


wire IFU_IDU_valid;
wire IFU_IDU_PC;
wire IFU_IDU_inst;
wire IFU_IDU_id;
wire IDU_IFU_ready;
wire ISU_IFU_PCmis;
wire ISU_IFU_PCnew;
wire IFU_RAM_valid;
wire IFU_RAM_raddr;
wire RAM_IFU_ready;
wire RAM_IFU_valid;
wire RAM_IFU_rdata;
wire IFU_RAM_ready;

wire IDU_ISU_valid; //IDU ISU有效信号
wire IDU_GPR_addr1;
wire IDU_GPR_addr2;
wire IDU_ISU_PCnew;
wire IDU_ISU_PCmis;
wire IDU_EXU_valid;
wire IDU_EXU_rs1;
wire IDU_EXU_rs2;
wire IDU_EXU_ope;
wire IDU_EXU_rd;
wire IDU_EXU_func;//这里描述得到的结果是什么含义，0-0-0-0-0-0-0-0-st-ld-alu运算

wire IDU_GPR_data1;
wire IDU_GPR_data2;//IDU通过ISU访问GPR；GPR的读行为不需要经过一拍
wire ISU_IDU_ready;  //ISU IDU准备好信号
wire EXU_ISU_valid;
wire EXU_ISU_rd;
wire EXU_ISU_res;
wire MEM_st_en;
wire MEM_ld_en;
wire WBU_w_en;
wire ISU_EXU_ready;


wire EXU_IDU_ready;

module MEM#(
    parameter SRAM_WAIT_CYCLES = 2   // 根据时钟频率调整，至少 2
)(
    .clk(clk),
    .rst(rst),
    .EXU_MEM_valid(),
    .EXU_MEM_wen(),
    .EXU_MEM_ren(),
    .EXU_MEM_wdata(),
    .EXU_MEM_addr(),
    .EXU_MEM_rd(),
    .MEM_EXU_ready(),
    .MEM_WBU_valid(),
    .MEM_WBU_data(),
    .MEM_WBU_rd(),
    .WBU_MEM_ready(),
    .IFU_MEM_valid(),
    .IFU_MEM_en(),
    .IFU_MEM_PC(),
    .MEM_IFU_inst(),
    .MEM_IFU_ready(),
    .MEM_IFU_finish(),
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

    .IFU_IDU_valid(IFU_IDU_valid),
    .IFU_IDU_PC(IFU_IDU_PC),
    .IFU_IDU_inst(IFU_IDU_inst),
    .IFU_IDU_id(IFU_IDU_id),
    .IDU_IFU_ready(IDU_IFU_ready),
    .ISU_IFU_PCmis(ISU_IFU_PCmis),
    .ISU_IFU_PCnew(ISU_IFU_PCnew),
    .IFU_RAM_valid(IFU_RAM_valid),
    .IFU_RAM_raddr(IFU_RAM_raddr),
    .RAM_IFU_ready(RAM_IFU_ready),
    .RAM_IFU_valid(RAM_IFU_valid),
    .RAM_IFU_rdata(RAM_IFU_valid),
    .IFU_RAM_ready(IFU_RAM_ready)
);

IDU IDU(
    .clk(clk),
    .rst(rst),

    .IFU_IDU_valid(IFU_IDU_valid),
    .IFU_IDU_PC(IFU_IDU_PC),
    .IFU_IDU_inst(IFU_IDU_inst),
    .IFU_IDU_id(IFU_IDU_id),
    .IDU_IFU_ready(IDU_IFU_ready),
    .IDU_ISU_valid(IDU_ISU_valid),
    .IDU_GPR_addr1(IDU_GPR_addr1),
    .IDU_GPR_addr2(IDU_GPR_addr2),
    .IDU_GPR_data1(IDU_GPR_data1),
    .IDU_GPR_data2(IDU_GPR_data2),
    .IDU_ISU_PCnew(IDU_ISU_PCnew),
    .IDU_ISU_PCmis(IDU_ISU_PCmis),
    .ISU_IDU_ready(ISU_IDU_ready),
    .IDU_EXU_valid(IDU_EXU_valid),
    .IDU_EXU_rs1(IDU_EXU_rs1),
    .IDU_EXU_rs2(IDU_EXU_rs2),
    .IDU_EXU_ope(IDU_EXU_ope),
    .IDU_EXU_rd(IDU_EXU_rd),
    .IDU_EXU_func(IDU_EXU_func),
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
    .EXU_IDU_ready(EXU_IDU_ready),

    .EXU_ISU_valid(EXU_ISU_valid),
    .EXU_ISU_rd(EXU_ISU_rd),
    .EXU_ISU_res(EXU_ISU_res),
    .MEM_st_en(MEM_st_en),
    .MEM_ld_en(MEM_ld_en),
    .WBU_w_en(WBU_w_en),
    .ISU_EXU_ready(ISU_EXU_ready)

);

ISU ISU(
    .clk(clk),
    .rst(rst),

	.IDU_ISU_valid(IDU_ISU_valid), //IDU ISU有效信号
	.IDU_GPR_addr1(IDU_GPR_addr1),
	.IDU_GPR_addr2(IDU_GPR_addr2),
	.IDU_GPR_data1(IDU_GPR_data1),
	.IDU_GPR_data2(IDU_GPR_data2),//IDU通过ISU访问GPR；GPR的读行为不需要经过一拍
	.IDU_ISU_PCnew(IDU_ISU_PCnew),
	.IDU_ISU_PCmis(IDU_ISU_PCmis),
	.ISU_IDU_ready(ISU_IDU_ready),  //ISU IDU准备好信号
    .ISU_IFU_PCmis(ISU_IFU_PCmis),
    .ISU_IFU_PCnew(ISU_IFU_PCnew),
    .EXU_ISU_valid(EXU_ISU_valid),
    .EXU_ISU_rd(EXU_ISU_rd),
    .EXU_ISU_res(EXU_ISU_res),
    .MEM_st_en(MEM_st_en),
    .MEM_ld_en(MEM_ld_en),
    .WBU_w_en(WBU_w_en),
    .ISU_EXU_ready(ISU_EXU_ready)
);

// block_ram UART_window (
//     .clka (clk       ),
//     .wea  (ram_wen   ),
//     .addra(ram_addr  ),
//     .dina (ram_wdata ),
//     .douta(ram_rdata ) 
// );

endmodule
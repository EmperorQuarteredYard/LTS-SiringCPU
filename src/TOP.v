module TOP(
    input clk,
    input rstn,

	output        requ_valid,
    output [21:0] requ_addr,        //对于EXTRAM、BASERAM，其开头均为0b00011100 0，故仅需23位
    output        requ_type,        // 请求类别，0读1写
    output [31:0] requ_wdata,
    output [ 3:0] requ_wstrb,       // 写请求字节使能
    output        requ_exdat,       // 是否独占
    input         requ_ready,

    input         resp_valid,
    input  [31:0] resp_rdata,
    input         resp_exdat,
    output        resp_ready

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
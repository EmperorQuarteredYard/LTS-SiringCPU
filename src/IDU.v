module IDU
(
    input         clk,           //时钟输入
    input         rst,           //低电平复位信号

	input         IFU_IDU_valid, //IFU有效信号
	input  [31:0] IFU_IDU_PC,    //IFU PC输入
	input  [31:0] IFU_IDU_inst,  //IFU指令输入
	input  [ 1:0] IFU_IDU_id,    //IFU ID输入
	output        IDU_IFU_ready, //IDU IFU准备好信号

	output        IDU_ISU_valid, //IDU ISU有效信号
	output [ 4:0] IDU_GPR_addr1,
	output [ 4:0] IDU_GPR_addr2,
	input  [31:0] IDU_GPR_data1,
	input  [31:0] IDU_GPR_data2,//IDU通过ISU访问GPR；GPR的读行为不需要经过一拍

	output [31:0] IDU_ISU_PCnew,
	output        IDU_ISU_PCmis,
	input         ISU_IDU_ready,  //ISU IDU准备好信号

	output        IDU_EXU_valid,
	output [31:0] IDU_EXU_rs1,
	output [31:0] IDU_EXU_rs2,
	output [ 3:0] IDU_EXU_ope,
	output [ 4:0] IDU_EXU_rd,
	output [10:0] IDU_EXU_func,//这里描述得到的结果是什么含义，0-0-0-0-0-0-0-0-st-ld-alu运算
	input  [31:0] EXU_IDU_ready
);
reg [31:0] reg_PC;
reg [1:0]  reg_PCid;
reg        reg_valid;
reg  [31:0] reg_inst;
wire [31:0] wire_PC;
wire [31:0] wire_inst;

`define HANDSHAKE_ANALYSE
`ifdef HANDSHAKE_ANALYSE
wire IFU_IDU_handshake;
wire ISU_IDU_handshake;
wire IDU_EXU_handshake;

assign IDU_IFU_ready = (IDU_EXU_handshake & ISU_IDU_handshake) | reg_valid;
assign IDU_EXU_valid = reg_valid & ISU_IDU_handshake;//由于GPR的读取是异步的，故本周期内能完成操作，必定取决于能否与ISU握手
assign ISU_IDU_ready = 1'b1;

assign IFU_IDU_handshake = IFU_IDU_valid & IDU_IFU_ready;
assign ISU_IDU_handshake = IDU_ISU_valid & ISU_IDU_ready;//其实这里并没有用到握手信号，因为我没有考虑到一些情况，比如数据前递，等用到的时候再加吧
assign IDU_EXU_handshake = IDU_EXU_valid & EXU_IDU_ready;
`endif

`define OP_ANALYSE//指令解析
`ifdef OP_ANALYSE

assign wire_PC = reg_PC;
assign wire_inst = reg_inst;

wire [ 5:0] op_31_26;
wire [ 3:0] op_25_22;
wire [ 1:0] op_21_20;
wire [ 4:0] op_19_15;
wire [ 4:0] rd;
wire [ 4:0] rj;
wire [ 4:0] rk;
wire [11:0] i12;
wire [19:0] i20;
wire [15:0] i16;
wire [25:0] i26;

wire [63:0] op_31_26_d;
wire [15:0] op_25_22_d;
wire [ 3:0] op_21_20_d;
wire [31:0] op_19_15_d;

assign {op_31_26,op_25_22,op_21_20,op_19_15,rk,rj,rd} = wire_inst;

decoder_6_64 u_dec0(.in(op_31_26 ), .out(op_31_26_d ));
decoder_4_16 u_dec1(.in(op_25_22 ), .out(op_25_22_d ));
decoder_2_4  u_dec2(.in(op_21_20 ), .out(op_21_20_d ));
decoder_5_32 u_dec3(.in(op_19_15 ), .out(op_19_15_d ));
wire        inst_ld_o_st;
wire        inst_ld_x;
wire        inst_st_x;

wire        inst_lu12i_w;
wire        inst_pcaddu12i;
wire        inst_addi_w;
wire        inst_add_w;
wire        inst_sub_w;
wire        inst_slt;
wire        inst_and;
wire        inst_andi;
wire        inst_or;
wire        inst_ori;
wire        inst_xor;
wire        inst_sll_w;
wire        inst_slli_w;
wire        inst_srli_w;
wire        inst_ld_b;
wire        inst_ld_w;
wire        inst_st_b;
wire        inst_st_w;
wire        inst_b;
wire        inst_bl;
wire        inst_beq;
wire        inst_bne;
wire        inst_jirl;
wire        inst_mul_w;
wire        inst_cpucfg;
wire        inst_csrwr;
wire        inst_csrxchg;
wire        inst_cacop;

assign inst_ld_o_st      = op_31_26_d[6'h0a] & ~op_25_22[3];
assign inst_ld_x         = inst_ld_o_st & ~op_25_22[2];
assign inst_st_x         = inst_ld_o_st &  op_25_22[2];

assign inst_lu12i_w   = op_31_26_d[6'h05] & ~op_25_22[3];
assign inst_pcaddu12i = op_31_26_d[6'h07] & ~op_25_22[3];
assign inst_addi_w    = op_31_26_d[6'h00] & op_25_22_d[4'ha];
assign inst_add_w     = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1];
assign inst_sub_w     = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h02];
assign inst_slt       = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h04];
assign inst_and       = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h09];
assign inst_andi      = op_31_26_d[6'h00] & op_25_22_d[4'hd];
assign inst_or        = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0a];
assign inst_ori       = op_31_26_d[6'h00] & op_25_22_d[4'he];
assign inst_xor       = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0b];
assign inst_sll_w     = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h0e];
assign inst_slli_w    = op_31_26_d[6'h00] & op_25_22_d[4'h1] & op_21_20_d[2'h0] & op_19_15_d[5'h01];
assign inst_srli_w    = op_31_26_d[6'h00] & op_25_22_d[4'h1] & op_21_20_d[2'h0] & op_19_15_d[5'h09];
assign inst_ld_b      = op_31_26_d[6'h0a] & op_25_22_d[4'h0];
assign inst_ld_w      = op_31_26_d[6'h0a] & op_25_22_d[4'h2];
assign inst_st_b      = op_31_26_d[6'h0a] & op_25_22_d[4'h4];
assign inst_st_w      = op_31_26_d[6'h0a] & op_25_22_d[4'h6];
assign inst_b         = op_31_26_d[6'h14];
assign inst_bl        = op_31_26_d[6'h15];
assign inst_beq       = op_31_26_d[6'h16];
assign inst_bne       = op_31_26_d[6'h17];
assign inst_jirl      = op_31_26_d[6'h13];
assign inst_mul_w     = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h1] & op_19_15_d[5'h18];
assign inst_cpucfg    = op_31_26_d[6'h00] & op_25_22_d[4'h0] & op_21_20_d[2'h0] & op_19_15_d[5'h00] & (rk == 5'b11011);
assign inst_csrwr     = op_31_26_d[6'h01] & ~op_25_22[3]     & ~op_25_22[2] & (rj == 5'b00011);
assign inst_csrxchg   = op_31_26_d[6'h01] & ~op_25_22[3]     & ~op_25_22[2] & (rj != 5'b00001) & (rj != 5'b0);
assign inst_cacop     = op_31_26_d[6'h01] & op_25_22_d[4'h8];
`endif

`define IMM_ANALYSE//立即数分析
`ifdef IMM_ANALYSE
//立即数处理
wire [31:0] imm;
wire [31:0] offs;
wire [19:0] si20;
wire [11:0] si12;
wire [11:0] ui12;
// wire [ 4:0] ui5;
wire [15:0] offs16;
wire [15:0] offs26;
wire [13:0] csr14;
wire imm_si20_12;
wire imm_si12;
wire imm_ui12;
wire imm_offs16;
wire imm_offs26;
wire imm_csr14;
wire imm_ui5;
wire imm_4;
wire imm_en;
wire offs_en;

assign si20 = reg_inst[24:5];
assign si12 = reg_inst[21:10];
assign ui12 = reg_inst[21:10];
assign offs16 = reg_inst[25:10];
assign offs26 = {reg_inst[9:0],reg_inst[25:0]};

assign imm_si20_12 = inst_lu12i_w | inst_pcaddu12i;
assign imm_si12 = inst_addi_w | inst_ld_b | inst_ld_w | inst_st_b | inst_st_w | inst_cacop;//这里b,bl等等实际上应当触发流水线冲刷，并且将PC更新
assign imm_ui12 = inst_andi | inst_ori;
assign offs16   = inst_beq | inst_bne | inst_jirl;
assign offs26   = inst_b | inst_bl;
assign imm_ui5  = inst_slli_w|inst_srli_w;
assign imm_4 = inst_bl;
assign imm = {si20,12'b0}                    & {32{imm_si20_12}}|
			 {{20{si12[11]}},si12}           & {32{imm_si12}}|
			 {20'b0,ui12}                    & {32{imm_ui12}}|
			 {27'b0,rk}                      & {32{imm_ui5}}|
			 {32'h4}                         & {32{imm_4}};
assign offs = {{ 4{offs16[25]}},offs26,2'b00} & {32{offs26}}|
			  {{14{offs16[15]}},offs16,2'b00} & {32{offs16}};
assign imm_en = imm_csr14|imm_si12|imm_ui12|imm_4;
assign offs_en = offs16|offs26;


`endif

`define VAL_ANALYSE//向下一阶段的传值解析
`ifdef VAL_ANALYSE
wire rk_en,rj_en,pc_en,rd_en_forcmp;
assign rk_en = inst_add_w|inst_and|inst_mul_w|inst_or|inst_sub_w|inst_slt|inst_xor|inst_sll_w|inst_beq|inst_bne;
assign rj_en = rk_en|inst_addi_w|inst_andi|inst_ori|inst_slli_w|inst_srli_w|inst_ld_b|inst_ld_w|inst_st_b|inst_st_w|inst_jirl;//beq，bne，bl等跳转指令需要额外考虑
assign rd_en_forcmp = inst_beq|inst_bne;//这两者需要立即读取ed并进行比较，且取代的是rk(src1)的位置
assign rd_addr_set_1=inst_bl;
assign pc_en = inst_pcaddu12i;

assign IDU_GPR_addr1 = rj & {5{rj_en}}| rd & {5{rd_en_forcmp}};
assign IDU_GPR_addr2 = rk & {5{rk_en}};//如果使能信号为0的话就扔到r0，反正r0是正宗的垃圾桶，永远置零
assign IDU_EXU_rs1 = IDU_GPR_data1&{32{rj_en}}|wire_PC&{32{pc_en}};
assign IDU_EXU_rs2 = IDU_GPR_data2&{32{rk_en}}|imm&{32{imm_en}};
`endif

`define OPE_ANALYSE//对下一阶段的操作的解析
`ifdef OPE_ANALYSE
wire alu_en;
wire rd_en;

assign alu_en = inst_lu12i_w|inst_pcaddu12i|inst_addi_w|inst_add_w|inst_sub_w|inst_slt|inst_and|inst_andi|inst_or|inst_ori|inst_xor|inst_sll_w|inst_slli_w|inst_srli_w|inst_ld_o_st|inst_mul_w|inst_jirl;
assign rd_en = inst_lu12i_w|inst_pcaddu12i|inst_addi_w|inst_add_w|inst_sub_w|inst_slt|inst_and|inst_andi|inst_or|inst_ori|inst_xor|inst_sll_w|inst_slli_w|inst_srli_w|inst_mul_w|inst_jirl|inst_bl;
assign IDU_EXU_ope =alu_opadd & {4{inst_lu12i_w|inst_pcaddu12i|inst_addi_w|inst_add_w|inst_ld_o_st|inst_bl|inst_jirl}}|//其实这里不用写这么多的..毕竟alu_oppadd是0，但为了保留拓展性
                    alu_opmux  & {4{inst_mul_w}}|
                    alu_opsub  & {4{inst_sub_w}}|
                    // alu_opequ  & {4{0}}|
                    alu_opslt  & {4{inst_slt}}|
                    // alu_opsltu & {4{0}}|
                    // alu_opneg  & {4{0}}|
                    alu_opand  & {4{inst_and|inst_andi}}|
                    alu_opor   & {4{inst_or|inst_ori}}|
                    alu_opxor  & {4{inst_xor}}|
                    // alu_opnot  & {4{0}}|
                    alu_opsll  & {4{inst_sll_w|inst_slli_w}}|
                    alu_opslr  & {4{inst_srli_w}};
                    // alu_opasr  & {4{0}}|
                    // alu_oprcl  & {4{0}}|
                    // alu_oprc   & {4{0}};
assign IDU_EXU_func = {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,inst_st_x,inst_ld_x,alu_en};
assign IDU_EXU_rd   = rd & {5{rd_en}} | {4'b0,inst_bl};
`endif
//记录我这里已经堆了200行的代码了，奈何这里的东西不好模块化

`define JUM_ANALYSE//跳转指令处理
`ifdef JUM_ANALYSE
wire beq_jump;
assign beq_jump = (IDU_GPR_data1 == IDU_GPR_data2);
assign IDU_ISU_PCnew = (inst_jirl?IDU_GPR_data1:wire_PC) + (offs &{32{offs_en}});
assign IDU_ISU_PCmis = inst_jirl|inst_b|inst_bl|(inst_beq&beq_jump)|(inst_bne&~beq_jump);
`endif

always @(posedge clk) begin
    if (rst) begin
        reg_PC    <= 32'b0;
        reg_PCid    <= 2'b0;
        reg_inst  <= 32'b0;
		reg_valid <= 1'b0;
    end 
	else begin
        // 如果当前可以接收新指令（空闲）且 IFU 提供有效数据，则锁存
        if (IFU_IDU_handshake) begin
            reg_PC    <= IFU_IDU_PC;
            reg_PCid    <= IFU_IDU_id;
            reg_inst  <= IFU_IDU_inst;
        end
		reg_valid <= IFU_IDU_handshake;
    end
end
endmodule
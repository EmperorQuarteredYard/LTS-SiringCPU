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
    output [31:0] o32_simulate0,
    output [31:0] o32_simulate1,
    output [31:0] o32_simulate2,
    output [31:0] o32_simulate3,
    output [31:0] o32_simulate4,
    output [31:0] o32_simulate5,
    output [31:0] o32_simulate6,
    output [31:0] o32_simulate7,
    output [31:0] o32_simulate8,
    output [31:0] o32_simulate9,
    output [31:0] o01_simulate ,
    `endif

    // EXT SRAM
    output [19:0] EXTRAM_a,
    inout  [31:0] EXTRAM_dq,
    output        EXTRAM_oe_n,
    output        EXTRAM_we_n,
    output        EXTRAM_ce_n,
    output [3:0]  EXTRAM_be_n


);

wire [31:0] w_nxt_inst;
wire [31:0] w_nxt_PC;

reg [31:0] r_PC;
reg [31:0] r_inst;
reg [31:0] GPR [31:0];

wire [31:0] w_rk;
wire [31:0] w_rj;
wire [31:0] w_rd;
wire [31:0] w_inst;
wire [31:0] w_PC;

assign w_inst = r_inst;
assign w_PC = r_PC;

//I/O通道
`define IO_PIPE
`ifdef IO_PIPE
reg [19:0] r_t_EXTRAM_addr;
reg [31:0] r_t_EXTRAM_data;
reg        r_t_EXTRAM_oe_n;
reg        r_t_EXTRAM_we_n;
reg [ 3:0] r_t_EXTRAM_be_n;
reg        r_t_EXTRAM_ce_n;
reg [ 4:0] r_t_GPR_rd;

wire [31:0] w_t_EXTRAM_faddr;
wire [19:0] w_t_EXTRAM_addr;
wire [31:0] w_t_EXTRAM_data;
wire        w_t_EXTRAM_oe_n;
wire        w_t_EXTRAM_we_n;
wire        w_t_EXTRAM_ce_n;
wire [ 3:0] w_t_EXTRAM_be_n;

assign BASERAM_be_n = 4'b0;
assign BASERAM_oe_n = 1'b0;
assign BASERAM_we_n = 1'b1;
assign BASERAM_ce_n = 1'b0;
assign BASERAM_a    = w_nxt_PC[21:2];
assign w_nxt_inst   = BASERAM_dq;

assign EXTRAM_a    = r_t_EXTRAM_addr;
assign EXTRAM_dq   = r_t_EXTRAM_we_n?32'bz:r_t_EXTRAM_data;
assign EXTRAM_oe_n = r_t_EXTRAM_oe_n;
assign EXTRAM_we_n = r_t_EXTRAM_we_n;
assign EXTRAM_ce_n = r_t_EXTRAM_ce_n;
assign EXTRAM_be_n = r_t_EXTRAM_be_n;
// assign GPR[r_t_GPR_rd] = (r_t_EXTRAM_ce_n|r_t_EXTRAM_oe_n)?GPR[r_t_GPR_rd]:((r_t_GPR_rd == 5'b0)?32'b0:EXTRAM_dq);//这里应当放到时序块中，并且加上数据前递
`endif

`define INST_DECODE
`ifdef INST_DECODE
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

assign {op_31_26,op_25_22,op_21_20,op_19_15,rk,rj,rd} = w_inst;
//指令定义
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
//指令类定义
wire        inst_ld_o_st;
wire        inst_ld_x;
wire        inst_st_x;
//指令类解析
assign inst_ld_o_st      = (op_31_26 == 6'h0a) & ~op_25_22[3];
assign inst_ld_x         = inst_ld_o_st & ~op_25_22[2];
assign inst_st_x         = inst_ld_o_st &  op_25_22[2];
//指令解析
assign inst_lu12i_w   = (op_31_26 == 6'h05) & ~op_25_22[3];
assign inst_pcaddu12i = (op_31_26 == 6'h07) & ~op_25_22[3];
assign inst_addi_w    = (op_31_26 == 6'h00) & (op_25_22 == 4'ha);
assign inst_add_w     = (op_31_26 == 6'h00) & (op_25_22 == 4'h0) & (op_21_20 == 2'h1);
assign inst_sub_w     = (op_31_26 == 6'h00) & (op_25_22 == 4'h0) & (op_21_20 == 2'h1) & (op_19_15 == 5'h02);
assign inst_slt       = (op_31_26 == 6'h00) & (op_25_22 == 4'h0) & (op_21_20 == 2'h1) & (op_19_15 == 5'h04);
assign inst_and       = (op_31_26 == 6'h00) & (op_25_22 == 4'h0) & (op_21_20 == 2'h1) & (op_19_15 == 5'h09);
assign inst_andi      = (op_31_26 == 6'h00) & (op_25_22 == 4'hd);
assign inst_or        = (op_31_26 == 6'h00) & (op_25_22 == 4'h0) & (op_21_20 == 2'h1) & (op_19_15 == 5'h0a);
assign inst_ori       = (op_31_26 == 6'h00) & (op_25_22 == 4'he);
assign inst_xor       = (op_31_26 == 6'h00) & (op_25_22 == 4'h0) & (op_21_20 == 2'h1) & (op_19_15 == 5'h0b);
assign inst_sll_w     = (op_31_26 == 6'h00) & (op_25_22 == 4'h0) & (op_21_20 == 2'h1) & (op_19_15 == 5'h0e);
assign inst_slli_w    = (op_31_26 == 6'h00) & (op_25_22 == 4'h1) & (op_21_20 == 2'h0) & (op_19_15 == 5'h01);
assign inst_srli_w    = (op_31_26 == 6'h00) & (op_25_22 == 4'h1) & (op_21_20 == 2'h0) & (op_19_15 == 5'h09);
assign inst_ld_b      = (op_31_26 == 6'h0a) & (op_25_22 == 4'h0);
assign inst_ld_w      = (op_31_26 == 6'h0a) & (op_25_22 == 4'h2);
assign inst_st_b      = (op_31_26 == 6'h0a) & (op_25_22 == 4'h4);
assign inst_st_w      = (op_31_26 == 6'h0a) & (op_25_22 == 4'h6);
assign inst_b         = (op_31_26 == 6'h14);
assign inst_bl        = (op_31_26 == 6'h15);
assign inst_beq       = (op_31_26 == 6'h16);
assign inst_bne       = (op_31_26 == 6'h17);
assign inst_jirl      = (op_31_26 == 6'h13);
assign inst_mul_w     = (op_31_26 == 6'h00) & (op_25_22 == 4'h0) & (op_21_20 == 2'h1) & (op_19_15 == 5'h18);
assign inst_cpucfg    = (op_31_26 == 6'h00) & (op_25_22 == 4'h0) & (op_21_20 == 2'h0) & (op_19_15 == 5'h00) & (rk ==  5'b11011);
assign inst_csrwr     = (op_31_26 == 6'h01) & ~op_25_22[3]     & ~op_25_22[2] & (rj ==  5'b00011);
assign inst_csrxchg   = (op_31_26 == 6'h01) & ~op_25_22[3]     & ~op_25_22[2] & (rj != 5'b00001) & (rj != 5'b0);
assign inst_cacop     = (op_31_26 == 6'h01) & (op_25_22 == 4'h8); 

//立即数定义
wire [31:0] imm;
wire [31:0] offs;
wire [19:0] si20;
wire [11:0] si12;
wire [11:0] ui12;
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
//立即数提取
assign si20 = w_inst[24:5];
assign si12 = w_inst[21:10];
assign ui12 = w_inst[21:10];
assign offs16 = w_inst[25:10];
assign offs26 = {w_inst[9:0],w_inst[25:0]};
//立即数拼合
assign imm_si20_12 = inst_lu12i_w | inst_pcaddu12i;
assign imm_si12 = inst_addi_w | inst_ld_b | inst_ld_w | inst_st_b | inst_st_w | inst_cacop;
assign imm_ui12 = inst_andi | inst_ori;
assign imm_offs16   = inst_beq | inst_bne | inst_jirl;
assign imm_offs26   = inst_b | inst_bl;
assign imm_ui5  = inst_slli_w|inst_srli_w;
assign imm_4 = inst_bl;
assign imm = {si20,12'b0}                    & {32{imm_si20_12}}|
			 {{20{si12[11]}},si12}           & {32{imm_si12}}|
			 {20'b0,ui12}                    & {32{imm_ui12}}|
			 {27'b0,rk}                      & {32{imm_ui5}}|
			 {32'h4}                         & {32{imm_4}};
assign offs = {{ 4{offs26[25]}},offs26,2'b00} & {32{imm_offs26}}|
			  {{14{offs16[15]}},offs16,2'b00} & {32{imm_offs16}};
assign imm_en = imm_csr14|imm_si12|imm_ui12|imm_4;
assign offs_en = offs16|offs26;
//读取被操作数
assign w_rd = (rd==5'b0)?32'b0:(rd==r_t_GPR_rd&(~r_t_EXTRAM_ce_n)&(~r_t_EXTRAM_oe_n))?EXTRAM_dq:GPR[rd];
assign w_rk = (rk==5'b0)?32'b0:(rk==r_t_GPR_rd&(~r_t_EXTRAM_ce_n)&(~r_t_EXTRAM_oe_n))?EXTRAM_dq:GPR[rk];
assign w_rj = (rj==5'b0)?32'b0:(rj==r_t_GPR_rd&(~r_t_EXTRAM_ce_n)&(~r_t_EXTRAM_oe_n))?EXTRAM_dq:GPR[rj];//运用了一点流水线CPU的数据前递的思想
`endif

`define INST_EXECUTE
`ifdef INST_EXECUTE
//GPR
wire [31:0] w_res_addr;
wire        w_rd_wen;
wire [ 4:0] w_rd_addr;
wire [31:0] w_rd_wdata;
assign w_rd_wdata = inst_lu12i_w   ? imm        :
                    inst_pcaddu12i ? (w_PC + imm) :
                    inst_addi_w    ? (imm + w_rj) :
                    inst_add_w     ? (w_rk + w_rj) :
                    inst_sub_w     ? (w_rj - w_rk) :
                    inst_slt       ? {32{w_rj < w_rk}} :
                    inst_and       ? (w_rj & w_rk) :
                    inst_andi      ? (w_rj & imm) :
                    inst_or        ? (w_rj | w_rk) :
                    inst_ori       ? (w_rj | imm) :
                    inst_xor       ? (w_rj ^ w_rk) :
                    inst_sll_w     ? (w_rj << w_rk[4:0]) :
                    inst_slli_w    ? (w_rj << imm) :
                    inst_srli_w    ? (w_rj >> imm) :
                    inst_bl        ? (w_PC + 32'h4) :
                    inst_jirl      ? (w_PC + 32'h4) :
                    inst_mul_w     ? (w_rj + w_rk) :
                    32'b0;
assign     w_rd_wen        = inst_lu12i_w|inst_pcaddu12i|inst_addi_w|inst_add_w|inst_sub_w|inst_slt|inst_and|inst_andi|inst_or|inst_ori|inst_xor|inst_sll_w|inst_slli_w|inst_srli_w|inst_mul_w|inst_bl;
assign     w_rd_addr       = inst_bl?5'h01:rd;//注意！这里也包括ld写入的数据
//EXTRAM
assign     w_t_EXTRAM_ce_n  = ~(inst_ld_o_st);
assign     w_t_EXTRAM_be_n  = (inst_ld_b|inst_st_b)?4'b1100:4'b0000; 
assign     w_t_EXTRAM_data  = w_rd;
assign     w_t_EXTRAM_faddr = imm+w_rj;
assign     w_t_EXTRAM_addr  = w_t_EXTRAM_faddr[21:2];
assign     w_t_EXTRAM_oe_n  =~inst_ld_x;
assign     w_t_EXTRAM_we_n  =~inst_st_x;


//判断新PC
wire beq_jump;
assign beq_jump = (w_rj == w_rd);
assign w_nxt_PC = (inst_jirl?w_rj:w_PC) + ((inst_b|inst_bl|inst_jirl|(inst_beq&beq_jump)|(inst_bne&~beq_jump)) ?(offs & {32{offs_en}}) : 32'h4);
`endif

`ifdef ENVIRONMENT_SIMULATE
assign o32_simulate0 = {32{inst_ld_o_st}};
assign o32_simulate1 = {32{w_EXTRAM_wr_sel}};
assign o32_simulate2 = w_EXTRAM_wdata;
assign o32_simulate3 = {27'b0,w_rd_addr};
assign o32_simulate4 = w_rj;
assign o32_simulate5 = w_rk;
assign o32_simulate6 = w_rd;
assign o32_simulate7 = {32{(inst_b|inst_bl|inst_jirl|(inst_beq&beq_jump)|(inst_bne&~beq_jump))}};
assign o32_simulate8 = imm;
assign o32_simulate9 = offs;
assign o01_simulate  = {inst_lu12i_w,inst_pcaddu12i,inst_addi_w,inst_add_w,inst_sub_w,inst_slt,inst_and,inst_andi,inst_or,inst_ori,inst_xor,inst_sll_w,inst_slli_w,inst_srli_w,inst_ld_b,inst_ld_w,inst_st_b,inst_st_w,inst_b,inst_bl,inst_beq,inst_bne,inst_jirl,inst_mul_w,inst_cpucfg,inst_csrwr,inst_csrxchg,inst_cacop,inst_ld_o_st,inst_ld_x,inst_st_x,(inst_b|inst_bl|inst_jirl|(inst_beq&beq_jump)|(inst_bne&~beq_jump))};
`endif

`define SEQUENTIAL_LOGIC
`ifdef SEQUENTIAL_LOGIC
integer i;
// reg [19:0]test_temp_addr;
always @(posedge clk) begin
    if(~rstn)begin
        r_PC   <= `RST_PC;
        r_inst <= 32'b0;
        r_t_EXTRAM_addr <= 20'b0;
        r_t_EXTRAM_data <= 32'b0;
        r_t_EXTRAM_oe_n <= 1'b1;
        r_t_EXTRAM_be_n <= 4'hf;
        r_t_EXTRAM_ce_n <= 1'h1;
        r_t_EXTRAM_we_n <= 1'b1;
        for (i=0; i<31; i=i+1) begin : gen_rst_gpr
            GPR[i]<=32'b0;
        end
        // test_temp_addr <= 8'h10;
    end
    else begin
        r_PC   <= w_nxt_PC;
        r_inst <= w_nxt_inst;
        if(~(r_t_EXTRAM_ce_n|r_t_EXTRAM_oe_n))begin
            GPR[r_t_GPR_rd] <= EXTRAM_dq;
        end
        if(~w_t_EXTRAM_ce_n)begin
            // test_temp_addr <= test_temp_addr+1;
            // r_t_EXTRAM_addr <= test_temp_addr;
            // r_t_EXTRAM_data <= w_inst;
            // r_t_EXTRAM_oe_n <= 1'b1;
            // r_t_EXTRAM_we_n <= 1'b0;
            // r_t_EXTRAM_ce_n <= 1'b0;;
            // r_t_EXTRAM_be_n <= 4'b0;;
            
            r_t_EXTRAM_addr <= w_t_EXTRAM_addr;
            r_t_EXTRAM_data <= w_t_EXTRAM_data;
            r_t_EXTRAM_oe_n <= w_t_EXTRAM_oe_n;
            r_t_EXTRAM_we_n <= w_t_EXTRAM_we_n;
            r_t_EXTRAM_ce_n <= w_t_EXTRAM_ce_n;
            r_t_EXTRAM_be_n <= w_t_EXTRAM_be_n;
            r_t_GPR_rd      <= w_rd_addr;
            // r_t_GPR_rd      <= w_rd_addr;
        end
        if(w_rd_wen)begin
           GPR[w_rd_addr] <=w_rd_wdata;
        end
    end
end
`endif

endmodule
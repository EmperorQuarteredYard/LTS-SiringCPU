`define ENVIRONMENT_FPGA
//========================缺省值==============================
`define RST_PC          32'h1c000000//实际上应该是1c000000，这里省去了一拍的进位(应当需要根据实际情况判断)

//========================ALU调用掩码约定======================
`define alu_opadd  4'h0;
`define alu_opmux  4'h1;
`define alu_opsub  4'h2;
`define alu_opequ  4'h3;
`define alu_opslt  4'h4;
`define alu_opsltu 4'h5;
`define alu_opneg  4'h6;
`define alu_opand  4'h7;
`define alu_opor   4'h8;
`define alu_opxor  4'h9;
`define alu_opnot  4'ha;
`define alu_opsll  4'hb;
`define alu_opslr  4'hc;
`define alu_opasr  4'hd;
`define alu_oprcl  4'he;
`define alu_oprcr  4'hf;
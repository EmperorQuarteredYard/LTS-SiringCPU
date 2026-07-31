//========================全局设置============================
`define PC_LENGTH 32//在本项目中，如果区分ExtRAM和BaseRAM，那么可以将PC缩短到21位
`define INSTRUCTION_LENGTH 32
`define ENVIRONMENT_FPGA
`define BASE_RAM_PRE_ADDR    10'b0001110000
`define EXT_RAM_PRE_ADDR     10'b0001110001
`define UART_WINDOW_PRE_ADDR 12'b000111110000
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
//========================AXI状态约定=========================
`define AXI_IDLE       4'd0,
`define AXI_WR_ADDR    4'd1,
`define AXI_WR_START   4'd2,
`define AXI_WR_WAIT    4'd3,
`define AXI_WR_DONE    4'd4,
`define AXI_READ_START 4'd5,
`define AXI_READ_WAIT  4'd6,
`define AXI_READ_DONE  4'd7;
`include "define.vh"
module ALU(
    input wire [ 3:0]op, //0mov,1add,2sub,3cmp,4slt,5sltu,6neg,7and,8or,9xor,Anot,Bsll,Cslr,Dasr,Ercl,Frcr
    input wire [31:0]src1,
    input wire [31:0]src2,
    output wire [31:0]res
);
wire [31:0] innres[15:0];

wire [31:0]num_32_1 = 32'hffffffff;

assign innres[alu_opmux] = src1 *  src2;//这里应该做成多拍的乘法器
assign innres[alu_opadd] = src1 +  src2;
assign innres[alu_opsub] = src1 -  src2;
assign innres[alu_opequ] = {31'b0,src1 == src2};
assign innres[alu_opslt] = {31'b0, $signed(src1) < $signed(src2)};
assign innres[alu_opsltu] = {31'b0,src1 < src2};
assign innres[alu_opneg] = ~src1 + 1'b1;
assign innres[alu_opand] = src1 &  src2;
assign innres[alu_opor ] = src1 |  src2;
assign innres[alu_opxor] = src1 ^  src2;
assign innres[alu_opnot] = ~src1;
assign innres[alu_opsll] = src1 << src2[4:0];
assign innres[alu_opslr] = src1 >> src2[4:0];
assign innres[alu_opasr] = (src1 >> src2[4:0])|({32{src1[31]}}&~(num_32_1>>src2[4:0]));
assign innres[alu_oprcl] = src1 << src2[4:0] |src1 >> (32'd32 - src2[4:0] );
assign innres[alu_oprcr] = src1 >> src2[4:0] |src1 << (32'd32 - src2[4:0] );

assign res = innres[op];
endmodule
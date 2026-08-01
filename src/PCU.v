`include "define.vh"
module PCU(
    input clk,
    input rst,

    output [31:0] PC,
    input  [31:0] inst,
    input         IFU_IDU_handshake,
    output [ 1:0] PCid,

    input        PCmis,
    input [31:0] PCnew
);

reg [31:0] reg_PC;
reg [ 1:0] reg_id;
assign PC = reg_PC;
assign PCid=reg_id;

/*分支预测，主要是处理几条无条件跳转指令
| 0 1 0 1 0 0 offs[15:0] offs[25:16]                    | B         |
| 0 1 0 1 0 1 offs[15:0] offs[25:16]                    | BL        |
| 0 1 0 1 1 1 offs[15:0] rj rd                          | BNE       |
*/
wire [ 5:0] op_31_26;
wire [15:0] offs1;
wire [ 9:0] offs2;
assign {op_31_26,offs1,offs2} = inst;


wire [31:0]imm_lst [2:0];
wire offb16,offb26;
wire [31:0]prd_PC;

assign imm_lst[0] = 32'h4;
assign imm_lst[1] = {{ 4{offs2[ 9]}},offs2,offs1,2'b00};//B/BL
assign imm_lst[2] = {{14{offs1[15]}},offs1,2'b00};//BNE

assign offb26 = (op_31_26[5:1] ==5'b01010 );//B/BL
assign offb16 = (op_31_26[5:0] ==6'b010111);//BNE
assign prd_PC = reg_PC+imm_lst[{offb16,offb26}];


always @(posedge clk) begin
    if(rst)begin
		reg_PC <= `RST_PC;
		reg_id <= 2'b00;
    end
    else if(IFU_IDU_handshake)begin
        reg_id<=reg_id+1;
        if(PCmis)begin
            reg_PC<=PCnew;
            reg_id<=0;
        end
        else begin
            reg_PC<=prd_PC;
        end
    end
end


endmodule
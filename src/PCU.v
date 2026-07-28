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
JRIL由于需要读取寄存器，不处理
也可以处理有条件跳转指令，如bne，这里和JIRL合并处理
| 0 1 0 1 1 1 offs[15:0] rj rd                          | BNE       |
*/
/*
这几条指令的详细描述(来自官方文档)：
### B
```
B 无条件跳转到目标地址处。其跳转目标地址是将指令码中的 26 比特立即数 offs26 逻辑左移 2 位后再符号扩展，所得的偏移值加上该分支指令的 PC。
B:
PC = PC + SignExtend({offs26, 2'b0}, 32)
需要注意的是，该指令如果在写汇编时采用直接填入偏移值的方式，则汇编表示中的立即数应填入以字节为单位的偏移值，即指令码中 offs26<<2。
指令格式：
0 1 0 1 0 0 offs[15:0] offs[25:16]
```
### BL
```
BL 无条件跳转到目标地址处，同时将该指令的 PC 值加 4 的结果写入到 1 号通用寄存器 r1 中。该指令的跳转目标地址是将指令码中的 26 比特立即数 offs26 逻辑左移 2 位后再符号扩展，所得的偏移值加上该分支指令的 PC。

BL:
GR[1] = PC + 4
PC = PC + SignExtend({offs26, 2'b0}, 32)
在 LA ABI 中，1 号通用寄存器 r1 作为返回地址寄存器 ra。
需要注意的是，该指令如果在写汇编时采用直接填入偏移值的方式，则汇编表示中的立即数应填入以字节为单位的偏移值，即指令码中 offs26<<2。
指令格式：
0 1 0 1 0 1 offs[15:0] offs[25:16]
```
### BNE
```
BNE 将通用寄存器 rj 和通用寄存器 rd 的值进行比较，如果两者不等则跳转到目标地址，否则不跳转。
BNE:
if GR[rj]!=GR[rd] :
PC = PC + SignExtend({offs16, 2'b0}, 32)
指令格式：
0 1 0 1 1 1 offs[15:0] rj rd
```
### JIRL
```
JIRL 无条件跳转到目标地址处，同时将该指令的 PC 值加 4 的结果写入到通用寄存器 rd 中。该指令的跳转目标地址是将指令码中的 16 比特立即数 offs16 逻辑左移 2 位后再符号扩展，所得的偏移值加上通用寄存器 rj 中的值。
JIRL:
GR[rd] = PC + 4
PC = GR[rj] + SignExtend({offs16, 2'b0}, 32)
当 rd 等于 0 时，JIRL 的功能即是一条普通的非调用间接跳转指令。
rd 等于 0，rj 等于 1 且 offs16 等于 0 的 JIRL 常作为调用返回间接跳转使用
需要注意的是，该指令如果在写汇编时采用直接填入偏移值的方式，则汇编表示中的立即数应填入以字节为单位的偏移值，即指令码中 offs16<<2。
指令格式：
0 1 0 0 1 1 offs[15:0](16) rj(5) rd(5)
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
		reg_PC <= RST_PC;
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
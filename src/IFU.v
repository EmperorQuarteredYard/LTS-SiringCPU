`include "define.vh"
module IFU(
    input clk,
    input rst,

    // output [31:0] o32_simulate,
    // output        o01_simulate,

    output        IFU_IDU_valid,
    output [31:0] IFU_IDU_pc,
    output [31:0] IFU_IDU_inst,
    output [ 1:0] IFU_IDU_id,
    input         IDU_IFU_ready,

    input         ISU_IFU_PCmis,
    input  [31:0] ISU_IFU_PCnew,

    output        IFU_RAM_valid,
    output [31:0] IFU_RAM_raddr,
    input         RAM_IFU_ready,

    input         RAM_IFU_valid,
    input  [31:0] RAM_IFU_rdata,
    output        IFU_RAM_ready
);
reg [31:0] reg_pc;
reg [31:0] reg_inst;
reg [31:0] reg_nxt_inst;
// reg        reg_nxt_valid;
reg        reg_valid;

wire [31:0] wire_inst;
wire        wire_valid;
wire [31:0] wire_pc;
wire [31:0] wire_nxt_pc;
// wire        wire_nxt_valid;


assign wire_pc    = reg_pc;
assign wire_inst  = reg_inst;
assign wire_valid = reg_valid;
// assign wire_nxt_valid = reg_nxt_valid;

assign IFU_IDU_pc = wire_pc;
assign IFU_IDU_inst = wire_inst;
assign IFU_RAM_raddr = wire_nxt_pc;
assign IFU_RAM_valid = 1'b1;
assign IFU_RAM_ready = 1'b1;
assign IFU_IDU_id = wire_pc[6:5];

/*超级简单的分支预测，主要是处理几条无条件跳转指令
| 0 1 0 1 0 0 offs[15:0] offs[25:16]                    | B         |
| 0 1 0 1 0 1 offs[15:0] offs[25:16]                    | BL        |
| 0 1 0 1 1 1 offs[15:0] rj rd                          | BNE       |
*/
wire [ 5:0] op_31_26;
wire [15:0] offs1;
wire [ 9:0] offs2;
assign {op_31_26,offs1,offs2} = wire_inst;
assign wire_nxt_pc = wire_pc + (op_31_26[5:1] == 5'b01010  ? {{ 4{offs2[ 9]}},offs2,offs1,2'b00}:
                                op_31_26      == 6'b010111 ? {{14{offs1[15]}},offs1,2'b00}:
                                32'h4);


wire IFU_IDU_handshake;
wire RAM_res_handshake;
assign IFU_IDU_valid = wire_valid;
assign IFU_IDU_handshake = IFU_IDU_valid & IDU_IFU_ready;
assign RAM_res_handshake = RAM_IFU_valid & IFU_RAM_ready;
always @(posedge clk) begin
    reg_valid <= 1'b0;
    if(rst)begin
        reg_pc <= `RST_PC;
        reg_inst <= 32'b0;
        reg_valid <= 1'b0;//这边缘怎么还平行了
        // reg_nxt_valid <= 1'b0;
    end
    else if (ISU_IFU_PCmis) begin
        reg_pc <= ISU_IFU_PCnew - 32'h4;
        reg_valid <= 1'b0;
        // reg_nxt_valid <= 1'b0;
    end 
    else begin
        if((IFU_IDU_handshake|~wire_valid)&RAM_res_handshake)begin
            reg_pc <= wire_nxt_pc;
            reg_inst <= RAM_IFU_rdata;
            reg_valid <= 1'b1;
            // reg_nxt_valid <= 1'b1;//这里是多此一举
        end
    end
end

endmodule
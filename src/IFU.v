`include "define.vh"
module IFU(
    input clk,
    input rst,

    // output [31:0] o32_simulate,
    // output        o01_simulate,

    output        o01_IFU_IDU_valid,
    output [31:0] o32_IFU_IDU_PC,
    output [31:0] o32_IFU_IDU_inst,
    output [ 1:0] o02_IFU_IDU_id,
    input         i01_IDU_IFU_ready,

    input         i01_ISU_IFU_PCmis,
    input  [31:0] i32_ISU_IFU_PCnew,

    output        o01_IFU_RAM_valid,
    output [31:0] o32_IFU_RAM_raddr,
    input         i01_RAM_IFU_ready,

    input         i01_RAM_IFU_valid,
    input  [31:0] i32_RAM_IFU_rdata,
    output        o01_IFU_RAM_ready
);

reg        r01_valid;
reg [31:0] r32_pc;
reg [31:0] r32_inst;

wire        w01_valid;
wire [31:0] w32_nxt_pc;
wire [31:0] w32_pc;
wire [31:0] w32_inst;
wire        w01_IFU_IDU_handshake;
wire        w01_RAM_req_handshake;
wire        w01_RAM_res_handshake;

assign w32_pc   = r32_pc;
assign w32_inst = r32_inst;
assign w01_valid = r01_valid;


/*超级简单的分支预测，主要是处理几条无条件跳转指令
| 0 1 0 1 0 0 offs[15:0] offs[25:16]                    | B         |
| 0 1 0 1 0 1 offs[15:0] offs[25:16]                    | BL        |
| 0 1 0 1 1 1 offs[15:0] rj rd                          | BNE       |
*/
wire [ 5:0] op_31_26;
wire [15:0] offs1;
wire [ 9:0] offs2;
assign {op_31_26,offs1,offs2} = w32_inst;
// assign w32_nxt_pc = w32_pc + (op_31_26[5:1] == 5'b01010  ? {{ 4{offs2[ 9]}},offs2,offs1,2'b00}:
//                                 op_31_26      == 6'b010111 ? {{14{offs1[15]}},offs1,2'b00}:
//                                 32'h4);
assign w32_nxt_pc = w32_pc+32'h4;
assign o32_IFU_IDU_inst  = w32_inst;
assign o32_IFU_IDU_PC    = w32_pc;
assign o02_IFU_IDU_id    = w32_pc[4:3];

assign o32_IFU_RAM_raddr = w32_nxt_pc;

assign o01_IFU_IDU_valid = w01_valid&~i01_ISU_IFU_PCmis;
assign w01_IFU_IDU_handshake = o01_IFU_IDU_valid & i01_IDU_IFU_ready;
assign o01_IFU_RAM_ready = 1'b1;
assign w01_RAM_res_handshake = o01_IFU_RAM_ready & i01_RAM_IFU_valid;
assign o01_IFU_RAM_valid = 1'b1;
assign w01_RAM_req_handshake = i01_RAM_IFU_ready & o01_IFU_RAM_valid;


always @(posedge clk) begin
    if(rst)begin
        r01_valid <= 1'b0;
        r32_inst <= 32'b0;
        r32_pc <= `RST_PC;
    end
    else begin
        if(w01_IFU_IDU_handshake|~w01_valid)begin
            r01_valid<=w01_RAM_res_handshake;
            if(w01_RAM_res_handshake)begin
                r32_inst <= i32_RAM_IFU_rdata;
                r32_pc   <= w32_nxt_pc;
            end
        end
        if(i01_ISU_IFU_PCmis)begin
            r01_valid <= 1'b0;
            r32_pc<=i32_ISU_IFU_PCnew-32'h4;
            r32_inst<=32'b0;
        end
    end
end

endmodule
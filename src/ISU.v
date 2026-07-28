module ISU
(
    input clk,
    input rst,

	input         IDU_ISU_valid, //IDU ISU有效信号
	input  [ 4:0] IDU_GPR_addr1,
	input  [ 4:0] IDU_GPR_addr2,
	output [31:0] IDU_GPR_data1,
	output [31:0] IDU_GPR_data2,//IDU通过ISU访问GPR；GPR的读行为不需要经过一拍

	input  [31:0] IDU_ISU_PCnew,
	input         IDU_ISU_PCmis,
	output        ISU_IDU_ready,  //ISU IDU准备好信号

    // input         RAM_IFU_valid,
    // input  [31:0] RAM_IFU_rdata,
    // output        IFU_RAM_ready,

    output        ISU_IFU_PCmis,
    output [31:0] ISU_IFU_PCnew,

    input         EXU_ISU_valid,
    input  [ 4:0] EXU_ISU_rd,
    input  [31:0] EXU_ISU_res,
    input         MEM_st_en,
    input         MEM_ld_en,
    input         WBU_w_en,
    output        ISU_EXU_ready
);
`define BASE_PART
`ifdef BASE_PART
// reg [31:0] reg_RAM_rdata;
reg [ 4:0] reg_EXU_rd;
reg [31:0] reg_EXU_res;
reg        reg_st_en;
reg        reg_ld_en;
reg        reg_wb_en;

// wire [31:0] wire_RAM_rdata;
wire [ 4:0] wire_EXU_rd;
wire [31:0] wire_EXU_res;
wire        wire_st_en;
wire        wire_ld_en;
wire        wire_wb_en;

assign wire_RAM_rdata = reg_RAM_rdata;
assign wire_EXU_rd    = reg_EXU_rd;
assign wire_EXU_res   = reg_EXU_res;
assign wire_st_en     = reg_st_en;
assign wire_ld_en     = reg_ld_en;
assign wire_wb_en     = reg_wb_en;
`endif
assign ISU_IFU_PCmis = IDU_ISU_PCmis;
assign ISU_IFU_PCnew = IDU_ISU_PCnew;
`define GPR_OPERATION
`ifdef GPR_OPERATION
reg [31:0] GPR [31:0];
reg [31:0] GPR_lock;
reg reg_lock_rd;
reg reg_unlock_rd;

// assign GPR[wire_EXU_rd[4:0]] = (wire_EXU_rd!= 5'b0 & wire_wb_en)?wire_EXU_res:32'b0;
assign IDU_GPR_data1 = GPR[IDU_GPR_addr1]&{32{IDU_ISU_valid}};
assign IDU_GPR_data2 = GPR[IDU_GPR_addr2]&{32{IDU_ISU_valid}};
wire wire_lock_rd;
wire wire_unlock_rd;
`endif

`define HANDSHAKE_ANALYSE
`ifdef HANDSHAKE_ANALYSE
wire IDU_ISU_handshake;
wire ISU_EXU_handshake;
assign IDU_ISU_handshake = IDU_ISU_valid & ISU_IDU_ready;
assign ISU_EXU_handshake = EXU_ISU_valid & ISU_EXU_ready;
assign ISU_EXU_ready = 1'b1;
assign ISU_IDU_ready = 1'b1;
`endif
always @(posedge clk) begin
    if (rst)begin
        // reg_RAM_rdata <= 32'b0;
        reg_EXU_rd <= 5'b0;
        reg_EXU_res <= 32'b0;
        reg_st_en <= 1'b0;
        reg_ld_en <= 1'b0;
        reg_wb_en <= 1'b0;
    end
    else if(IDU_ISU_handshake)begin
        // reg_RAM_rdata <= 
        GPR[reg_EXU_rd]<= reg_EXU_res;
        reg_st_en <= MEM_st_en;
        reg_ld_en <= MEM_ld_en;
        reg_wb_en <= WBU_w_en;
    end
    
end
endmodule




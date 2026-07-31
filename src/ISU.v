module ISU
(
    input clk,
    input rst,

	input         IDU_ISU_valid, //IDU ISU有效信号
	input  [ 4:0] IDU_GPR_rj,
	input  [ 4:0] IDU_GPR_rk,
	input  [ 4:0] IDU_GPR_rd,
	output [31:0] GPR_IDU_rj,
	output [31:0] GPR_IDU_rk,
	output [31:0] GPR_IDU_rd,//IDU通过ISU访问GPR；GPR的读行为不需要经过一拍

	input  [31:0] IDU_ISU_PCnew,
	input         IDU_ISU_PCmis,
	output        ISU_IDU_ready,  //ISU IDU准备好信号

    output        ISU_IFU_PCmis,
    output [31:0] ISU_IFU_PCnew,

    input         MEM_ISU_valid,
    input  [31:0] MEM_ISU_data,
    input  [ 4:0] MEM_ISU_rd,
    output        ISU_MEM_ready,

    input         EXU_ISU_valid,
    input  [ 4:0] EXU_ISU_rd,
    input  [31:0] EXU_ISU_res,
    input         MEM_ld_en,
    input         ISU_wb_en,
    output        ISU_EXU_ready
);
`define BASE_PART
`ifdef BASE_PART
// reg [31:0] reg_RAM_rdata;
// reg [ 4:0] reg_EXU_rd;
// reg [31:0] reg_EXU_res;
// reg        reg_ld_en;
// reg        reg_wb_en;
// reg [ 4:0] reg_MEM_rd;
// reg [31:0] reg_EXU_data;//根本不需要

// wire [31:0] wire_RAM_rdata;
wire [ 4:0] wire_EXU_rd;
wire [31:0] wire_EXU_res;
wire        wire_ld_en;
wire        wire_wb_en;

// assign wire_RAM_rdata = reg_RAM_rdata;
// assign wire_EXU_rd    = reg_EXU_rd;
// assign wire_EXU_res   = reg_EXU_res;
// assign wire_ld_en     = reg_ld_en;
// assign wire_wb_en     = reg_wb_en;
`endif
assign ISU_IFU_PCmis = IDU_ISU_PCmis;
assign ISU_IFU_PCnew = IDU_ISU_PCnew;
`define GPR_OPERATION
`ifdef GPR_OPERATION
reg [31:0] GPR [31:0];
reg [31:0] GPR_lock;

// assign GPR[wire_EXU_rd[4:0]] = (wire_EXU_rd!= 5'b0 & wire_wb_en)?wire_EXU_res:32'b0;
assign GPR_IDU_rj = (ISU_wb_en&(EXU_ISU_rd == IDU_GPR_rj))?EXU_ISU_res:GPR[IDU_GPR_rj]&{32{IDU_ISU_valid}};//如果EXU在当前周期中产生了IDU正在访问的结果，那么返回EXU的值 注意！这里是非常危险的！不要复用！
assign GPR_IDU_rk = (ISU_wb_en&(EXU_ISU_rd == IDU_GPR_rk))?EXU_ISU_res:GPR[IDU_GPR_rk]&{32{IDU_ISU_valid}};
assign GPR_IDU_rd = (ISU_wb_en&(EXU_ISU_rd == IDU_GPR_rd))?EXU_ISU_res:GPR[IDU_GPR_rd]&{32{IDU_ISU_valid}};
//这里简单做一个前推。ld产生的东西我就落锁了
`endif

`define HANDSHAKE_ANALYSE
`ifdef HANDSHAKE_ANALYSE
wire IDU_ISU_handshake;
wire ISU_EXU_handshake;
assign IDU_ISU_handshake = IDU_ISU_valid & ISU_IDU_ready;
assign ISU_EXU_handshake = EXU_ISU_valid & ISU_EXU_ready;
assign MEM_ISU_handshake = MEM_ISU_valid & ISU_EXU_ready;
assign ISU_EXU_ready = 1'b1;
assign ISU_EXU_ready = 1'b1;
assign ISU_IDU_ready = (GPR_lock[IDU_GPR_rj] & IDU_GPR_rj!=5'b0)|(GPR_lock[IDU_GPR_rk] & IDU_GPR_rk!=5'b0)|(GPR_lock[IDU_GPR_rd] & IDU_GPR_rd!=5'b0) ;//如果访问到被锁存的内容，则返回"没准备好"
`endif
always @(posedge clk) begin
    if (rst)begin
        // reg_RAM_rdata <= 32'b0;
        // reg_EXU_rd <= 5'b0;
        // reg_EXU_res <= 32'b0;
        // reg_ld_en <= 1'b0;
        // reg_wb_en <= 1'b0;
    end
    else begin
        
        if(MEM_ISU_handshake)begin
            GPR_lock[MEM_ISU_rd] <= 0;//这里必须把MEM的解除锁放前面！
        end
        if(IDU_ISU_handshake)begin
            // reg_RAM_rdata <= 
            // reg_ld_en <= MEM_ld_en;
            // reg_wb_en <= ISU_wb_en;
            if(ISU_wb_en)begin
                GPR[EXU_ISU_rd] <= EXU_ISU_res;
            end
            if(MEM_ld_en & MEM_ISU_rd != 5'b0 )begin
                GPR_lock[MEM_ISU_rd] <= 1;//这里实际上应当要防信号毛刺
            end
        end
    end 
    
end
endmodule
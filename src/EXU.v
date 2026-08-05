module EXU(
    input         clk,           //时钟输入
    input         rst,           //低电平复位信号
    
	input         IDU_EXU_valid,
	input  [31:0] IDU_EXU_rs1,
	input  [31:0] IDU_EXU_rs2,
	input  [ 3:0] IDU_EXU_ope,
	input  [ 4:0] IDU_EXU_rd,
	input  [10:0] IDU_EXU_func,//这里描述得到的结果是什么含义，0-0-0-0-0-0-0-0-st-ld-wb(就是是不是R型指令)
    input  [31:0] IDU_EXU_wdata,
    input  [ 3:0] IDU_EXU_wstrb,//高有效
	output        EXU_IDU_ready,

    output        EXU_MEM_valid,
    output [31:0] EXU_MEM_addr,
    output [31:0] EXU_MEM_wdata,
    output [ 3:0] EXU_MEM_wstrb,//高有效
    output [ 4:0] EXU_MEM_rd,
    output        MEM_ld_en,
    output        MEM_st_en,
    input         MEM_EXU_ready,

    output        EXU_ISU_valid,
    output [ 4:0] EXU_ISU_rd,
    output [31:0] EXU_ISU_res,
    output        ISU_wb_en,
    input         ISU_EXU_ready
);
reg [31:0] reg_rs1;
reg [31:0] reg_rs2;
reg [31:0] reg_wdata;
reg [ 3:0] reg_ope;
reg [ 4:0] reg_rd;
reg [10:0] reg_func;
reg        reg_valid;
reg [ 3:0] reg_wstrb;


wire [31:0] wire_rs1;
wire [31:0] wire_rs2;
wire [31:0] wire_wdata;
wire [ 3:0] wire_ope;
wire [ 4:0] wire_rd;
wire [10:0] wire_func;
wire [31:0] wire_res;
wire        wire_valid;
wire        wire_st_en;
wire        wire_ld_en;
wire        wire_wb_en;
wire        wire_wstrb;

assign wire_rs1   = reg_rs1;
assign wire_rs2   = reg_rs2;
assign wire_wdata = reg_wdata;
assign wire_ope   = reg_ope;
assign wire_rd    = reg_rd;
assign wire_func  = reg_func;
assign wire_wstrb = reg_wstrb;

assign wire_st_en  = wire_func[2];
assign wire_ld_en  = wire_func[1];
// assign wire_alu_en = wire_func[0];
ALU ALU(
    .op(wire_ope),
    .src1(wire_rs1),
    .src2(wire_rs2),
    .res(wire_res)
);

wire IDU_EXU_handshake;
wire EXU_ISU_handshake;
wire EXU_MEM_handshake;

assign IDU_EXU_handshake = IDU_EXU_valid & EXU_IDU_ready;
assign EXU_ISU_handshake = EXU_ISU_valid & ISU_EXU_ready;
assign EXU_MEM_valid = MEM_ld_en | MEM_st_en;
assign EXU_ISU_valid = wire_valid;
assign EXU_IDU_ready = (~wire_valid) | (EXU_ISU_handshake);

assign EXU_ISU_rd    = wire_rd;
assign EXU_ISU_res   = wire_res;
assign EXU_MEM_wdata = wire_wdata;
assign EXU_MEM_wstrb = wire_wstrb;
assign EXU_MEM_addr  = wire_res;
assign MEM_ld_en     = wire_ld_en;
assign MEM_st_en     = wire_st_en;
assign ISU_wb_en      = wire_rd != 5'b0 & wire_wb_en;//当不允许写入或写入的寄存器为0时，则向下传不写入

assign EXU_ISU_rd    = wire_rd;
assign EXU_ISU_res   = wire_res;
assign EXU_ISU_valid = wire_valid;
assign EXU_IDU_ready = (~wire_valid) | (EXU_ISU_handshake);
assign MEM_ld_en     = wire_ld_en;

always @(posedge clk) begin
    if(rst)begin
        reg_rs1   <= 32'b0;
        reg_rs2   <= 32'b0;
        reg_ope   <= 4'b0;
        reg_rd    <= 5'b0;
        reg_func  <= 11'b0;
        reg_valid <= 1'b0;
        reg_wstrb <= 4'hf;
    end
    else if(IDU_EXU_handshake)begin
        reg_rs1   <= IDU_EXU_rs1;
        reg_rs2   <= IDU_EXU_rs2;
        reg_ope   <= IDU_EXU_ope;
        reg_rd    <= IDU_EXU_rd;
        reg_func  <= IDU_EXU_func;
        reg_wstrb <= IDU_EXU_wstrb;
    end
    reg_valid <= IDU_EXU_handshake;
end

endmodule
module EXU(
    input         clk,           //时钟输入
    input         rst,           //低电平复位信号
    
	input         IDU_EXU_valid,
	input  [31:0] IDU_EXU_rs1,
	input  [31:0] IDU_EXU_rs2,
	input  [ 3:0] IDU_EXU_ope,
	input  [ 4:0] IDU_EXU_rd,
	input  [10:0] IDU_EXU_func,//这里描述得到的结果是什么含义，0-0-0-0-0-0-0-0-st-ld-alu运算
	output [31:0] EXU_IDU_ready,

    output        EXU_ISU_valid,
    output [ 4:0] EXU_ISU_rd,
    output [31:0] EXU_ISU_res,
    output        MEM_ld_en,
    output        WBU_w_en,
    input         ISU_EXU_ready
    // 待添加：
    
	// .data_requ_valid(data_requ_valid),
	// .data_requ_addr (data_requ_addr),
	// .data_requ_type (data_requ_type),
	// .data_requ_wdata(data_requ_wdata),
	// .data_requ_wstrb(data_requ_wstrb),
	// .data_requ_ready(data_requ_ready),

	// .data_resp_valid(data_resp_valid),
	// .data_resp_rdata(data_resp_rdata),
	// .data_resp_ready(data_resp_ready),

	// .WBU_ISU_wen  (WBU_ISU_wen),
	// .WBU_ISU_waddr(WBU_ISU_waddr),
	// .WBU_ISU_wdata(WBU_ISU_wdata)
);
reg [31:0] reg_rs1;
reg [31:0] reg_rs2;
reg [ 3:0] reg_ope;
reg [ 4:0] reg_rd;
reg [10:0] reg_func;
reg        reg_valid;


wire [31:0] wire_rs1;
wire [31:0] wire_rs2;
wire [ 3:0] wire_ope;
wire [ 4:0] wire_rd;
wire [10:0] wire_func;
wire [31:0] wire_res;
wire        wire_valid;
wire        wire_st_en;
wire        wire_ld_en;
wire        wire_alu_en;

assign wire_rs1  = reg_rs1;
assign wire_rs2  = reg_rs2;
assign wire_ope  = reg_ope;
assign wire_rd   = reg_rd;
assign wire_func = reg_func;

assign wire_st_en = wire_func[2];
assign wire_ld_en = wire_func[1];
assign wire_alu_en  = wire_func[0];
ALU ALU(
    .op(wire_ope),
    .src1(wire_rs1),
    .src2(wire_rs2),
    .res(wire_res)
);

wire IDU_EXU_handshake;
wire EXU_ISU_handshake;
wire EXU_MEMU_handshake;

assign IDU_EXU_handshake = IDU_EXU_valid & EXU_IDU_ready;
assign EXU_ISU_handshake = EXU_ISU_valid & ISU_EXU_ready;

assign EXU_ISU_rd    = wire_rd;
assign EXU_ISU_res   = wire_res;
assign EXU_ISU_valid = wire_valid;
assign EXU_IDU_ready = (~wire_valid) | (EXU_ISU_handshake);
assign MEM_ld_en     = wire_ld_en;
assign WBU_w_en     = wire_rd == 5'b0;//做双重保险

always @(posedge clk) begin
    if(rst)begin
        reg_rs1   <= 32'b0;
        reg_rs2   <= 32'b0;
        reg_ope   <= 4'b0;
        reg_rd    <= 5'b0;
        reg_func  <= 11'b0;
        reg_valid <= 1'b0;
    end
    else if(IDU_EXU_handshake)begin
        reg_rs1   <= IDU_EXU_rs1;
        reg_rs2   <= IDU_EXU_rs2;
        reg_ope   <= IDU_EXU_ope;
        reg_rd    <= IDU_EXU_rd;
        reg_func  <= IDU_EXU_func;
    end
        reg_valid <= IDU_EXU_handshake;
end

endmodule
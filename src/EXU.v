module EXU(
    input         clk,           //时钟输入
    input         rst,           //低电平复位信号
    
	input         i01_IDU_EXU_valid,
	input  [31:0] i32_IDU_EXU_rs1,
	input  [31:0] i32_IDU_EXU_rs2,
	input  [ 3:0] i04_IDU_EXU_ope,
	input  [ 4:0] i05_IDU_EXU_rd,
	input  [10:0] i11_IDU_EXU_func,//这里描述得到的结果是什么含义，0-0-0-0-0-0-0-0-st-ld-wb(就是是不是R型指令)
    input  [31:0] i32_IDU_EXU_wdata,
    input  [ 3:0] i04_IDU_EXU_wstrb,//高有效
	output        o01_EXU_IDU_ready,

    output        o01_EXU_MEM_valid,
    output [31:0] o32_EXU_MEM_addr,
    output [31:0] o32_EXU_MEM_wdata,
    output [ 3:0] o04_EXU_MEM_wstrb,//高有效
    output [ 4:0] o05_EXU_MEM_rd,
    output        o01_MEM_ld_en,
    output        o01_MEM_st_en,
    input         i01_MEM_EXU_ready,

    output        o01_EXU_ISU_valid,
    output [ 4:0] o05_EXU_ISU_rd,
    output [31:0] o32_EXU_ISU_res,
    output        o01_ISU_wb_en,
    input         i01_ISU_EXU_ready
);

reg        r01_reg_valid;
reg [31:0] r32_IDU_EXU_rs1;
reg [31:0] r32_IDU_EXU_rs2;
reg [ 3:0] r04_IDU_EXU_ope;
reg [ 4:0] r05_IDU_EXU_rd;
reg [10:0] r11_IDU_EXU_func;
reg [31:0] r32_IDU_EXU_wdata;
reg [ 3:0] r04_IDU_EXU_wstrb;

wire        w01_reg_valid;
wire [31:0] w32_IDU_EXU_rs1;
wire [31:0] w32_IDU_EXU_rs2;
wire [ 3:0] w04_IDU_EXU_ope;
wire [ 4:0] w05_IDU_EXU_rd;
wire [10:0] w11_IDU_EXU_func;
wire [31:0] w32_IDU_EXU_wdata;
wire [ 3:0] w04_IDU_EXU_wstrb;
wire [31:0] w32_ALU_res;
wire        w01_wb_en;
wire        w01_st_en;
wire        w01_ld_en;
wire        w01_valid;

assign w01_reg_valid     = r01_reg_valid;
assign w32_IDU_EXU_rs1   = r32_IDU_EXU_rs1;
assign w32_IDU_EXU_rs2   = r32_IDU_EXU_rs2;
assign w04_IDU_EXU_ope   = r04_IDU_EXU_ope;
assign w05_IDU_EXU_rd    = r05_IDU_EXU_rd;
assign w11_IDU_EXU_func  = r11_IDU_EXU_func;
assign w32_IDU_EXU_wdata = r32_IDU_EXU_wdata;
assign w04_IDU_EXU_wstrb = r04_IDU_EXU_wstrb;

assign w01_valid         = (w11_IDU_EXU_func == 11'b0 ? 1'b0 : 1'b1)&w01_reg_valid;

ALU u_ALU(
    .op(w04_IDU_EXU_ope),
    .src1(w32_IDU_EXU_rs1),
    .src2(w32_IDU_EXU_rs2),
    .res(w32_ALU_res)
);

wire w01_IDU_EXU_handshake;
wire w01_EXU_ISU_handshake;
wire w01_EXU_MEM_handshake;

assign w01_IDU_EXU_handshake = i01_IDU_EXU_valid & o01_EXU_IDU_ready;
assign w01_EXU_ISU_handshake = o01_EXU_ISU_valid & i01_ISU_EXU_ready;
assign w01_EXU_MEM_handshake = o01_EXU_MEM_valid & i01_MEM_EXU_ready;
assign o01_EXU_ISU_valid = w01_valid;//这里比较特殊，因为EXU需要将计算结果通过ISU前递给IDU
assign o01_EXU_IDU_ready = (~w01_valid|(w01_EXU_ISU_handshake&w01_wb_en)|(w01_EXU_MEM_handshake&(w01_ld_en|w01_st_en)));
assign o01_EXU_MEM_valid = w01_st_en|w01_ld_en;

assign w01_wb_en = w11_IDU_EXU_func[0];
assign w01_ld_en = w11_IDU_EXU_func[1];
assign w01_st_en = w11_IDU_EXU_func[2];

assign o32_EXU_MEM_addr = w32_ALU_res;
assign o32_EXU_MEM_wdata = w32_IDU_EXU_wdata;
assign o04_EXU_MEM_wstrb = w04_IDU_EXU_wstrb;
assign o05_EXU_MEM_rd    = w05_IDU_EXU_rd;
assign o01_MEM_ld_en     = w01_ld_en;
assign o01_MEM_st_en     = w01_st_en;

assign o01_ISU_wb_en     = w01_wb_en;
assign o05_EXU_ISU_rd    = w05_IDU_EXU_rd;
assign o32_EXU_ISU_res   = w32_ALU_res;
always @(posedge clk) begin
    if(rst)begin
        r01_reg_valid     <=  1'b0;
        r32_IDU_EXU_rs1   <= 32'b0;
        r32_IDU_EXU_rs2   <= 32'b0;
        r04_IDU_EXU_ope   <=  4'b0;
        r05_IDU_EXU_rd    <=  5'b0;
        r11_IDU_EXU_func  <= 11'b0;
        r32_IDU_EXU_wdata <= 32'b0;
        r04_IDU_EXU_wstrb <=  4'hf;
    end
    if(w01_IDU_EXU_handshake)begin
        r01_reg_valid     <=  1'b1;
        r32_IDU_EXU_rs1   <= i32_IDU_EXU_rs1;
        r32_IDU_EXU_rs2   <= i32_IDU_EXU_rs2;
        r04_IDU_EXU_ope   <= i04_IDU_EXU_ope;
        r05_IDU_EXU_rd    <= i05_IDU_EXU_rd;
        r11_IDU_EXU_func  <= i11_IDU_EXU_func;
        r32_IDU_EXU_wdata <= i32_IDU_EXU_wdata;
        r04_IDU_EXU_wstrb <= i04_IDU_EXU_wstrb;
    end
end
endmodule
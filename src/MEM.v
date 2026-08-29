module MEM(
    input clk,
    input rst,

    input         i01_EXU_MEM_valid,
    input         i01_EXU_MEM_ld_en,
    input         i01_EXU_MEM_st_en,
    input  [31:0] i32_EXU_MEM_wdata,
    input  [31:0] i32_EXU_MEM_addr,
    input  [ 4:0] i05_EXU_MEM_rd,
    input  [ 3:0] i04_EXU_MEM_wstrb,//高有效
    output        o01_MEM_EXU_ready,
    
    output        o01_MEM_ISU_valid,
    output [31:0] o32_MEM_ISU_data,
    output [ 4:0] o05_MEM_ISU_rd,
    input         i01_ISU_MEM_ready,

    output        o01_MEM_RAM_valid,
    output [31:0] o32_MEM_RAM_addr,
    output [31:0] o32_MEM_RAM_data,
    output        o01_MEM_RAM_type,
    output        o04_MEM_RAM_wstrb,
    input         i01_RAM_MEM_ready,

    input         i01_RAM_MEM_valid,
    input  [31:0] i32_RAM_MEM_rdata,
    output        o01_MEM_RAM_ready
);

reg         r01_reg_valid;
reg         r01_EXU_MEM_ld_en;
reg         r01_EXU_MEM_st_en;
reg  [31:0] r32_EXU_MEM_wdata;
reg  [31:0] r32_EXU_MEM_addr;
reg  [ 4:0] r05_EXU_MEM_rd;
reg  [ 3:0] r04_EXU_MEM_wstrb;

wire         w01_valid;
wire         w01_reg_valid;
wire         w01_EXU_MEM_valid;
wire         w01_EXU_MEM_ld_en;
wire         w01_EXU_MEM_st_en;
wire  [31:0] w32_EXU_MEM_wdata;
wire  [31:0] w32_EXU_MEM_addr;
wire  [ 4:0] w05_EXU_MEM_rd;
wire  [ 3:0] w04_EXU_MEM_wstrb;

assign w01_reg_valid     = r01_reg_valid;
assign w01_EXU_MEM_ld_en = r01_EXU_MEM_ld_en;
assign w01_EXU_MEM_st_en = r01_EXU_MEM_st_en;
assign w32_EXU_MEM_wdata = r32_EXU_MEM_wdata;
assign w32_EXU_MEM_addr  = r32_EXU_MEM_addr;
assign w05_EXU_MEM_rd    = r05_EXU_MEM_rd;
assign w04_EXU_MEM_wstrb = r04_EXU_MEM_wstrb;

wire         w01_EXU_MEM_handshake;
wire         w01_MEM_ISU_handshake;
wire         w01_RAM_req_handshake;
wire         w01_RAM_res_handshake;

assign w01_EXU_MEM_handshake = i01_EXU_MEM_valid & o01_MEM_EXU_ready;
assign w01_MEM_ISU_handshake = o01_MEM_ISU_valid & i01_ISU_MEM_ready;
assign w01_RAM_req_handshake = o01_MEM_RAM_valid & i01_RAM_MEM_ready;

assign o01_MEM_EXU_ready = (~w01_valid)|(w01_MEM_ISU_handshake)|(w01_EXU_MEM_st_en & w01_RAM_req_handshake);//当前寄存器无效/MEM阶段能成功接受/RAM成功接受ST
assign o01_MEM_RAM_ready = i01_ISU_MEM_ready;//由RAM向ISU的端口直接透传
assign o01_MEM_ISU_valid = i01_RAM_MEM_valid&w01_EXU_MEM_ld_en;//由RAM向ISU的端口直接透传，但这里稍加处理
assign o01_MEM_RAM_valid = w01_valid;

assign w01_valid = w01_reg_valid /*& (w01_EXU_MEM_ld_en | w01_EXU_MEM_st_en)*/;
assign o32_MEM_ISU_data = i32_RAM_MEM_rdata;
assign o05_MEM_ISU_rd   = w05_EXU_MEM_rd;
assign o32_MEM_RAM_addr = w32_EXU_MEM_addr;
assign o32_MEM_RAM_data = w32_EXU_MEM_wdata;
assign o01_MEM_RAM_type = w01_EXU_MEM_st_en;
assign o04_MEM_RAM_wstrb= w04_EXU_MEM_wstrb;

always @(posedge clk) begin
    if(rst) begin
        r01_reg_valid <=  1'b0;
        r01_EXU_MEM_ld_en <=  1'b0;
        r01_EXU_MEM_st_en <=  1'b0;
        r32_EXU_MEM_wdata <= 32'b0;
        r32_EXU_MEM_addr  <= 32'b0;
        r05_EXU_MEM_rd    <=  5'b0;
        r04_EXU_MEM_wstrb <=  4'b0;
    end 
    else begin
        if(w01_EXU_MEM_handshake)begin
            r01_reg_valid <= 1'b1;
            r01_EXU_MEM_ld_en <= i01_EXU_MEM_ld_en;
            r01_EXU_MEM_st_en <= i01_EXU_MEM_st_en;
            r32_EXU_MEM_wdata <= i32_EXU_MEM_wdata;
            r32_EXU_MEM_addr  <= i32_EXU_MEM_addr;
            r05_EXU_MEM_rd    <= i05_EXU_MEM_rd;
            r04_EXU_MEM_wstrb <= i04_EXU_MEM_wstrb;
        end
    end
end
endmodule
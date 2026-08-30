module ISU(
    input clk,
    input rst,

	input         i01_IDU_ISU_valid, //IDU ISU有效信号
	input  [ 4:0] i05_IDU_GPR_rj,
	input  [ 4:0] i05_IDU_GPR_rk,
	input  [ 4:0] i05_IDU_GPR_rd,
	output [31:0] o32_GPR_IDU_rj,
	output [31:0] o32_GPR_IDU_rk,
	output [31:0] o32_GPR_IDU_rd,//IDU通过ISU访问GPR；GPR的读行为不需要经过一拍
    
	input  [31:0] i32_IDU_ISU_PCnew,
	input         i01_IDU_ISU_PCmis,
	output        o01_ISU_IDU_ready,  //ISU IDU准备好信号

    output        o01_ISU_IFU_PCmis,
    output [31:0] o32_ISU_IFU_PCnew,

    input         i01_MEM_ISU_valid,
    input  [31:0] i32_MEM_ISU_data,
    input  [ 4:0] i05_MEM_ISU_rd,
    output        o01_ISU_MEM_ready,

    input         i01_EXU_ISU_valid,
    input  [ 4:0] i05_EXU_ISU_rd,
    input  [31:0] i32_EXU_ISU_res,
    input         i01_EXU_MEM_ld_en,
    input         i01_EXU_ISU_wb_en,
    output        o01_ISU_EXU_ready
);
`define BASE_PART
`ifdef BASE_PART
wire [ 4:0] w05_EXU_rd;
wire [31:0] w32_EXU_res;
wire        w01_ld_en;
wire        w01_wb_en;
`endif
assign o01_ISU_IFU_PCmis = i01_IDU_ISU_PCmis;
assign o32_ISU_IFU_PCnew = i32_IDU_ISU_PCnew;
`define GPR_OPERATION
`ifdef GPR_OPERATION
reg [31:0] GPR [31:0];
reg [31:0] GPR_lock;

// assign GPR[w_EXU_rd[4:0]] = (w_EXU_rd!= 5'b0 & w_wb_en)?w_EXU_res:32'b0;
// 前递优先级：MEM > EXU > GPR
assign o32_GPR_IDU_rj = (i01_MEM_ISU_valid & (i05_MEM_ISU_rd == i05_IDU_GPR_rj)) ? i32_MEM_ISU_data :
                        (i01_EXU_ISU_wb_en & (i05_EXU_ISU_rd == i05_IDU_GPR_rj)) ? i32_EXU_ISU_res :
                        GPR[i05_IDU_GPR_rj] & {32{i01_IDU_ISU_valid}};

assign o32_GPR_IDU_rk = (i01_MEM_ISU_valid & (i05_MEM_ISU_rd == i05_IDU_GPR_rk)) ? i32_MEM_ISU_data :
                        (i01_EXU_ISU_wb_en & (i05_EXU_ISU_rd == i05_IDU_GPR_rk)) ? i32_EXU_ISU_res :
                        GPR[i05_IDU_GPR_rk] & {32{i01_IDU_ISU_valid}};

assign o32_GPR_IDU_rd = (i01_MEM_ISU_valid & (i05_MEM_ISU_rd == i05_IDU_GPR_rd)) ? i32_MEM_ISU_data :
                        (i01_EXU_ISU_wb_en & (i05_EXU_ISU_rd == i05_IDU_GPR_rd)) ? i32_EXU_ISU_res :
                        GPR[i05_IDU_GPR_rd] & {32{i01_IDU_ISU_valid}};//这里简单做一个前推。ld产生的东西我就落锁了
`endif

`define HANDSHAKE_ANALYSE
`ifdef HANDSHAKE_ANALYSE
wire w01_IDU_ISU_handshake;
wire w01_EXU_ISU_handshake;
wire w01_MEM_ISU_handshake;
assign w01_IDU_ISU_handshake = i01_IDU_ISU_valid & o01_ISU_IDU_ready;
assign w01_EXU_ISU_handshake = i01_EXU_ISU_valid & o01_ISU_EXU_ready;
assign w01_MEM_ISU_handshake = i01_MEM_ISU_valid & o01_ISU_EXU_ready;
assign o01_ISU_MEM_ready = 1'b1;
assign o01_ISU_EXU_ready = 1'b1;assign o01_ISU_IDU_ready = ~(
    (GPR_lock[i05_IDU_GPR_rj] & (i05_IDU_GPR_rj != 5'b0)) |
    (GPR_lock[i05_IDU_GPR_rk] & (i05_IDU_GPR_rk != 5'b0)) |
    (GPR_lock[i05_IDU_GPR_rd] & (i05_IDU_GPR_rd != 5'b0)) |
    (i01_EXU_MEM_ld_en & (i05_EXU_ISU_rd != 5'b0) & (
        (i05_EXU_ISU_rd == i05_IDU_GPR_rj) |
        (i05_EXU_ISU_rd == i05_IDU_GPR_rk) |
        (i05_EXU_ISU_rd == i05_IDU_GPR_rd)
    ))
);//如果访问到被锁存的内容，则返回"没准备好"
`endif
integer i;
always @(posedge clk) begin
    if (rst)begin
        for(i = 0;i<32;i=i+1)begin
            GPR[i] <=0;
            GPR_lock[i]<=0;
        end
    end
    else begin
        
        if(w01_MEM_ISU_handshake)begin
            GPR[i05_MEM_ISU_rd]<= i32_MEM_ISU_data;
            GPR_lock[i05_MEM_ISU_rd] <= 0;//这里必须把MEM的解除锁放上锁前面！
        end
        if(w01_EXU_ISU_handshake)begin
            if(i01_EXU_ISU_wb_en)begin
                GPR[i05_EXU_ISU_rd] <= i32_EXU_ISU_res;
            end
        end
        if(i01_EXU_MEM_ld_en & i05_MEM_ISU_rd != 5'b0 )begin
            GPR_lock[i05_MEM_ISU_rd] <= 1;
        end
    end 
    
end
endmodule
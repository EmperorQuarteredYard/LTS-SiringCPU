module MEM#(
    parameter SRAM_WAIT_CYCLES = 2   // 根据时钟频率调整，至少 2
)(
    input clk,
    input rst,

    input         i01_EXU_MEM_valid,
    input         i01_EXU_MEM_wen,
    input         i01_EXU_MEM_ren,
    input  [31:0] i32_EXU_MEM_wdata,
    input  [31:0] i32_EXU_MEM_addr,
    input  [ 4:0] i05_EXU_MEM_rd,
    input  [ 3:0] i04_EXU_MEM_wstrb,//高有效
    output        o01_MEM_EXU_ready,
    
    output        o01_MEM_ISU_valid,
    output [31:0] o32_MEM_ISU_data,
    output [ 4:0] o05_MEM_ISU_rd,
    input         i01_ISU_MEM_ready
);


always @(posedge clk) begin
end
endmodule
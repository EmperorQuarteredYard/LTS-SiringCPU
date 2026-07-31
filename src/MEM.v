module MEM#(
    parameter SRAM_WAIT_CYCLES = 2   // 根据时钟频率调整，至少 2
)(
    input clk,
    input rst,

    input         EXU_MEM_valid,
    input         EXU_MEM_wen,
    input         EXU_MEM_ren,
    input  [31:0] EXU_MEM_wdata,
    input  [31:0] EXU_MEM_addr,
    input  [ 4:0] EXU_MEM_rd,
    output        MEM_EXU_ready,
    
    output        MEM_ISU_valid,
    output [31:0] MEM_ISU_data,
    output [ 4:0] MEM_ISU_rd,
    input         ISU_MEM_ready,

    input         IFU_MEM_valid,
    input         IFU_MEM_en,
    input  [31:0] IFU_RAM_raddr,
    output [31:0] RAM_IFU_rdata,
    output        MEM_IFU_ready,
    output        MEM_IFU_finish,

    //UART_window
    // input         UART_wen,
    // input         UART_addr,
    // input         UART_wdata,
    // input         UART_rdata,

    // BASE SRAM
    output [19:0] BASERAM_a,
    inout  [31:0] BASERAM_dq,
    output        BASERAM_oe_n,
    output        BASERAM_we_n,
    output        BASERAM_ce_n,
    output [3:0]  BASERAM_be_n,

    // EXT SRAM
    output [19:0] EXTRAM_a,
    inout  [31:0] EXTRAM_dq,
    output        EXTRAM_oe_n,
    output        EXTRAM_we_n,
    output        EXTRAM_ce_n,
    output [3:0]  EXTRAM_be_n
);
reg         reg_wen;
reg         reg_ren;
reg  [31:0] reg_wdata;
reg  [31:0] reg_addr;
reg  [ 4:0] reg_rd;
reg         reg_valid;

wire         wire_wen;
wire         wire_ren;
wire  [31:0] wire_wdata;
wire  [31:0] wire_addr;
wire  [ 4:0] wire_rd;
wire         wire_valid;

assign wire_wen   = reg_wen;
assign wire_ren   = reg_ren;
assign wire_wdata = reg_wdata;
assign wire_addr  = reg_addr;
assign wire_rd    = reg_rd;
assign wire_valid = reg_valid;

`define EXTRAM_OPERATION
`ifdef EXTRAM_OPERATION
wire        data_requ_valid;
wire [19:0] data_requ_addr;
wire        data_requ_type;
wire [31:0] data_requ_wdata;
wire [ 3:0] data_requ_wstrb;
wire        data_requ_exdat;
wire        data_requ_ready;
wire        data_resp_valid;
wire [31:0] data_resp_rdata;
wire        data_resp_ready;

RAM EXTRAM(
    .clk(clk),
    .rst(rst),
    .RAM_data(EXTRAM_dq),
    .RAM_addr(EXTRAM_a),
    .RAM_be_n(EXTRAM_be_n),
    .RAM_ce_n(EXTRAM_ce_n),
    .RAM_oe_n(EXTRAM_oe_n),
    .RAM_we_n(EXTRAM_we_n),
    .requ_valid(data_requ_valid),
    .requ_addr(data_requ_addr),
    .requ_type(data_requ_type),
    .requ_wdata(data_requ_wdata),
    .requ_wstrb(data_requ_wstrb),
    .requ_exdat(data_requ_exdat),
    .requ_ready(data_requ_ready),
    .resp_valid(data_resp_valid),
    .resp_rdata(data_resp_rdata),
    .resp_exdat(),
    .resp_ready(data_resp_ready)
);

wire EXU_MEM_handshake;
wire MEM_ISU_handshake;

assign EXU_MEM_handshake = EXU_MEM_valid & MEM_EXU_ready;
assign MEM_ISU_handshake = MEM_ISU_valid & ISU_MEM_ready;
assign MEM_ISU_valid     = wire_valid&data_resp_valid;
assign MEM_EXU_ready     = ((~wire_valid)|MEM_ISU_handshake) & data_requ_ready;
assign data_requ_valid   = wire_valid;
assign data_requ_addr    = wire_addr[19:0];
assign data_requ_type    = wire_wen;
assign data_requ_wdata   = wire_wdata;
assign data_requ_wstrb   = 4'b0;
assign data_requ_exdat   = 1'b1;
assign data_resp_ready   = 1'b1;
assign MEM_ISU_rd        = wire_rd;
assign MEM_ISU_data      = data_resp_rdata;

`endif

`define BASERAM_OPERATION
`ifdef BASERAM_OPERATION
wire        inst_requ_valid;
wire [19:0] inst_requ_addr;
wire        inst_requ_type;
wire [31:0] inst_requ_wdata;
wire [ 3:0] inst_requ_wstrb;
wire        inst_requ_exdat;
wire        inst_requ_ready;
wire        inst_resp_valid;
wire [31:0] inst_resp_rdata;
wire        inst_resp_ready;

assign inst_requ_valid = IFU_MEM_valid & IFU_MEM_en;
assign inst_requ_addr  = IFU_RAM_raddr[19:0];
assign inst_requ_type  = 1'b0;
assign inst_requ_wdata = 32'b0;
assign inst_requ_wstrb = 4'b0;
assign inst_requ_exdat = 1'b0;
assign MEM_IFU_ready   = inst_requ_ready;
assign MEM_IFU_finish  = inst_resp_valid;
assign inst_resp_rdata = RAM_IFU_rdata;
assign inst_resp_ready = 1'b1;

RAM BASERAM(
    .clk(clk),
    .rst(rst),
    .RAM_data(BASERAM_dq),
    .RAM_addr(BASERAM_a),
    .RAM_be_n(BASERAM_be_n),
    .RAM_ce_n(BASERAM_ce_n),
    .RAM_oe_n(BASERAM_oe_n),
    .RAM_we_n(BASERAM_we_n),
    .requ_valid(inst_requ_valid),
    .requ_addr(inst_requ_addr),
    .requ_type(inst_requ_type),
    .requ_wdata(inst_requ_wdata),
    .requ_wstrb(inst_requ_wstrb),
    .requ_exdat(inst_requ_exdat),
    .requ_ready(inst_requ_ready),
    .resp_valid(inst_resp_valid),
    .resp_rdata(inst_resp_rdata),
    .resp_exdat(),
    .resp_ready(inst_resp_ready)
);
`endif

always @(posedge clk) begin
    if (rst)begin
        reg_wen   <= 1'b0;
        reg_ren   <= 1'b0;
        reg_wdata <= 32'b0;
        reg_addr  <= 32'b0;
        reg_rd    <= 5'b0;
        reg_valid <= 1'b0;
    end
    else if(EXU_MEM_handshake)begin
        reg_wen   <= EXU_MEM_wen;
        reg_ren   <= EXU_MEM_ren;
        reg_wdata <= EXU_MEM_wdata;
        reg_addr  <= EXU_MEM_addr;
        reg_rd    <= EXU_MEM_rd;
        reg_valid <= 1'b1;
    end
end
    
endmodule
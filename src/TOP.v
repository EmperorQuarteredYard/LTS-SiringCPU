`include "define.vh"

module TOP(
    input clk,
    input rst,
`ifdef ENVIRONMENT_SIMULATE
    output [31:0] o32_simulate0,
    output [31:0] o32_simulate1,
    output [31:0] o32_simulate2,
    output [31:0] o32_simulate3,
    output [31:0] o32_simulate4,
    output [31:0] o32_simulate5,
    output [31:0] o32_simulate6,
    output [31:0] o32_simulate7,
    output [31:0] o32_simulate8,
    output [31:0] o32_simulate9,
    output        o01_simulate,
    output [31:0] ShakeStatus,
`endif
    output [19:0] BASERAM_a,
    inout  [31:0] BASERAM_dq,
    output        BASERAM_oe_n,
    output        BASERAM_we_n,
    output        BASERAM_ce_n,
    output [3:0]  BASERAM_be_n,
    output [19:0] EXTRAM_a,
    inout  [31:0] EXTRAM_dq,
    output        EXTRAM_oe_n,
    output        EXTRAM_we_n,
    output        EXTRAM_ce_n,
    output [3:0]  EXTRAM_be_n
);//=============连线信号=============

wire        w01_EXU_IDU_ready;
wire        w01_EXU_ISU_valid;
wire        w01_EXU_ISU_wb_en;
wire        w01_EXU_MEM_ld_en;
wire        w01_EXU_MEM_st_en;
wire        w01_EXU_MEM_valid;
wire        w01_IDU_EXU_valid;
wire        w01_IDU_IFU_ready;
wire        w01_IDU_ISU_PCmis;
wire        w01_IDU_ISU_valid;
wire        w01_IFU_IDU_valid;
wire        w01_IFU_RAM_ready;
wire        w01_IFU_RAM_valid;
wire        w01_ISU_EXU_ready;
wire        w01_ISU_IDU_ready;
wire        w01_ISU_IFU_PCmis;
wire        w01_ISU_MEM_ready;
wire        w01_MEM_EXU_ready;
wire        w01_MEM_ISU_valid;
wire        w01_MEM_RAM_ready;
wire        w01_MEM_RAM_valid;
wire        w01_MEM_RAM_type;
wire        w01_RAM_IFU_ready;
wire        w01_RAM_IFU_valid;
wire        w01_RAM_MEM_ready;
wire        w01_RAM_MEM_valid;
wire [ 1:0] w02_IFU_IDU_id;
wire [ 3:0] w04_EXU_MEM_wstrb;
wire [ 3:0] w04_IDU_EXU_ope;
wire [ 3:0] w04_IDU_EXU_wstrb;
wire [ 3:0] w04_MEM_RAM_wstrb;
wire [ 4:0] w05_EXU_ISU_rd;
wire [ 4:0] w05_EXU_MEM_rd;
wire [ 4:0] w05_IDU_EXU_rd;
wire [ 4:0] w05_IDU_GPR_rd;
wire [ 4:0] w05_IDU_GPR_rj;
wire [ 4:0] w05_IDU_GPR_rk;
wire [ 4:0] w05_MEM_ISU_rd;
wire [10:0] w11_IDU_EXU_func;
wire [31:0] w32_EXU_ISU_res;
wire [31:0] w32_EXU_MEM_addr;
wire [31:0] w32_EXU_MEM_wdata;
wire [31:0] w32_GPR_IDU_rd;
wire [31:0] w32_GPR_IDU_rj;
wire [31:0] w32_GPR_IDU_rk;
wire [31:0] w32_IDU_EXU_rs1;
wire [31:0] w32_IDU_EXU_rs2;
wire [31:0] w32_IDU_EXU_wdata;
wire [31:0] w32_IDU_ISU_PCnew;
wire [31:0] w32_IFU_IDU_PC;
wire [31:0] w32_IFU_IDU_inst;
wire [31:0] w32_IFU_RAM_raddr;
wire [31:0] w32_ISU_IFU_PCnew;
wire [31:0] w32_MEM_ISU_data;
wire [31:0] w32_MEM_RAM_addr;
wire [31:0] w32_MEM_RAM_data;
wire [31:0] w32_RAM_IFU_rdata;
wire [31:0] w32_RAM_MEM_rdata;
wire [31:0] w32_simulate;

`ifdef ENVIRONMENT_SIMULATE
wire [31:0] w32_simulate_ISU;
wire [31:0] w32_simulate_IDU;
`endif
//=============悬空连线=============

//=============异常连线=============
//这里用`/**/`包含多个异常的连线，如多个output对应到同一个连线(但是允许一个连线对多个input)

//=============模块实例=============
IDU u_IDU (
    .clk(clk),
    .rst(rst),

`ifdef ENVIRONMENT_SIMULATE
    .o32_simulate(w32_simulate_IDU),
`endif

    .i01_IFU_IDU_valid(w01_IFU_IDU_valid),
    .i32_IFU_IDU_PC(w32_IFU_IDU_PC),
    .i32_IFU_IDU_inst(w32_IFU_IDU_inst),
    .i02_IFU_IDU_id(w02_IFU_IDU_id),
    .o01_IDU_IFU_ready(w01_IDU_IFU_ready),

    .o01_IDU_ISU_valid(w01_IDU_ISU_valid),
    .o05_IDU_GPR_rj(w05_IDU_GPR_rj),
    .o05_IDU_GPR_rk(w05_IDU_GPR_rk),
    .o05_IDU_GPR_rd(w05_IDU_GPR_rd),
    .i32_GPR_IDU_rj(w32_GPR_IDU_rj),
    .i32_GPR_IDU_rk(w32_GPR_IDU_rk),
    .i32_GPR_IDU_rd(w32_GPR_IDU_rd),

    .o32_IDU_ISU_PCnew(w32_IDU_ISU_PCnew),
    .o01_IDU_ISU_PCmis(w01_IDU_ISU_PCmis),
    .i01_ISU_IDU_ready(w01_ISU_IDU_ready),

    .o01_IDU_EXU_valid(w01_IDU_EXU_valid),
    .o32_IDU_EXU_rs1(w32_IDU_EXU_rs1),
    .o32_IDU_EXU_rs2(w32_IDU_EXU_rs2),
    .o04_IDU_EXU_ope(w04_IDU_EXU_ope),
    .o05_IDU_EXU_rd(w05_IDU_EXU_rd),
    .o11_IDU_EXU_func(w11_IDU_EXU_func),
    .o04_IDU_EXU_wstrb(w04_IDU_EXU_wstrb),
    .o32_IDU_EXU_wdata(w32_IDU_EXU_wdata),
    .i01_EXU_IDU_ready(w01_EXU_IDU_ready)
);

IFU u_IFU (
    .clk(clk),
    .rst(rst),

    .o01_IFU_IDU_valid(w01_IFU_IDU_valid),
    .o32_IFU_IDU_PC(w32_IFU_IDU_PC),
    .o32_IFU_IDU_inst(w32_IFU_IDU_inst),
    .o02_IFU_IDU_id(w02_IFU_IDU_id),
    .i01_IDU_IFU_ready(w01_IDU_IFU_ready),

    .i01_ISU_IFU_PCmis(w01_ISU_IFU_PCmis),
    .i32_ISU_IFU_PCnew(w32_ISU_IFU_PCnew),

    .o01_IFU_RAM_valid(w01_IFU_RAM_valid),
    .o32_IFU_RAM_raddr(w32_IFU_RAM_raddr),
    .i01_RAM_IFU_ready(w01_RAM_IFU_ready),

    .i01_RAM_IFU_valid(w01_RAM_IFU_valid),
    .i32_RAM_IFU_rdata(w32_RAM_IFU_rdata),
    .o01_IFU_RAM_ready(w01_IFU_RAM_ready)
);

ISU u_ISU (
    .clk(clk),
    .rst(rst),
`ifdef ENVIRONMENT_SIMULATE
    .o32_simulate_ISU(w32_simulate_ISU),
`endif

    .i01_IDU_ISU_valid(w01_IDU_ISU_valid),
    .i05_IDU_GPR_rj(w05_IDU_GPR_rj),
    .i05_IDU_GPR_rk(w05_IDU_GPR_rk),
    .i05_IDU_GPR_rd(w05_IDU_GPR_rd),
    .o32_GPR_IDU_rj(w32_GPR_IDU_rj),
    .o32_GPR_IDU_rk(w32_GPR_IDU_rk),
    .o32_GPR_IDU_rd(w32_GPR_IDU_rd),

    .i32_IDU_ISU_PCnew(w32_IDU_ISU_PCnew),
    .i01_IDU_ISU_PCmis(w01_IDU_ISU_PCmis),
    .o01_ISU_IDU_ready(w01_ISU_IDU_ready),

    .o01_ISU_IFU_PCmis(w01_ISU_IFU_PCmis),
    .o32_ISU_IFU_PCnew(w32_ISU_IFU_PCnew),

    .i01_MEM_ISU_valid(w01_MEM_ISU_valid),
    .i32_MEM_ISU_data(w32_MEM_ISU_data),
    .i05_MEM_ISU_rd(w05_MEM_ISU_rd),
    .o01_ISU_MEM_ready(w01_ISU_MEM_ready),

    .i01_EXU_ISU_valid(w01_EXU_ISU_valid),
    .i05_EXU_ISU_rd(w05_EXU_ISU_rd),
    .i32_EXU_ISU_res(w32_EXU_ISU_res),
    .i01_EXU_MEM_ld_en(w01_EXU_MEM_ld_en),
    .i01_EXU_ISU_wb_en(w01_EXU_ISU_wb_en),
    .o01_ISU_EXU_ready(w01_ISU_EXU_ready)
);

MEM u_MEM (
    .clk(clk),
    .rst(rst),

    .i01_EXU_MEM_valid(w01_EXU_MEM_valid),
    .i01_EXU_MEM_ld_en(w01_EXU_MEM_ld_en),
    .i01_EXU_MEM_st_en(w01_EXU_MEM_st_en),
    .i32_EXU_MEM_wdata(w32_EXU_MEM_wdata),
    .i32_EXU_MEM_addr(w32_EXU_MEM_addr),
    .i05_EXU_MEM_rd(w05_EXU_MEM_rd),
    .i04_EXU_MEM_wstrb(w04_EXU_MEM_wstrb),
    .o01_MEM_EXU_ready(w01_MEM_EXU_ready),

    .o01_MEM_ISU_valid(w01_MEM_ISU_valid),
    .o32_MEM_ISU_data(w32_MEM_ISU_data),
    .o05_MEM_ISU_rd(w05_MEM_ISU_rd),
    .i01_ISU_MEM_ready(w01_ISU_MEM_ready),

    .o01_MEM_RAM_valid(w01_MEM_RAM_valid),
    .o32_MEM_RAM_addr(w32_MEM_RAM_addr),
    .o32_MEM_RAM_data(w32_MEM_RAM_data),
    .o01_MEM_RAM_type(w01_MEM_RAM_type),
    .o04_MEM_RAM_wstrb(w04_MEM_RAM_wstrb),
    .i01_RAM_MEM_ready(w01_RAM_MEM_ready),

    .i01_RAM_MEM_valid(w01_RAM_MEM_valid),
    .i32_RAM_MEM_rdata(w32_RAM_MEM_rdata),
    .o01_MEM_RAM_ready(w01_MEM_RAM_ready)
);

EXU u_EXU (
    .clk(clk),
    .rst(rst),

    .i01_IDU_EXU_valid(w01_IDU_EXU_valid),
    .i32_IDU_EXU_rs1(w32_IDU_EXU_rs1),
    .i32_IDU_EXU_rs2(w32_IDU_EXU_rs2),
    .i04_IDU_EXU_ope(w04_IDU_EXU_ope),
    .i05_IDU_EXU_rd(w05_IDU_EXU_rd),
    .i11_IDU_EXU_func(w11_IDU_EXU_func),
    .i32_IDU_EXU_wdata(w32_IDU_EXU_wdata),
    .i04_IDU_EXU_wstrb(w04_IDU_EXU_wstrb),
    .o01_EXU_IDU_ready(w01_EXU_IDU_ready),

    .o01_EXU_MEM_valid(w01_EXU_MEM_valid),
    .o32_EXU_MEM_addr(w32_EXU_MEM_addr),
    .o32_EXU_MEM_wdata(w32_EXU_MEM_wdata),
    .o04_EXU_MEM_wstrb(w04_EXU_MEM_wstrb),
    .o05_EXU_MEM_rd(w05_EXU_MEM_rd),
    .o01_EXU_MEM_ld_en(w01_EXU_MEM_ld_en),
    .o01_EXU_MEM_st_en(w01_EXU_MEM_st_en),
    .i01_MEM_EXU_ready(w01_MEM_EXU_ready),

    .o01_EXU_ISU_valid(w01_EXU_ISU_valid),
    .o05_EXU_ISU_rd(w05_EXU_ISU_rd),
    .o32_EXU_ISU_res(w32_EXU_ISU_res),
    .o01_EXU_ISU_wb_en(w01_EXU_ISU_wb_en),
    .i01_ISU_EXU_ready(w01_ISU_EXU_ready)
);





RAM #(
    .MAX_WAIT_CYCLE (3),
    .MAX_KEEP_CYCLE (15)
) u_BASE_RAM (
    .clk            (clk),
    .rst            (rst),
    
`ifdef ENVIRONMENT_SIMULATE
    .o32_simulate   (),
`endif
    .RAM_data       (BASERAM_dq),
    .RAM_addr       (BASERAM_a),
    .RAM_be_n       (BASERAM_be_n),
    .RAM_ce_n       (BASERAM_ce_n),
    .RAM_oe_n       (BASERAM_oe_n),
    .RAM_we_n       (BASERAM_we_n),
    .requ_valid     (w01_IFU_RAM_valid),
    .requ_addr      (w32_IFU_RAM_raddr[21:2]),
    .requ_type      (1'b0),
    .requ_wdata     (32'b0),
    .requ_wstrb     (4'b1111),
    .requ_exdat     (1'b0),
    .requ_ready     (w01_RAM_IFU_ready),
    .resp_valid     (w01_RAM_IFU_valid),
    .resp_rdata     (w32_RAM_IFU_rdata),
    .resp_exdat     (),
    .resp_ready     (w01_IFU_RAM_ready)
);

RAM #(
    .MAX_WAIT_CYCLE (3),
    .MAX_KEEP_CYCLE (15)
) u_EXT_RAM (
    .clk            (clk),
    .rst            (rst),
`ifdef ENVIRONMENT_SIMULATE
    .o32_simulate   (),
`endif
    .RAM_data       (EXTRAM_dq),
    .RAM_addr       (EXTRAM_a),
    .RAM_be_n       (EXTRAM_be_n),
    .RAM_ce_n       (EXTRAM_ce_n),
    .RAM_oe_n       (EXTRAM_oe_n),
    .RAM_we_n       (EXTRAM_we_n),
    .requ_valid     (w01_MEM_RAM_valid),
    .requ_addr      (w32_MEM_RAM_addr[21:2]),
    .requ_type      (w01_MEM_RAM_type),
    .requ_wdata     (w32_MEM_RAM_data),
    .requ_wstrb     (w04_MEM_RAM_wstrb),
    .requ_exdat     (1'b0),
    .requ_ready     (w01_RAM_MEM_ready),
    .resp_valid     (w01_RAM_MEM_valid),
    .resp_rdata     (w32_RAM_MEM_rdata),
    .resp_exdat     (),
    .resp_ready     (w01_MEM_RAM_ready)
);

`ifdef ENVIRONMENT_SIMULATE
assign o32_simulate0 = {3'b0,w05_IDU_GPR_rj,3'b0,w05_IDU_GPR_rk,3'b0,w05_IDU_GPR_rd,3'b0,w05_MEM_ISU_rd};
assign o32_simulate1 = w32_MEM_ISU_data;
assign o32_simulate2 = w32_IDU_ISU_PCnew;
assign o32_simulate3 = {32{w01_IDU_ISU_PCmis}};
assign o32_simulate4 = w32_RAM_MEM_rdata;
assign o32_simulate5 = w32_IDU_EXU_rs2;
assign o32_simulate6 = w32_IFU_IDU_PC;
assign o32_simulate7 = {28'bz,w04_IDU_EXU_wstrb&{4{w11_IDU_EXU_func[1]}}};
assign o32_simulate8 = {32{(EXTRAM_dq == 32'h6)?1:0}};
assign o32_simulate9 = w32_simulate_ISU;
// assign o01_simulate  = ;
assign ShakeStatus   = {
    w01_IFU_IDU_valid,w01_IDU_IFU_ready,
    w01_IDU_EXU_valid,w01_EXU_IDU_ready, 
    w01_EXU_MEM_valid,w01_MEM_EXU_ready,
    w01_MEM_ISU_valid,w01_ISU_MEM_ready,
    4'bz,
    w01_RAM_IFU_valid,w01_IFU_RAM_ready,
    w01_IFU_RAM_valid,w01_RAM_IFU_ready,
    w01_RAM_MEM_valid,w01_MEM_RAM_ready,
    w01_MEM_RAM_valid,w01_RAM_MEM_ready,
    4'bz,
    w01_EXU_ISU_valid,w01_ISU_MEM_ready,
    w01_IDU_ISU_valid,w01_ISU_IDU_ready,
    4'bz
    };
`endif

endmodule
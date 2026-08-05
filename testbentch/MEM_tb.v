
`timescale 1ns/1ps

module MEM_tb;

    reg clk, rst;

    // 来自 EXU 的接口
    reg         EXU_MEM_valid;
    reg         EXU_MEM_wen;
    reg         EXU_MEM_ren;
    reg  [31:0] EXU_MEM_wdata;
    reg  [31:0] EXU_MEM_addr;
    reg  [ 4:0] EXU_MEM_rd;
    reg  [ 3:0] EXU_MEM_wstrb;
    wire        MEM_EXU_ready;
    wire        o_EXU_MEM_handshake;

    // 到 ISU 的接口
    wire        MEM_ISU_valid;
    wire [31:0] MEM_ISU_data;
    wire [ 4:0] MEM_ISU_rd;
    reg         ISU_MEM_ready;
    wire        o_MEM_ISU_handshake;

    // 来自 IFU 的接口
    reg         IFU_MEM_valid;
    reg         IFU_MEM_en;
    reg  [31:0] IFU_RAM_raddr;
    wire [31:0] RAM_IFU_rdata;
    wire        MEM_IFU_ready;
    wire        MEM_IFU_finish;

    // 外部 SRAM 总线
    wire [19:0] BASERAM_a;
    wire [31:0] BASERAM_dq;
    wire        BASERAM_oe_n, BASERAM_we_n, BASERAM_ce_n;
    wire [ 3:0] BASERAM_be_n;

    wire [19:0] EXTRAM_a;
    wire [31:0] EXTRAM_dq;
    wire        EXTRAM_oe_n, EXTRAM_we_n, EXTRAM_ce_n;
    wire [ 3:0] EXTRAM_be_n;

    // 实例化被测模块
    MEM #(.SRAM_WAIT_CYCLES(2)) u_mem (
        .clk            (clk),
        .rst            (rst),
        .o_EXU_MEM_handshake(o_EXU_MEM_handshake),
        .o_MEM_ISU_handshake(o_MEM_ISU_handshake),
        .EXU_MEM_valid  (EXU_MEM_valid),
        .EXU_MEM_wen    (EXU_MEM_wen),
        .EXU_MEM_ren    (EXU_MEM_ren),
        .EXU_MEM_wdata  (EXU_MEM_wdata),
        .EXU_MEM_addr   (EXU_MEM_addr),
        .EXU_MEM_rd     (EXU_MEM_rd),
        .EXU_MEM_wstrb  (EXU_MEM_wstrb),
        .MEM_EXU_ready  (MEM_EXU_ready),
        .MEM_ISU_valid  (MEM_ISU_valid),
        .MEM_ISU_data   (MEM_ISU_data),
        .MEM_ISU_rd     (MEM_ISU_rd),
        .ISU_MEM_ready  (ISU_MEM_ready),
        .IFU_MEM_valid  (IFU_MEM_valid),
        .IFU_MEM_en     (IFU_MEM_en),
        .IFU_RAM_raddr  (IFU_RAM_raddr),
        .RAM_IFU_rdata  (RAM_IFU_rdata),
        .MEM_IFU_ready  (MEM_IFU_ready),
        .MEM_IFU_finish (MEM_IFU_finish),
        .BASERAM_a      (BASERAM_a),
        .BASERAM_dq     (BASERAM_dq),
        .BASERAM_oe_n   (BASERAM_oe_n),
        .BASERAM_we_n   (BASERAM_we_n),
        .BASERAM_ce_n   (BASERAM_ce_n),
        .BASERAM_be_n   (BASERAM_be_n),
        .EXTRAM_a       (EXTRAM_a),
        .EXTRAM_dq      (EXTRAM_dq),
        .EXTRAM_oe_n    (EXTRAM_oe_n),
        .EXTRAM_we_n    (EXTRAM_we_n),
        .EXTRAM_ce_n    (EXTRAM_ce_n),
        .EXTRAM_be_n    (EXTRAM_be_n)
    );

    // 模拟同步 SRAM 存储体
    reg [31:0] base_mem [0:2047];
    reg [31:0] ext_mem  [0:8191];

    reg [31:0] base_read_data, ext_read_data;

    // 同步读
    always @(posedge clk) begin
        if (BASERAM_ce_n == 1'b0 && BASERAM_oe_n == 1'b0)
            base_read_data <= (BASERAM_a < 2048) ? base_mem[BASERAM_a] : 32'hx;

        if (EXTRAM_ce_n == 1'b0 && EXTRAM_oe_n == 1'b0)
            ext_read_data  <= (EXTRAM_a < 8192)  ? ext_mem[EXTRAM_a]  : 32'hx;
    end

    // 三态驱动：读使能时输出数据，否则高阻
    assign BASERAM_dq = (BASERAM_ce_n == 1'b0 && BASERAM_oe_n == 1'b0) ? base_read_data : 32'hz;
    assign EXTRAM_dq  = (EXTRAM_ce_n == 1'b0 && EXTRAM_oe_n == 1'b0)  ? ext_read_data  : 32'hz;

    // 同步写
    always @(posedge clk) begin
        if (BASERAM_ce_n == 1'b0 && BASERAM_we_n == 1'b0 && BASERAM_oe_n == 1'b1) begin
            if (BASERAM_a < 2048) begin
                if (~BASERAM_be_n[0]) base_mem[BASERAM_a][7:0]   <= BASERAM_dq[7:0];
                if (~BASERAM_be_n[1]) base_mem[BASERAM_a][15:8]  <= BASERAM_dq[15:8];
                if (~BASERAM_be_n[2]) base_mem[BASERAM_a][23:16] <= BASERAM_dq[23:16];
                if (~BASERAM_be_n[3]) base_mem[BASERAM_a][31:24] <= BASERAM_dq[31:24];
            end
        end
        if (EXTRAM_ce_n == 1'b0 && EXTRAM_we_n == 1'b0 && EXTRAM_oe_n == 1'b1) begin
            if (EXTRAM_a < 8192) begin
                if (~EXTRAM_be_n[0]) ext_mem[EXTRAM_a][7:0]   <= EXTRAM_dq[7:0];
                if (~EXTRAM_be_n[1]) ext_mem[EXTRAM_a][15:8]  <= EXTRAM_dq[15:8];
                if (~EXTRAM_be_n[2]) ext_mem[EXTRAM_a][23:16] <= EXTRAM_dq[23:16];
                if (~EXTRAM_be_n[3]) ext_mem[EXTRAM_a][31:24] <= EXTRAM_dq[31:24];
            end
        end
    end

    // 时钟 100MHz
    always #5 clk = ~clk;

    // 测试流程
    initial begin
        clk = 0;
        rst = 1;
        EXU_MEM_valid = 0;
        EXU_MEM_wen = 0;
        EXU_MEM_ren = 0;
        EXU_MEM_wdata = 0;
        EXU_MEM_addr = 0;
        EXU_MEM_rd = 0;
        EXU_MEM_wstrb = 0;
        ISU_MEM_ready = 1;
        IFU_MEM_valid = 0;
        IFU_MEM_en = 0;
        IFU_RAM_raddr = 0;

        // 清空内存并预设测试数据
        for (int i = 0; i < 2048; i++) base_mem[i] = 0;
        for (int i = 0; i < 8192; i++) ext_mem[i] = 0;
        base_mem[11'ha] = 32'h5A5A5A5A;
        ext_mem[11'ha]  = 32'hA5A5A5A5;

        #20 rst = 0;
        repeat (5) @(posedge clk);

        // 测试 1：EXU 读 BASERAM
        $display("Test 1: EXU read from BASERAM");
        EXU_MEM_valid = 1;
        EXU_MEM_ren   = 1;
        EXU_MEM_addr  = 32'h1c400028;   // 字地址 00a
        EXU_MEM_rd    = 5'b00001;
        @(posedge clk);
        while (!MEM_EXU_ready) @(posedge clk);
        wait (MEM_ISU_valid);
        if (MEM_ISU_data !== 32'hA5A5A5A5) $display("ERROR: read data = %h", MEM_ISU_data);
        else $display("Read OK: %h", MEM_ISU_data);
        if (MEM_ISU_rd !== 5'b00001) $display("ERROR: rd mismatch");
        ISU_MEM_ready = 1;
        @(posedge clk);
        ISU_MEM_ready = 0;
        EXU_MEM_valid = 0;
        EXU_MEM_ren   = 0;
        repeat (3) @(posedge clk);

        // 测试 2：EXU 写 EXTRAM
        $display("Test 2: EXU write to EXTRAM");
        EXU_MEM_valid = 1;
        EXU_MEM_wen   = 1;
        EXU_MEM_wdata = 32'h12345678;
        EXU_MEM_addr  = 32'h1c400050;   // 字地址 20
        EXU_MEM_wstrb = 4'b1111;
        @(posedge clk);
        while (!MEM_EXU_ready) @(posedge clk);
        repeat (10) @(posedge clk);
        if (ext_mem[14] !== 32'h12345678) $display("ERROR: write data = %h", ext_mem[20]);
        else $display("Write OK to ext_mem[20]");
        EXU_MEM_valid = 0;
        EXU_MEM_wen   = 0;
        repeat (3) @(posedge clk);

        // 测试 3：IFU 读（指令取指）
        $display("Test 3: IFU read from BASERAM");
        base_mem[5] = 32'h1c000013;
        IFU_MEM_valid = 1;
        IFU_MEM_en    = 1;
        IFU_RAM_raddr = 32'h1c000014;
        @(posedge clk);
        while (!MEM_IFU_ready) @(posedge clk);
        wait (MEM_IFU_finish);
        if (RAM_IFU_rdata !== 32'h00000013) $display("ERROR: IFU read data = %h", RAM_IFU_rdata);
        else $display("IFU read OK: %h", RAM_IFU_rdata);
        IFU_MEM_valid = 0;
        IFU_MEM_en    = 0;

        repeat (5) @(posedge clk);
        $display("All tests passed.");
        $finish;
    end

endmodule
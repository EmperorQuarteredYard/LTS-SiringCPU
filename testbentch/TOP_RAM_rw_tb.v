`timescale 1ns/1ps

module TOP_tb;

    // 时钟和复�?
    reg clk;
    reg rstn;

    // 与TOP模块的信号连�?
    wire [19:0] BASERAM_a;
    wire [31:0] BASERAM_dq;
    wire        BASERAM_oe_n;
    wire        BASERAM_we_n;
    wire        BASERAM_ce_n;
    wire [3:0]  BASERAM_be_n;

    wire [19:0] EXTRAM_a;
    wire [31:0] EXTRAM_dq;
    wire        EXTRAM_oe_n;
    wire        EXTRAM_we_n;
    wire        EXTRAM_ce_n;
    wire [3:0]  EXTRAM_be_n;

    // 实例化待测模�?
    TOP u_top (
        .clk         (clk),
        .rstn        (rstn),
        .BASERAM_a   (BASERAM_a),
        .BASERAM_dq  (BASERAM_dq),
        .BASERAM_oe_n(BASERAM_oe_n),
        .BASERAM_we_n(BASERAM_we_n),
        .BASERAM_ce_n(BASERAM_ce_n),
        .BASERAM_be_n(BASERAM_be_n),
        .EXTRAM_a    (EXTRAM_a),
        .EXTRAM_dq   (EXTRAM_dq),
        .EXTRAM_oe_n (EXTRAM_oe_n),
        .EXTRAM_we_n (EXTRAM_we_n),
        .EXTRAM_ce_n (EXTRAM_ce_n),
        .EXTRAM_be_n (EXTRAM_be_n)
    );

    initial clk = 0;
    always #5 clk = ~clk;   // 10ns 周期

    reg [31:0] baseram_mem [0:255];          // �?�? 256 �? 32-bit �?
    reg [31:0] baseram_dout;

    reg [31:0] extram_mem [0:4095];          // 16KB (地址 0~16380)
    reg [31:0] extram_dout;

    assign BASERAM_dq = (BASERAM_ce_n == 1'b0 && BASERAM_oe_n == 1'b0) ? baseram_dout : 32'hz;

    assign EXTRAM_dq = (EXTRAM_ce_n == 1'b0 && EXTRAM_oe_n == 1'b0) ? extram_dout : 32'hz;

    integer i;
    initial begin
        // ---------- 指令编码 ----------
        // LU12I.w r1, 1    => r1 = 0x1000
        baseram_mem[0] = {7'b0001010, 20'd1, 5'd1};

        // LD.W r3, r1, 0   => r3 = [0x1000]
        baseram_mem[1] = {10'b0010100010, 12'b0, 5'd1, 5'd3};

        // ADDI.W r3, r3, 1 => r3 = r3 + 1
        baseram_mem[2] = {10'b0000001010, 12'd1, 5'd3, 5'd3};

        // ST.W r3, r1, 0   => [0x1000] = r3
        baseram_mem[3] = {10'b0010100110, 12'b0, 5'd1, 5'd3};

        // NOP (ADD.W r0, r0, r0)
        baseram_mem[4] = {17'b00000000000100000, 5'b0, 5'b0, 5'b0};
        baseram_mem[5] = baseram_mem[4];
        baseram_mem[6] = baseram_mem[4];
        baseram_mem[7] = baseram_mem[4];
        for (i = 8; i < 256; i=i+1) baseram_mem[i] = baseram_mem[4];

        extram_mem[32'h1000 >> 2] = 32'h12345678;   // 0x1000 / 4 = 0x400
        for (i = 0; i < 4096; i=i+1) begin
            if (i != (32'h1000 >> 2)) extram_mem[i] = 32'h0;
        end
    end

    always @(*) begin
        if (BASERAM_ce_n == 1'b0 && BASERAM_oe_n == 1'b0) begin
            baseram_dout = baseram_mem[BASERAM_a];   // 地址直接作为索引 (字地�?)
        end else begin
            baseram_dout = 32'hx;
        end

        if (EXTRAM_ce_n == 1'b0 && EXTRAM_oe_n == 1'b0) begin
            extram_dout = extram_mem[EXTRAM_a];
        end else begin
            extram_dout = 32'hx;
        end
    end

    always @(posedge clk) begin
        if (EXTRAM_ce_n == 1'b0 && EXTRAM_we_n == 1'b0 && EXTRAM_oe_n == 1'b1) begin
            if (~EXTRAM_be_n[0]) extram_mem[EXTRAM_a][7:0]   = EXTRAM_dq[7:0];
            if (~EXTRAM_be_n[1]) extram_mem[EXTRAM_a][15:8]  = EXTRAM_dq[15:8];
            if (~EXTRAM_be_n[2]) extram_mem[EXTRAM_a][23:16] = EXTRAM_dq[23:16];
            if (~EXTRAM_be_n[3]) extram_mem[EXTRAM_a][31:24] = EXTRAM_dq[31:24];

            // 打印调试信息
            $display("[%0t] EXTRAM Write: addr=0x%05h, data=0x%08h, be_n=%b",
                     $time, {EXTRAM_a, 2'b00}, EXTRAM_dq, EXTRAM_be_n);
        end
    end

    // 复位与测试流�?
    reg test_done;
    reg [31:0] check_addr;
    reg [31:0] expected_data;

    initial begin
        test_done = 0;
        check_addr = 32'h1000;
        expected_data = 32'h12345679;

        rstn = 0;
        #20;
        rstn = 1;
        $display("[%0t] Reset released", $time);

        #2000;

        // �?查结�?
        if (extram_mem[check_addr >> 2] == expected_data) begin
            $display("[%0t] Test PASSED! EXTRAM[0x%08h] = 0x%08h (expected 0x%08h)",
                     $time, check_addr, extram_mem[check_addr >> 2], expected_data);
        end else begin
            $display("[%0t] Test FAILED! EXTRAM[0x%08h] = 0x%08h (expected 0x%08h)",
                     $time, check_addr, extram_mem[check_addr >> 2], expected_data);
        end

        test_done = 1;
        #20;
        $finish;
    end

    initial begin
        #5000;
        if (!test_done) begin
            $display("[%0t] Timeout! Simulation terminated.", $time);
            $finish;
        end
    end

    // 波形转储
    initial begin
        $dumpfile("TOP_tb.vcd");
        $dumpvars(0, TOP_tb);
    end

endmodule
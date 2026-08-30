`timescale 1ns/1ps
`include "define.vh"
module TOP_tb;

    reg clk;
    reg rst;

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
    
    wire [31:0] o32_simulate0;
    wire [31:0] o32_simulate1;
    wire [31:0] o32_simulate2;
    wire [31:0] o32_simulate3;
    wire [31:0] o32_simulate4;
    wire [31:0] o32_simulate5;
    wire [31:0] o32_simulate6;
    wire [31:0] o32_simulate7;
    wire [31:0] o32_simulate8;
    wire [31:0] o32_simulate9;
    // wire [31:0] o01_simulate;
    wire [31:0] ShakeStatus;

    TOP u_top (
        .clk         (clk),
        .rst        (rst),
        .o32_simulate0(o32_simulate0),
        .o32_simulate1(o32_simulate1),
        .o32_simulate2(o32_simulate2),
        .o32_simulate3(o32_simulate3),
        .o32_simulate4(o32_simulate4),
        .o32_simulate5(o32_simulate5),
        .o32_simulate6(o32_simulate6),
        .o32_simulate7(o32_simulate7),
        .o32_simulate8(o32_simulate8),
        .o32_simulate9(o32_simulate9),
        // .o01_simulate(o01_simulate),
        .ShakeStatus(ShakeStatus),
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
    always #10 clk = ~clk;

    //  RAM 行为模型 
    reg [31:0] INSTR_MEM [0:2047];
    reg [31:0] DATA_MEM  [0:8191];

    // 同步读寄存器（在时钟上升沿更新）
    reg [31:0] instr_read_data;
    reg [31:0] data_read_data;
    integer i;

    `define inst_LU12I_W   7 'b0001010
    `define inst_ADDI_W    10'b0000001010
    `define inst_PCADDU12I 7 'b0001110
    `define inst_ADD_W     17'b00000000000100000
    `define inst_SUB_W     17'b00000000000100010
    `define inst_SLT       17'b00000000000100100
    `define inst_AND       17'b00000000000101001
    `define inst_ANDI      10'b0000001101
    `define inst_OR        17'b00000000000101010
    `define inst_ORI       10'b0000001110
    `define inst_XOR       17'b00000000000101011
    `define inst_SLL_W     17'b00000000000101110
    `define inst_SLLI_W    17'b00000000010000001
    `define inst_SRLI_W    17'b00000000010001001
    `define inst_LD_B      10'b0010100000
    `define inst_LD_W      10'b0010100010
    `define inst_ST_B      10'b0010100100
    `define inst_ST_W      10'b0010100110
    `define inst_B         6 'b010100
    `define inst_BL        6 'b010101
    `define inst_BEQ       6 'b010110
    `define inst_BNE       6 'b010111
    `define inst_JIRL      6 'b010011
    `define inst_MUL_W     17'b00000000000111000
    
    // 在这里指定BASERAM的内容(指令)
    initial begin
        for (i = 0; i < 2048; i = i + 1) INSTR_MEM[i] = 32'h00000000;
        // 示例：INSTR_MEM[0] = {7'b0001010, 20'd1, 5'd1};
        INSTR_MEM[11'h000] = {`inst_LU12I_W,  20'h1c400, 5'h6};      // r6  = 0x1c400000
        INSTR_MEM[11'h001] = {`inst_PCADDU12I,20'h00000, 5'h17};     // r23 = PC = 0x1c000004
        INSTR_MEM[11'h002] = {`inst_ADDI_W,   12'h00a,   5'h0, 5'h7}; // r7  = 10
        INSTR_MEM[11'h003] = {`inst_ADDI_W,   12'h006,   5'h0, 5'h8}; // r8  = 6
        INSTR_MEM[11'h004] = {`inst_ADD_W,    5'h8, 5'h7, 5'h9};      // r9  = 16
        INSTR_MEM[11'h005] = {`inst_SUB_W,    5'h8, 5'h7, 5'ha};      // r10 = 4
        INSTR_MEM[11'h006] = {`inst_SLT,      5'h7, 5'h8, 5'hb};      // r11 = 1
        INSTR_MEM[11'h007] = {`inst_AND,      5'h8, 5'h7, 5'hc};      // r12 = 2
        INSTR_MEM[11'h008] = {`inst_ANDI,     12'h00f,  5'h7, 5'hd};  // r13 = 10
        INSTR_MEM[11'h009] = {`inst_OR,       5'h8, 5'h7, 5'he};      // r14 = 14
        INSTR_MEM[11'h00a] = {`inst_ORI,      12'h001,  5'h7, 5'hf};  // r15 = 11
        INSTR_MEM[11'h00b] = {`inst_XOR,      5'h8, 5'h7, 5'h10};     // r16 = 12
        INSTR_MEM[11'h00c] = {`inst_SLL_W,    5'h8, 5'h7, 5'h11};     // r17 = 640
        INSTR_MEM[11'h00d] = {`inst_SLLI_W,   5'h02, 5'h7, 5'h12};    // r18 = 40
        INSTR_MEM[11'h00e] = {`inst_SRLI_W,   5'h01, 5'h7, 5'h13};    // r19 = 5
        INSTR_MEM[11'h00f] = {`inst_MUL_W,    5'h8, 5'h7, 5'h14};     // r20 = 60

        INSTR_MEM[11'h010] = {`inst_ST_W,     12'h000, 5'h6, 5'h9};   // [0x1c400000] = 16
        INSTR_MEM[11'h011] = {`inst_ST_W,     12'h004, 5'h6, 5'ha};   // [0x1c400004] = 4
        INSTR_MEM[11'h012] = {`inst_ST_W,     12'h008, 5'h6, 5'hb};   // [0x1c400008] = 1
        INSTR_MEM[11'h013] = {`inst_ST_W,     12'h00c, 5'h6, 5'h0};   // [0x1c40000c] = 0
        INSTR_MEM[11'h014] = {`inst_ST_W,     12'h010, 5'h6, 5'hc};   // [0x1c400010] = 2
        INSTR_MEM[11'h015] = {`inst_ST_W,     12'h014, 5'h6, 5'hd};   // [0x1c400014] = 10
        INSTR_MEM[11'h016] = {`inst_ST_W,     12'h018, 5'h6, 5'he};   // [0x1c400018] = 14
        INSTR_MEM[11'h017] = {`inst_ST_W,     12'h01c, 5'h6, 5'hf};   // [0x1c40001c] = 11
        INSTR_MEM[11'h018] = {`inst_ST_W,     12'h020, 5'h6, 5'h10};  // [0x1c400020] = 12
        INSTR_MEM[11'h019] = {`inst_ST_W,     12'h024, 5'h6, 5'h11};  // [0x1c400024] = 640
        INSTR_MEM[11'h01a] = {`inst_ST_W,     12'h028, 5'h6, 5'h12};  // [0x1c400028] = 40
        INSTR_MEM[11'h01b] = {`inst_ST_W,     12'h02c, 5'h6, 5'h13};  // [0x1c40002c] = 5
        INSTR_MEM[11'h01c] = {`inst_ST_W,     12'h030, 5'h6, 5'h14};  // [0x1c400030] = 60
        INSTR_MEM[11'h01d] = {`inst_ST_W,     12'h034, 5'h6, 5'h17};  // [0x1c400034] = 0x1c000004

        INSTR_MEM[11'h01e] = {`inst_LD_W,     12'h000, 5'h6, 5'h15};  // r21 = 16
        INSTR_MEM[11'h01f] = {`inst_ST_W,     12'h038, 5'h6, 5'h15};  // [0x1c400038] = 16
        INSTR_MEM[11'h020] = {`inst_ST_W,     12'h03c, 5'h6, 5'h0};   // [0x1c40003c] = 0
        INSTR_MEM[11'h021] = {`inst_ST_B,     12'h03c, 5'h6, 5'h8};   // [0x1c40003c] = 6
        INSTR_MEM[11'h022] = {`inst_LD_B,     12'h03c, 5'h6, 5'h16};  // r22 = 6
        INSTR_MEM[11'h023] = {`inst_ST_W,     12'h040, 5'h6, 5'h16};  // [0x1c400040] = 6
        INSTR_MEM[11'h024] = {`inst_ST_W,     12'h044, 5'h6, 5'h0};   // [0x1c400044] = 0
        INSTR_MEM[11'h025] = {`inst_ST_B,     12'h044, 5'h6, 5'h7};   // [0x1c400044] = 10

        INSTR_MEM[11'h026] = {`inst_ADDI_W,   12'h001, 5'h0, 5'h18};  // r24 = 1
        INSTR_MEM[11'h027] = {`inst_ADDI_W,   12'h001, 5'h0, 5'h19};  // r25 = 1
        INSTR_MEM[11'h028] = {`inst_BEQ,      16'h0001, 5'h18, 5'h19};// 相等，跳到下一条
        INSTR_MEM[11'h029] = {`inst_BNE,      16'h0000, 5'h18, 5'h19};// 不等不成立，顺序执行
        INSTR_MEM[11'h02a] = {`inst_BL,       16'h0001, 10'h000};     // r1 = PC+4，跳到下一条
        INSTR_MEM[11'h02b] = {`inst_JIRL,     16'h0001, 5'h1, 5'h0};  // 跳到 r1+4，即最后的 B
        INSTR_MEM[11'h02c] = {`inst_B,        16'h0000, 10'h000};     // 自循环，仿真结束
        // for(i = 0;i<12;i=i+1)begin
        //     $display("%08h",INSTR_MEM[i]);
        // end
        /*
        INSTR_MEM[] = {`inst_,};
        */
        
    end

    // 在这里指定EXTRAM是否输出(指令)
    reg         CHECK_EN [0:8191];
    reg  [31:0] EXPECTED [0:8191];

    initial begin
        for (i = 0; i < 8192; i = i + 1) begin
            CHECK_EN[i] = 0;
            EXPECTED[i] = 32'h0;
        end                
        EXPECTED[0]  = 32'd16;
        EXPECTED[1]  = 32'd4;
        EXPECTED[2]  = 32'd1;
        EXPECTED[3]  = 32'd0;
        EXPECTED[4]  = 32'd2;
        EXPECTED[5]  = 32'd10;
        EXPECTED[6]  = 32'd14;
        EXPECTED[7]  = 32'd11;
        EXPECTED[8]  = 32'd12;
        EXPECTED[9]  = 32'd640;
        EXPECTED[10] = 32'd40;
        EXPECTED[11] = 32'd5;
        EXPECTED[12] = 32'd60;
        EXPECTED[13] = 32'h1c000004;   // PCADDU12I 结果
        EXPECTED[14] = 32'd16;         // LD.W 读回
        EXPECTED[15] = 32'd6;          // ST.B 写低字节
        EXPECTED[16] = 32'd6;          // LD.B 读回
        EXPECTED[17] = 32'd10;         // ST.B 写低字节

        CHECK_EN[0]  = 1'b1;
        CHECK_EN[1]  = 1'b1;
        CHECK_EN[2]  = 1'b1;
        CHECK_EN[3]  = 1'b1;
        CHECK_EN[4]  = 1'b1;
        CHECK_EN[5]  = 1'b1;
        CHECK_EN[6]  = 1'b1;
        CHECK_EN[7]  = 1'b1;
        CHECK_EN[8]  = 1'b1;
        CHECK_EN[9]  = 1'b1;
        CHECK_EN[10] = 1'b1;
        CHECK_EN[11] = 1'b1;
        CHECK_EN[12] = 1'b1;
        CHECK_EN[13] = 1'b1;
        CHECK_EN[14] = 1'b1;
        CHECK_EN[15] = 1'b1;
        CHECK_EN[16] = 1'b1;
        CHECK_EN[17] = 1'b1;
        
        // 格式: CHECK_EN[地址索引] = 1; EXPECTED[地址索引] = 期望值;
        // 注意: 地址索引 = 物理地址 >> 2 (因 BASERAM_a/EXTRAM_a 已省略低2位)
        // 示例: CHECK_EN[32'h1000 >> 2] = 1; EXPECTED[32'h1000 >> 2] = 32'h12345679;
        /*
        EXPECTED[ >> 2] = ;
        CHECK_EN[ >> 2] = ;
        */
        
    end

    // 指定触发检查的终止 PC (物理地址) 
    reg [31:0] END_PC_PHYSICAL;
    reg        check_triggered;

    initial begin
        END_PC_PHYSICAL = 32'h1c0000b0;
        check_triggered  = 0;
        $display("simulation will end at 0x%05h",(END_PC_PHYSICAL[21:2]));
    end

    assign BASERAM_dq = (BASERAM_ce_n == 1'b0 && BASERAM_oe_n == 1'b0) ? instr_read_data : 32'hz;
    assign EXTRAM_dq  = (EXTRAM_ce_n  == 1'b0 && EXTRAM_oe_n  == 1'b0) ? data_read_data  : 32'hz;
//注：以下已经改为异步读
    //  同步读
    always @(*) begin
        // BASERAM 同步读
        if (BASERAM_ce_n == 1'b0 && BASERAM_oe_n == 1'b0) begin
            instr_read_data <= (BASERAM_a < 2048) ? INSTR_MEM[BASERAM_a] : 32'hx;
        end
        // 注意：当 ce_n 或 oe_n 无效时，instr_read_data 保持原值，
        // 但三态总线已被断开，因此不会造成总线冲突
        
        // EXTRAM 同步�?
        if (EXTRAM_ce_n == 1'b0 && EXTRAM_oe_n == 1'b0) begin
            data_read_data <= (EXTRAM_a < 8192) ? DATA_MEM[EXTRAM_a] : 32'hx;
        end
    end

    //同步写
    always @(*) begin
        if (EXTRAM_ce_n == 1'b0 && EXTRAM_we_n == 1'b0 && EXTRAM_oe_n == 1'b1) begin
            if (EXTRAM_a < 8192) begin
                if (~EXTRAM_be_n[0]) DATA_MEM[EXTRAM_a][7:0]   <= EXTRAM_dq[7:0];
                if (~EXTRAM_be_n[1]) DATA_MEM[EXTRAM_a][15:8]  <= EXTRAM_dq[15:8];
                if (~EXTRAM_be_n[2]) DATA_MEM[EXTRAM_a][23:16] <= EXTRAM_dq[23:16];
                if (~EXTRAM_be_n[3]) DATA_MEM[EXTRAM_a][31:24] <= EXTRAM_dq[31:24];
                $display("[%0t] EXTRAM Write: Addr=0x%05h, Data=0x%08h", 
                         $time, {EXTRAM_a, 2'b00}, EXTRAM_dq);
            end
        end
    end

    //检查
    always @(posedge clk) begin
        if (~rst && !check_triggered) begin
            if (BASERAM_a == (END_PC_PHYSICAL[21:2])) begin
                check_triggered <= 1;
                $display("[%0t] Trigger: BASERAM_a reached 0x%05h (Physical PC = 0x%08h)", 
                         $time, BASERAM_a, END_PC_PHYSICAL);
            end
        end
    end

    // 测试流程、结果检查
    reg test_done;
    reg [31:0] fail_cnt;
    integer j;

    initial begin
        test_done = 0;
        fail_cnt  = 0;
        rst = 1;
        #30;
        rst = 0;
        $display("[%0t] Simulation Start, waiting for PC trigger...", $time);

        wait(check_triggered == 1);
        
        // 等待流水线排空
        // #1000;

        $display("\n[%0t] Verification Results:", $time);
        for (j = 0; j < 8192; j = j + 1) begin
            if (CHECK_EN[j]) begin
                if (DATA_MEM[j] == EXPECTED[j]) begin
                    $display("  [PASS] Addr 0x%05h = 0x%08h", {j, 2'b00}, DATA_MEM[j]);
                end else begin
                    $display("  [FAIL] Addr 0x%05h = 0x%08h (Expected 0x%08h)", 
                             {j, 2'b00}, DATA_MEM[j], EXPECTED[j]);
                    fail_cnt = fail_cnt + 1;
                end
            end
        end

        if (fail_cnt == 0) $display("\n>>> TEST PASSED <<<");
        else $display("\n>>> TEST FAILED (%0d errors) <<<", fail_cnt);

        test_done = 1;
        #20;
        $finish;
    end

    // 超时保护
    initial begin
        #100000;
        if (!test_done) begin
            $display("[%0t] Timeout! PC never reached 0x%08h", $time, END_PC_PHYSICAL);
            check_triggered<= 1;
        end
    end


endmodule
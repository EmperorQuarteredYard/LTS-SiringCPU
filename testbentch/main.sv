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
    // wire [31:0] o32_simulate3;
    // wire [31:0] o32_simulate4;
    // wire [31:0] o32_simulate5;
    // wire [31:0] o32_simulate6;
    // wire [31:0] o32_simulate7;
    // wire [31:0] o32_simulate8;
    // wire [31:0] o32_simulate9;
    // wire [31:0] o01_simulate;
    wire [15:0] ShakeStatus;

    TOP u_top (
        .clk         (clk),
        .rst        (rst),
        .o32_simulate0(o32_simulate0),
        .o32_simulate1(o32_simulate1),
        .o32_simulate2(o32_simulate2),
        // .o32_simulate3(o32_simulate3),
        // .o32_simulate4(o32_simulate4),
        // .o32_simulate5(o32_simulate5),
        // .o32_simulate6(o32_simulate6),
        // .o32_simulate7(o32_simulate7),
        // .o32_simulate8(o32_simulate8),
        // .o32_simulate9(o32_simulate9),
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
        INSTR_MEM[11'h000] = {`inst_LU12I_W,20'h1c400  , 5'h6};
        INSTR_MEM[11'h001] = {`inst_ADDI_W ,12'h100, 5'h6, 5'h7};
        INSTR_MEM[11'h002] = {`inst_ADDI_W ,12'h1, 5'h0, 5'h2};
        INSTR_MEM[11'h003] = {`inst_ADDI_W ,12'h1, 5'h0, 5'h3};
        INSTR_MEM[11'h004] = {`inst_ADD_W  , 5'h2, 5'h3, 5'h2};
        INSTR_MEM[11'h005] = {`inst_ST_W   ,12'h0, 5'h6, 5'h2};
        INSTR_MEM[11'h006] = {`inst_ADDI_W ,12'h4, 5'h6, 5'h6};
        INSTR_MEM[11'h007] = {`inst_ADD_W  , 5'h3, 5'h0, 5'h4};
        INSTR_MEM[11'h008] = {`inst_ADD_W  , 5'h2, 5'h0, 5'h3};
        INSTR_MEM[11'h009] = {`inst_ADD_W  , 5'h4, 5'h0, 5'h2};
        INSTR_MEM[11'h00a] = {`inst_BNE    ,16'hfffa, 5'h6, 5'h7};
        INSTR_MEM[11'h00b] = {`inst_BNE    ,16'hffff, 5'h6, 5'h7};
        for(i = 0;i<12;i=i+1)begin
            $display("%08h",INSTR_MEM[i]);
        end
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
        EXPECTED[0] = 32'd2;
        EXPECTED[1] = 32'd3;
        EXPECTED[2] = 32'd5;
        EXPECTED[3] = 32'd8;
        EXPECTED[4] = 32'd13;
        EXPECTED[5] = 32'd21;
        EXPECTED[6] = 32'd34;
        EXPECTED[7] = 32'd55;
        EXPECTED[8] = 32'd89;
        EXPECTED[9] = 32'd144;
        EXPECTED[10] = 32'd233;
        EXPECTED[11] = 32'd377;
        EXPECTED[12] = 32'd610;
        EXPECTED[13] = 32'd987;
        EXPECTED[14] = 32'd1597;
        EXPECTED[15] = 32'd2584;
        EXPECTED[16] = 32'd4181;
        EXPECTED[17] = 32'd6765;
        EXPECTED[18] = 32'd10946;
        EXPECTED[19] = 32'd17711;
        EXPECTED[20] = 32'd28657;
        EXPECTED[21] = 32'd46368;
        EXPECTED[22] = 32'd75025;
        EXPECTED[23] = 32'd121393;
        EXPECTED[24] = 32'd196418;
        EXPECTED[25] = 32'd317811;
        EXPECTED[26] = 32'd514229;
        EXPECTED[27] = 32'd832040;
        EXPECTED[28] = 32'd1346269;
        EXPECTED[29] = 32'd2178309;
        EXPECTED[30] = 32'd3524578;
        EXPECTED[31] = 32'd5702887;
        EXPECTED[32] = 32'd9227465;
        EXPECTED[33] = 32'd14930352;
        EXPECTED[34] = 32'd24157817;
        EXPECTED[35] = 32'd39088169;
        EXPECTED[36] = 32'd63245986;
        EXPECTED[37] = 32'd102334155;
        EXPECTED[38] = 32'd165580141;
        EXPECTED[39] = 32'd267914296;
        EXPECTED[40] = 32'd433494437;
        EXPECTED[41] = 32'd701408733;
        EXPECTED[42] = 32'd1134903170;
        EXPECTED[43] = 32'd1836311903;
        EXPECTED[44] = 32'd2971215073;
        EXPECTED[45] = 32'd512559680;
        EXPECTED[46] = 32'd3483774753;
        EXPECTED[47] = 32'd3996334433;
        EXPECTED[48] = 32'd3185141890;
        EXPECTED[49] = 32'd2886509027;
        EXPECTED[50] = 32'd1776683621;
        EXPECTED[51] = 32'd368225352;
        EXPECTED[52] = 32'd2144908973;
        EXPECTED[53] = 32'd2513134325;
        EXPECTED[54] = 32'd363076002;
        EXPECTED[55] = 32'd2876210327;
        EXPECTED[56] = 32'd3239286329;
        EXPECTED[57] = 32'd1820529360;
        EXPECTED[58] = 32'd764848393;
        EXPECTED[59] = 32'd2585377753;
        EXPECTED[60] = 32'd3350226146;
        EXPECTED[61] = 32'd1640636603;
        EXPECTED[62] = 32'd695895453;
        EXPECTED[63] = 32'd2336532056;

        CHECK_EN[0] = 1'b1;
        CHECK_EN[1] = 1'b1;
        CHECK_EN[2] = 1'b1;
        CHECK_EN[3] = 1'b1;
        CHECK_EN[4] = 1'b1;
        CHECK_EN[5] = 1'b1;
        CHECK_EN[6] = 1'b1;
        CHECK_EN[7] = 1'b1;
        CHECK_EN[8] = 1'b1;
        CHECK_EN[9] = 1'b1;
        CHECK_EN[10] = 1'b1;
        CHECK_EN[11] = 1'b1;
        CHECK_EN[12] = 1'b1;
        CHECK_EN[13] = 1'b1;
        CHECK_EN[14] = 1'b1;
        CHECK_EN[15] = 1'b1;
        CHECK_EN[16] = 1'b1;
        CHECK_EN[17] = 1'b1;
        CHECK_EN[18] = 1'b1;
        CHECK_EN[19] = 1'b1;
        CHECK_EN[20] = 1'b1;
        CHECK_EN[21] = 1'b1;
        CHECK_EN[22] = 1'b1;
        CHECK_EN[23] = 1'b1;
        CHECK_EN[24] = 1'b1;
        CHECK_EN[25] = 1'b1;
        CHECK_EN[26] = 1'b1;
        CHECK_EN[27] = 1'b1;
        CHECK_EN[28] = 1'b1;
        CHECK_EN[29] = 1'b1;
        CHECK_EN[30] = 1'b1;
        CHECK_EN[31] = 1'b1;
        CHECK_EN[32] = 1'b1;
        CHECK_EN[33] = 1'b1;
        CHECK_EN[34] = 1'b1;
        CHECK_EN[35] = 1'b1;
        CHECK_EN[36] = 1'b1;
        CHECK_EN[37] = 1'b1;
        CHECK_EN[38] = 1'b1;
        CHECK_EN[39] = 1'b1;
        CHECK_EN[40] = 1'b1;
        CHECK_EN[41] = 1'b1;
        CHECK_EN[42] = 1'b1;
        CHECK_EN[43] = 1'b1;
        CHECK_EN[44] = 1'b1;
        CHECK_EN[45] = 1'b1;
        CHECK_EN[46] = 1'b1;
        CHECK_EN[47] = 1'b1;
        CHECK_EN[48] = 1'b1;
        CHECK_EN[49] = 1'b1;
        CHECK_EN[50] = 1'b1;
        CHECK_EN[51] = 1'b1;
        CHECK_EN[52] = 1'b1;
        CHECK_EN[53] = 1'b1;
        CHECK_EN[54] = 1'b1;
        CHECK_EN[55] = 1'b1;
        CHECK_EN[56] = 1'b1;
        CHECK_EN[57] = 1'b1;
        CHECK_EN[58] = 1'b1;
        CHECK_EN[59] = 1'b1;
        CHECK_EN[60] = 1'b1;
        CHECK_EN[61] = 1'b1;
        CHECK_EN[62] = 1'b1;
        CHECK_EN[63] = 1'b1;
        
        // 格式: CHECK_EN[地址索引] = 1; EXPECTED[地址索引] = 期望值;
        // 注意: 地址索引 = 物理地址 >> 2 (因 BASERAM_a/EXTRAM_a 已省略低2位)
        // 示例: CHECK_EN[32'h1000 >> 2] = 1; EXPECTED[32'h1000 >> 2] = 32'h12345679;
        /*
        EXPECTED[ >> 2] = ;
        CHECK_EN[ >> 2] = ;
        */
        
    end

    // 指定触发�?查的终止 PC (物理地址) 
    reg [31:0] END_PC_PHYSICAL;
    reg        check_triggered;

    initial begin
        END_PC_PHYSICAL = 32'h1c000100;   // �?后一条指令的物理地址
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
            $finish;
        end
    end


endmodule
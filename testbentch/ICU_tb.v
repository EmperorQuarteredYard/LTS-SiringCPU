`timescale 1ns/1ps

module ICU_tb;

    reg         clk;
    reg         rst;
    reg         RAM_IFU_ready;
    reg         RAM_IFU_valid;
    reg  [31:0] RAM_IFU_rdata;
    reg  [31:0] PC;

    wire        IFU_RAM_valid;
    wire [31:0] IFU_RAM_raddr;
    wire        IFU_RAM_ready;
    wire [31:0] inst;
    wire        valid;
    wire        o_cac_hit;
    wire [ 1:0] IFU_state;

    ICU u_ICU (
        .clk            (clk),
        .rst            (rst),
        .IFU_RAM_valid  (IFU_RAM_valid),
        .IFU_RAM_raddr  (IFU_RAM_raddr),
        .RAM_IFU_ready  (RAM_IFU_ready),
        .RAM_IFU_valid  (RAM_IFU_valid),
        .RAM_IFU_rdata  (RAM_IFU_rdata),
        .IFU_RAM_ready  (IFU_RAM_ready),,
        // .o_cac_hit      (o_cac_hit),
        // .state          (IFU_state)
        .PC             (PC),
        .inst           (inst),
        .valid          (valid)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        RAM_IFU_ready = 0;
        RAM_IFU_valid = 0;
        RAM_IFU_rdata = 0;
        PC = 32'h1c000000;

        #15 rst = 0;
        #10;
        $display("[%t] After reset: valid=%b, IFU_RAM_valid=%b, IFU_RAM_ready=%b, inst=%h",
                 $time, valid, IFU_RAM_valid, IFU_RAM_ready, inst);

        //首次访问 miss，应发起 RAM 请求
        PC = 32'h1c000000;          
        #10;
        $display("[%t] After miss: IFU_RAM_valid=%b, IFU_RAM_raddr=%h, IFU_RAM_ready=%b",
                 $time, IFU_RAM_valid, IFU_RAM_raddr, IFU_RAM_ready);
        RAM_IFU_ready = 1;
        #10;
        RAM_IFU_ready = 0;
        #10;
        $display("[%t] Before data: IFU_RAM_valid=%b, IFU_RAM_ready=%b",
                 $time, IFU_RAM_valid, IFU_RAM_ready);
        RAM_IFU_valid = 1;
        RAM_IFU_rdata = 32'h12345678;
        #10;
        RAM_IFU_valid = 0;
        // 此时 cache 填充完成，状态回到00，且valid应为1
        #10;
        $display("[%t] After fill: valid=%b, inst=%h, PC=%h",
                 $time, valid, inst, PC);

        if (inst == 32'h12345678 && valid == 1)
            $display("[%t] Test 1 PASS: cache fill success", $time);
        else
            $display("[%t] Test 1 FAIL: inst=%h, valid=%b", $time, inst, valid);

        //命中，valid 保持有效
        #20;
        $display("[%t] Hit check: valid=%b, inst=%h", $time, valid, inst);
        if (valid == 1 && inst == 32'h12345678)
            $display("[%t] Test 2 PASS", $time);
        else
            $display("[%t] Test 2 FAIL", $time);

        //不同 tag 的地址 miss
        PC = 32'h1c001000;
        #10;
        $display("[%t] New PC miss: IFU_RAM_valid=%b, IFU_RAM_raddr=%h",
                 $time, IFU_RAM_valid, IFU_RAM_raddr);
        RAM_IFU_ready = 1;
        #12;
        RAM_IFU_ready = 0;
        #8;
        RAM_IFU_valid = 1;
        RAM_IFU_rdata = 32'habcdef00;
        #12;
        RAM_IFU_valid = 0;
        #8;
        $display("[%t] After second fill: valid=%b, inst=%h", $time, valid, inst);
        if (valid == 1 && inst == 32'habcdef00)
            $display("[%t] Test 3 PASS", $time);
        else
            $display("[%t] Test 3 FAIL", $time);

        //复位后状态清零
        rst = 1;
        #20;
        rst = 0;
        #10;
        $display("[%t] After reset again: valid=%b, IFU_RAM_valid=%b", $time, valid, IFU_RAM_valid);
        if (valid == 0)
            $display("[%t] Test 4 PASS", $time);
        else
            $display("[%t] Test 4 FAIL", $time);

        $finish;
    end

endmodule
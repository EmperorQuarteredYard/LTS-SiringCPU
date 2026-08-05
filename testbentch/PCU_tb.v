`timescale 1ns/1ps
`define RST_PC 32'h1c000000

module tb_PCU;

    reg         clk;
    reg         rst;
    wire [31:0] PC;
    reg  [31:0] inst;
    reg         IFU_IDU_handshake;
    wire [ 1:0] PCid;
    reg         PCmis;
    reg  [31:0] PCnew;

    PCU u_PCU (
        .clk                (clk),
        .rst                (rst),
        .PC                 (PC),
        .inst               (inst),
        .IFU_IDU_handshake  (IFU_IDU_handshake),
        .PCid               (PCid),
        .PCmis              (PCmis),
        .PCnew              (PCnew)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        inst = 32'h0;
        IFU_IDU_handshake = 0;
        PCmis = 0;
        PCnew = 32'h0;

        #10; rst = 0; #5;

        // 复位检查
        if (PC !== `RST_PC || PCid !== 2'b00)
            $display("[ERROR] Reset: PC=%h, PCid=%b", PC, PCid);
        else
            $display("[PASS] Reset: PC=%h, PCid=%b", PC, PCid);

        // 非分支 → PC+4
        inst = 32'h00000000;
        IFU_IDU_handshake = 1;
        #10;
        if (PC !== 32'h1c000004 || PCid !== 2'b01)
            $display("[ERROR] Non-branch: PC=%h, PCid=%b", PC, PCid);
        else
            $display("[PASS] Non-branch: PC=%h, PCid=%b", PC, PCid);

        // B +0x10
        inst = {6'b010100, 16'h0004, 10'h000};
        IFU_IDU_handshake = 1;
        #10;
        if (PC !== 32'h1c000014 || PCid !== 2'b10)
            $display("[ERROR] B +0x10: PC=%h, PCid=%b", PC, PCid);
        else
            $display("[PASS] B +0x10: PC=%h, PCid=%b", PC, PCid);

        // BL -0x20
        inst = {6'b010101, 16'hFFF8, 10'h3FF};
        IFU_IDU_handshake = 1;
        #10;
        if (PC !== 32'h1bfffff4 || PCid !== 2'b11)
            $display("[ERROR] BL -0x20: PC=%h, PCid=%b", PC, PCid);
        else
            $display("[PASS] BL -0x20: PC=%h, PCid=%b", PC, PCid);

        // BNE +0x40 (ID回绕)
        inst = {6'b010111, 16'h0010, 10'h000};
        IFU_IDU_handshake = 1;
        #10;
        if (PC !== 32'h1c000034 || PCid !== 2'b00)
            $display("[ERROR] BNE +0x40: PC=%h, PCid=%b", PC, PCid);
        else
            $display("[PASS] BNE +0x40: PC=%h, PCid=%b", PC, PCid);

        // 强制跳转
        PCnew = 32'h1c001000;
        PCmis = 1;
        IFU_IDU_handshake = 1;
        #10;
        if (PC !== 32'h1c001000 || PCid !== 2'b00)
            $display("[ERROR] PCmis: PC=%h, PCid=%b", PC, PCid);
        else
            $display("[PASS] PCmis: PC=%h, PCid=%b", PC, PCid);

        // 连续握手
        PCmis = 0;
        inst = 32'h00000000;
        IFU_IDU_handshake = 1;
        #10;
        if (PC !== 32'h1c001004 || PCid !== 2'b01)
            $display("[ERROR] After mis: PC=%h, PCid=%b", PC, PCid);
        else
            $display("[PASS] After mis: PC=%h, PCid=%b", PC, PCid);

        IFU_IDU_handshake = 1;
        #10;
        if (PC !== 32'h1c001008 || PCid !== 2'b10)
            $display("[ERROR] Second: PC=%h, PCid=%b", PC, PCid);
        else
            $display("[PASS] Second: PC=%h, PCid=%b", PC, PCid);

        // 无握手保持
        IFU_IDU_handshake = 0;
        #10;
        if (PC !== 32'h1c001008 || PCid !== 2'b10)
            $display("[ERROR] No handshake: PC=%h, PCid=%b", PC, PCid);
        else
            $display("[PASS] No handshake: PC=%h, PCid=%b", PC, PCid);

        // 继续握手
        IFU_IDU_handshake = 1;
        #10;
        if (PC !== 32'h1c00100C || PCid !== 2'b11)
            $display("[ERROR] Continue: PC=%h, PCid=%b", PC, PCid);
        else
            $display("[PASS] Continue: PC=%h, PCid=%b", PC, PCid);

        $display("Testbench finished.");
        $finish;
    end

    initial begin
        $dumpfile("tb_PCU.vcd");
        $dumpvars(0, tb_PCU);
    end

endmodule
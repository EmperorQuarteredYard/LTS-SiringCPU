`timescale 1ns/1ps

module IFU_tb;

    reg         clk;
    reg         rst;

    wire        IFU_IDU_valid;
    wire [31:0] IFU_IDU_PC;
    wire [31:0] IFU_IDU_inst;
    wire [ 1:0] IFU_IDU_id;

    reg         IDU_IFU_ready;
    reg         ISU_IFU_PCmis;
    reg  [31:0] ISU_IFU_PCnew;

    wire        IFU_RAM_valid;
    wire [31:0] IFU_RAM_raddr;
    wire        IFU_RAM_ready;

    reg         RAM_IFU_ready;
    reg         RAM_IFU_valid;
    reg  [31:0] RAM_IFU_rdata;

    // 待测 IFU
    IFU u_ifu (
        .clk              (clk),
        .rst              (rst),

        .IFU_IDU_valid    (IFU_IDU_valid),
        .IFU_IDU_PC       (IFU_IDU_PC),
        .IFU_IDU_inst     (IFU_IDU_inst),
        .IFU_IDU_id       (IFU_IDU_id),

        .IDU_IFU_ready    (IDU_IFU_ready),

        .ISU_IFU_PCmis    (ISU_IFU_PCmis),
        .ISU_IFU_PCnew    (ISU_IFU_PCnew),

        .IFU_RAM_valid    (IFU_RAM_valid),
        .IFU_RAM_raddr    (IFU_RAM_raddr),

        .RAM_IFU_ready    (RAM_IFU_ready),

        .RAM_IFU_valid    (RAM_IFU_valid),
        .RAM_IFU_rdata    (RAM_IFU_rdata),

        .IFU_RAM_ready    (IFU_RAM_ready)
    );

    // 时钟 100MHz
    always #5 clk = ~clk;

    // --------------------------------------------------------------------
    // 简单 RAM 行为模型：每次只处理一个读请求，延时 2 拍返回 NOP 指令
    // --------------------------------------------------------------------
    reg [1:0] ram_state;
    reg [1:0] wait_cnt;
    reg [31:0] req_addr;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RAM_IFU_ready <= 1'b1;
            RAM_IFU_valid <= 1'b0;
            RAM_IFU_rdata <= 32'h0;
            ram_state <= 2'b00;
            wait_cnt <= 2'd0;
            req_addr <= 32'h0;
        end else begin
            case (ram_state)
                2'b00: begin  // 空闲，接受请求
                    if (IFU_RAM_valid && RAM_IFU_ready) begin
                        req_addr <= IFU_RAM_raddr;
                        RAM_IFU_ready <= 1'b0;
                        wait_cnt <= 2'd0;
                        ram_state <= 2'b01;
                    end
                end

                2'b01: begin  // 延时 2 拍后返回数据
                    if (wait_cnt == 2'd1) begin
                        RAM_IFU_valid <= 1'b1;
                        RAM_IFU_rdata <= 32'h00000013;   // RISC-V NOP
                        ram_state <= 2'b10;
                    end else begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end
                end

                2'b10: begin  // 等待 IFU 接收数据
                    if (RAM_IFU_valid && IFU_RAM_ready) begin
                        RAM_IFU_valid <= 1'b0;
                        RAM_IFU_ready <= 1'b1;
                        ram_state <= 2'b00;
                    end
                end
            endcase
        end
    end

    // --------------------------------------------------------------------
    // 测试流程
    // --------------------------------------------------------------------
    initial begin
        clk = 1'b0;
        rst = 1'b1;
        IDU_IFU_ready = 1'b0;
        ISU_IFU_PCmis = 1'b0;
        ISU_IFU_PCnew = 32'h0;

        // 复位释放
        #10 rst = 1'b0;

        // 等待第一次取指有效
        @(posedge clk);
        wait(IFU_IDU_valid);

        // 检查复位后 PC = 1c000000
        if (IFU_RAM_raddr !== 32'h1c000000) begin
            $display("Error: initial PC should be 1c000000, got %h", IFU_RAM_raddr);
        end

        // 连续取 8 条指令，每次握手后 PC 应 +4
        repeat (8) begin
            @(posedge clk);
            wait(IFU_IDU_valid);

            $display("PC = %h, inst = %h, valid = %b", IFU_IDU_PC, IFU_IDU_inst, IFU_IDU_valid);

            // 完成一次握手，PCU 更新 PC
            IDU_IFU_ready = 1'b1;
            @(posedge clk);
            IDU_IFU_ready = 1'b0;
        end

        // 测试分支转移：PCmis + PCnew
        @(posedge clk);
        ISU_IFU_PCmis = 1'b1;
        ISU_IFU_PCnew = 32'h1c000100;
        @(posedge clk);
        ISU_IFU_PCmis = 1'b0;

        // 等待取指目标地址
        wait(IFU_RAM_raddr == 32'h1c000100);
        $display("Branch target PC = %h, raddr = %h", ISU_IFU_PCnew, IFU_RAM_raddr);

        // 继续取指观察
        repeat (4) begin
            @(posedge clk);
            wait(IFU_IDU_valid);
            IDU_IFU_ready = 1'b1;
            @(posedge clk);
            IDU_IFU_ready = 1'b0;
        end

        #100;
        $display("Test finished.");
        $finish;
    end

endmodule
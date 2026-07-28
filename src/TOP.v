module TOP(
    input clk,
    input rstn

);
wire rst = !rstn;
wire ram_wen;
wire ram_addr;
wire ram_rdata;
wire ram_wdata;

block_ram block_ram (
    .clka (clk       ),
    .wea  (ram_wen   ),
    .addra(ram_addr  ),
    .dina (ram_wdata ),
    .douta(ram_rdata ) 
);

wire PC;

endmodule
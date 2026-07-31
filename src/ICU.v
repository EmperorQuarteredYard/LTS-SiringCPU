module ICU(
    input clk,
    input rst,

    output        IFU_RAM_valid,
    output [31:0] IFU_RAM_raddr,
    input         RAM_IFU_ready,

    input         RAM_IFU_valid,
    input  [31:0] RAM_IFU_rdata,
    output        IFU_RAM_ready,

    input  [31:0] PC,
    output [31:0] inst,
    output        valid
);
wire [4:0] addr_id;
wire [26:0] addr_tag;
assign {addr_tag, addr_id} = PC;
reg  [31:0] cac_valid;
reg  [26:0] cac_tag   [31:0];
reg  [31:0] cac_inst  [31:0];
reg  [ 1:0] reg_state;//状态机：00表示可用，01表示正在向内存询问，10表示正在向内存取指
wire        cac_hit;
wire [31:0] nxt_cac_valid;
assign cac_hit = (cac_valid[addr_id] && cac_tag[addr_id] == addr_tag);
assign inst    =  cac_inst[addr_id];
assign valid   =  cac_hit && !rst && (reg_state == 2'b00);

assign IFU_RAM_valid = (reg_state == 2'b01) & !rst;
assign IFU_RAM_raddr = PC;
assign IFU_RAM_ready = (reg_state == 2'b10) & !rst;


always @(posedge clk)
begin
	if(rst)
	begin
		reg_state <= 2'b00;
		cac_valid <= 0;
	end
	else
	case(reg_state)
	2'b00:
		if(!cac_hit)
		begin
			reg_state <= 2'b01;
		end
	2'b01:
		if(RAM_IFU_ready)
		begin
			reg_state <= 2'b10;
		end
	2'b10:
		if(RAM_IFU_valid)
		begin
			cac_valid[addr_id] <= 1;
			cac_tag  [addr_id] <= addr_tag;
			cac_inst [addr_id] <= RAM_IFU_rdata;
			reg_state <= 2'b00;
		end
	default:
		reg_state <= 2'b00;
	endcase
end

endmodule
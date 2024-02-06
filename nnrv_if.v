`default_nettype none

module nnrv_if
(
i_clk,
i_rst,

o_pc,
o_rd_en,
o_ce,
i_rom_instr,

o_id_instr
);

/* parameter */

parameter INSTR_WIDTH = 32;
parameter ADDR_WIDTH = 8;
parameter XLEN = 32;

/* port */

input wire i_clk;
input wire i_rst;

output wire [ADDR_WIDTH-1:0] o_pc;
output reg o_rd_en;
output reg o_ce;
input wire [INSTR_WIDTH-1:0] i_rom_instr;

output wire [INSTR_WIDTH-1:0] o_id_instr;

/* local */

reg [ADDR_WIDTH-1:0] pc = {ADDR_WIDTH{1'b0}};
reg [INSTR_WIDTH-1:0] instr = {INSTR_WIDTH{1'b0}};

assign o_pc = pc;
assign o_id_instr = instr;

initial begin
	o_rd_en = 1'h1;
	o_ce = 1'h1;
end

always @ (posedge i_clk) begin
	if (i_rst) begin
		pc <= {ADDR_WIDTH{1'b0}};
	end
	else begin
		pc <= pc + 4;
	end
end

always @ (posedge i_clk or posedge i_rst) begin
	if (i_rst) begin
		instr <= {XLEN{1'b0}};
	end else begin
		instr <= i_rom_instr;
	end
end

endmodule

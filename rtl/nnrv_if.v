`default_nettype none

module nnrv_if
(
i_clk,
i_rst,

o_ram_rd_addr,
o_ram_rd_en,
o_ram_rd_mask,
i_ram_rd_data,

o_id_instr,
o_id_cur_pc,
i_id_jmp_stall,
i_id_jmp_pc,
i_id_hazard_stall
);

/* parameter */

parameter INSTR_WIDTH = 32;
parameter ADDR_WIDTH = 8;
parameter XLEN = 32;

/* port */

input wire i_clk;
input wire i_rst;

output wire [XLEN-1:0] o_ram_rd_addr;
output reg o_ram_rd_en;
output reg [3:0] o_ram_rd_mask;
input wire [INSTR_WIDTH-1:0] i_ram_rd_data;

output wire [INSTR_WIDTH-1:0] o_id_instr;
output wire [XLEN-1:0] o_id_cur_pc;
input wire i_id_jmp_stall;
input wire [XLEN-1:0] i_id_jmp_pc;
input wire i_id_hazard_stall;

/* define */

/* local */

reg [XLEN-1:0] pc = {XLEN{1'b0}};
reg [INSTR_WIDTH-1:0] instr = {INSTR_WIDTH{1'b0}};

reg [XLEN-1:0] cur_pc = {XLEN{1'b0}};

assign o_ram_rd_addr = (i_id_jmp_stall) ? i_id_jmp_pc : (i_id_hazard_stall) ? cur_pc : pc;
assign o_id_instr = instr;
assign o_id_cur_pc = cur_pc;

initial begin
	o_ram_rd_en = 1'b1;
	o_ram_rd_mask = 4'b1111;
end

always @ (posedge i_clk or posedge i_rst) begin
	if (i_rst) begin
		pc <= {XLEN{1'b0}};
	end else if (i_id_jmp_stall) begin
		pc <= i_id_jmp_pc + 4;
	end else if (i_id_hazard_stall) begin
	    pc <= pc;
	end else begin
		pc <= pc + 4;
	end
end

always @ (posedge i_clk or posedge i_rst) begin
	if (i_rst) begin
		instr <= {XLEN{1'b0}};
		cur_pc <= {XLEN{1'b0}};
	end else if (i_id_jmp_stall) begin
	    instr <= i_ram_rd_data;
		cur_pc <= i_id_jmp_pc;
	end else if (i_id_hazard_stall) begin
	    instr <= i_ram_rd_data;
		cur_pc <= cur_pc;
	end else begin
		instr <= i_ram_rd_data;
		cur_pc <= pc;
	end
end

endmodule

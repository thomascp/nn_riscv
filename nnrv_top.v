`default_nettype none

module nnrv_top
(
i_clk,
i_rst
);

/* parameter */

parameter INSTR_WIDTH = 32;
parameter ADDR_WIDTH = 8;
parameter XLEN = 32;

/* port */

input wire i_clk;
input wire i_rst;

/* local */

wire [ADDR_WIDTH-1:0] rom_addr;
wire rom_rd_en;
wire rom_ce;
wire [INSTR_WIDTH-1:0] rom_instr;

wire [INSTR_WIDTH-1:0] if_instr;

wire id_reg_r1_en;
wire id_reg_r2_en;
wire [4:0] id_reg_r1;
wire [XLEN-1:0] id_reg_r1_reg;
wire [4:0] id_reg_r2;
wire [XLEN-1:0] id_reg_r2_reg;

wire [XLEN-1:0] id_exec_op1;
wire [XLEN-1:0] id_exec_op2;
wire [3:0] id_exec_type;
wire [4:0] id_exec_rd;

wire exec_mem_rd_en;
wire [4:0] exec_mem_rd;
wire [XLEN-1:0] exec_mem_rd_reg;

wire mem_wb_rd_en;
wire [4:0] mem_wb_rd;
wire [XLEN-1:0] mem_wb_rd_reg;

wire wb_reg_rd_en;
wire [4:0] wb_reg_rd;
wire [XLEN-1:0] wb_reg_rd_reg;

rom rom (
	.i_addr(rom_addr),
	.i_rd_en(rom_rd_en),
	.i_ce(rom_ce),
	.o_data(rom_instr)
);

nnrv_if nnrv_if (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.o_pc(rom_addr),
	.o_rd_en(rom_rd_en),
	.o_ce(rom_ce),
	.i_rom_instr(rom_instr),
	.o_id_instr(if_instr)
);

nnrv_reg nnrv_reg (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_r1_en(id_reg_r1_en),
	.i_r1(id_reg_r1),
	.i_r2_en(id_reg_r2_en),
	.i_r2(id_reg_r2),
	.i_w_en(wb_reg_rd_en),
	.i_w(wb_reg_rd),
	.i_w_reg(wb_reg_rd_reg),
	.o_r1_reg(id_reg_r1_reg),
	.o_r2_reg(id_reg_r2_reg)
);

nnrv_id nnrv_id (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_if_instr(if_instr),
	.o_exec_op1(id_exec_op1),
	.o_exec_op2(id_exec_op2),
	.o_exec_type(id_exec_type),
	.o_exec_rd(id_exec_rd),
	.o_reg_r1_en(id_reg_r1_en),
	.o_reg_r1(id_reg_r1),
	.i_reg_r1_reg(id_reg_r1_reg),
	.o_reg_r2_en(id_reg_r2_en),
	.o_reg_r2(id_reg_r2),
	.i_reg_r2_reg(id_reg_r2_reg)
);

nnrv_exec nnrv_exec (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_id_op1(id_exec_op1),
	.i_id_op2(id_exec_op2),
	.i_id_exec_type(id_exec_type),
	.i_id_rd(id_exec_rd),
	.o_mem_rd_en(exec_mem_rd_en),
	.o_mem_rd(exec_mem_rd),
	.o_mem_rd_reg(exec_mem_rd_reg)
);

nnrv_mem nnrv_mem (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_exec_rd_en(exec_mem_rd_en),
	.i_exec_rd(exec_mem_rd),
	.i_exec_rd_reg(exec_mem_rd_reg),
	.o_wb_rd_en(mem_wb_rd_en),
	.o_wb_rd(mem_wb_rd),
	.o_wb_rd_reg(mem_wb_rd_reg)
);

nnrv_wb nnrv_wb (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_mem_rd_en(mem_wb_rd_en),
	.i_mem_rd(mem_wb_rd),
	.i_mem_rd_reg(mem_wb_rd_reg),
	.o_reg_w_en(wb_reg_rd_en),
	.o_reg_w(wb_reg_rd),
	.o_reg_w_reg(wb_reg_rd_reg)
);


endmodule
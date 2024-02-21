`default_nettype none

module nnrv_top
# (
parameter INSTR_WIDTH = 32,
parameter ADDR_WIDTH = 8,
parameter XLEN = 32
)
(
input wire i_clk,
input wire i_rst,
output wire o_led
);

/* local */

wire [XLEN-1:0] ram_rd1_addr;
wire ram_rd1_en;
wire [3:0] ram_rd1_mask;
wire [INSTR_WIDTH-1:0] ram_rd1_data;
wire [XLEN-1:0] ram_rd2_addr;
wire ram_rd2_en;
wire [3:0] ram_rd2_mask;
wire [INSTR_WIDTH-1:0] ram_rd2_data;
wire [XLEN-1:0] ram_wr_addr;
wire ram_wr_en;
wire [3:0] ram_wr_mask;
wire [INSTR_WIDTH-1:0] ram_wr_data;

wire [INSTR_WIDTH-1:0] if_instr;
wire [XLEN-1:0] if_cur_pc;

wire id_reg_r1_en;
wire id_reg_r2_en;
wire [4:0] id_reg_r1;
wire [XLEN-1:0] id_reg_r1_reg;
wire [4:0] id_reg_r2;
wire [XLEN-1:0] id_reg_r2_reg;

wire id_jmp_stall;
wire [XLEN-1:0] id_jmp_pc;
wire [XLEN-1:0] id_exec_op1;
wire [XLEN-1:0] id_exec_op2;
wire [3:0] id_exec_type;
wire [4:0] id_exec_rd;
wire id_exec_rd_en;
wire [3:0] id_exec_ram_mask;
wire id_exec_sign;
wire [XLEN-1:0] i_id_pc;

wire exec_mem_rd_en;
wire [4:0] exec_mem_rd;
wire [XLEN-1:0] exec_mem_rd_reg;
wire exec_mem_ram_wr_en;
wire exec_mem_ram_rd_en;
wire [XLEN-1:0] exec_mem_ram_addr;
wire [XLEN-1:0] exec_mem_ram_data;
wire [3:0] exec_mem_ram_mask;
wire exec_mem_sign;
wire exec_id_hazard_stall;
wire exec_id_rd_en;
wire exec_id_rd_ready;
wire [4:0] exec_id_rd;
wire [XLEN-1:0] exec_id_rd_reg;

wire mem_wb_rd_en;
wire [4:0] mem_wb_rd;
wire [XLEN-1:0] mem_wb_rd_reg;
wire mem_id_rd_en;
wire mem_id_rd_ready;
wire [4:0] mem_id_rd;
wire [XLEN-1:0] mem_id_rd_reg;

wire wb_reg_rd_en;
wire [4:0] wb_reg_rd;
wire [XLEN-1:0] wb_reg_rd_reg;

assign o_led = ram.ram[40][28];

ram ram (
    .i_clk(i_clk),
    .i_rd1_addr(ram_rd1_addr[ADDR_WIDTH-1:0]),
    .i_rd1_en(ram_rd1_en),
    .i_rd1_mask(ram_rd1_mask),
    .o_rd1_data(ram_rd1_data),
    .i_rd2_addr(ram_rd2_addr[ADDR_WIDTH-1:0]),
    .i_rd2_en(ram_rd2_en),
    .i_rd2_mask(ram_rd2_mask),
    .o_rd2_data(ram_rd2_data),
    .i_wr_addr(ram_wr_addr[ADDR_WIDTH-1:0]),
    .i_wr_en(ram_wr_en),
    .i_wr_mask(ram_wr_mask),
    .i_wr_data(ram_wr_data)
);

nnrv_if nnrv_if (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .o_ram_rd_addr(ram_rd1_addr),
    .o_ram_rd_en(ram_rd1_en),
    .o_ram_rd_mask(ram_rd1_mask),
    .i_ram_rd_data(ram_rd1_data),
    .o_id_instr(if_instr),
    .o_id_cur_pc(if_cur_pc),
    .i_id_jmp_stall(id_jmp_stall),
    .i_id_jmp_pc(id_jmp_pc),
    .i_id_hazard_stall(exec_id_hazard_stall)
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
    .i_if_pc(if_cur_pc),
    .o_if_jmp_stall(id_jmp_stall),
    .o_if_jmp_pc(id_jmp_pc),
    .o_if_hazard_stall(exec_id_hazard_stall),
    .o_exec_pc(i_id_pc),
    .o_exec_op1(id_exec_op1),
    .o_exec_op2(id_exec_op2),
    .o_exec_type(id_exec_type),
    .o_exec_rd_en(id_exec_rd_en),
    .o_exec_rd(id_exec_rd),
    .o_exec_ram_mask(id_exec_ram_mask),
    .o_exec_sign(id_exec_sign),
    .o_reg_r1_en(id_reg_r1_en),
    .o_reg_r1(id_reg_r1),
    .i_reg_r1_reg(id_reg_r1_reg),
    .o_reg_r2_en(id_reg_r2_en),
    .o_reg_r2(id_reg_r2),
    .i_reg_r2_reg(id_reg_r2_reg),
    .i_exec_rd_en(exec_id_rd_en),
    .i_exec_rd_ready(exec_id_rd_ready),
    .i_exec_rd(exec_id_rd),
    .i_exec_rd_reg(exec_id_rd_reg),
    .i_mem_rd_en(mem_id_rd_en),
    .i_mem_rd_ready(mem_id_rd_ready),
    .i_mem_rd(mem_id_rd),
    .i_mem_rd_reg(mem_id_rd_reg)
);

nnrv_exec nnrv_exec (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_id_op1(id_exec_op1),
    .i_id_op2(id_exec_op2),
    .i_id_exec_type(id_exec_type),
    .i_id_ram_mask(id_exec_ram_mask),
    .i_id_sign(id_exec_sign),
    .i_id_rd(id_exec_rd),
    .i_id_rd_en(id_exec_rd_en),
    .i_id_pc(i_id_pc),
    .o_id_rd_en(exec_id_rd_en),
    .o_id_rd_ready(exec_id_rd_ready),
    .o_id_rd(exec_id_rd),
    .o_id_rd_reg(exec_id_rd_reg),
    .o_mem_rd_en(exec_mem_rd_en),
    .o_mem_rd(exec_mem_rd),
    .o_mem_rd_reg(exec_mem_rd_reg),
    .o_mem_ram_wr_en(exec_mem_ram_wr_en),
    .o_mem_ram_rd_en(exec_mem_ram_rd_en),
    .o_mem_ram_addr(exec_mem_ram_addr),
    .o_mem_ram_data(exec_mem_ram_data),
    .o_mem_ram_mask(exec_mem_ram_mask),
    .o_mem_sign(exec_mem_sign)
);

nnrv_mem nnrv_mem (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .o_id_rd_en(mem_id_rd_en),
    .o_id_rd_ready(mem_id_rd_ready),
    .o_id_rd(mem_id_rd),
    .o_id_rd_reg(mem_id_rd_reg),
    .i_exec_rd_en(exec_mem_rd_en),
    .i_exec_rd(exec_mem_rd),
    .i_exec_rd_reg(exec_mem_rd_reg),
    .i_exec_ram_wr_en(exec_mem_ram_wr_en),
    .i_exec_ram_rd_en(exec_mem_ram_rd_en),
    .i_exec_ram_addr(exec_mem_ram_addr),
    .i_exec_ram_data(exec_mem_ram_data),
    .i_exec_ram_mask(exec_mem_ram_mask),
    .i_exec_sign(exec_mem_sign),
    .o_ram_rd_addr(ram_rd2_addr),
    .o_ram_rd_en(ram_rd2_en),
    .o_ram_rd_mask(ram_rd2_mask),
    .i_ram_rd_data(ram_rd2_data),
    .o_ram_wr_addr(ram_wr_addr),
    .o_ram_wr_en(ram_wr_en),
    .o_ram_wr_mask(ram_wr_mask),
    .o_ram_wr_data(ram_wr_data),
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
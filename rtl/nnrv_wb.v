`default_nettype none

module nnrv_wb
# (
parameter XLEN = 64
)
(
input wire i_clk,
input wire i_rst,

input wire i_mem_rd_en,
input wire [4:0] i_mem_rd,
input wire [XLEN-1:0] i_mem_rd_reg,

output wire o_reg_w_en,
output wire [4:0] o_reg_w,
output wire [XLEN-1:0] o_reg_w_reg
);

/* define */


/* local */

assign o_reg_w_en = i_mem_rd_en;
assign o_reg_w = i_mem_rd;
assign o_reg_w_reg = i_mem_rd_reg;

endmodule

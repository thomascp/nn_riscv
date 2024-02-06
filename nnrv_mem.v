`default_nettype none

module nnrv_mem
(
i_clk,
i_rst,

i_exec_rd_en,
i_exec_rd,
i_exec_rd_reg,

o_wb_rd_en,
o_wb_rd,
o_wb_rd_reg
);

/* parameter */

parameter INSTR_WIDTH = 32;
parameter XLEN = 32;

/* port */

input wire i_clk;
input wire i_rst;

input wire i_exec_rd_en;
input wire [4:0] i_exec_rd;
input wire [XLEN-1:0] i_exec_rd_reg;
output wire o_wb_rd_en;
output wire [4:0] o_wb_rd;
output wire [XLEN-1:0] o_wb_rd_reg;

/* define */

/* local */

reg rd_en = 1'b0;
reg [4:0] rd = 5'b0;
reg [XLEN-1:0] rd_reg = {XLEN{1'b0}};

assign o_wb_rd_en = rd_en;
assign o_wb_rd = rd;
assign o_wb_rd_reg = rd_reg;


always @ (posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        rd_en <= 1'b0;
        rd <= 5'b0;
        rd_reg = {XLEN{1'b0}};
    end else begin
        rd_en <= i_exec_rd_en;
        rd <= i_exec_rd;
        rd_reg = i_exec_rd_reg;
    end
end

endmodule

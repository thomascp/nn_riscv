`default_nettype none

module nnrv_exec
(
i_clk,
i_rst,

i_id_op1,
i_id_op2,
i_id_exec_type,

i_id_rd,

o_mem_rd_en,
o_mem_rd,
o_mem_rd_reg
);

/* parameter */

parameter INSTR_WIDTH = 32;
parameter XLEN = 32;

/* port */

input wire i_clk;
input wire i_rst;

input wire [XLEN-1:0] i_id_op1;
input wire [XLEN-1:0] i_id_op2;
input wire [3:0] i_id_exec_type;

input wire [4:0] i_id_rd;

output wire o_mem_rd_en;
output wire [4:0] o_mem_rd;
output wire [XLEN-1:0] o_mem_rd_reg;

/* define */

`define OP_ADD          4'b0001
`define OP_SUB          4'b0010
`define OP_SLT          4'b0011
`define OP_SLTU         4'b0100
`define OP_XOR          4'b0101
`define OP_OR           4'b0110
`define OP_AND          4'b0111
`define OP_SLL          4'b1000
`define OP_SRL          4'b1001
`define OP_SRA          4'b1010

/* local */

reg rd_en = 1'b0;
reg [4:0] rd = 5'b0;
reg [XLEN-1:0] rd_reg = {XLEN{1'b0}};

/* logic */

assign o_mem_rd_en = rd_en;
assign o_mem_rd = rd;
assign o_mem_rd_reg = rd_reg;

always @ (posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        rd_reg <= {XLEN{1'b0}};
        rd_en <= 1'b0;
        rd <= 5'b0;
    end else begin
        rd <= i_id_rd;
        case(i_id_exec_type)
        `OP_SUB  : begin
                   rd_reg <= i_id_op1 - i_id_op2;
                   rd_en <= 1'b1;
                   end
        `OP_ADD  : begin
                   rd_reg <= (i_id_op1 + i_id_op2);
                   rd_en <= 1'b1;
                   end
        `OP_SLT  : begin
                   rd_reg <= ($signed(i_id_op1) < $signed(i_id_op2));
                   rd_en <= 1'b1;
                   end
        `OP_SLTU : begin
                   rd_reg <= (i_id_op1 < i_id_op2);
                   rd_en <= 1'b1;
                   end
        `OP_XOR  : begin
                   rd_reg <= i_id_op1 ^ i_id_op2;
                   rd_en <= 1'b1;
                   end
        `OP_OR   : begin
                   rd_reg <= i_id_op1 | i_id_op2;
                   rd_en <= 1'b1;
                   end
        `OP_AND  : begin
                   rd_reg <= i_id_op1 & i_id_op2;
                   rd_en <= 1'b1;
                   end
        `OP_SLL  : begin
                   rd_reg <= i_id_op1 << i_id_op2;
                   rd_en <= 1'b1;
                   end
        `OP_SRL  : begin
                   rd_reg <= i_id_op1 << i_id_op2;
                   rd_en <= 1'b1;
                   end
        `OP_SRA  : begin
                   rd_reg <= i_id_op1 >>> i_id_op2;
                   rd_en <= 1'b1;
                   end
        default  : begin
                   rd_reg <= {XLEN{1'b0}};
                   rd_en <= 1'b0;
                   end
        endcase

    end
end

endmodule
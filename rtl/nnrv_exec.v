`default_nettype none

module nnrv_exec
(
i_clk,
i_rst,

i_id_op1,
i_id_op2,
i_id_exec_type,
i_id_ram_mask,
i_id_sign,

i_id_rd,
i_id_rd_en,
i_id_pc,

o_id_rd_en,
o_id_rd_ready,
o_id_rd,
o_id_rd_reg,

o_mem_rd_en,
o_mem_rd,
o_mem_rd_reg,
o_mem_ram_wr_en,
o_mem_ram_rd_en,
o_mem_ram_addr,
o_mem_ram_data,
o_mem_ram_mask,
o_mem_sign
);

/* parameter */

parameter XLEN = 32;
parameter ADDR_WIDTH = 8;

/* port */

input wire i_clk;
input wire i_rst;

input wire [XLEN-1:0] i_id_op1;
input wire [XLEN-1:0] i_id_op2;
input wire [3:0] i_id_exec_type;
input wire [3:0] i_id_ram_mask;
input wire i_id_sign;

input wire [4:0] i_id_rd;
input wire i_id_rd_en;
input wire [XLEN-1:0] i_id_pc;

output wire o_id_rd_en;
output wire o_id_rd_ready;
output wire [4:0] o_id_rd;
output wire [XLEN-1:0] o_id_rd_reg;

output wire o_mem_rd_en;
output wire [4:0] o_mem_rd;
output wire [XLEN-1:0] o_mem_rd_reg;

output wire o_mem_ram_wr_en;
output wire o_mem_ram_rd_en;
output wire [XLEN-1:0] o_mem_ram_addr;
output wire [XLEN-1:0] o_mem_ram_data;
output wire [3:0] o_mem_ram_mask;
output wire o_mem_sign;

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
`define OP_JMP          4'b1011
`define OP_LOAD         4'b1100
`define OP_STORE        4'b1101

/* local */

reg rd_en = 1'b0;
reg [4:0] rd = 5'b0;
reg [XLEN-1:0] rd_reg = {XLEN{1'b0}};

wire [XLEN-1:0] ram_full_mask;
wire [1:0] op2_shift;
wire [4:0] op2_full_shift;

reg mem_ram_wr_en;
reg mem_ram_rd_en;
reg [XLEN-1:0] mem_ram_addr;
reg [XLEN-1:0] mem_ram_data;
reg [3:0] mem_ram_mask;
reg mem_sign;

reg rd_ready = 1'b0;

/* logic */

assign o_mem_rd_en = rd_en;
assign o_mem_rd = rd;
assign o_mem_rd_reg = rd_reg;

assign ram_full_mask = {{8{i_id_ram_mask[3]}}, {8{i_id_ram_mask[2]}}, {8{i_id_ram_mask[1]}}, {8{i_id_ram_mask[0]}}};
assign op2_shift = i_id_op2[1:0];
assign op2_full_shift = {3'b000, op2_shift} << 3;

assign o_mem_ram_wr_en = mem_ram_wr_en;
assign o_mem_ram_rd_en = mem_ram_rd_en;
assign o_mem_ram_addr = mem_ram_addr;
assign o_mem_ram_data = mem_ram_data;
assign o_mem_ram_mask = mem_ram_mask;
assign o_mem_sign = mem_sign;

assign o_id_rd_en = rd_en;
assign o_id_rd_ready = rd_ready;
assign o_id_rd = rd;
assign o_id_rd_reg = rd_reg;

always @ (posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        rd_reg <= {XLEN{1'b0}};
        rd_en <= 1'b0;
        rd <= 5'b0;
        rd_ready <= 1'b0;
        mem_ram_rd_en <= 1'b0;
        mem_ram_wr_en <= 1'b0;
        mem_ram_addr <= 0;
        mem_ram_mask <= 0;
        mem_sign <= 0;
        mem_ram_data <= 0;
    end else begin
        rd <= i_id_rd;
        rd_en <= i_id_rd_en;
        case(i_id_exec_type)
        `OP_SUB  : begin
                   rd_reg <= i_id_op1 - i_id_op2;
                   rd_ready <= 1'b1;
                   end
        `OP_ADD  : begin
                   rd_reg <= (i_id_op1 + i_id_op2);
                   rd_ready <= 1'b1;
                   end
        `OP_SLT  : begin
                   rd_reg <= ($signed(i_id_op1) < $signed(i_id_op2));
                   rd_ready <= 1'b1;
                   end
        `OP_SLTU : begin
                   rd_reg <= (i_id_op1 < i_id_op2);
                   rd_ready <= 1'b1;
                   end
        `OP_XOR  : begin
                   rd_reg <= i_id_op1 ^ i_id_op2;
                   rd_ready <= 1'b1;
                   end
        `OP_OR   : begin
                   rd_reg <= i_id_op1 | i_id_op2;
                   rd_ready <= 1'b1;
                   end
        `OP_AND  : begin
                   rd_reg <= i_id_op1 & i_id_op2;
                   rd_ready <= 1'b1;
                   end
        `OP_SLL  : begin
                   rd_reg <= i_id_op1 << i_id_op2;
                   rd_ready <= 1'b1;
                   end
        `OP_SRL  : begin
                   rd_reg <= i_id_op1 >> i_id_op2;
                   rd_ready <= 1'b1;
                   end
        `OP_SRA  : begin
                   rd_reg <= $signed(i_id_op1) >>> i_id_op2;
                   rd_ready <= 1'b1;
                   end
        `OP_JMP  : begin
                   rd_reg <= i_id_pc + 4;
                   rd_ready <= 1'b1;
                   end
        `OP_LOAD : begin
                   mem_ram_rd_en <= 1'b1;
                   mem_ram_wr_en <= 1'b0;
                   mem_ram_addr <= i_id_op2;
                   mem_ram_mask <= i_id_ram_mask << op2_shift;
                   mem_sign <= i_id_sign;
                   rd_ready <= 1'b0;
                   end
        `OP_STORE: begin
                   mem_ram_rd_en <= 1'b0;
                   mem_ram_wr_en <= 1'b1;
                   mem_ram_addr <= i_id_op2;
                   mem_ram_data <= (i_id_op1 & ram_full_mask) << op2_full_shift;
                   mem_ram_mask <= i_id_ram_mask << op2_shift;
                   mem_sign <= i_id_sign;
                   rd_ready <= 1'b0;
                   end
        default  : begin
                   rd_reg <= {XLEN{1'b0}};
                   mem_ram_rd_en <= 1'b0;
                   mem_ram_wr_en <= 1'b0;
                   rd_ready <= 1'b0;
                   end
        endcase

    end
end

endmodule

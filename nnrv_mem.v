`default_nettype none

module nnrv_mem
(
i_clk,
i_rst,

o_id_rd_en,
o_id_rd_ready,
o_id_rd,
o_id_rd_reg,

i_exec_rd_en,
i_exec_rd,
i_exec_rd_reg,
i_exec_ram_wr_en,
i_exec_ram_rd_en,
i_exec_ram_addr,
i_exec_ram_data,
i_exec_ram_mask,
i_exec_sign,

o_ram_rd_addr,
o_ram_rd_en,
o_ram_rd_mask,
i_ram_rd_data,

o_ram_wr_addr,
o_ram_wr_en,
o_ram_wr_mask,
o_ram_wr_data,

o_wb_rd_en,
o_wb_rd,
o_wb_rd_reg
);

/* parameter */

parameter XLEN = 32;

/* port */

input wire i_clk;
input wire i_rst;

output wire o_id_rd_en;
output wire o_id_rd_ready;
output wire [4:0] o_id_rd;
output wire [XLEN-1:0] o_id_rd_reg;

input wire i_exec_rd_en;
input wire [4:0] i_exec_rd;
input wire [XLEN-1:0] i_exec_rd_reg;

input wire i_exec_ram_wr_en;
input wire i_exec_ram_rd_en;
input wire [XLEN-1:0] i_exec_ram_addr;
input wire [XLEN-1:0] i_exec_ram_data;
input wire [3:0] i_exec_ram_mask;
input wire i_exec_sign;

output wire [XLEN-1:0] o_ram_rd_addr;
output wire o_ram_rd_en;
output wire [3:0] o_ram_rd_mask;
input wire [XLEN-1:0] i_ram_rd_data;

output wire [XLEN-1:0] o_ram_wr_addr;
output wire o_ram_wr_en;
output wire [3:0] o_ram_wr_mask;
output wire [XLEN-1:0] o_ram_wr_data;

output wire o_wb_rd_en;
output wire [4:0] o_wb_rd;
output wire [XLEN-1:0] o_wb_rd_reg;

/* define */

/* local */

reg rd_en = 1'b0;
reg [4:0] rd = 5'b0;
reg [XLEN-1:0] rd_reg = {XLEN{1'b0}};
reg [XLEN-1:0] rd_reg_exec = {XLEN{1'b0}};
reg [XLEN-1:0] rd_reg_nosign = {XLEN{1'b0}};

reg [4:0] mask_bits = 0;
reg [4:0] right_shift = 0;

reg rd_ready = 1'b0;

reg ram_rd_en = 1'b0;
reg sign = 1'b0;

assign o_wb_rd_en = rd_en;
assign o_wb_rd = rd;
assign o_wb_rd_reg = rd_reg;

assign o_ram_rd_en = i_exec_ram_rd_en;
assign o_ram_rd_addr = i_exec_ram_addr;
assign o_ram_rd_mask = i_exec_ram_mask;

assign o_ram_wr_en = i_exec_ram_wr_en;
assign o_ram_wr_addr = i_exec_ram_addr;
assign o_ram_wr_mask = i_exec_ram_mask;
assign o_ram_wr_data = i_exec_ram_data;

assign o_id_rd_en = rd_en;
assign o_id_rd_ready = rd_ready;
assign o_id_rd = rd;
assign o_id_rd_reg = rd_reg;

always @ * begin
    if (o_ram_rd_mask[0] == 1'b1) begin
        right_shift = 0;
    end else if (o_ram_rd_mask[1:0] == 2'b10) begin
        right_shift = 8;
    end else if (o_ram_rd_mask[2:0] == 3'b100) begin
        right_shift = 16;
    end else if (o_ram_rd_mask[3:0] == 4'b1000) begin
        right_shift = 24;
    end else begin
        right_shift = 0;
    end
end

always @ * begin
    rd_reg = {XLEN{1'b0}};
    if (ram_rd_en) begin
        if (sign) begin
            case (mask_bits)
                8:  rd_reg = {{24{rd_reg_nosign[7]}}, rd_reg_nosign[7:0]};
                16: rd_reg = {{16{rd_reg_nosign[15]}}, rd_reg_nosign[15:0]};
                default: rd_reg = rd_reg_nosign;
            endcase
        end else begin
            rd_reg = rd_reg_nosign;
        end
    end else begin
        rd_reg = rd_reg_exec;
    end
end

always @ (posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        rd_en <= 1'b0;
        rd <= 5'b0;
        rd_reg <= {XLEN{1'b0}};
        rd_reg_exec <= {XLEN{1'b0}};
        rd_ready <= 1'b0;
        ram_rd_en <= 1'b0;
        sign <= 1'b0;
    end else begin
        rd_en <= i_exec_rd_en;
        rd <= i_exec_rd;
        ram_rd_en <= i_exec_ram_rd_en;
        sign <= i_exec_sign;
        if (i_exec_ram_rd_en) begin
            case(i_exec_ram_mask)
                4'b0001, 4'b0010, 4'b0100, 4'b1000 : mask_bits <= 8;
                4'b0011, 4'b0110, 4'b1100          : mask_bits <= 16;
                default : mask_bits <= 32;
            endcase
            rd_reg_nosign <= (i_ram_rd_data >> right_shift);
            rd_ready <= 1'b1;
        end else begin
            rd_reg_exec <= i_exec_rd_reg;
            rd_ready <= 1'b1;
        end
    end
end

endmodule

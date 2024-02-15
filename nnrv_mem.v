`default_nettype none

module nnrv_mem
(
i_clk,
i_rst,

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
reg [XLEN-1:0] rd_reg_tmp = {XLEN{1'b0}};

reg [4:0] left_shift;
reg [4:0] right_shift;

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

always @ * begin
    if (o_ram_rd_mask[3] == 1'b1) begin
        left_shift = 0;
    end else if (o_ram_rd_mask[3:2] == 2'b01) begin
        left_shift = 8;
    end else if (o_ram_rd_mask[3:1] == 3'b001) begin
        left_shift = 16;
    end else if (o_ram_rd_mask[3:0] == 4'b0001) begin
        left_shift = 24;
    end else begin
        left_shift = 0;
    end
end

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

always @ (posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        rd_en <= 1'b0;
        rd <= 5'b0;
        rd_reg <= {XLEN{1'b0}};
    end else begin
        rd_en <= i_exec_rd_en;
        rd <= i_exec_rd;
        if (o_ram_rd_en) begin
            if (i_exec_sign) begin
                rd_reg <= ((i_ram_rd_data << left_shift) >>> (right_shift + left_shift));
            end else begin
                rd_reg <= (i_ram_rd_data >> right_shift);
            end
        end else begin
            rd_reg <= i_exec_rd_reg;
        end
    end
end

endmodule

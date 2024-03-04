`default_nettype none

module nnrv_mem
# (
parameter XLEN = 64,
parameter MASK_WIDTH = 8
)
(
input wire i_clk,
input wire i_rst,

output wire o_id_rd_en,
output wire o_id_rd_ready,
output wire [4:0] o_id_rd,
output wire [XLEN-1:0] o_id_rd_reg,

input wire i_exec_rd_en,
input wire [4:0] i_exec_rd,
input wire [XLEN-1:0] i_exec_rd_reg,

input wire i_exec_ram_wr_en,
input wire i_exec_ram_rd_en,
input wire [XLEN-1:0] i_exec_ram_addr,
input wire [XLEN-1:0] i_exec_ram_data,
input wire [MASK_WIDTH-1:0] i_exec_ram_mask,
input wire i_exec_sign,

output wire [XLEN-1:0] o_ram_rd_addr,
output wire o_ram_rd_en,
output wire [MASK_WIDTH-1:0] o_ram_rd_mask,
input wire [XLEN-1:0] i_ram_rd_data,

output wire [XLEN-1:0] o_ram_wr_addr,
output wire o_ram_wr_en,
output wire [MASK_WIDTH-1:0] o_ram_wr_mask,
output wire [XLEN-1:0] o_ram_wr_data,

output wire o_wb_rd_en,
output wire [4:0] o_wb_rd,
output wire [XLEN-1:0] o_wb_rd_reg
);

/* define */

/* local */

reg rd_en = 1'b0;
reg [4:0] rd = 5'b0;
reg [XLEN-1:0] rd_reg = {XLEN{1'b0}};

reg rd_ready = 1'b0;

reg ram_rd_en = 1'b0;

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

always @ (posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        rd_en <= 1'b0;
        rd <= 5'b0;
        rd_reg <= 0;
        rd_ready <= 1'b0;
        ram_rd_en <= 1'b0;
    end else begin
        rd_en <= i_exec_rd_en;
        rd <= i_exec_rd;
        ram_rd_en <= i_exec_ram_rd_en;
        if (i_exec_ram_rd_en) begin
            case(i_exec_ram_mask)
                8'b00000001:
                        if (i_exec_sign) begin
                            rd_reg <= {{56{i_ram_rd_data[7]}}, i_ram_rd_data[7:0]};
                        end else begin
                            rd_reg <= {56'b0, i_ram_rd_data[7:0]};
                        end
                8'b00000010:
                        if (i_exec_sign) begin
                            rd_reg <= {{56{i_ram_rd_data[15]}}, i_ram_rd_data[15:8]};
                        end else begin
                            rd_reg <= {56'b0, i_ram_rd_data[15:8]};
                        end
                8'b00000100:
                        if (i_exec_sign) begin
                            rd_reg <= {{56{i_ram_rd_data[23]}}, i_ram_rd_data[23:16]};
                        end else begin
                            rd_reg <= {56'b0, i_ram_rd_data[23:16]};
                        end
                8'b00001000:
                        if (i_exec_sign) begin
                            rd_reg <= {{56{i_ram_rd_data[31]}}, i_ram_rd_data[31:24]};
                        end else begin
                            rd_reg <= {56'b0, i_ram_rd_data[31:24]};
                        end
                8'b00010000:
                        if (i_exec_sign) begin
                            rd_reg <= {{56{i_ram_rd_data[39]}}, i_ram_rd_data[39:32]};
                        end else begin
                            rd_reg <= {56'b0, i_ram_rd_data[39:32]};
                        end
                8'b00100000:
                        if (i_exec_sign) begin
                            rd_reg <= {{56{i_ram_rd_data[47]}}, i_ram_rd_data[47:40]};
                        end else begin
                            rd_reg <= {56'b0, i_ram_rd_data[47:40]};
                        end
                8'b01000000:
                        if (i_exec_sign) begin
                            rd_reg <= {{56{i_ram_rd_data[55]}}, i_ram_rd_data[55:48]};
                        end else begin
                            rd_reg <= {56'b0, i_ram_rd_data[55:48]};
                        end
                8'b10000000:
                        if (i_exec_sign) begin
                            rd_reg <= {{56{i_ram_rd_data[63]}}, i_ram_rd_data[63:56]};
                        end else begin
                            rd_reg <= {56'b0, i_ram_rd_data[63:56]};
                        end
                8'b00000011:
                        if (i_exec_sign) begin
                            rd_reg <= {{48{i_ram_rd_data[15]}}, i_ram_rd_data[15:0]};
                        end else begin
                            rd_reg <= {48'b0, i_ram_rd_data[15:0]};
                        end
                8'b00000110:
                        if (i_exec_sign) begin
                            rd_reg <= {{48{i_ram_rd_data[23]}}, i_ram_rd_data[23:8]};
                        end else begin
                            rd_reg <= {48'b0, i_ram_rd_data[23:8]};
                        end
                8'b00001100:
                        if (i_exec_sign) begin
                            rd_reg <= {{48{i_ram_rd_data[31]}}, i_ram_rd_data[31:16]};
                        end else begin
                            rd_reg <= {48'b0, i_ram_rd_data[31:16]};
                        end
                8'b00011000:
                        if (i_exec_sign) begin
                            rd_reg <= {{48{i_ram_rd_data[39]}}, i_ram_rd_data[39:24]};
                        end else begin
                            rd_reg <= {48'b0, i_ram_rd_data[39:24]};
                        end
                8'b00110000:
                        if (i_exec_sign) begin
                            rd_reg <= {{48{i_ram_rd_data[47]}}, i_ram_rd_data[47:32]};
                        end else begin
                            rd_reg <= {48'b0, i_ram_rd_data[47:32]};
                        end
                8'b01100000:
                        if (i_exec_sign) begin
                            rd_reg <= {{48{i_ram_rd_data[55]}}, i_ram_rd_data[55:40]};
                        end else begin
                            rd_reg <= {48'b0, i_ram_rd_data[55:40]};
                        end
                8'b11000000:
                        if (i_exec_sign) begin
                            rd_reg <= {{48{i_ram_rd_data[63]}}, i_ram_rd_data[63:48]};
                        end else begin
                            rd_reg <= {48'b0, i_ram_rd_data[63:48]};
                        end
                8'b00001111:
                        if (i_exec_sign) begin
                            rd_reg <= {{32{i_ram_rd_data[31]}}, i_ram_rd_data[31:0]};
                        end else begin
                            rd_reg <= {32'b0, i_ram_rd_data[31:0]};
                        end
                8'b00011110:
                        if (i_exec_sign) begin
                            rd_reg <= {{32{i_ram_rd_data[39]}}, i_ram_rd_data[39:8]};
                        end else begin
                            rd_reg <= {32'b0, i_ram_rd_data[39:8]};
                        end
                8'b00111100:
                        if (i_exec_sign) begin
                            rd_reg <= {{32{i_ram_rd_data[47]}}, i_ram_rd_data[47:16]};
                        end else begin
                            rd_reg <= {32'b0, i_ram_rd_data[47:16]};
                        end
                8'b01111000:
                        if (i_exec_sign) begin
                            rd_reg <= {{32{i_ram_rd_data[55]}}, i_ram_rd_data[55:24]};
                        end else begin
                            rd_reg <= {32'b0, i_ram_rd_data[55:24]};
                        end
                8'b11110000:
                        if (i_exec_sign) begin
                            rd_reg <= {{32{i_ram_rd_data[63]}}, i_ram_rd_data[63:32]};
                        end else begin
                            rd_reg <= {32'b0, i_ram_rd_data[63:32]};
                        end
                8'b11111111:
                        rd_reg <= i_ram_rd_data;
                default:
                        rd_reg <= i_ram_rd_data;
            endcase
            rd_ready <= 1'b1;
        end else begin
            rd_reg <= i_exec_rd_reg;
            rd_ready <= 1'b1;
        end
    end
end

endmodule

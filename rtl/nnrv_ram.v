`default_nettype none

module ram
# (
parameter DATA_WIDTH = 64,
parameter ADDR_WIDTH = 8,
parameter MASK_WIDTH = DATA_WIDTH >> 3,
parameter RAM_DEPTH = 1 << ADDR_WIDTH
)
(
input wire i_clk,

input wire [ADDR_WIDTH-1:0] i_rd1_addr,
input wire i_rd1_en,
input wire [MASK_WIDTH-1:0] i_rd1_mask,
output wire [DATA_WIDTH-1:0] o_rd1_data,

input wire [ADDR_WIDTH-1:0] i_rd2_addr,
input wire i_rd2_en,
input wire [MASK_WIDTH-1:0] i_rd2_mask,
output wire [DATA_WIDTH-1:0] o_rd2_data,

input wire [ADDR_WIDTH-1:0] i_wr_addr,
input wire i_wr_en,
input wire [MASK_WIDTH-1:0] i_wr_mask,
input wire [DATA_WIDTH-1:0] i_wr_data
);

/* local */

reg [DATA_WIDTH-1:0] ram [0:RAM_DEPTH-1];

wire [ADDR_WIDTH-1:0] rd1_addr;
reg [DATA_WIDTH-1:0] rd1_mask;
wire [ADDR_WIDTH-1:0] rd2_addr;
reg [DATA_WIDTH-1:0] rd2_mask;
wire [ADDR_WIDTH-1:0] wr_addr;
reg [DATA_WIDTH-1:0] wr_mask;

assign rd1_addr = {2'h0, i_rd1_addr[ADDR_WIDTH-1:2]};
assign o_rd1_data = (i_rd1_en) ? (ram[rd1_addr] & rd1_mask) : 8'b0;

always @* begin
  for (integer i = 0; i < MASK_WIDTH; i++) begin
    rd1_mask[i * 8 +: 8] = i_rd1_mask[i] ? 8'hFF : 8'h00;
  end
end

assign rd2_addr = {2'h0, i_rd2_addr[ADDR_WIDTH-1:2]};
assign o_rd2_data = (i_rd2_en) ? (ram[rd2_addr] & rd2_mask) : 8'b0;

always @* begin
  for (integer i = 0; i < MASK_WIDTH; i++) begin
    rd2_mask[i * 8 +: 8] = i_rd2_mask[i] ? 8'hFF : 8'h00;
  end
end

assign wr_addr = {2'h0, i_wr_addr[ADDR_WIDTH-1:2]};

always @* begin
  for (integer i = 0; i < MASK_WIDTH; i++) begin
    wr_mask[i * 8 +: 8] = i_wr_mask[i] ? 8'hFF : 8'h00;
  end
end

always @ (posedge i_clk) begin
  if (i_wr_en) begin
    ram[wr_addr] <= ((ram[wr_addr] & ~wr_mask) | (i_wr_data & wr_mask));
  end
end

initial begin
  $readmemh("ram.mem", ram);
end

endmodule

`default_nettype none

module ram
# (
parameter DATA_WIDTH = 64,
parameter ADDR_WIDTH = 10,
parameter MASK_WIDTH = DATA_WIDTH >> 3,
parameter RAM_DEPTH = (1 << ADDR_WIDTH) / MASK_WIDTH
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
wire [DATA_WIDTH-1:0] rd1_mask;
wire [ADDR_WIDTH-1:0] rd2_addr;
wire [DATA_WIDTH-1:0] rd2_mask;
wire [ADDR_WIDTH-1:0] wr_addr;
wire [DATA_WIDTH-1:0] wr_mask;

assign rd1_addr = {3'h0, i_rd1_addr[ADDR_WIDTH-1:3]};
assign o_rd1_data = (i_rd1_en) ? (ram[rd1_addr] & rd1_mask) : 8'b0;

assign rd1_mask = {{8{i_rd1_mask[7]}}, {8{i_rd1_mask[6]}}, {8{i_rd1_mask[5]}}, {8{i_rd1_mask[4]}},
                   {8{i_rd1_mask[3]}}, {8{i_rd1_mask[2]}}, {8{i_rd1_mask[1]}}, {8{i_rd1_mask[0]}}};

assign rd2_addr = {3'h0, i_rd2_addr[ADDR_WIDTH-1:3]};
assign o_rd2_data = (i_rd2_en) ? (ram[rd2_addr] & rd2_mask) : 8'b0;

assign rd2_mask = {{8{i_rd2_mask[7]}}, {8{i_rd2_mask[6]}}, {8{i_rd2_mask[5]}}, {8{i_rd2_mask[4]}},
                   {8{i_rd2_mask[3]}}, {8{i_rd2_mask[2]}}, {8{i_rd2_mask[1]}}, {8{i_rd2_mask[0]}}};

assign wr_addr = {3'h0, i_wr_addr[ADDR_WIDTH-1:3]};

assign wr_mask = {{8{i_wr_mask[7]}}, {8{i_wr_mask[6]}}, {8{i_wr_mask[5]}}, {8{i_wr_mask[4]}},
                  {8{i_wr_mask[3]}}, {8{i_wr_mask[2]}}, {8{i_wr_mask[1]}}, {8{i_wr_mask[0]}}};

always @ (posedge i_clk) begin
  if (i_wr_en) begin
    ram[wr_addr] <= ((ram[wr_addr] & ~wr_mask) | (i_wr_data & wr_mask));
  end
end

initial begin
  $readmemh("ram.mem", ram);
end

endmodule

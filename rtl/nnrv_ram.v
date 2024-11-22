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
output wire o_rd1_ready,
output wire [DATA_WIDTH-1:0] o_rd1_data,

input wire [ADDR_WIDTH-1:0] i_rd2_addr,
input wire i_rd2_en,
input wire [MASK_WIDTH-1:0] i_rd2_mask,
output wire o_rd2_ready,
output wire [DATA_WIDTH-1:0] o_rd2_data,

input wire [ADDR_WIDTH-1:0] i_wr_addr,
input wire i_wr_en,
input wire [MASK_WIDTH-1:0] i_wr_mask,
input wire [DATA_WIDTH-1:0] i_wr_data,
output wire o_wr_ready
);

/* local */

reg [DATA_WIDTH-1:0] ram [0:RAM_DEPTH-1];

wire [ADDR_WIDTH-1:0] rd1_addr;
wire [DATA_WIDTH-1:0] rd1_mask;
wire [ADDR_WIDTH-1:0] rd2_addr;
wire [DATA_WIDTH-1:0] rd2_mask;
wire [ADDR_WIDTH-1:0] wr_addr;
wire [DATA_WIDTH-1:0] wr_mask;

/*
`define TEST_RD1_DELAY
`define TEST_RD2_DELAY
`define TEST_WR_DELAY
*/

`ifdef TEST_RD1_DELAY

reg rd1_ready = 1'b0;
reg rd1_working = 0;
reg [1:0] rd1_cntdown = 0;

`else

reg rd1_ready = 1'b1;

`endif

`ifdef TEST_RD2_DELAY

reg rd2_ready = 1'b0;
reg rd2_working = 0;
reg [1:0] rd2_cntdown = 0;

`else

reg rd2_ready = 1'b1;

`endif

`ifdef TEST_WR_DELAY

reg wr_ready = 1'b0;
reg wr_working = 0;
reg [1:0] wr_cntdown = 0;

`else

reg wr_ready = 1'b1;

`endif

assign rd1_addr = {3'h0, i_rd1_addr[ADDR_WIDTH-1:3]};
assign o_rd1_data = (i_rd1_en) ? (ram[rd1_addr] & rd1_mask) : 8'b0;
assign o_rd1_ready = rd1_ready;

assign rd1_mask = {{8{i_rd1_mask[7]}}, {8{i_rd1_mask[6]}}, {8{i_rd1_mask[5]}}, {8{i_rd1_mask[4]}},
                   {8{i_rd1_mask[3]}}, {8{i_rd1_mask[2]}}, {8{i_rd1_mask[1]}}, {8{i_rd1_mask[0]}}};

assign rd2_addr = {3'h0, i_rd2_addr[ADDR_WIDTH-1:3]};
assign o_rd2_data = (i_rd2_en) ? (ram[rd2_addr] & rd2_mask) : 8'b0;
assign o_rd2_ready = rd2_ready;

assign rd2_mask = {{8{i_rd2_mask[7]}}, {8{i_rd2_mask[6]}}, {8{i_rd2_mask[5]}}, {8{i_rd2_mask[4]}},
                   {8{i_rd2_mask[3]}}, {8{i_rd2_mask[2]}}, {8{i_rd2_mask[1]}}, {8{i_rd2_mask[0]}}};

assign wr_addr = {3'h0, i_wr_addr[ADDR_WIDTH-1:3]};
assign o_wr_ready = wr_ready;

assign wr_mask = {{8{i_wr_mask[7]}}, {8{i_wr_mask[6]}}, {8{i_wr_mask[5]}}, {8{i_wr_mask[4]}},
                  {8{i_wr_mask[3]}}, {8{i_wr_mask[2]}}, {8{i_wr_mask[1]}}, {8{i_wr_mask[0]}}};

always @ (posedge i_clk) begin
  if (i_wr_en) begin
    ram[wr_addr] <= ((ram[wr_addr] & ~wr_mask) | (i_wr_data & wr_mask));
  end
end

`ifdef TEST_RD1_DELAY

always @ (posedge i_clk or i_rd1_en) begin
  if (i_rd1_en) begin
    if (rd1_working == 0) begin
      rd1_working <= 1;
      rd1_cntdown <= 3;
      rd1_ready <= 0;
    end else begin
      rd1_cntdown -= 1;
      if (rd1_cntdown == 0) begin
        rd1_working <= 0;
        rd1_ready <= 1;
      end
    end
  end else begin
    rd1_working <= 0;
    rd1_ready <= 0;
  end
end

`endif

`ifdef TEST_RD2_DELAY

always @ (posedge i_clk or i_rd2_en) begin
  if (i_rd2_en) begin
    if (rd2_working == 0) begin
      rd2_working <= 1;
      rd2_cntdown <= 3;
      rd2_ready <= 0;
    end else begin
      rd2_cntdown -= 1;
      if (rd2_cntdown == 0) begin
        rd2_working <= 0;
        rd2_ready <= 1;
      end
    end
  end else begin
    rd2_working <= 0;
    rd2_ready <= 0;
  end
end

`endif

`ifdef TEST_WR_DELAY

always @ (posedge i_clk or i_wr_en) begin
  if (i_wr_en) begin
    if (wr_working == 0) begin
      wr_working <= 1;
      wr_cntdown <= 3;
      wr_ready <= 0;
    end else begin
      wr_cntdown -= 1;
      if (wr_cntdown == 0) begin
        wr_working <= 0;
        wr_ready <= 1;
      end
    end
  end else begin
    wr_working <= 0;
    wr_ready <= 0;
  end
end

`endif

initial begin
  $readmemh("ram.mem", ram);
end

endmodule

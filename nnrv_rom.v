`default_nettype none

module rom
(
i_addr,
i_rd_en,
i_ce,
o_data
);

/* parameter */

parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 8;
parameter RAM_DEPTH = 1 << ADDR_WIDTH;

/* port */

input wire [ADDR_WIDTH-1:0] i_addr;
input wire i_rd_en;
input wire i_ce;
output wire [DATA_WIDTH-1:0] o_data;

/* local */

reg [DATA_WIDTH-1:0] rom [0:RAM_DEPTH-1];
wire [ADDR_WIDTH-1:0] addr;

assign addr = {2'h0, i_addr[ADDR_WIDTH-1:2]};
assign o_data = (i_ce && i_rd_en) ? rom[addr] : 8'b0;

initial begin
  $readmemh("rom.mem", rom);
end

endmodule

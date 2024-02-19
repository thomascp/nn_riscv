
module nnrv_board
(
clk,
led
);

input wire clk;
output wire led;

reg rst = 1'b0;

nnrv_top nnrv_top (
	.i_clk(clk),
	.i_rst(rst),
	.o_led(led)
);

endmodule
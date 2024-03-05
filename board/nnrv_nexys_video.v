
module nnrv_board
(
input wire clk,
output wire led
);

reg rst = 1'b0;
reg div2_clk = 1'b0;

always @ (posedge clk) begin
    div2_clk = div2_clk + 1;
end

nnrv_top nnrv_top (
    .i_clk(div2_clk),
    .i_rst(rst),
    .o_led(led)
);

endmodule
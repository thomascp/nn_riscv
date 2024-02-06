
module nnrv_tb;

reg clk;
reg rst;

initial begin
  clk = 0;
  rst = 1;
  #500 rst = 0;
  #20000 $finish;
end

always begin
 #100 clk = !clk;
end

nnrv_top nnrv_top (
	.i_clk(clk),
	.i_rst(rst)
);

endmodule
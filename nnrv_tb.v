
module nnrv_tb;

reg clk;
reg rst;

initial begin
  clk = 0;
  rst = 1;
  #500 rst = 0;
  #2000 $finish;
end

always begin
 #100 clk = !clk;
end

integer reg_idx = 0;
always @ (posedge clk) begin
    $display("\n\npc %08x, instr %08x, regs:", nnrv_top.nnrv_if.pc, nnrv_top.nnrv_if.instr);
    for (reg_idx = 0; reg_idx < 32; reg_idx = reg_idx + 1)
    begin
      if ((reg_idx % 8) == 0)
      begin
        $write("\n");
      end
      $write("x%02d [%08x] ", reg_idx, nnrv_top.nnrv_reg.regs[reg_idx]);
    end
end

nnrv_top nnrv_top (
	.i_clk(clk),
	.i_rst(rst)
);

endmodule
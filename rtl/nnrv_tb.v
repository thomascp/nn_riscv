
module nnrv_tb;

reg clk;
reg rst;
wire led;

integer reg_idx = 0;
integer file;

initial begin
  clk = 0;
  rst = 0;

  $dumpfile("nnrv.vcd");
  $dumpvars(0,nnrv_tb);
  for (reg_idx = 0; reg_idx < 32; reg_idx = reg_idx + 1)
    $dumpvars(0, nnrv_tb.nnrv_top.nnrv_reg.regs[reg_idx]);

  #3000;

  file = $fopen ("result.log", "w");
  for (reg_idx = 0; reg_idx < 32; reg_idx = reg_idx + 1) begin
    if ((reg_idx % 8) == 0)
    begin
      $fwrite(file, "\n");
    end
    $fwrite(file, "x%02d [%08x] ", reg_idx, nnrv_top.nnrv_reg.regs[reg_idx]);
  end
  $fclose(file);
  #100 $finish;
end

always begin
 #5 clk = !clk;
end

/*
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
*/

nnrv_top nnrv_top (
    .i_clk(clk),
    .i_rst(rst),
    .o_led(led)
);

endmodule
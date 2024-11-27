
module nnrv_tb;

reg clk;
reg rst;
wire led;

integer reg_idx = 0;
integer file;
integer record = 0;

initial begin
  clk = 0;
  rst = 0;

  $dumpfile("nnrv.vcd");
  $dumpvars(0,nnrv_tb);
  for (reg_idx = 0; reg_idx < 32; reg_idx = reg_idx + 1)
    $dumpvars(0, nnrv_tb.nnrv_top.nnrv_reg.regs[reg_idx]);
  for (reg_idx = 0; reg_idx < 32; reg_idx = reg_idx + 1)
    $dumpvars(0, nnrv_tb.nnrv_top.ram.ram[reg_idx]);

  #60000;

  file = $fopen ("result.log", "w");
  $fwrite(file, "regs :\n");
  for (reg_idx = 0; reg_idx < 32; reg_idx = reg_idx + 1) begin
    if ((reg_idx % 8) == 0)
    begin
      $fwrite(file, "\n");
    end
    $fwrite(file, "x%02d [%08x] ", reg_idx, nnrv_top.nnrv_reg.regs[reg_idx]);
  end
  $fwrite(file, "\n\nram :\n\n");
  for (reg_idx = 0; reg_idx < 32; reg_idx = reg_idx + 1) begin
    $fwrite(file, "0x%08x [%08x]\n", reg_idx * 8, nnrv_top.ram.ram[reg_idx]);
  end
  $fclose(file);

  #10
  
  /* dump signature file */

  file = $fopen ("DUT-nn_riscv.signature", "w");
  for (reg_idx = 0; reg_idx < nnrv_top.ram.RAM_DEPTH; reg_idx = reg_idx + 1) begin
    if (nnrv_top.ram.ram[reg_idx] == 'h6F5CA309E7D4B281)
    begin
      if (record == 0) begin
        record = 1;
      end else begin
        record = 0;
        $fwrite(file, "%04x\n", nnrv_top.ram.ram[reg_idx][31:0]);
        $fwrite(file, "%04x\n", nnrv_top.ram.ram[reg_idx][63:32]);
        if (reg_idx % 2 == 0)
        begin
          $fwrite(file, "%04x\n", nnrv_top.ram.ram[reg_idx+1][31:0]);
          $fwrite(file, "%04x\n", nnrv_top.ram.ram[reg_idx+1][63:32]);
        end
      end
    end
    if (record)
    begin
      $fwrite(file, "%04x\n", nnrv_top.ram.ram[reg_idx][31:0]);
      $fwrite(file, "%04x\n", nnrv_top.ram.ram[reg_idx][63:32]);
    end
  end
  $fclose(file);

  #10

  $finish;
end

always begin
 #1 clk = !clk;
end

nnrv_top nnrv_top (
    .i_clk(clk),
    .i_rst(rst),
    .o_led(led)
);

endmodule
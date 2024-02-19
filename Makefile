
# https://riscvasm.lucasteske.dev/#

all:
	iverilog -o nnrv nnrv_mem.v nnrv_wb.v nnrv_exec.v nnrv_reg.v nnrv_id.v nnrv_ram.v nnrv_if.v nnrv_top.v nnrv_tb.v
	vvp nnrv
	#gtkwave test.vcd

show: all
	gtkwave nnrv.vcd &

clean:
	rm -rf nnrv.vcd nnrv

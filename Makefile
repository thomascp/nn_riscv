
# https://riscvasm.lucasteske.dev/#

RTL=./rtl

compile:
	iverilog -I$(RTL)/ -o nnrv $(RTL)/nnrv_mem.v $(RTL)/nnrv_wb.v $(RTL)/nnrv_exec.v $(RTL)/nnrv_reg.v $(RTL)/nnrv_id.v $(RTL)/nnrv_ram.v $(RTL)/nnrv_if.v $(RTL)/nnrv_top.v $(RTL)/nnrv_tb.v

run: compile
	cp $(RTL)/ram.mem ram.mem
	vvp nnrv

show: compile run
	gtkwave nnrv.vcd &

test: compile
	cd test ; \
	bash test.sh ; \
	#cd ..

clean:
	rm -rf nnrv.vcd nnrv ram.mem result.log

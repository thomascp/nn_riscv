# nn_riscv

nn_riscv is a simple RISC-V CPU core written in Verilog. It currently supports the RV64I
instruction set and has passed the RISC-V compliance tests. This project is a personal interest
project, and I work on it as a way to explore CPU design and improve my skills.

## Status and Plans
Right now, nn_riscv is a basic CPU core, but my goal is to eventually make it capable of running
Linux. In the future, I hope to add features like a GPU or NPU to make it more complete. The
project is still in its early stages, and there’s a lot to learn and improve.

## Simulation
nn_riscv use iverilog as the simulator, simulation is quite easy. Just use these commands to
start the simulation and debug the CPU.

```
# compile the CPU
make compile

# compile the codes and copy the ram.mem to rtl folder
riscv64-unknown-elf-gcc -march=rv64g -Ttest.lds -nostartfiles -nostdlib test.asm -o test.out
riscv64-unknown-elf-objcopy -O binary test.out test.bin
hexdump -v -e '1/4 "%08x" "\n"' test.bin | sed 'N;s/\(.*\)\n\(.*\)/\2\1/' > ram.mem

# compile and run the CPU
make run

# use gtkwave to show and debug the simulation
make show
```

## FPGA
Supported FPGAs are listed in the board folder, only nexys_video is supported by now.

## Compliance Test
The compliance test configuration is loacted in riscof folder.
Follow the [riscof link](https://riscof.readthedocs.io/en/stable/installation.html#) to do the
tests.

## About Me
I am an embedded software engineer specializing in writing drivers and system software. My daily
work involves understanding hardware-software interaction in depth, which has sparked my
curiosity about the inner workings of CPUs. Although Verilog is new territory for me, I wanted
to dive deeper into CPU design to bridge the gap between my software expertise and the hardware
world.

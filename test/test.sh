#!/bin/bash

for as in *.s
do
    echo "--> test "$as
    target=$(echo $as | sed "s/\.s//g")
    riscv64-unknown-elf-gcc -march=rv64g -Ttest.lds -nostartfiles -nostdlib $as -o test.out
    riscv64-unknown-elf-objcopy -O binary test.out test.bin
    hexdump -ve '1/4 "%08x\n"' test.bin > ram.mem

    vvp ../nnrv
    if [ ! -f $target".gt" ]
    then
        echo "----- Failure -----"
        echo $target".gt doesn't exist"
        exit 1
    fi
    diffout=$(diff -w result.log $target".gt")
    if [ ! -z "$diffout" ]
    then
        echo "----- Failure -----"
        echo "--> failed at "$as
        echo $diffout
        exit 1
    fi
done

echo "----- All Pass -----"

rm -rf nnrv.vcd result.log test.out ram.mem test.bin a.out

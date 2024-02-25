#!/bin/bash

do_clean () {
   rm -rf nnrv.vcd result.log test.out ram.mem test.bin a.out
}

for as in *.s
do
    echo "--> test "$as
    target=$(echo $as | sed "s/\.s//g")
    riscv64-unknown-elf-gcc -march=rv64g -Ttest.lds -nostartfiles -nostdlib $as -o test.out
    riscv64-unknown-elf-objcopy -O binary test.out test.bin
    hexdump -ve '1/8 "%016x\n"' test.bin > ram.mem

    vvp ../nnrv
    if [ ! -f $target".gt" ]
    then
        echo "----- Failure -----"
        echo $target".gt doesn't exist"
        do_clean
        exit 1
    fi
    diffout=$(diff -w result.log $target".gt")
    if [ ! -z "$diffout" ]
    then
        echo "----- Failure -----"
        echo "--> failed at "$as
        echo $diffout
        #do_clean
        exit 1
    fi
done

echo "----- All Pass -----"
do_clean

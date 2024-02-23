.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
    addi x1, x0, 1
    addi x2, x0, 1
    addi x3, x0, 2
    addi x4, x0, -1
    nop
    nop
    nop
    nop
    nop
    beq x1, x2, test
    addi x5, x0, 5
test:
    addi x6, x0, 6
    nop
    bne x1, x3, testbne
    addi x7, x0, 7
testbne:
    addi x8, x0, 8
    nop
    blt x4, x1, testblt
    addi x9, x0, 9
testblt:
    addi x10, x0, 10
    nop
    bge x3, x2, testbge
    addi x11, x0, 11
testbge:
    addi x12, x0, 12
    nop
    bltu x4, x1, testbltu
    addi x13, x0, 13
testbltu:
    addi x14, x0, 14
    nop
    bgeu x3, x2, testbgeu
    addi x15, x0, 15
testbgeu:
    addi x16, x0, 16
    nop

loop:
     jal x0, loop

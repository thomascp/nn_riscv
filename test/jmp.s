.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
    addi x1, x0, 1
    jal x31, test
    addi x2, x0, 2
test:
    addi x3, x0, 3
    nop
    nop
    nop
    la x4, testjalr
    nop
    nop
    nop
    nop
    nop
    jalr x30, 0(x4)
    addi x5, x0, 4
    nop
    nop
    nop
testjalr:
    addi x6, x0, 5
    nop
    nop

loop:
	jal x0, loop
.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
    addi x1, x0, 1
    jal x31, test
    addi x2, x0, 2
test:
    addi x3, x0, 3
    la x4, testjalr
    jalr x30, 0(x4)
    addi x5, x0, 4
testjalr:
    addi x6, x0, 5
loop:
	jal x0, loop
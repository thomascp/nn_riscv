.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
    la x31, read_v
    la x30, write_v
    nop
    nop
    nop
    nop
    nop
    lbu x1, 0(x31)
    lbu x2, 1(x31)
    lbu x3, 2(x31)
    lbu x4, 3(x31)
    lb x5, 0(x31)
    lb x6, 1(x31)
    lb x7, 2(x31)
    lb x8, 3(x31)
    lhu x9, 4(x31)
    lh x10, 4(x31)
    lhu x11, 6(x31)
    lh x12, 6(x31)
    lhu x13, 5(x31)
    lh x14, 5(x31)
    lw x15, 8(x31)
    nop
    nop
    nop
    nop
    nop
    sb x2, 0(x30)
    sh x9, 4(x30)
    sw x15, 8(x30)
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
loop:
	jal x0, loop

read_v:
	.word 0x1234abcd
    .word 0x87658321
	.word 0xabcdef12
write_v:
    .word 0x55555555
    .word 0x55555555
    .word 0x55555555
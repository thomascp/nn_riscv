.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
    addi x1, x0, 0x55
    addi x2, x0, 0xaa
    addi x3, x0, -1
    nop
    nop
    nop
    nop
    nop
    slti x5, x3, 0
    slti x6, x2, 0x55
    sltiu x7, x3, 0
    sltiu x8, x1, 0xaa
    xori x9, x1, 0x11
    ori x10, x1, 0x11
    andi x11, x1, 0x11
    slli x12, x2, 24
    nop
    nop
    nop
    nop
    nop
    srli x13, x12, 24
    srai x14, x12, 24
    nop
    nop
    nop
    nop
    nop
    nop
loop:
	jal x0, loop
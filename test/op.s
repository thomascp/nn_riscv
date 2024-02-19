.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
    addi x1, x0, 0x55
    addi x2, x0, 0xaa
    addi x3, x0, -1
    addi x4, x0, 24
    nop
    nop
    nop
    nop
    nop
    slt x5, x3, x1
    slt x6, x2, x1
    sltu x7, x1, x3
    sltu x8, x2, x1
    xor x9, x1, x2
    or x10, x1, x2
    and x11, x1, x2
    sll x12, x2, x4
    nop
    nop
    nop
    nop
    nop
    srl x13, x12, x4
    sra x14, x12, x4
    add x15, x1, x2
    sub x16, x2, x1
    nop
    nop
    nop
    nop
    nop
    nop
loop:
	jal x0, loop
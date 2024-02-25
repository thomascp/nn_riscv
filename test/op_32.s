.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
    add  x31, x0, 24
    add  x30, x0, 0x55
    add  x29, x0, 0xaa
    addw x1, x0, 0x55
    addw x2, x0, 0xaa
    sllw x3, x1, x31
    sllw x5, x2, x31
    srlw x7, x3, x31
    srlw x8, x5, x31
    sraw x9, x3, x31
    sraw x10, x5, x31
    subw x11, x2, x1
    nop
    nop
    nop
    nop
    nop
    nop
loop:
    jal x0, loop
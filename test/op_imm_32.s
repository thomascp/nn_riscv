.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
    addiw x1, x0, 0x55
    addiw x2, x0, 0xaa
    slliw x3, x1, 24
    slliw x5, x2, 24
    srliw x7, x3, 24
    srliw x8, x5, 24
    sraiw x9, x3, 24
    sraiw x10, x5, 24
    nop
    nop
    nop
    nop
    nop
    nop
loop:
    jal x0, loop
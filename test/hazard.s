.global _boot
.text

_boot:                    /* x0  = 0    0x000 */
    /* Test ADDI */
    la x30, test1
    la x31, test2
    addi x1 , x0,   1
    addi x2 , x1,   2
    sub x3, x2, x1
    sw x3, 0(x30)
    lw x4, 0(x31)
    addi x5, x4, 1
    nop
    nop
    nop
    nop
    nop
loop:
    jal x0, loop

test1:
    .word 0xaaaaaaaa
test2:
    .word 0x55555555
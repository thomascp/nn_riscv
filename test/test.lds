  MEMORY
  {
    ROM (rwx) : ORIGIN = 0x00000000, LENGTH = 0x10000
    RAM (rwx) : ORIGIN = 0x00010000, LENGTH = 0x08000
  }
  SECTIONS
  {
    .text :
    {
      *(.boot)
      *(.text)
      *(.text)
      *(.rodata*)
    } > ROM
    .data :
    {
      *(.sbss)
      *(.data)
      *(.bss)
      *(.rela*)
      *(COMMON)
    } > RAM
  }

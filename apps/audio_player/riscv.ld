/*
    GNU linker script for RISC-V
*/
MEMORY
{
  FLASH      (rx)  : ORIGIN = 0x020100000, LENGTH = 0x10000000
  PSRAM      (rwx) : ORIGIN = 0x080000000, LENGTH = 0x00800000

}

/* top end of the stack */
__stacktop = ORIGIN(PSRAM) + LENGTH(PSRAM);

/* entry point */
ENTRY(_start)

/* define output sections */
SECTIONS {
    .init : {
        . = ALIGN(4);
        build/start.o(.text*)  /* c runtime initialization (code) */
    } >FLASH

    /* C runtime initialization code and readonly data goes to the FLASH */
    .text : {
        . = ALIGN(4);
        _etext = .;             /* define a global symbol at end of code */
        _sidata = _etext;       /* This is used by the startup in order to initialize the .data section */
    } >FLASH

    .data : AT ( _sidata ) {
        . = ALIGN(4);
        _sdata = .;        /* create a global symbol at data start; used by startup code in order to initialise the .data section in RAM */
        _ram_start = .;    /* create a global symbol at ram start (e.g., for garbage collector) */

        *(.text)                /* .text sections (code) */
        *(.text*)               /* .text* sections (code) */
        . = ALIGN(4);
        *(.data)
        *(.data*)
        *(.sdata)
        *(.sdata*)
        . = ALIGN(4);
        *(.rodata)              /* .rodata sections (constants, strings, etc.) */
        *(.rodata*)             /* .rodata* sections (constants, strings, etc.) */
        *(.srodata)             /* .rodata sections (constants, strings, etc.) */
        *(.srodata*)            /* .rodata* sections (constants, strings, etc.) */

        . = ALIGN(4);
        _edata = .;        /* define a global symbol at data end; used by startup code in order to initialise the .data section in RAM */
    } > PSRAM


    .bss :
    {
        . = ALIGN(4);
        _sbss = .;
        *(.bss)
        *(.bss*)
        *(.sbss)
        *(.sbss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } >PSRAM

    .heap :
    {
        . = ALIGN(4);
        _heap_start = .;
    } >PSRAM
}

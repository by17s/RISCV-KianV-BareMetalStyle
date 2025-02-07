/*
 *  audio_player.c for KianV RV32E ASIC
 *
 *  Copyright (c) 2025 Hirosh Dabui <hirosh@dabui.de>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose, with or without fee, is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS," AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES, OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA, OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE, OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */
.section .text
.global _start
.type _start, @function

# Memory-mapped IO Addresses
.equ IO_BASE, 0x10000000
.equ REG_DIV, (IO_BASE + 0x0010)
.equ SPI_REG_DIV, (IO_BASE + 0x500000 + 0x0010)
.equ FREQ, 31500000
.equ BAUDRATE, 3000000

# UART Configuration
.equ UART_BASE, 0x10000000
.equ UART_TX_OFFSET, 0x00
.equ UART_LSR_OFFSET, 0x05
.equ LSR_THRE, 0x20

_start:
    li x1, 0
    li x2, 0
    li x3, 0
    li x4, 0
    li x5, 0
    li x6, 0
    li x7, 0
    li x8, 0
    li x9, 0
    li x10, 0
    li x11, 0
    li x12, 0
    li x13, 0
    li x14, 0
    li x15, 0

    li t0, REG_DIV
    li t1, (10000 << 16) | (FREQ / BAUDRATE)
    sw t1, 0(t0)

    li t2, UART_BASE

    lui sp, %hi(__stacktop)
    addi sp, sp, %lo(__stacktop)

    la a0, _sbss
    la a1, _ebss
    bge a0, a1, end_init_bss
loop_init_bss:
    sw zero, 0(a0)
    addi a0, a0, 4
    blt a0, a1, loop_init_bss
end_init_bss:
    la a0, _sidata
    la a1, _sdata
    la a2, _edata
    bge a1, a2, end_init_data
loop_init_data:
    lw a3, 0(a0)
    sw a3, 0(a1)
    addi a0, a0, 4
    addi a1, a1, 4
    blt a1, a2, loop_init_data
end_init_data:

    call main
    j _start

send_uart:
    li s0, LSR_THRE
uart_wait:
    lb t1, UART_LSR_OFFSET(t2)
    and t1, t1, s0
    beqz t1, uart_wait       
    sb a1, UART_TX_OFFSET(t2) 
    ret


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

#include <math.h>
#include <stdint.h>
#include <stdarg.h>

#define IO_BASE 0x10000000
#define LSR_DR 0x01
#define LSR_TEMT 0x40
#define LSR_THRE 0x20
#define PWM_ADDR (IO_BASE + 0x14)
//#define REG_DIV (IO_BASE + 0x10)
#define SPI_DIV (IO_BASE + 0x500010)
#define UART_LSR (IO_BASE + 0x5)
#define UART_RX (IO_BASE)
#define UART_TX (IO_BASE)

volatile uint32_t *const pwm_device = (volatile uint32_t *)PWM_ADDR;
volatile uint8_t *const samples = (volatile uint8_t *)(0x20000000 + 1024 * 1024 * 2);

int sample_size;

uint8_t getNextAudioSample() {
    static int i = 0;
    uint8_t sample = *(samples + i);
    i = (i + 1) % sample_size;
    return sample;
}

void uart_write_char(char c) {
    while (!(*(volatile uint8_t *)UART_LSR & LSR_THRE)) {
    }
    *(volatile uint8_t *)UART_TX = c;
}

void uart_write_string(const char *str) {
    while (*str) {
        uart_write_char(*str++);
    }
}

void printf(const char *format, ...) {
    char buffer[128];
    char *ptr = buffer;
    va_list args;

    va_start(args, format);
    while (*format) {
        if (*format == '%') {
            format++;
            if (*format == 'd') {
                int value = va_arg(args, int);
                if (value < 0) {
                    *ptr++ = '-';
                    value = -value;
                }
                char temp[10];
                int len = 0;
                do {
                    temp[len++] = '0' + (value % 10);
                    value /= 10;
                } while (value);
                while (len--) {
                    *ptr++ = temp[len];
                }
            } else if (*format == 'u') {  // Unsigned integer
                unsigned int value = va_arg(args, unsigned int);
                char temp[10];
                int len = 0;
                do {
                    temp[len++] = '0' + (value % 10);
                    value /= 10;
                } while (value);
                while (len--) {
                    *ptr++ = temp[len];
                }
            } else if (*format == 'c') {
                char value = (char)va_arg(args, int);
                *ptr++ = value;
            } else if (*format == 's') {
                const char *value = va_arg(args, const char *);
                while (*value) {
                    *ptr++ = *value++;
                }
            } else {
                *ptr++ = '%';
                *ptr++ = *format;
            }
        } else {
            *ptr++ = *format;
        }
        format++;
    }
    *ptr = '\0';
    va_end(args);

    uart_write_string(buffer);
}

uint32_t parseHeader() {
    uint32_t sample_count = 0;

    sample_count |= (uint32_t)samples[0];
    sample_count |= (uint32_t)samples[1] << 8;
    sample_count |= (uint32_t)samples[2] << 16;

    return sample_count;
}

int main() {
    printf("Starting audio playback...\n");

    sample_size = parseHeader();
    printf("Playing %u samples...\n", sample_size);


    for (uint32_t i = 0; i < sample_size; i++) {
        uint8_t sample = getNextAudioSample();
        *pwm_device = sample;

        __asm__ volatile("nop");
        __asm__ volatile("nop");
        __asm__ volatile("nop");
        __asm__ volatile("nop");
        __asm__ volatile("nop");
        __asm__ volatile("nop");
        __asm__ volatile("nop");
        __asm__ volatile("nop");
        __asm__ volatile("nop");
        __asm__ volatile("nop");
        __asm__ volatile("nop");
        __asm__ volatile("nop");
    }

    printf("Playback finished.\n");
    return 0;
}

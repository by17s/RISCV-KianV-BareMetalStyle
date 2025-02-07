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
#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input file> <output file>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

if [ ! -f "$INPUT_FILE" ]; then
    echo " Error: Input file '$INPUT_FILE' not found!"
    exit 1
fi

FILESIZE=$(stat -c%s "$INPUT_FILE")

if [ "$FILESIZE" -eq 0 ]; then
    echo " Error: File is empty!"
    exit 1
fi

BYTE1=$(printf "%02x" $((FILESIZE & 0xFF)))
BYTE2=$(printf "%02x" $(((FILESIZE >> 8) & 0xFF)))
BYTE3=$(printf "%02x" $(((FILESIZE >> 16) & 0xFF)))

echo -ne "\\x$BYTE1\\x$BYTE2\\x$BYTE3" > header.bin

cat header.bin "$INPUT_FILE" > "$OUTPUT_FILE"

rm header.bin

echo "✅ Header added successfully!"
echo "   Output File: $OUTPUT_FILE"
echo "   Original Size: $FILESIZE bytes"
echo "   New Size: $(stat -c%s "$OUTPUT_FILE") bytes"


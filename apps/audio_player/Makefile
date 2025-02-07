# Target and Toolchain
TARGET = pwm_player.c
CC = riscv32-unknown-elf-gcc
AS = riscv32-unknown-elf-as
LD = riscv32-unknown-elf-ld
OBJCOPY = riscv32-unknown-elf-objcopy
OBJDUMP = riscv32-unknown-elf-objdump
CFLAGS = -march=rv32e -mabi=ilp32e -O2 -Wall -ffreestanding -nostdlib
LIBGCC = $(shell $(CC) --print-libgcc-file-name)
LIBM = $(shell $(CC) --print-file-name=libm.a)
LDFLAGS = -T riscv.ld -nostdlib $(LIBGCC) $(LIBM)

# Directories
SRC_DIR = .
BUILD_DIR = build

# Source Files
C_SOURCES = main.c
ASM_SOURCES = start.S
OBJS = $(addprefix $(BUILD_DIR)/, $(C_SOURCES:.c=.o) $(ASM_SOURCES:.S=.o))

# Rules
all: $(TARGET).elf $(TARGET).bin

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Compile C files
$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

# Compile Assembly files (.S instead of .s to enable preprocessor macros)
$(BUILD_DIR)/%.o: %.S | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@  # Using GCC instead of AS for macro expansion

# Link everything together
$(TARGET).elf: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^ $(LIBM) $(LIBGCC)

# Convert ELF to binary
$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

# Dump disassembly
dump: $(TARGET).elf
	$(OBJDUMP) -D $< > $(TARGET).dump

# Clean build files
clean:
	rm -rf $(BUILD_DIR) $(TARGET).elf $(TARGET).bin $(TARGET).dump *.o

.PHONY: all clean dump


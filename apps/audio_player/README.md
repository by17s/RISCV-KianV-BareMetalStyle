# Setting Up the Toolchain and Running the Player KianV RV32E RISC-V ASIC

## 1. Install the Toolchain

You need to install the toolchain first. Just run the following commands:

```sh
sudo apt-get update
sudo apt-get install autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain.git
cd riscv-gnu-toolchain
./configure --prefix=/opt/riscv32e --with-arch=rv32e --with-abi=ilp32e
make
export PATH=/opt/riscv32e/bin:$PATH
```

## 2. Build the Player

Once the toolchain is set up, you can compile the player by simply running:

```sh
make
```

## 3. Flashing the Player

Flash the **pwm_player.bin** file to the **1 MiB offset** in flash memory.

```sh
# Example flashing command (adjust as needed)
flash_tool --write pwm_player.bin --offset 0x100000
```

## 4. Preparing the WAV File

You need a WAV file with the following format:

```sh
file technik.wav
technik.wav: RIFF (little-endian) data, WAVE audio, Microsoft PCM, 8-bit, mono, 8000 Hz
```

Use `add_24bit_header.sh` to prepend a header to the WAV file:

```sh
./add_24bit_header.sh technik.wav /tmp/tmpmusic.bin
```

## 5. Flashing the Processed Audio File

The resulting `.bin` file must be flashed to a **2 MiB offset**:

```sh
flash_tool --write /tmp/tmpmusic.bin --offset 0x200000
```

## 6. Adjusting the CPU Frequency

The CPU frequency must be set to **31.5 MHz**. If necessary, you can modify the frequency in the source code.

---

That's all! 🎵 Now your player should be ready to run.

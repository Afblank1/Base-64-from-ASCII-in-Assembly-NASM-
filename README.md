# x86-64 Base64 Encoder

A high-performance Base64 encoder written in pure **Assembly (NASM)** for Linux. This project was a deep dive into bit-manipulation, manual memory management, and x86-64 system calls. I created this project to get more comfortable with Assembly as well as to challenge myself.

## How it Works
Instead of using high level libraries, this program interacts directly with CPU registers and the Linux kernel.

* **Register Packing:** The program reads three 8 bit ASCII characters from the input buffer and packs them into a single 24 bit window inside a 64 bit register `RAX`.
* **Bit Shifting:** The 24 bit stream is sliced into four 6 bit chunks using logical shifts `shr`, `shl` and bitwise masking `and`. 
* **Lookup Table:** Each 6 bit value acts as an index into the Base64 alphabet string to retrieve the corresponding character.
* **Manual Padding:** Implements logic to handle inputs that aren't multiples of 3 bytes by applying `=` padding characters.



## Things I learned!
* **Endianness Management:** Handled the conversion between Little Endian memory storage and the Big Endian bitstream required for the Base64 algorithm.
* **Pointer Arithmetic:** Orchestrated two simultaneous pointers `RSI` for input, `RDI` for output advancing at different rates (3:4 ratio).
* **Memory Safety:** Used `sys_read` and `sys_write` system calls for I/O and calculated string lengths dynamically using pointer subtraction `sub rdx, output_buffer`

## Prerequisites
* **OS:** Linux (Tested on Arch Linux)
* **Assembler:** NASM
* **Linker:** GNU ld

## Build & Run
```bash
# Assemble using NASM
nasm -f elf64 base64.asm -o base64.o

# Link the object file
ld base64.o -o base64

# Run the encoder
./base64

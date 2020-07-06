# macOS Catalina 10.15.5
# Dual-Core Intel Core i5
#
# brew install i386-elf-gdb
# brew install i686-elf-binutils
# brew install i686-elf-gcc

# source code
A_SOURCES := $(wildcard boot/*.s)
C_SOURCES := $(wildcard kernel/*.c drivers/*.c common/*.c)
HEADERS := $(wildcard kernel/*.h drivers/*.h common/*.h)

# object file
OUT_DIR = out
A_OUTS := $(patsubst %.s, $(OUT_DIR)/%.o, $(A_SOURCES))
C_OUTS := $(patsubst %.c, $(OUT_DIR)/%.o, $(C_SOURCES))

# binary
BIN_DIR = bin
A_BINS := $(patsubst %.s, $(BIN_DIR)/%.bin, $(A_SOURCES))
C_BINS := $(patsubst %.c, $(BIN_DIR)/%.bin, $(C_SOURCES))

# cross compiler
CC = /usr/local/opt/i686-elf-gcc/bin/i686-elf-gcc
LD = /usr/local/opt/i686-elf-binutils/bin/i686-elf-ld
ASM = /usr/local/bin/nasm
QEMU = /usr/local/bin/qemu-system-i386
GDB = /usr/local/opt/i386-elf-gdb/bin/i386-elf-gdb

CFLAGS = -g -I.
KERNEL_OFFSET = 0x1000

run: $(BIN_DIR)/os_image.bin
	$(QEMU) -fda $<

debug: $(BIN_DIR)/os_image.bin $(BIN_DIR)/kernel/kernel.elf
	$(QEMU) -fda $< -s -S &
	${GDB} -ex "target remote localhost:1234" -ex "symbol-file $(BIN_DIR)/kernel/kernel.elf"

$(BIN_DIR)/os_image.bin: $(BIN_DIR)/boot/bootsector.bin $(BIN_DIR)/kernel/kernel.bin
	mkdir -p $(shell dirname $@)
	cat $^ > $@

# '--oformat binary' deletes all symbols as a collateral, so we don't need
# to 'strip' them manually on this case
$(BIN_DIR)/kernel/kernel.bin: $(OUT_DIR)/boot/kernel_entry.o $(C_OUTS)
	mkdir -p $(shell dirname $@)
	$(LD) -o $@ -Ttext $(KERNEL_OFFSET) $^ --oformat binary

# only for providing symbol table when debug
$(BIN_DIR)/kernel/kernel.elf: $(OUT_DIR)/boot/kernel_entry.o $(C_OUTS)
	mkdir -p $(shell dirname $@)
	$(LD) -o $@ -Ttext $(KERNEL_OFFSET) $^

.SILENT: print clean

print:
	echo 'S source files:' $(A_SOURCES)
	echo 'S objects' $(A_OUTS)
	echo 'C header files:' $(HEADERS)
	echo 'C source files:' $(C_SOURCES)
	echo 'C objects' $(C_OUTS)

clean:
	rm -rf $(OUT_DIR) $(BIN_DIR)

# general rules to compile assembly to elf
$(OUT_DIR)/%.o: %.s
	mkdir -p $(shell dirname $@)
	$(ASM) -f elf $< -o $@

# general rules to compile assembly to binary
$(BIN_DIR)/%.bin: %.s
	mkdir -p $(shell dirname $@)
	$(ASM) -f bin $< -o $@

# general rules to compile c to elf
$(OUT_DIR)/%.o: %.c ${HEADERS}
	mkdir -p $(shell dirname $@)
	${CC} ${CFLAGS} -ffreestanding -c $< -o $@


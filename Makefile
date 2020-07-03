bs = bootsector
build_dir = bin
bs_obj = $(build_dir)/$(bs)/$(bs).o

qemu: $(bs)
	qemu-system-i386 -fda $(bs_obj)

qemu_tty: $(bs)
	qemu-system-i386 -nographic -fda $(bs_obj)

qemu_gdb: $(bs)
	qemu-system-i386 -nographic -fda $(bs_obj) -gdb tcp::8850 -S

.PHONY: $(bs)

.SILENT: clean

$(bs):
	make -C $(bs)

clean:
	rm -rf $(build_dir)


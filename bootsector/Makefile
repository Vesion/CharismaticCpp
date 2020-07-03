BS = bootsector
build_dir = ../bin/$(BS)

bs_src := $(BS).s
bs_obj := $(build_dir)/$(BS).o

all: $(build_dir) $(bs_obj)

.SILENT: clean

clean:
	rm -rf $(build_dir)

$(build_dir):
	mkdir -p $(build_dir)

$(bs_obj): $(bs_src)
	nasm -f bin $< -o $@

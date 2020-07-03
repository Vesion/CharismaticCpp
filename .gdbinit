define hook-stop
	# Translate the segment:offset into a physical address
	printf "[%4x:%4x] ", $cs, $eip
	x/i $cs*16+$eip
end

set disassembly intel

layout asm
layout reg

set architecture i8086

target remote localhost:8850

b *0x7c00
c


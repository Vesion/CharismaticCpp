; This file should be linked with kernel to make the 
; very first instruction of kernel be 'call main'
[bits 32]
; define calling point. Must have same name as kernel.c 'main' function
[extern main] 
; calls the C function. The linker will know where it is placed in memory
call main 
jmp $

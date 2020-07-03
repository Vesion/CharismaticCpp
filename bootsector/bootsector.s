[org 0x7c00]

[bits 16]
; init stack
mov bp, 0x9000
mov sp, bp

; print string
mov bx, MSG_REAL_MODE
call print
call print_nl

; load 2 sectors from disk to [es:bx]
mov bx, 0x9fff
mov dh, 2
call disk_load
mov dx, [bx]
call print_hex
call print_nl

call switch_to_pm

jmp $ ; this will actually never be executed

%include "utils.s"
%include "utils_32.s"
%include "gdt.s"
%include "gdt_switch.s"

[bits 32]
BEGIN_PM: ; after the switch we will get here
mov ebx, MSG_PROT_MODE
call print_string_pm ; Note that this will be written at the top left corner
jmp $

MSG_REAL_MODE: db "Started in 16-bit real mode", 0
MSG_PROT_MODE: db "Loaded 32-bit protected mode", 0

; sector 1, bootsector
times 510-($-$$) db 0
dw 0xaa55

times 256 dw 0xface ; sector 2 = 512 bytes
times 256 dw 0xdada ; sector 3 = 512 bytes


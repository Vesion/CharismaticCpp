; put code in the offset a bootsector should start
[org 0x7c00]
KERNEL_OFFSET equ 0x1000 ; The same one we used when linking the kernel

[bits 16]
boot:
  ; init stack
  mov bp, 0x9000
  mov sp, bp

  ; print string
  mov bx, MSG_REAL_MODE
  call print
  call print_nl

  ; load kernel before switching to protected mode because
  ; we cannot use BIOS int after that
  call load_kernel

  ; switch to protected mode
  call switch_to_pm

  jmp $ ; this will actually never be executed

%include "boot/print.s"
%include "boot/disk_load.s"
%include "boot/gdt.s"
%include "boot/switch_pm.s"
%include "boot/print_32.s"

[bits 16]
load_kernel:
  mov bx, MSG_LOAD_KERNEL
  call print
  call print_nl

  mov bx, KERNEL_OFFSET ; read from disk and store in 0x1000
  ; num of sectors want to load
  ; because our future kernel will be larger, make this big
  mov dh, 16 
  mov dl, [BOOT_DRIVE]
  call disk_load
  ret

[bits 32]
BEGIN_PM: ; after the switch we will get here
  mov ebx, MSG_PROT_MODE
  call print_string_pm ; Note that this will be written at the top left corner
  call KERNEL_OFFSET ; Give control to the kernel
  jmp $

BOOT_DRIVE db 0 ; store it in memory because 'dl' may get overwritten
MSG_REAL_MODE: db "Started in 16-bit real mode", 0
MSG_PROT_MODE: db "Switch to 32-bit protected mode", 0
MSG_LOAD_KERNEL db "Loading kernel into memory", 0

; sector 1, bootsector
; padding
times 510-($-$$) db 0
; magic number
dw 0xaa55


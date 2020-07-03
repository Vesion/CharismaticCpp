[bits 16]
switch_to_pm:
  cli ; disable interrupts
  lgdt [gdt_descriptor] ; load the GDT descriptor

  ; set 32-bit mode bit in cr0
  mov eax, cr0
  or eax, 0x1
  mov cr0, eax

  jmp CODE_SEG:init_pm ; far jump by using a different segment

[bits 32]
init_pm:
  ; update the segment registers
  mov ax, DATA_SEG
  mov ds, ax
  mov ss, ax
  mov es, ax
  mov fs, ax
  mov gs, ax

  ; update the stack right at the top of the free space
  mov ebp, 0x90000
  mov esp, ebp

  ; call a well-known label with useful code
  call BEGIN_PM 


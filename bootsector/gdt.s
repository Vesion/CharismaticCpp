gdt_start:
  ; null descriptor
  dd 0x0 ; 4 byte
  dd 0x0 ; 4 byte

; code segment descriptor
gdt_code:
  dw 0xffff    ; limit 0xffff
  dw 0x0       ; base 0x00
  db 0x0       ; base 0x000
  db 10011010b ; type 1010: 1 for code segment, 
               ;            0 for code in lower privilege may not call code in this segment,
               ;            1 for readable
               ;            0 for accessed, usually for debuggin and virtual memory
               ; descriptor type 1: code or data segment
               ; privilege 00: highest privilege
               ; present 1: in memory
  db 11001111b ; limit 1111: 0xfffff
               ; avl 0: our own use
               ; 64-bit code segment 0: unused on 32-bit processor
               ; default operation size 1: 32-bit
               ; granularity 1: multiple limit by 4K, 0xfffff*16*16*16 = 0xfffff000, allowing to span 4Gb of memory
  db 0x0       ; base 0x0000

; data segment descriptor
gdt_data:
  dw 0xffff
  dw 0x0
  db 0x0
  db 10010010b ; type 0010: 0 for data segment,
               ;            0 for allowing segment to expand down
               ;            1 for writable
               ;            0 for accessed
  db 11001111b
  db 0x0

gdt_end:

; GDT descriptor
gdt_descriptor:
  dw gdt_end - gdt_start - 1 ; size (16 bit), always one less of its true size
  dd gdt_start ; address (32 bit)

; define some constants for later use
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start


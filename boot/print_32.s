[bits 32] ; using 32-bit protected mode

; print using VGA
print_string_pm:
  pusha
  mov edx, VIDEO_MEMORY

print_string_pm_loop:
  mov al, [ebx] ; [ebx] is the address of our character
  mov ah, TEXT_COLOR

  cmp al, 0 ; check if end of string
  je print_string_pm_done

  mov [edx], ax ; store character + attribute in video memory
  add ebx, 1 ; next char
  add edx, 2 ; next video memory position

  jmp print_string_pm_loop

print_string_pm_done:
  popa
  ret

; VGA constants
VIDEO_MEMORY: equ 0xb8000
TEXT_COLOR: equ 0x0e ; the color byte for each character


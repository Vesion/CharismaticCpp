; print string in [bx]
; while (string[i] != 0) { print string[i]; i++ }
print:
  pusha

print_loop:
  mov al, [bx] ; 'bx' is the base address for the string
  cmp al, 0
  je done

  mov ah, 0x0e ; tty mode
  int 0x10 ; BIOS ISR

  add bx, 1 ; next character
  jmp print_loop

done:
  popa
  ret

; print '\n`
print_nl:
  pusha

  mov ah, 0x0e
  mov al, 0x0a ; newline
  int 0x10
  mov al, 0x0d ; carriage return
  int 0x10

  popa
  ret

; print 2-byte string in hex
; e.g. 0x12ab -> "0x12AB"
print_hex:
  pusha
  mov cx, 0 ; our index variable

print_hex_loop:
  cmp cx, 4 ; loop 4 times
  je print_hex_done

  mov ax, dx ; we will use 'ax' as our working register
  and ax, 0x000f ; get the least significant 4 bits
  add al, '0' ; convert it to ascii
  cmp al, '9' ; if > 9, add extra 8 to represent 'A' to 'F'
  jle print_hex_step2
  add al, 7 ; 'A' is ascii 65, '9' is 57

print_hex_step2:
  mov bx, HEX_OUT + 5 ; the last char of string
  sub bx, cx ; index char
  mov [bx], al ; modify the char
  ror dx, 4 ; right shift 4 bits

  add cx, 1 ; increment counter
  jmp print_hex_loop

print_hex_done:
  mov bx, HEX_OUT
  call print

  popa
  ret

HEX_OUT: db '0x0000',0 ; reserve memory for our new string


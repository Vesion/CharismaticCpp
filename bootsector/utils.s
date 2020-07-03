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

; load 'dh' sectors from drive 'dl' into [es:bx]
disk_load:
  pusha
  push dx ; save dx since we will use it in BIOS int

  mov ah, 0x02 ; ah <- int 0x13 function. 0x02 = 'read'
  mov al, dh   ; al <- number of sectors to read (0x01 .. 0x80)
  mov cl, 0x02 ; cl <- sector (0x01 .. 0x11)
               ; 0x01 is our boot sector, 0x02 is the first 'available' sector
  mov ch, 0x00 ; ch <- cylinder (0x0 .. 0x3FF, upper 2 bits in 'cl')
  ; dl <- drive number. Our caller sets it as a parameter and gets it from BIOS
  ; (0 = floppy, 1 = floppy2, 0x80 = hdd, 0x81 = hdd2)
  mov dh, 0x00 ; dh <- head number (0x0 .. 0xF)

  ; [es:bx] <- pointer to buffer where the data will be stored
  ; caller sets it up for us, and it is actually the standard location for int 13h
  int 0x13      ; BIOS interrupt
  jc disk_error ; if error (stored in the carry bit)

  pop dx
  cmp al, dh    ; BIOS also sets 'al' to the # of sectors read. Compare it.
  jne sectors_error
  popa
  ret


disk_error:
  mov bx, DISK_ERROR
  call print
  call print_nl
  mov dh, ah ; ah = error code, dl = disk drive that dropped the error
  call print_hex ; check out the code at http://stanislavs.org/helppc/int_13-1.html
  jmp disk_loop

sectors_error:
  mov bx, SECTORS_ERROR
  call print

disk_loop:
  jmp $

DISK_ERROR: db "Disk read error", 0
SECTORS_ERROR: db "Incorrect number of sectors read", 0


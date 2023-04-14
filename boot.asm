; This is pretty much a boot sector. The only purpose of this module
; is to load our game code into memory and let CPU do the rest of the work of executing
; the game. This way we dont have any restriction on the game size and our game
; does not have to fit inside the bootsector which is 512B. The game code can
; reside independently on the disk.

ORG 0
BITS 16
_start:
    jmp short start
    nop
times 33 db 0

start:
    jmp 0x7c0:step2

step2:
    cli
    mov ax, 0x7c0                               ; set all the segment registers
    mov ds, ax
    mov es, ax
    mov ax, 0x00
    mov ss, ax
    mov sp, 0x7c00
    sti

    mov ax, 0003h                               ; Clear the screen
    int 10h

; the following block with load 3 sectors from the disk.
; These three sectors contain the actual game code. After
; loading to memory we jump to that memory adress to start
; executing our game code.
.load_game_sectors
    mov ah, 02h                                 ; bios function code for reading disk sectors into memory
    mov al, 3                                   ; Number of sectors to read
    mov ch, 0                                   ; lower eight bits of cylinder number
    mov cl, 2                                   ; Sector number (1-63). We want to read from the 2nd sector.
    mov dh, 0
    mov bx, 9000h                               ; memory adress where we want to load our sectors
    int 0x13                                    ; Bios interrupt call
    jc error
    jmp 9000h                                   ; If read successfully then jump to our game code
    jmp $                                       ; Keep jumping here

error:
    mov si, error_message
    call print
    jmp $

print:
    mov bx, 0
.loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .loop
.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10
    ret



error_message: db "Failed to load game sectors", 0

times 510-($ - $$) db 0
dw 0xAA55

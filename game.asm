; game state constants
%define start_pos_x 10
%define start_pos_y 10

%define VGA_WIDTH 319
%define VGA_HEIGHT 119
%define PLAYER_START_X 160
%define PLAYER_START_Y 170
%define PLAYER_LENGTH 20
%define PLAYER_WIDTH 10
%define PLAYER_VELOCITY 5

%define ENEMY_START_X 0
%define ENEMY_START_Y 0
%define ENEMY_LENGTH 20
%define ENEMY_WIDTH 5
%define ENEMY_X_VELOCITY 1
%define ENEMY_Y_VELOCITY 5
%define ENEMY_DIRECTION 1

%define BULLET_START_Y 200
%define BULLET_START_X 0
%define BULLET_Y_VELOCITY 2
%define BULLET_IS_VISIBLE 0



ORG 9000h

jmp _stage2_start

struc PlayerStruc
    .pos_x: resw 1
    .pos_y: resw 1
    .r_length: resw 1
    .r_width: resw 1
    .x_velocity: resw 1
endstruc

player:
    istruc PlayerStruc
        at PlayerStruc.pos_x, dw PLAYER_START_X
        at PlayerStruc.pos_y, dw PLAYER_START_Y
        at PlayerStruc.r_length, dw PLAYER_LENGTH
        at PlayerStruc.r_width, dw PLAYER_WIDTH
        at PlayerStruc.x_velocity, dw PLAYER_VELOCITY
    iend

struc Point
    .pos_x: resw 1
    .pos_y: resw 1
endstruc

struc EnemyStruc
    .pos_x: resw 1
    .pos_y: resw 1
    .r_length: resw 1
    .r_width: resw 1
    .x_velocity: resw 1
    .y_velocity: resw 1
    .x_direction: resb 1
endstruc

alien:
    istruc EnemyStruc
        at EnemyStruc.pos_x, dw ENEMY_START_X
        at EnemyStruc.pos_y, dw ENEMY_START_Y
        at EnemyStruc.r_length, dw ENEMY_LENGTH
        at EnemyStruc.r_width, dw ENEMY_WIDTH
        at EnemyStruc.x_velocity, dw ENEMY_X_VELOCITY
        at EnemyStruc.y_velocity, dw ENEMY_Y_VELOCITY
        at EnemyStruc.x_direction, db ENEMY_DIRECTION
    iend

struc BulletStruc
    .pos_x: resw 1
    .pos_y: resw 1
    .is_visible: resb 1
    .y_velocity: resw 1
endstruc

bullet:
    istruc BulletStruc
        at BulletStruc.pos_x, dw BULLET_START_X
        at BulletStruc.pos_y, dw BULLET_START_Y
        at BulletStruc.is_visible, db BULLET_IS_VISIBLE
        at BulletStruc.y_velocity, db BULLET_Y_VELOCITY
    iend



pt:
    istruc Point
        at Point.pos_x, dw start_pos_x
        at Point.pos_y, dw start_pos_y
    iend

score: db 'Hello world'
score_length: db $ - score

_stage2_start:

    mov ax, 0013h
    int 10h
    call clear_screen
    ;call write_text


game_loop:

    call game_state_upate
    call draw
    call delay

    jmp game_loop

init:

    mov word[pt+Point.pos_x], start_pos_x
    mov word[pt+Point.pos_y], start_pos_y
    ret

game_state_upate:

    push ax
    push bx
    push cx
    mov ah, 1h
    int 16h
    jz .input_handling_done

    xor ah, ah
    int 16h

    cmp al, 'a'
    jz .move_left

    cmp al, 'd'
    jz .move_right

    cmp al, 'w'
    jz .move_up

    cmp al, 's'
    jz .move_down

    cmp al, ' '
    jz .spawn_bullet

    jmp .input_handling_done

.move_left:
    mov bx, word[player+PlayerStruc.pos_x]
    sub bx, word[player+PlayerStruc.x_velocity]
    cmp bx, 0
    jl .input_handling_done
    mov word[player+PlayerStruc.pos_x], bx
    jmp .input_handling_done

.move_right:
    mov bx, word[player+PlayerStruc.pos_x]
    add bx, word[player+PlayerStruc.x_velocity]
    add bx, word[player+PlayerStruc.r_width]
    cmp bx, VGA_WIDTH
    jg .input_handling_done
    sub bx, word[player+PlayerStruc.r_width]
    mov word[player+PlayerStruc.pos_x], bx
    jmp .input_handling_done

.move_up:
    ;dec word[player+Rectangle.pos_y]
    jmp .input_handling_done

.move_down:
    ;inc word[player+Rectangle.pos_y]
    jmp .input_handling_done

.spawn_bullet:
    cmp byte[bullet+BulletStruc.is_visible], 1
    je .input_handling_done
    mov ax, word[player+PlayerStruc.pos_y]
    sub ax, 5
    mov word[bullet+BulletStruc.pos_y], ax
    mov byte[bullet+BulletStruc.is_visible], 1


.input_handling_done:
    mov bx, word[alien+EnemyStruc.pos_x]
    mov ax, word[alien+EnemyStruc.x_velocity]
    imul byte[alien+EnemyStruc.x_direction]
    add bx, ax
    mov word[alien+EnemyStruc.pos_x], bx
    cmp bx, 0
    jnl .check_for_right_edge
    xor ah, ah
    mov al, byte[alien+EnemyStruc.x_direction]
    mov cl, -1
    imul cl
    mov byte[alien+EnemyStruc.x_direction], al
.check_for_right_edge:
    add bx, word[alien+EnemyStruc.r_length]
    cmp bx, VGA_WIDTH
    jl .enemy_movement_done
    xor ah, ah
    mov al, byte[alien+EnemyStruc.x_direction]
    mov cl, -1
    imul cl
    mov byte[alien+EnemyStruc.x_direction], al

    ; move the enemy down
    mov bx, word[alien+EnemyStruc.pos_y]
    add bx, word[alien+EnemyStruc.y_velocity]
    mov word[alien+EnemyStruc.pos_y], bx

.enemy_movement_done:

    cmp byte[bullet+BulletStruc.is_visible], 1
    jne .bullet_movement_done
    xor dx, dx
    xor bx, bx
    mov ax, word[player+PlayerStruc.r_length]
    mov bl, 2
    idiv bl
    xor ah, ah
    mov bx, word[player+PlayerStruc.pos_x]
    add bx, ax
    mov word[bullet+BulletStruc.pos_x], bx

    mov bx, word[bullet+BulletStruc.pos_y]
    sub bx, word[bullet+BulletStruc.y_velocity]
    mov word[bullet+BulletStruc.pos_y], bx
    add bx, 5
    cmp bx, 0
    jnl .bullet_movement_done
    mov byte[bullet+BulletStruc.is_visible], 0

.bullet_movement_done:
    cmp byte[bullet+BulletStruc.is_visible], 1
    jne .enemy_bullet_collision_detection_done
    mov bx, word[alien+EnemyStruc.pos_x]
    cmp word[bullet+BulletStruc.pos_x], bx
    jl .enemy_bullet_collision_detection_done
    add bx, word[alien+EnemyStruc.r_length]
    cmp word[bullet+BulletStruc.pos_x], bx
    jg .enemy_bullet_collision_detection_done
    mov bx, word[alien+EnemyStruc.pos_y]
    add bx, word[alien+EnemyStruc.r_width]
    cmp word[bullet+BulletStruc.pos_y], bx
    jg .enemy_bullet_collision_detection_done

    mov byte[bullet+BulletStruc.is_visible], 0
    mov word[alien+EnemyStruc.pos_x], ENEMY_START_X
    mov word[alien+EnemyStruc.pos_y], ENEMY_START_Y
    mov word[bullet+BulletStruc.pos_x], BULLET_START_X
    mov word[bullet+BulletStruc.pos_y], BULLET_START_Y

.enemy_bullet_collision_detection_done:
    mov bx, word[alien+EnemyStruc.pos_y]
    add bx, word[alien+EnemyStruc.r_width]
    cmp bx, word[player+PlayerStruc.pos_y]
    jl .player_dead_check_done
    call reset_game

.player_dead_check_done:

.done:
    pop cx
    pop bx
    pop ax
    ret

draw:

    push ax
    call clear_screen
    call write_text

    ; draw the player
    mov ax, word [player+PlayerStruc.pos_x]
    push ax
    mov ax, word[player+PlayerStruc.pos_y]
    push ax
    mov ax, word[player+PlayerStruc.r_length]
    push ax
    mov ax, word[player+PlayerStruc.r_width]
    push ax
    call draw_rectangle

    mov ax, word [alien+EnemyStruc.pos_x]
    push ax
    mov ax, word[alien+EnemyStruc.pos_y]
    push ax
    mov ax, word[alien+EnemyStruc.r_length]
    push ax
    mov ax, word[alien+EnemyStruc.r_width]
    push ax
    call draw_rectangle

    cmp byte[bullet+BulletStruc.is_visible], 1
    jne .done
    mov ax, word [bullet+BulletStruc.pos_x]
    push ax
    mov ax, word [bullet+BulletStruc.pos_y]
    push ax
    add ax, 5
    push ax
    call vline


    

.done:
    pop ax
    ret

delay:
    push cx
    push dx
    push ax
    xor cx, cx
    mov dx, 0fffh
    mov ah, 86h
    int 15h

.delay_done:
    pop ax
    pop dx
    pop cx

    ret

reset_game:
    mov word[player+PlayerStruc.pos_x], PLAYER_START_X
    mov word[player+PlayerStruc.pos_y], PLAYER_START_Y
    mov word[alien+EnemyStruc.pos_x], ENEMY_START_X
    mov word[alien+EnemyStruc.pos_y], ENEMY_START_Y
    mov word[bullet+BulletStruc.pos_x], BULLET_START_X
    mov word[bullet+BulletStruc.pos_y], BULLET_START_Y
    mov byte[bullet+BulletStruc.is_visible], 0
    ret

write_text:
    push ax
    push bx
    push cx
    push dx
    push bp
    push es

    mov ax, cs
    mov es, ax

    mov ax, 1300h
    mov bx, 0064h
    xor cx, cx
    mov cl, byte[score_length]
    xor dx, dx
    mov dl, 1
    mov dh, 0ah
    mov bp, score
    int 10h

.done
    pop es
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax

    ret

;.animate_rectangle:
    ;;call clear_screen
;
    ;;push cx
    ;;push dx
    ;;push ax
    ;;xor cx, cx
    ;;mov dx, 0fffh
    ;;mov ah, 86h
    ;;int 15h
    ;;pop ax
    ;;pop dx
    ;;pop cx
;
    ;mov ax, word[rect+Rectangle.pos_x]
    ;push ax
    ;mov ax, word[rect+Rectangle.pos_y]
    ;push ax
    ;mov ax, word[rect+Rectangle.r_length]
    ;push ax
    ;mov ax, word[rect+Rectangle.r_width]
    ;push ax
    ;call draw_rectangle
    ;mov ah, 1h
    ;int 16h
    ;jz .animate_rectangle
;
    ;xor ah, ah
    ;int 16h
;
    ;cmp al, 'a'
    ;jz .move_left
;
    ;cmp al, 'd'
    ;jz .move_right
;
    ;cmp al, 'w'
    ;jz .move_up
;
    ;cmp al, 's'
    ;jz .move_down
;
    ;jmp .animate_rectangle
;
;.move_left:
    ;dec word[rect+Rectangle.pos_x]
    ;jmp .animate_rectangle
;
;.move_right:
    ;inc word[rect+Rectangle.pos_x]
    ;jmp .animate_rectangle
;
;.move_up:
    ;dec word[rect+Rectangle.pos_y]
    ;jmp .animate_rectangle
;
;.move_down:
    ;inc word[rect+Rectangle.pos_y]
    ;jmp .animate_rectangle


clear_screen:
    push ax
    push bx
    push cx
    push es
    push di

    mov al, 0x0
    mov ah, al
    mov bx, 0A000H
    mov es, bx
    mov cx, 32000
    mov di, 0
    rep stosw

    pop di
    pop es
    pop cx
    pop bx
    pop ax

    ret

set_pixel:
    push ax
    push bx
    push cx
    push dx
    push bp
    push es
    mov bp, sp

    mov ax, [bp+12]
    cmp ax, 0
    jl .end_pixel
    cmp ax, 199
    jg .end_pixel

    mov bx, [bp+14]
    cmp bx, 0
    jl .end_pixel
    cmp bx, 319
    jg .end_pixel

    mov cx, 320
    imul cx
    add bx, ax

    mov ax, 0a000h
    mov es, ax

    mov al, 9
    mov [es:bx], al

.end_pixel:
    pop es
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret 4

draw_a_dot:
    mov ax, 300
    push ax
    mov ax, 100
    push ax
    call set_pixel
    ret

hline:
    push ax
    push bx
    push cx
    push dx
    push di
    push bp
    ;push es
    mov bp, sp

    mov ax, [bp+14]
    cmp ax, 0
    jl .hline_done
    cmp ax, 199
    jg .hline_done

    mov bx, 320
    imul bx
    mov [bp+14], ax

    mov ax, [bp+18]
    mov bx, [bp+16]

    cmp ax, bx
    jle .hline_sort
    xchg ax, bx
.hline_sort:
    cmp ax, 0
    jge .done_x1
    mov ax, 0

.done_x1:
    cmp bx, 319
    jle .done_x2
    mov bx, 319

.done_x2:
    cmp ax, bx
    jg .hline_done

    sub bx, ax
    inc bx
    mov cx, bx
    
    add ax, [bp+14]
    mov di, ax

    mov ax, 0a000h
    mov es, ax

    mov ax, 9
    cld
    rep stosb

.hline_done:
    ;pop es
    pop bp
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret 6

vline:
    ;push es
    push ax
    push bx
    push cx
    push dx
    push bp
    mov bp, sp

    mov ax, [bp+16]
    cmp ax, 0
    jl .vline_done
    cmp ax, 319
    jg .vline_done

    mov ax, [bp+14]
    mov bx, [bp+12]

    cmp ax, bx
    jle .vline_sort
    xchg ax, bx

.vline_sort:
    cmp ax, 0
    jge .done_y1
    mov ax, 0

.done_y1:
    cmp bx, 199
    jle .done_y2
    mov bx, 199

.done_y2:
    cmp ax, bx
    jg .vline_done

    sub bx, ax
    inc bx
    mov cx, bx

    mov bx, 320
    imul bx
    add ax, [bp+16]
    mov bx, ax

    mov ax, 0a000h
    mov es, ax

    mov al, 9

.vline_loop:
    mov [es:bx], al
    add bx, 320
    loop .vline_loop

.vline_done:
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ;pop es
    ret 6

draw_rectangle:
    push ax
    push bx
    push cx
    push dx
    push bp
    mov bp, sp

    ; [bp+12] -> breadth
    ; [bp+14] -> length
    ; [bp+16] -> y
    ; [bp+18] -> x

    mov ax, [bp+18]
    mov bx, [bp+16]
    push ax
    add ax, [bp+14]
    push ax
    push bx
    call hline
    push ax
    push bx
    add bx, [bp+12]
    push bx
    call vline
    push ax
    sub ax, [bp+14]
    push ax
    push bx
    call hline
    push ax
    push bx
    sub bx, [bp+12]
    push bx
    call vline

.rectangle_done:
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret 8

times 1024 - ($ - $$) db 0

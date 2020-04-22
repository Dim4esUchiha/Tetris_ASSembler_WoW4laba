.model tiny
.code

org 100h

start:
    push 0b800h;adres videopamati
    pop es
    
    mov ax,1;ystanovka videoreshima
    int 10h
       
new_game:    
    call delay
    call clear_field
    call niz_field
    call draw_box
init_new_fig:


    
    call check_lines
    call init_new_figure;v figure oofset(random) TetrisFigures
    
    mov fast,0
    mov corX,66
    mov corY,0  
    call check_game_over    
    cmp gameover,1
    jne new_game
    
    
    inc color
    cmp color,8
    je zero_color
obratno:        
main_cycle:    
    call draw_field
    call draw_figure
    cmp fast,1
    je fast_down
    call delay;shdem nashatie klavishi
    call key 
fast_down:              
    call check_ground
    cmp canleave,0
    je init_new_fig;;;;tut eshe v field nado zapisat figuru esli nelza v check_ground
    ;proverka na zemlu
    ;da -zapisat figure v field(v check_ground) , new figure
    ;net - idem dalshe    
    inc corY        
    jmp main_cycle                     
    jmp to_end
    
zero_color:
    mov color,3
    jmp obratno 
;;;;;;;;;;;;;;;;;;;;SDVIG_POLE;;;;;;;;;;;;;;;;;;;;;;;;;                                              
sdvig_pole proc
    push cx
    xor ax,ax
    mov ax,yfor_lines
    
    mov cx,ax
    dec cx
    
    mov bx,18
    mul bx
        
    mov di,offset field
    add di,ax
    
    mov si,offset field
    add si,ax
    sub si,18
        
perepis_loop:
    mov dx,18
    
    iz_si_v_di:
        mov al,[si]
        mov [di],al
        inc di
        inc si
        dec dx
        cmp dx,0
        je next_strochka
        jmp iz_si_v_di
next_strochka:
        sub si,36
        sub di,36        
    loop perepis_loop
    pop cx    
    ret
sdvig_pole endp                                             
;;;;;;;;;;;;;;CHECK_LINE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_line proc
    push cx
    mov cx,9
    xor ax,ax
    xor bx,bx
    
    mov ax,yfor_lines
    mov bx,18
    mul bx
    
    mov di,offset field
    add di,ax
check_line_loop:
    cmp [di],0
    je no_line
    add di,2                  
    loop check_line_loop
    
    mov gotovo,0
    jmp end_check_line
no_line:
    mov gotovo,1        
end_check_line:    
    pop cx
    ret
check_line endp
;;;;;;;;;;;;;;;CHECK_LINES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_lines proc
    pusha
    push es
    push 0700h
    pop es
    
    mov ax,corY;20;corY    
    mov yfor_lines,ax
    
    mov cx,3
    
    call otstup_snizu
    mov ax,otstupsnizu
    sub cx,ax 
            
check_lines_loop:    
    call check_line
    cmp gotovo,1
    jne sdvig_field
ugu:  
    inc yfor_lines
    loop check_lines_loop
    jmp end_check_lines
sdvig_field:
    call sdvig_pole    
    jmp ugu 
end_check_lines:
    pop es    
    popa
    ret
check_lines endp
;;;;;;;;;;;;;;;CLEAR_FIELD;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
clear_field proc
    pusha       
    mov di,offset field
    mov cx,432
clear_loop:        
    
    mov [di],0               
    inc di               
    loop clear_loop
    
    popa
    ret
clear_field endp   
;;;;;;;;;;;;;;;;;;;;;CHECK_GAME_OVER;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
check_game_over proc
    pusha
    push es
    push 0700h
    pop es           
    
    
    mov di,offset field

    mov cx,9
check_game_over_loop:
    cmp [di],0
    jne yes_game_over
    add di,2
    loop check_game_over_loop    
no_game_over:    
    mov gameover,1
    jmp end_check_game_over
yes_game_over:    
    mov gameover,0
end_check_game_over:    
    pop es
    popa
    ret
check_game_over endp        
;;;;;;;;;;;;;;;;MOVE_TO_FIELD;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
move_to_field proc
    pusha 
    
    xor ax,ax
    mov al,color
    
    push es 
    push 0700h
    pop es
    mov si,offset figure
    
    mov di,offset field    
    call get_field_cor
    add di,corXField

    
    mov count,0

tri_po_tri:
    cmp count,3
    je end_move
    mov cx,3
move_loop:
    cmp [si],1
    jne next_move
    mov [di],219
    inc di
    mov [di],al
    inc di
    sub di,2
next_move:
    inc si
    add di,2       
    loop move_loop
    inc count
    sub di,6
    add di,18
    jmp tri_po_tri
   
end_move:                
    pop es
    popa
    ret
move_to_field endp
;;;;;;;;;;;;;;;CHECK_GROUND;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_ground proc
    pusha
    push es       
    push 0700h
    pop es 
    
    mov count,0
    
    mov si,offset figure
    add si,6
        
    mov di,offset field
    
    call get_field_cor
    add di,corXField
    add di,54
    
check_liniya:
    cmp count,3
    je can_leave    
    mov cx,3
check_3_gr:
    cmp [si],0 
    jne check_di
no_di:
    inc si
    add di,2
    loop check_3_gr     
    
    dec si
    sub si,5
    
    sub di,6
    sub di,18
    inc count
    jmp check_liniya
        
check_di:
    cmp [di],0
    jne cant_leave        
    jmp no_di
can_leave:
    mov canleave,1
    jmp end_check_ground
cant_leave:
    mov canleave,0 
    call move_to_field          
end_check_ground:        
    pop es
    popa
    ret
check_ground endp
;;;;;;;;;;;;GET_FIELD_COR;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
get_field_cor proc
    pusha
    
    mov ax,corY
    mov corYField,ax
    mov bx,18 
    mul bx
    mov cx,corX
    sub cx,60
    add ax,cx
    ;v a x koordinata ugla kvadratika
    mov corXField,ax
  
    popa
    ret
get_field_cor endp
;;;;;;;;;;;;OTSTUPI;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
otstup_snizu proc
    pusha
    xor ax,ax
    mov si,offset figure
    push si
    
    
    add si,6
    mov cx,3
otstup_niz:
    cmp [si],0
    jne end_otstup_niz        
    inc si
    loop otstup_niz
    
    inc ax
    pop si
    push si;bespolezno no dla logiki nado
    add si,3
    
    mov cx,3
plus_otstup:
    cmp [si],0
    jne end_otstup_niz
    inc si
    loop plus_otstup
        
    inc ax
    
end_otstup_niz:
    mov otstupsnizu,ax
    pop si    
    popa
    ret
otstup_snizu endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;getOtstup_pravo;;;;;;;;;;;;;;;;;;
getOtstup_pravo proc
    pusha
    
    mov si,offset FIGURE
    add si,2
    mov ax,0;otstup
    
    mov cx,3
    
    push si
get_otstupr:
    cmp [si],0
    jne konec_otstupr    
    add si,3
    loop get_otstupr
    add ax,2
    
       
    pop si
    dec si
    mov cx,3
next_stolbecr:
    cmp [si],0
    jne konec_otstupr    
    add si,3   
    loop next_stolbecr        
    add ax,2
konec_otstupr:
    cmp ax,0
    jne kk1
    pop si
kk1:
    mov otstuppravo,ax
    popa
    ret
getOtstup_pravo endp 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;getOtstup_levo;;;;;;;;;;;;;;;;;;
getOtstup_levo proc
    pusha
    
    mov si,offset FIGURE
    mov ax,0;otstup
    
    mov cx,3
    
    push si
get_otstupl:
    cmp [si],0
    jne konec_otstupl    
    add si,3
    loop get_otstupl
    add ax,2
        
    pop si
    inc si
    mov cx,3
next_stolbecl:
    cmp [si],0
    jne konec_otstupl    
    add si,3   
    loop next_stolbecl        
    add ax,2
konec_otstupl:
    cmp ax,0
    jne kk
    pop si
kk:
    mov otstuplevo,ax
    popa
    ret
getOtstup_levo endp
;;;;;;;;;;;check_valid_corX;;;;;;;;;;;;;;
check_valid_corX proc
    pusha
    mov ax,corY
    mov bx,SCREEN_WIDTH
    mul bx
    
    mov cx,ax
    add cx,corX
    
    
    add ax,start_field_pos;start_field_pos;lavaya granica
    
    mov dx,ax
    
    sub ax,2
    sub ax,otstuplevo
    
    xor bx,bx
    mov bx,dx
    
    add bx,14;pravaya
    add bx,otstuppravo
    ;v ax nachalo linii
    ;v cx koor ugla otkuda risuem
    
    cmp ax,cx
    jl check_right
    jmp ne_norm
check_right:
    cmp bx,cx
    ja normm
    jmp ne_norm    
normm:   
    mov norm,1
    jmp check_end    
ne_norm: 
    mov norm,0
    jmp check_end    
check_end:        
    popa
    ret
check_valid_corX endp
;;;;;;;;;;;;DELAY;;;;;;;;;;;;;;;;;;;;;;;;;
delay proc
    pusha    
    mov cx,0000
    mov dx,60000;60miliseconds
    mov ah,86h
    int 15h
    int 15h 
    int 15h
    int 15h
    int 15h 
    popa    
    ret
delay endp 
;;;;;;;;;;;;;GETCOR;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
getCor proc
    push ax    
    push bx
    mov ax,corY
    
    mov bx,SCREEN_WIDTH
    mul bx
    
    add ax,corX 
    mov di,ax
    
    pop bx
    pop ax
    ret
getCor endp    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;INIT_NEW_FIGURE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_new_figure proc
    pusha
check_rand:
    cmp rand,3
    jne ini
    mov rand,0    
ini:    
    mov ax,rand
    mov bx,9
    mul bx
    
    mov si,offset figure ; kuda peresilayem
    mov di,offset TetrisFigures
    add di,ax
    
    mov cx,9 
init_new:
    mov bl,[di]
    mov [si],bl
    inc si
    inc di
    loop init_new
    inc rand    
    popa 
    ret
init_new_figure endp
;;;;;;;;;;;;;DRAW_FIGURE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;otrisovka figuri
draw_figure proc
    pusha
    xor ax,ax
    mov al,color
    mov count,0
    
    
    call getCor;mov di,corY*SCREEN_WIDTH;66
    
    mov cx,9
    mov si,offset figure
draw_figure_loop:
    cmp count,3
    je next_draw_line 
check: 
    cmp cx,0
    je end_draw_figure   
    cmp [si],0
    jne draw_brick
    
    inc count
    add di,2
    inc si
    loop draw_figure_loop
    jmp end_draw_figure
    
next_draw_line:
    mov count,0
    sub di,6
    add di,SCREEN_WIDTH    
    jmp check
draw_brick:    
    push si
    lea si,brick
    add brick[1],al
    movsw   
    
    pop si
    inc si
    
    sub brick[1],al
    dec cx
    inc count
    jmp draw_figure_loop 
end_draw_figure:
    mov count,0    
    popa
    ;inc color
    ret 
draw_figure endp 


;;;;;;;;;;;;;COPY v di zapisivaem to chto v si;;;;;;;;;;;;;;;;;;;;;;;;;
copy proc
    push es
    push ds
    pop es     
    mov cx,9    
    rep
    movsb 
    pop es   
    ret
copy endp  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_f_zero proc
    pusha
    
    mov si,offset figure
    
    mov di,offset field
    call get_field_cor
    add di,corXField
    
    mov count,0
check_l:
    cmp count,3
    je end_check_f_zero_one
    mov cx,3
one_check:                    ;;norm_rotate
    cmp [si],0
    jne chec_one_di    
check_si_next:    
    inc si
    add di,2
    loop one_check
    
    inc count
    sub di,6
    add di,18
    jmp check_l    
chec_one_di:
    cmp [di],0
    jne end_check_f_zero_zero 
    
    jmp check_si_next
    
end_check_f_zero_zero:
    mov norm_rotate,0
    jmp enddd        
end_check_f_zero_one:
    mov norm_rotate,1
enddd:        
    popa
    ret
check_f_zero endp
;;;;;;;;;;;;;;;ROTATE_FIGURE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rotate_figure proc
    pusha         
    push es
    push 0700h
    pop es
    
    
    
    mov di,offset previous
    mov si,offset figure
    call copy
    
    mov di,offset rotated_figure
    mov si,offset figure
    
    
    add si,6
    mov bx,3
    mov cx,3
    jmp rotate
checks:
    dec bx
    cmp bx,0
    je rotate_end
    sub si,6
    
    sub di,9
    inc di
    
    mov cx,3
rotate:
    mov al,[si]
    mov [di],al
    inc si
    add di,3
    loop rotate
    jmp checks
rotate_end:
    
    
    push norm
        
    mov di,offset Figure
    mov si,offset rotated_figure
    call copy
    
        
    call getOtstup_levo
    call getOtstup_pravo
    call check_valid_corX
    
    cmp norm,1
    je check_field_zero   
    jmp no_rotate
    
    
check_field_zero:
    call check_f_zero   
    cmp norm_rotate,1
    je end_rotate        
no_rotate:    
    mov di,offset FIGURE
    mov si,offset previous
    call copy
    
end_rotate:    
    pop norm
    pop es
    popa
    ret
rotate_figure endp
;;;;;;;;;;;;;;;;;;;CHECK_RIGHT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_right_b proc
    pusha 
    
    push es
    push 0700h
    pop es
    
    mov count,0
    
    mov si,offset figure
    add si,2
   
    mov di,offset field
    call get_field_cor
    add di,corXField
    add di,4
    
check_right_liniya:
    cmp count,3
    je can_leave_right
    mov cx,3
check_3_right:
    cmp [si],0
    jne check_di_right
no_di_rght:
    add si,3
    add di,18
    loop check_3_right    
    
    
    sub si,3
    sub si,7
    
    sub di,54
    dec di
    inc count
    jmp check_right_liniya
    
check_di_right:
    cmp [di],0
    jne cant_leave_right
    jmp no_di_rght    
    
can_leave_right:
    mov norm_right,1
    jmp end_right
cant_leave_right:
    mov norm_right,0      
end_right:        
    pop es
    popa
    ret
check_right_b endp
;;;;;;;;;;;;;;;;;;;CHECK_LEFT;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
check_left proc
    pusha
    push es
    push 0700h
    pop es    
    
    mov count,0
    
    mov si,offset figure
    mov di,offset field
    call get_field_cor
    add di,corXField
check_left_liniya:
    cmp count,3
    je can_leave_left
    mov cx,3
check_3_left:
    cmp [si],0
    jne check_di_left
no_di_lft:
    add si,3
    add di,18
    loop check_3_left
    
    sub si,3
    sub si,5
    
    sub di,52
    inc di
    inc count
    jmp check_left_liniya

check_di_left:
    cmp [di],0
    jne cant_leave_left
    jmp no_di_lft    
    
can_leave_left:
    mov norm_left,1
    jmp end_left
cant_leave_left:
    mov norm_left,0      
end_left:
    pop es    
    popa
    ret
check_left endp
;;;;;;;;;;;;;KEY;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;obrabotchik klaviaturi
key proc
    pusha
    xor ax,ax
    
    mov ah,1;func proverki klavi
    int 16h
    jz key_end;no_key_pressed;klavisha ne nashata
    
    xor ah,ah
    int 16h;schitivaem klavishu v ah ee kod
    ;75 - strelka vlevo
    ;77 - strelka vpravo
    ;72 - strelka vverx
    ;80 - strelka vniz
    cmp ah,75
    jne not_key_strelka_vlevo
    ;deistviya po nashatiyu "vlevo"
    
    sub corX,2;sdvigaem vlevo
    call getOtstup_levo;berem otstup tekushei figuri
    call check_valid_corX;proverayem koordinati figuri    
    cmp norm,1;norm v konec(popadaet v granicu)
    je check_left_border
    add corX,2
    jmp key_end
    
check_left_border:;(proverka chtobi bilo tam pusto)    
    call check_left
    cmp norm_left,0
    jne key_end    
    add corX,2;esli net to sdvinut nelza vozrashaem koordinati obratno
    jmp key_end
    
       
not_key_strelka_vlevo:
    cmp ah,77
    jne key_vverx_mb        
    ;deistviya po nashatiyu "vpravo"
    add corX,2
    call getOtstup_pravo 
    call check_valid_corX   
    
    cmp norm,1
    je check_right_border
    sub corX,2
    jmp key_end
check_right_border:
    call check_right_b
    cmp norm_right,0
    jne key_end
    sub corX,2
    jmp key_end
    
        
key_vverx_mb: 
    cmp ah,72
    jne key_vniz_mb
    
    call rotate_figure   
    jmp key_end
    
key_vniz_mb:
    cmp ah,80
    jne key_end
    mov fast,1        
key_end:    
    popa
    ret
key endp 
;;;;;;;;;;;;;;DRAW_FIELD;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;otrisovka vnutrennosti korobki                                             
draw_field proc
    pusha
    
    mov di,start_field_pos
    mov si,offset field
    mov cx,216
    mov ax,0
fill:
    cmp cx,0
    je end_draw_field
    cmp ax,9
    je next_line
draw:
    movsw
    inc ax 
    dec cx
    jmp fill
next_line:
    mov ax,0
    sub di,18
    add di,SCREEN_WIDTH
    jmp draw
end_draw_field: 
    popa   
    ret
draw_field endp 
;;;;;;;;;;;;;;;DRAW_BOX;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;otrisovka obolochki korobki    
draw_box proc
    pusha
    
    mov ax,48;vsego 48 bricks po obe storoni  
    mov di,start_pos_box
rightStena:
    mov cx,24
my_loop:
    mov si,offset stena
    movsw
        
    dec ax
        
    add di,78
    loop my_loop 
        
    mov di,78
    cmp ax,0
    jnz rightStena  
    
    popa      
    ret
draw_box endp
;;;;;;;;;;;;NIZ_FIELD;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;pol korobki
niz_field proc
    pusha
    mov si,offset field
    add si,414
    mov cx,9
nizf:
    mov [si],219;219
    inc si
    mov [si],7
    inc si
    loop nizf
        
    popa
    ret
niz_field endp  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SCRENN_HEIGHT equ 24
SCREEN_WIDTH equ 80
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stena db 186,1dh
brick db 219,0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start_pos_box dw 58
start_field_pos dw 60
field db 432 dup(0)

color db 3
count db 0
count_move db 0


norm dw 0 
norm_left dw 0
norm_right dw 0
norm_rotate dw 0

otstuplevo dw 0
otstuppravo dw 0
otstupsnizu dw 0

touch_Groung_flag dw 0

corX dw 0
corY dw 0

yfor_lines dw 0

corXField dw 0
corYField dw 0
field_length dw 0

canleave dw 0

gameover dw 0
gotovo dw 0

previous db 9 dup(?)
rotated_figure db 9 dup(?)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
rand dw 2
fast dw 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
figure db 9 dup(?)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TetrisFigures:
        db 0,1,0
        db 1,1,1
        db 0,0,0
        ;;;;;;;;
        db 1,1,0
        db 1,1,0
        db 0,0,0
        ;;;;;;;;
        db 1,1,0
        db 1,0,0
        db 1,0,0  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to_end:    
    mov ah,4ch
    int 21h   
end start    
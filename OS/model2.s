;TEAM：zzz Class：1519
START:
    mov ax,0a90h                ; 起始地址
    mov ds,ax
    mov ax,0b800h 
    mov es,ax
    mov word[x],0              ;x = -1
    mov word[y],39               ;y = -1
    mov byte[dir],D_R           ;dir = 1
    mov byte[color],5fh         ;color = 1fh
    mov word[cnt], 0
BEGIN:
    inc word[cnt]
    cmp word[cnt], 400          ; 用于用户程序的计时，到达256时退出程序
    jz RETURN

    mov ah,01h
    int 16h
    jnz RETURN
    mov cx,070h
    jmp DELAY
RETURN:
    ret
DELAY:                          ; 二重循环用以延时
    push cx
    mov  cx,0ffffh
DELAY2:
    loop DELAY2
    pop  cx
    loop DELAY
    ; 选择一个方向    
    cmp byte[dir],1
    jz DDRR
    cmp byte[dir],2
    jz DDLL
    cmp byte[dir],3
    jz UURR
    cmp byte[dir],4
    jz UULL
    jmp START

;down and right 
DDRR:
    mov byte[dir],D_R
    cmp word[y],79
    jz DDLL
    cmp word[x],12
    jz UURR
    inc word[x]
    inc word[y]
    jmp SHOW

;down and left
DDLL:
    mov byte[dir],D_L
    cmp word[y],40
    jz DDRR
    cmp word[x],12
    jz UULL
    inc word[x]
    dec word[y]
    jmp SHOW

;up and left
UULL:
    mov byte[dir],U_L
    cmp word[y],40
    jz UURR
    cmp word[x],0
    jz DDLL
    dec word[x]
    dec word[y]
    jmp SHOW

;up and right
UURR:
    mov byte[dir],U_R
    cmp word[y],79
    jz UULL
    cmp word[x],0
    jz DDRR
    dec word[x]
    inc word[y]
    jmp SHOW

SHOW:
    ;show the char 'A'
    mov ax,[x]
    mov cx,80
    mul cx
    add ax,[y]
    mov cx,2
    mul cx
    mov bx,ax
    mov al,'A'
    mov ah,05h
    mov [es:bx],ax
    
    jmp SHOW_NAME
    jmp BEGIN

;show the Team and Class
SHOW_NAME: 
    mov word[xx],4
    mov cx,4
LOOP1:  
    push cx
    mov word[yy],50
    mov cx,17
LOOP2:
    call CAL
    mov byte[es:bx],'#'
    mov al,07h
    mov byte[es:bx+1],al
    inc word[yy]    
    loop LOOP2
    pop cx
    inc word[xx]
    loop LOOP1
    ;show the name
    mov word[xx],5
    mov word[yy],52
    mov si,0
    mov cx,13
LOOP3:
    call CAL
    mov al,byte[myname+si]
    mov byte[es:bx],al
    inc word[yy]
    inc si
    loop LOOP3
    ;show the ID
    mov word[xx],6
    mov word[yy],53
    mov si,0
    mov cx,11
LOOP4:
    call CAL
    mov al,byte[myid+si]
    mov byte[es:bx],al
    inc word[yy]
    inc si
    loop LOOP4
    
    jmp BEGIN

CAL:mov ax,word[xx]
    mov bx,80
    mul bx
    add ax,word[yy]
    mov bx,2
    mul bx
    mov bx,ax
    ret
    
end:
    jmp $ 

DEFINE:
    D_R equ 1
    D_L equ 2
    U_R equ 3
    U_L equ 4
    xx dw 0
    yy dw 0
    x dw 0
    y dw 0
    dir db D_R
    myname db '     ZZZ     '
    myid db '   15 19   '
    color db 4fh
    cnt dw 0
    times 1022-($-$$) db 0
    db 0x55,0xaa
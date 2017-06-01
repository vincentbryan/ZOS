int33h proc
	cli
	push es
	push ax
	;es置零
	xor ax,ax
	mov es,ax
	;填充中断向量
	mov word ptr es:[0cch],offset interrupt33h
	mov ax,800h
	mov word ptr es:[0ceh],ax
	pop ax
	pop es
	sti
	ret
int33h endp

message33h1 db 'This is program of INT 33H'
message33h1length equ $-message33h1
;中断处理程序33h
interrupt33h proc
 	cli
	push es
	push si
	push di
	push ax
	push bx
	push cx
	push dx
	push bp
	push ds
	
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,0001h;bl颜色
	mov dx,0408h;行，列
	mov cx,message33h1length
	mov bp,offset message33h1
	int 10h
	
	mov al,20h
	out 20h,al
	out 0a0h,al

	pop ds
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
	pop es
 	sti
 	iret
interrupt33h endp

;INT 34H 右上角显示
;填充34h中断向量表
int34h proc
	cli
	push es
	push ax
	
	xor ax,ax
	mov es,ax
	mov word ptr es:[0d0h],offset interrupt34h
	mov ax,800h
	mov word ptr es:[0d2h],ax
	
	pop ax
	pop es
	sti
	ret
int34h endp

message34h1 db 'This is program of INT 34H'
message34h1length equ $-message34h1
;中断处理程序34h
interrupt34h proc
	cli
	push es
	push si
	push di
	push ax
	push bx
	push cx
	push dx
	push bp
	push ds
	
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,0002h;bl颜色
	mov dx,0508h;行，列
	mov cx,message34h1length
	mov bp,offset message34h1
	int 10h
	
	
	mov al,20h
	out 20h,al
	out 0a0h,al

	pop ds
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
	pop es
	sti
	iret
interrupt34h endp


;INT 35H 左下角显示
;填充35h中断向量表
int35h proc
	cli
	push es
	push ax
	
	xor ax,ax
	mov es,ax
	mov word ptr es:[0D4h],offset interrupt35h
	mov ax,800h
	mov word ptr es:[0d6h],ax
	
	pop ax
	pop es
	sti
	ret
int35h endp

message35h1 db 'This is program of INT 35H'
message35h1length equ $-message35h1
;中断处理程序35h
interrupt35h proc
	cli
	push es
	push si
	push di
	push ax
	push bx
	push cx
	push dx
	push bp
	push ds
	
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,0003h;bl颜色
	mov dx,0608h;行，列
	mov cx,message35h1length
	mov bp,offset message35h1
	int 10h
	
	mov al,20h
	out 20h,al
	out 0a0h,al

	pop ds
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
	pop es
	sti
	iret
interrupt35h endp

;INT 36H 右下角显示
;填充36h中断向量表
int36h proc
	cli
	push es
	push ax
	
	xor ax,ax
	mov es,ax
	mov word ptr es:[0d8h],offset interrupt36h
	mov ax,800h
	mov word ptr es:[0dah],ax
	
	pop ax
	pop es
	sti
	ret
int36h endp

message36h1 db 'This is program of INT 36H'
message36h1length equ $-message36h1
;中断处理程序36h
interrupt36h proc
	cli
	push es
	push si
	push di
	push ax
	push bx
	push cx
	push dx
	push bp
	push ds
	
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,0004h;bl颜色
	mov dx,0708h;行，列
	mov cx,message36h1length
	mov bp,offset message36h1
	int 10h
	
	mov al,20h
	out 20h,al
	out 0a0h,al

	pop ds
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
	pop es
	sti
	iret
interrupt36h endp




;系统调用21h，设置中断向量表
int21h proc 
	cli
	push ax
	push es
	xor ax,ax
	mov es,ax
	mov word ptr es:[84h],offset mysyscall
	mov ax,800h
	mov word ptr es:[86h],ax
	pop es
	pop ax
	sti
	ret
int21h endp

;跳转分支表
syscall_vector dw syscall0,syscall1,syscall2,syscall3
;系统调用入口，根据ah来判断具体功能
;因为此处用到al,bx，所以al,bx不能作为系统调用的参数
mysyscall proc
	cli
	push es
	push si
	push di
	push ax
	push bx
	push cx
	push dx
	push bp
	push ds
	;非法ah值将直接返回
	cmp ah,3
	jg mysyscall_next
	;计算系统调用的偏移量
	mov al,ah
	xor ah,ah
	shl ax,1;*2
	mov bx,offset syscall_vector
	add bx,ax
	;改段地址
	mov ax,800h
	mov es,ax
	mov ds,ax
	;调用对应系统调用
	call word ptr [bx]

mysyscall_next:
	mov al,20h
	out 20h,al
	out 0a0h,al
	
	pop ds
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	pop di
	pop si
	pop es
	sti
	iret
mysyscall endp
 

syscall0_Msg db 'This is program of sysycall_0'
syscall0_Msg_len equ $-syscall0_Msg
;中断处理程序syscall0h
syscall0 proc
	
	mov ax,800h
	mov es,ax
	mov ax,1301h
	mov bx,0005h;bl颜色
	mov dx,0508h;行，列
	mov cx,syscall0_Msg_len
	mov bp,offset syscall0_Msg
	int 10h
	
	mov al,20h
	out 20h,al
	out 0a0h,al

	ret
syscall0 endp

syscall1_Msg db 'This is program of sysycall_1'
syscall1_Msg_len equ $-syscall1_Msg
syscall1 proc

	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,0004h;bl颜色
	mov dx,0608h;行，列
	mov cx,syscall1_Msg_len
	mov bp,offset syscall1_Msg
	int 10h
	
	mov al,20h
	out 20h,al
	out 0a0h,al

	ret
syscall1 endp

syscall2_Msg db 'This is program of sysycall_2'
syscall2_Msg_len equ $-syscall2_Msg
syscall2 proc
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,0003h;bl颜色
	mov dx,0708h;行，列
	mov cx,syscall2_Msg_len
	mov bp,offset syscall2_Msg
	int 10h
	
	mov al,20h
	out 20h,al
	out 0a0h,al

	ret
syscall2 endp

syscall3_Msg db 'This is program of sysycall_3'
syscall3_Msg_len equ $-syscall3_Msg
syscall3 proc
	mov ax,cs
	mov es,ax
	mov ax,1301h
	mov bx,0002h;bl颜色
	mov dx,0808h;行，列
	mov cx,syscall3_Msg_len
	mov bp,offset syscall3_Msg
	int 10h
	
	mov al,20h
	out 20h,al
	out 0a0h,al

	ret
syscall3 endp
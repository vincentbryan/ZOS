
set_keyboard_interrupt proc
	cli
	push es
	push ax
	xor ax,ax
	mov es,ax
	;save the vector
	mov ax,word ptr es:[24h]
	mov word ptr [keyboardVec],ax
	mov ax,word ptr es:[26h]
	mov word ptr [keyboardVec+2],ax
	;fill the vector
	mov word ptr es:[24h],offset Ouch
	mov ax,800h
	mov word ptr es:[26h],ax
	;用于中断服务C程序的变量
	mov word ptr [_is_ouch],0	
	pop ax
	pop es
	sti
	ret
set_keyboard_interrupt endp
Ouch proc
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

	call near ptr _c_ouch
	;读缓冲区
	in al,60h
	
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
Ouch endp
re_keyboard_interrupt proc
	cli
	push es
	push ax
	xor ax,ax
	mov es,ax
	mov ax,word ptr [keyboardVec]
	mov word ptr es:[24h],ax
	mov ax,word ptr [keyboardVec+2]
	mov word ptr es:[26h],ax
	;用于中断服务C程序的变量
	mov word ptr [_is_ouch],0
	pop ax
	pop es
	sti
	ret
re_keyboard_interrupt endp
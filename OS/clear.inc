;清屏
public _clear
_clear proc 
    push ax
    push bx
    push cx
    push dx		
    mov	ax, 0600h			; AH = 6,  AL = 0
	mov	bx, 0700h			; 黑底白字(BL = 7)
	mov	cx, 0				; 左上角: (0, 0)
	mov	dx, 184fh			; 右下角: (24, 79)
	int	10h					; 显示中断
	mov word ptr [_x],0
	mov word ptr [_y],0
	mov word ptr [_pos],0
	call _setCursor
	pop dx
	pop cx
	pop bx
	pop ax
ret
_clear endp
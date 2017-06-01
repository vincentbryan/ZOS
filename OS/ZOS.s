extrn _main:near 
extrn _cal_pos:near
extrn _drawRect:near
extrn _pos:near
extrn _ch:near
extrn _x:near
extrn _y:near
extrn _offsetUser:near
extrn _d:near

; extrn _c_ouch:near
; extrn _is_ouch:near

extrn _curProc
extrn _saveProc
extrn _Schedule
extrn _special
extrn _procNum
extrn _curPCBid
extrn _procPtr


_TEXT segment byte public 'CODE'
DGROUP group _TEXT,_DATA,_BSS
	assume cs:_TEXT		;代码段为_TEXT开始
	org 100h
start:
	mov  ax,  800h	 
	mov  ds,  ax     	;数据段为800h    
	mov  es,  ax        
	mov  ss,  ax     	;栈段为800h
	mov  sp,  100h	 	;栈的起始为8100h
	; mov word ptr [800H:_procNum],3
	call near ptr _main
	jmp $

clkVec dw 0,0
keyboardVec dw 0,0
;置光标位置
public _setCursor
_setCursor proc
	push ax
	push bx
	push dx
	mov ah,02h
	mov dh,byte ptr [_x]
	mov dl,byte ptr [_y]
	mov bh,0
	int 10h
	pop dx
	pop bx
	pop ax
	ret
_setCursor endp


public _setInt
_setInt proc
	push ax
	push bx
	push dx
	int 33H
	int 34H
	int 35H
	int 36H
	pop dx
	pop bx
	pop ax
	ret
_setInt endp

public _set21Int
_set21Int proc
	push ax
	push bx
	push dx

	mov ah, 0
	int 21h
	mov ah, 1
	int 21h
	mov ah, 2
	int 21h
	mov ah, 3
	int 21h

	pop dx
	pop bx
	pop ax
	ret
_set21Int endp

;输出一个字符
public _printchar
_printchar proc
	push ax
	push es
	push bp
	push bx
	call _setCursor 				;设置光标
	mov bp,sp
	mov ax,0b800h   
	mov es,ax
	mov al,byte ptr [bp+2+2+2+2+2]	;取出字符
	mov ah,0fh
	mov bx,word ptr [_pos] 			;取出显示位置
	mov word ptr es:[bx],ax
	inc word ptr [_y] 				;y坐标+1
	call near ptr _cal_pos 			;重新计算坐标
	pop bx
	pop bp
	pop es
	pop ax
	ret
_printchar endp

;输出一个字符串
public _printstring
_printstring proc
    push bp
	push es
	push ax
	push ds
	mov	bp, sp
	mov ax, 0b800h					;显存的位置
	mov es, ax
	mov ax, 800h
	mov ds, ax
	mov	si, word ptr [bp+2+2+2+2+2]	;取出首字符地址
	mov	di, word ptr [_pos]			;取出显示位置
.1:
	mov al,byte ptr [si]			;把字符取出给AL
	inc si							;地址变为下个字符的地址
	test al,al 						;检测是否为空字符
	jz .2 							;是空字符就跳转.2
	cmp al,0ah						;检测是否为换行
	jz .3 							;是换行就跳转.3
	;既不是空字符也不是换行，则送显示位置显示，并更新显示位置
	mov	ah, 0Fh
	mov word ptr es:[di],ax
	inc byte ptr [_y]
	call near ptr _cal_pos
	mov di,word ptr [_pos]
	jmp .1
.3:;_x加1，_y清0，更新显示地址
	inc word ptr [_x]
	mov word ptr [_y],0
	call near ptr _cal_pos
	mov di,word ptr [_pos]
	jmp	.1
.2:;设置光标后退出
	call _setCursor
	pop ds
    pop ax
	pop es
	pop bp
ret
_printstring  endp

;键盘输入一个字符
public _inputchar
_inputchar proc
	push ax
	call _setCursor
	mov ax,0
	int 16h
	mov byte ptr [_ch],al
	pop ax
ret
_inputchar endp

include clear.inc

;读软盘到内存
;load(offsetBegin, sectorNum, sectorPos)
public _load
_load proc
	push ax
	push bx
	push cx
	push dx
	push es
	push bp
	mov bp,sp
	mov ax,cs              
    mov es,ax                	;设置段地址
    mov bx,word ptr [bp+12+2]  	;偏移地址
    mov ah,2                 	; 功能号
    mov al,byte ptr [bp+12+4] 	;扇区数
    mov dl,0                 	;驱动器号
    mov dh,0                 	;磁头号
    mov ch,0                 	;柱面号
    mov cl,byte ptr [bp+12+6]	;起始扇区号
    int 13H ;                
	pop bp
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_load endp
;跳转到用户程序
public _jmp
_jmp proc
	push ax
	push bx
	push cx
	push dx
	push es
	push ds

	; call re_clock_interrupt
	; call set_keyboard_interrupt
	call word ptr [_offsetUser]
	; call re_keyboard_interrupt
	; call set_clock_interrupt
	pop ds
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_jmp endp

; Finite dw 0	
pushReg:
; 压栈，按顺序作为Save_Process的参数
    push ss
	push ax
	push bx
	push cx
	push dx
	push sp
	push bp
	push si
	push di
	push ds
	push es
	.386
	push fs
	push gs
	.8086

	mov ax, cs ;xx 
	mov ds, ax
	mov es, ax

	call near ptr _saveProc
	; call save
	call near ptr _Schedule 
	
Pre:
	mov ax, cs ;xx
	mov ds, ax
	mov es, ax
	
	call near ptr _curProc 	; 获得当前的PCB地址
	mov bp, ax

	mov ss,word ptr ds:[bp+0]       ; 将当前的数据栈指向子进程ss：sp 
	mov sp,word ptr ds:[bp+16] 

	cmp word ptr ds:[bp+32],0 		; 比较status, 假如不是NEW，则跳转到No_First_Time
	jnz No_First_Time               ; 否则restart

;*****************************************
;*                Restart                *
; ****************************************
Restart:
    call near ptr _special         ; 把当前的PCB指针置为RUNNING
	
	push word ptr ds:[bp+30]
	push word ptr ds:[bp+28]
	push word ptr ds:[bp+26]
	
	push word ptr ds:[bp+2]
	push word ptr ds:[bp+4]
	push word ptr ds:[bp+6]
	push word ptr ds:[bp+8]
	push word ptr ds:[bp+10]
	push word ptr ds:[bp+12]
	push word ptr ds:[bp+14]
	push word ptr ds:[bp+18]
	push word ptr ds:[bp+20]
	push word ptr ds:[bp+22]
	push word ptr ds:[bp+24]

	pop ax
	pop cx
	pop dx
	pop bx
	pop bp
	pop si
	pop di
	pop ds
	pop es
	.386
	pop fs
	pop gs
	.8086

	cmp word ptr[_procNum],0 ; 若相等，则ZF为1
	;jnz Save                     ; 若ZF不为1，则跳转，即已经有进程
	; call _clear
	jz No_Progress              ; 若没有进程，则跳转到No_Progress

	push ax         
	mov al,20h
	out 20h,al
	out 0A0h,al
	pop ax
	iret

No_First_Time:	
	add sp,16 
	jmp Restart
	
No_Progress:
    ;call another_Timer
	push ax         
	mov al,20h
	out 20h,al
	out 0A0h,al
	pop ax
	iret
	
SetTimer: 
    push ax
    mov al,34h   ; 设控制字值 
    out 43h,al   ; 写控制字到控制字寄存器 
    mov ax,29830 ; 每秒 20 次中断（50ms 一次） 
    out 40h,al   ; 写计数器 0 的低字节 
    mov al,ah    ; AL=AH 
    out 40h,al   ; 写计数器 0 的高字节 
	pop ax
	ret
;===================================================
;				save using asm 

	
; ds_save dw ?
; ret_save dw ?
; si_save dw ?
; kernelsp dw ?	

; public save   
; save proc
; 	push ds
; 	push cs
; 	pop  ds
; 	pop  word ptr [ds_save]
; 	pop  word ptr [ret_save]
; 	mov  word ptr[si_save],si
; 	mov  si,word ptr [_procPtr]	
; 	add  si,26
; 	pop  word ptr [si]			; 保存ip
; 	add  si,2
; 	pop  word ptr [si]			; 保存cs
; 	add  si,2
; 	pop  word ptr [si]			; 保存flags
; 	mov  word ptr [si-14],sp 	; 保存sp
; 	mov  word ptr [si-30], ss 	; 保存ss
; 	mov  si,ds
; 	mov  ss,si
; 	mov  sp,word ptr [_procPtr] ; 
; 	add  sp,14
; 	push bp
; 	push si
; 	push di
; 	push word ptr[ds_save]
; 	push es
; 	.386
; 	push fs
; 	push gs
; 	.8086
; 	mov sp,word ptr [_procPtr] 	;
; 	add sp, 24
; 	push ax
; 	push cx
; 	push dx
; 	push bx
; 	; push word ptr[ds_save] 		; 保存ds到ax
; 	; push es
; 	; push bp
; 	; push di
; 	; push word ptr[si_save]
; 	; push dx
; 	; push cx
; 	; push bx
; 	; push ax

; 	mov sp,word ptr[kernelsp]
; 	mov ax,word ptr [ret_save]
; 	jmp ax
; save endp
;===================================================
public _setClock
_setClock proc
    push ax
	push bx
	push cx
	push dx
	push ds
	push es
	
    call SetTimer
    xor ax,ax
	mov es,ax
	mov word ptr es:[20h],offset pushReg
	mov ax,800h ; xx
	mov word ptr es:[22h],ax
	
	pop ax
	mov es,ax
	pop ax
	mov ds,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_setClock endp

; public _closeClock
; _closeClock proc
; 	cli
; 	; push es
; 	; push ax
; 	; xor ax,ax
; 	; mov es,ax
; 	; mov ax,word ptr [clkVec]
; 	; mov word ptr es:[20h],ax
; 	; mov ax,word ptr [clkVec+2]
; 	; mov word ptr es:[22h],ax
; 	; pop ax
; 	; pop es
; 	sti
; 	ret
; _closeClock endp
; ===========================================================


set_clock_interrupt proc
	cli
	push es
	push ax
	xor ax,ax
	mov es,ax

	;save the vector
	mov ax,word ptr [es:20h]
	mov word ptr [clkVec],ax
	mov ax,word ptr [es:22h]
	mov word ptr [clkVec+2],ax

	;fill the vector
	xor ax,ax
	mov es,ax
	mov word ptr es:[20h],offset clkIntFunc
	mov ax,800h ; 段地址
	mov word ptr es:[22h],ax

	pop ax
	pop es
	sti
	ret
set_clock_interrupt endp
;恢复时钟中断
re_clock_interrupt proc
	cli
	push es
	push ax
	xor ax,ax
	mov es,ax
	mov ax,word ptr [clkVec]
	mov word ptr es:[20h],ax
	mov ax,word ptr [clkVec+2]
	mov word ptr es:[22h],ax
	pop ax
	pop es
	sti
	ret
re_clock_interrupt endp

clkIntFunc proc
	push es
	push si
	push di
	push ax
	push bx
	push cx
	push dx
	push bp
	push ds
	
	call near ptr _drawRect
	
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
	iret
clkIntFunc endp

;输出一个指定位置的指定颜色的字符
;put_color_char(char,x,y,color)
public _putColorChar
_putColorChar proc
	mov bp,sp
	push es
	push ax
	push bx
	
	mov ax,0b800h
	mov es,ax
	mov ax,word ptr [bp+4];x
	mov bx,80
	mul bx
	add ax,word ptr [bp+6];y
	mov bx,2
	mul bx
	mov bx,ax
	mov ax,word ptr [bp+2];char
	mov byte ptr es:[bx],al
	mov ax,word ptr [bp+8];color
	mov byte ptr es:[bx+1],al
	
	pop bx
	pop ax
	pop es
	ret
_putColorChar endp

; include INT.inc
; include keyBoard.inc

_TEXT ends

;************DATA segment*************
_DATA segment word public 'DATA'
_DATA ends
;*************BSS segment*************
_BSS	segment word public 'BSS'
_BSS ends
;**************end of file***********
end start

; set_keyboard_interrupt proc
; 	cli
; 	push es
; 	push ax
; 	xor ax,ax
; 	mov es,ax
; 	;save the vector
; 	mov ax,word ptr es:[24h]
; 	mov word ptr [keyboardVec],ax
; 	mov ax,word ptr es:[26h]
; 	mov word ptr [keyboardVec+2],ax
; 	;fill the vector
; 	mov word ptr es:[24h],offset Ouch
; 	mov ax,800h
; 	mov word ptr es:[26h],ax
; 	;用于中断服务C程序的变量
; 	mov word ptr [_is_ouch],0	
; 	pop ax
; 	pop es
; 	sti
; 	ret
; set_keyboard_interrupt endp
; Ouch proc
; 	cli
; 	push es
; 	push si
; 	push di
; 	push ax
; 	push bx
; 	push cx
; 	push dx
; 	push bp
; 	push ds

; 	call near ptr _c_ouch
; 	;读缓冲区
; 	in al,60h
	
; 	mov al,20h
; 	out 20h,al
; 	out 0a0h,al

; 	pop ds
; 	pop bp
; 	pop dx
; 	pop cx
; 	pop bx
; 	pop ax
; 	pop di
; 	pop si
; 	pop es
; 	sti
; 	iret
; Ouch endp
; re_keyboard_interrupt proc
; 	cli
; 	push es
; 	push ax
; 	xor ax,ax
; 	mov es,ax
; 	mov ax,word ptr [keyboardVec]
; 	mov word ptr es:[24h],ax
; 	mov ax,word ptr [keyboardVec+2]
; 	mov word ptr es:[26h],ax
; 	;用于中断服务C程序的变量
; 	mov word ptr [_is_ouch],0
; 	pop ax
; 	pop es
; 	sti
; 	ret
; re_keyboard_interrupt endp

;INT 33H 左上角显示
;填充33h中断向量表
; int33h proc
; 	cli
; 	push es
; 	push ax
; 	;es置零
; 	xor ax,ax
; 	mov es,ax
; 	;填充中断向量
; 	mov word ptr es:[0cch],offset interrupt33h
; 	mov ax,800h
; 	mov word ptr es:[0ceh],ax
; 	pop ax
; 	pop es
; 	sti
; 	ret
; int33h endp

; message33h1 db 'This is program of INT 33H'
; message33h1length equ $-message33h1
; ;中断处理程序33h
; interrupt33h proc
;  	cli
; 	push es
; 	push si
; 	push di
; 	push ax
; 	push bx
; 	push cx
; 	push dx
; 	push bp
; 	push ds
	
; 	mov ax,cs
; 	mov es,ax
; 	mov ax,1301h
; 	mov bx,0001h;bl颜色
; 	mov dx,0408h;行，列
; 	mov cx,message33h1length
; 	mov bp,offset message33h1
; 	int 10h
	
; 	mov al,20h
; 	out 20h,al
; 	out 0a0h,al

; 	pop ds
; 	pop bp
; 	pop dx
; 	pop cx
; 	pop bx
; 	pop ax
; 	pop di
; 	pop si
; 	pop es
;  	sti
;  	iret
; interrupt33h endp

; ;INT 34H 右上角显示
; ;填充34h中断向量表
; int34h proc
; 	cli
; 	push es
; 	push ax
	
; 	xor ax,ax
; 	mov es,ax
; 	mov word ptr es:[0d0h],offset interrupt34h
; 	mov ax,800h
; 	mov word ptr es:[0d2h],ax
	
; 	pop ax
; 	pop es
; 	sti
; 	ret
; int34h endp

; message34h1 db 'This is program of INT 34H'
; message34h1length equ $-message34h1
; ;中断处理程序34h
; interrupt34h proc
; 	cli
; 	push es
; 	push si
; 	push di
; 	push ax
; 	push bx
; 	push cx
; 	push dx
; 	push bp
; 	push ds
	
; 	mov ax,cs
; 	mov es,ax
; 	mov ax,1301h
; 	mov bx,0002h;bl颜色
; 	mov dx,0508h;行，列
; 	mov cx,message34h1length
; 	mov bp,offset message34h1
; 	int 10h
	
	
; 	mov al,20h
; 	out 20h,al
; 	out 0a0h,al

; 	pop ds
; 	pop bp
; 	pop dx
; 	pop cx
; 	pop bx
; 	pop ax
; 	pop di
; 	pop si
; 	pop es
; 	sti
; 	iret
; interrupt34h endp


; ;INT 35H 左下角显示
; ;填充35h中断向量表
; int35h proc
; 	cli
; 	push es
; 	push ax
	
; 	xor ax,ax
; 	mov es,ax
; 	mov word ptr es:[0D4h],offset interrupt35h
; 	mov ax,800h
; 	mov word ptr es:[0d6h],ax
	
; 	pop ax
; 	pop es
; 	sti
; 	ret
; int35h endp

; message35h1 db 'This is program of INT 35H'
; message35h1length equ $-message35h1
; ;中断处理程序35h
; interrupt35h proc
; 	cli
; 	push es
; 	push si
; 	push di
; 	push ax
; 	push bx
; 	push cx
; 	push dx
; 	push bp
; 	push ds
	
; 	mov ax,cs
; 	mov es,ax
; 	mov ax,1301h
; 	mov bx,0003h;bl颜色
; 	mov dx,0608h;行，列
; 	mov cx,message35h1length
; 	mov bp,offset message35h1
; 	int 10h
	
; 	mov al,20h
; 	out 20h,al
; 	out 0a0h,al

; 	pop ds
; 	pop bp
; 	pop dx
; 	pop cx
; 	pop bx
; 	pop ax
; 	pop di
; 	pop si
; 	pop es
; 	sti
; 	iret
; interrupt35h endp

; ;INT 36H 右下角显示
; ;填充36h中断向量表
; int36h proc
; 	cli
; 	push es
; 	push ax
	
; 	xor ax,ax
; 	mov es,ax
; 	mov word ptr es:[0d8h],offset interrupt36h
; 	mov ax,800h
; 	mov word ptr es:[0dah],ax
	
; 	pop ax
; 	pop es
; 	sti
; 	ret
; int36h endp

; message36h1 db 'This is program of INT 36H'
; message36h1length equ $-message36h1
; ;中断处理程序36h
; interrupt36h proc
; 	cli
; 	push es
; 	push si
; 	push di
; 	push ax
; 	push bx
; 	push cx
; 	push dx
; 	push bp
; 	push ds
	
; 	mov ax,cs
; 	mov es,ax
; 	mov ax,1301h
; 	mov bx,0004h;bl颜色
; 	mov dx,0708h;行，列
; 	mov cx,message36h1length
; 	mov bp,offset message36h1
; 	int 10h
	
; 	mov al,20h
; 	out 20h,al
; 	out 0a0h,al

; 	pop ds
; 	pop bp
; 	pop dx
; 	pop cx
; 	pop bx
; 	pop ax
; 	pop di
; 	pop si
; 	pop es
; 	sti
; 	iret
; interrupt36h endp




; ;系统调用21h，设置中断向量表
; int21h proc 
; 	cli
; 	push ax
; 	push es
; 	xor ax,ax
; 	mov es,ax
; 	mov word ptr es:[84h],offset mysyscall
; 	mov ax,800h
; 	mov word ptr es:[86h],ax
; 	pop es
; 	pop ax
; 	sti
; 	ret
; int21h endp

; ;跳转分支表
; syscall_vector dw syscall0,syscall1,syscall2,syscall3
; ;系统调用入口，根据ah来判断具体功能
; ;因为此处用到al,bx，所以al,bx不能作为系统调用的参数
; mysyscall proc
; 	cli
; 	push es
; 	push si
; 	push di
; 	push ax
; 	push bx
; 	push cx
; 	push dx
; 	push bp
; 	push ds
; 	;非法ah值将直接返回
; 	cmp ah,3
; 	jg mysyscall_next
; 	;计算系统调用的偏移量
; 	mov al,ah
; 	xor ah,ah
; 	shl ax,1;*2
; 	mov bx,offset syscall_vector
; 	add bx,ax
; 	;改段地址
; 	mov ax,800h
; 	mov es,ax
; 	mov ds,ax
; 	;调用对应系统调用
; 	call word ptr [bx]

; mysyscall_next:
; 	mov al,20h
; 	out 20h,al
; 	out 0a0h,al
	
; 	pop ds
; 	pop bp
; 	pop dx
; 	pop cx
; 	pop bx
; 	pop ax
; 	pop di
; 	pop si
; 	pop es
; 	sti
; 	iret
; mysyscall endp
 

; syscall0_Msg db 'This is program of sysycall_0'
; syscall0_Msg_len equ $-syscall0_Msg
; ;中断处理程序syscall0h
; syscall0 proc
	
; 	mov ax,800h
; 	mov es,ax
; 	mov ax,1301h
; 	mov bx,0005h;bl颜色
; 	mov dx,0508h;行，列
; 	mov cx,syscall0_Msg_len
; 	mov bp,offset syscall0_Msg
; 	int 10h
	
; 	mov al,20h
; 	out 20h,al
; 	out 0a0h,al

; 	ret
; syscall0 endp

; syscall1_Msg db 'This is program of sysycall_1'
; syscall1_Msg_len equ $-syscall1_Msg
; syscall1 proc

; 	mov ax,cs
; 	mov es,ax
; 	mov ax,1301h
; 	mov bx,0004h;bl颜色
; 	mov dx,0608h;行，列
; 	mov cx,syscall1_Msg_len
; 	mov bp,offset syscall1_Msg
; 	int 10h
	
; 	mov al,20h
; 	out 20h,al
; 	out 0a0h,al

; 	ret
; syscall1 endp

; syscall2_Msg db 'This is program of sysycall_2'
; syscall2_Msg_len equ $-syscall2_Msg
; syscall2 proc
; 	mov ax,cs
; 	mov es,ax
; 	mov ax,1301h
; 	mov bx,0003h;bl颜色
; 	mov dx,0708h;行，列
; 	mov cx,syscall2_Msg_len
; 	mov bp,offset syscall2_Msg
; 	int 10h
	
; 	mov al,20h
; 	out 20h,al
; 	out 0a0h,al

; 	ret
; syscall2 endp

; syscall3_Msg db 'This is program of sysycall_3'
; syscall3_Msg_len equ $-syscall3_Msg
; syscall3 proc
; 	mov ax,cs
; 	mov es,ax
; 	mov ax,1301h
; 	mov bx,0002h;bl颜色
; 	mov dx,0808h;行，列
; 	mov cx,syscall3_Msg_len
; 	mov bp,offset syscall3_Msg
; 	int 10h
	
; 	mov al,20h
; 	out 20h,al
; 	out 0a0h,al

; 	ret
; syscall3 endp

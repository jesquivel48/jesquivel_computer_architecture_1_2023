section .data
	filename db "test.txt", 0
	buffersize equ 10

section .bss
	buffer resb buffersize
	filesize resw 1

section .text
	global _start
; Jonathan Esquivel Sanchez
; Incio de programa
_start:

	mov rax, 2		;SYS_OPEN
	mov rdi, filename
	mov rsi, 0		;read only
	mov rdx, 0
	syscall

	mov rbx,  rax
	mov r8, 0
	cmp rax, 0
	jl _error

_filesize:

	mov rdi, rax
	mov rax, 8 
	mov rsi, 0
	mov rdx, 2
	syscall
	mov r9, rax
	dec r9
	mov rax, 3
	mov rdi, rbx
	syscall
	
_readfile:

	mov rax, 2		;SYS_OPEN
	mov rdi, filename
	mov rsi, 0		;read only
	mov rdx, 0
	syscall

	mov rbx,  rax
	cmp rax, 0
	jl _error

	mov rax, rbx
	mov rdi, rax
	mov rax, 8 
	mov rsi, r8
	mov rdx, 0
	syscall
	
	mov rax, rbx
	mov rdi, rax
	mov rax, 0		;SYS_READ
	mov rsi, buffer
	mov rdx, buffersize
	syscall

	call _getfullword

	cmp r9, r8
	jge _endread	

	jmp _endprogram
	

_endread:

	mov rax, 3
	mov rdi, rbx
	syscall
	
	jmp _readfile
	
_endprogram:

	mov rax, 3
	mov rdi, rbx
	syscall

	mov rax, 60 ;Terminacion del programa
	pop rdi
	syscall

_print:
	mov edx, edx
	mov ecx, eax
	mov ebx, 1 		;STD_OUT
	mov eax, 4		;SYS_WRITE
	int 0x80
	ret

_getfullword:


	mov rcx, 0		;cl init and ch numcount
	mov rdx, 0		;buffcount
	mov r11, 0		;tempnum
	mov r12, 0		;msb
	
_spacebyte:
	
	mov bl, [buffer + rdx]
	inc ch
	inc rdx

	cmp bl, 32
	jg _spacebyte
	push rdx
	
	dec ch
	mov bh, ch
	add bh, cl
	mov rdx, 0
	push rcx
	mov ch, 0
	mov rdx, rcx
	pop rcx
	
	

_str2int:

	mov bl, 1
	mov ax, 1
	mov r10, 10
	
	push rdx
	call _pow_10
	pop rdx

	dec ch

	mov al, [buffer + rdx]
	sub al, 48
	
	push rdx
	mul r10
	pop rdx
	add r11, rax
	
	inc rdx

	cmp dl, bh
	jl _str2int

	cmp r12, 0
	jz _savenum

	mov rbx, r12
	mov rax, r11

	mov ah, bl
	
	pop rdx
	add r8, rdx
	ret
	;jmp _funcmod

_pow_10:

	cmp bl, ch
	je _pow_10_ret

	inc bl
	mul r10

	jmp _pow_10

_pow_10_ret:
	mov r10, rax
	ret


_savenum:
	pop rdx
	mov cl, dl
	mov r12, r11
	mov r11, 0
	jmp _spacebyte

_error:
	mov rax, 60 ;Terminacion del programa
	pop rdi
	syscall
	


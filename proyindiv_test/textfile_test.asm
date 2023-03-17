section .data
	filename db "test.txt", 0
	buffersize equ 4
	filesize dw 16

section .bss
	buffer resb buffersize

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
	
_readfile:

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

	add r8, rax

	call _print
	cmp r8, r9
	jl _readfile	
	

_end:

	mov rax, 3
	mov rdi, rbx
	syscall
	

	mov rax, 60 ;Terminacion del programa
	pop rdi
	syscall

_print:
	mov edx, buffersize
	mov ecx, buffer
	push rbx
	mov ebx, 1 		;STD_OUT
	mov eax, 4		;SYS_WRITE
	int 0x80
	pop rbx
	ret

_error:
	mov rax, 60 ;Terminacion del programa
	pop rdi
	syscall
	


section .data
	filename db "test.txt", 0

section .bss
	text resb 7

section .text
	global _start
; Jonathan Esquivel Sanchez
; Incio de programa
_start:

	mov rax, 2		;open
	mov rdi, filename
	mov rsi, 0		;read only
	mov rdx, 0
	syscall

	push rax
	mov rdi, rax
	mov rax, 0		;read
	mov rsi, text
	mov rdx, 6
	syscall

	mov rax, 3
	pop rdi
	syscall
	
	call _print

	mov rax, 60 ;Terminacion del programa
	mov rdi, 0
	syscall

_print:
	mov edx, 6
	mov ecx, text
	mov ebx, 1
	mov eax, 4
	int 0x80
	ret
	


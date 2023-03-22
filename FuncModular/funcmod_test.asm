section .bss ; Se crea el espacio de memoria para guardar los datos
	exp resw 2
	mod resw 2	
	base resb 1
	res resb 1
	exp_size resb 1


section .text
	global _start
; Jonathan Esquivel Sanchez
; Incio de programa

_start:
	mov eax, 50		;mod
	mov [mod], eax
	mov bl, 3		;base
	mov [base], bl
	mov bl, 1		;res
	mov [res], bl


	mov eax, 200		;exp
	mov [exp], eax
	mov ebx, 0x8000
	mov al, 0

find_exp_size:

	inc al
	mov ecx, [exp]
	and ecx, ebx
	shr ebx, 1
	cmp ecx, 0
	jz find_exp_size
	
	mov bl, 16
	sub bl, al
	mov [exp_size], bl


func_mod:

	mov eax, [exp]
	mov cl, [exp_size]
	cmp cl, 0
	jl end	

	
	shr eax, cl
	
	and eax, 1		;exp temp

	cmp eax, 0
	je func_mod_0	

	jmp func_mod_1


func_mod_1:

	mov al, [res]
	mul ax

	mov ebx, [mod]
	div bx
	
	mov al, [base]
	mul dx

	div ebx
	mov bl, dl
	mov [res], bl
	
	call dec_counter


func_mod_0:

	mov al, [res]
	mul ax

	mov ebx, [mod]
	div ebx
	
	mov bl, dl
	mov [res], bl
	
	call dec_counter

dec_counter:

	mov eax, [exp_size]
	dec eax
	mov [exp_size], eax
	jmp func_mod

end:
	mov al, [res]
	mov rax, 60 ;Terminacion del programa
	pop rdi
	syscall

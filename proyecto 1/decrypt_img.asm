section .data
	filename db "test.txt", 0
	keyfile db "llave.txt", 0
	keybuffersize equ 1024
	buffersize equ 10
	newfilename db "new_img.txt", 0
	nfbuffersize equ 1

section .bss
	keybuffer resb keybuffersize
	nfbuffer resb nfbuffersize
	buffer resb buffersize
	exp resw 2
	mod resw 2	
	base resw 1
	res resb 1
	exp_size resb 1

section .text
	global _start
; Jonathan Esquivel Sanchez
; Incio de programa
_start:
	call _getkeys

	mov rax, 2		;SYS_OPEN
	mov rdi, filename
	mov rsi, 0		;read only
	mov rdx, 0666o
	syscall

	mov r8, 0
	cmp rax, 0
	jl _error

	mov rbx,  rax

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

_createnewfile:

	mov rax, 2		;SYS_OPEN
	mov rdi, newfilename
	mov rsi, 64		;create
	mov rdx, 0666o
	syscall

	cmp rax, 0
	mov r8, 0
	jl _error

	mov rax, 3
	mov rdi, rbx
	syscall

	mov ebx, 0x8000
	mov al, 0
	jmp find_exp_size
	
_getkeys:

	mov rax, 2		;SYS_OPEN
	mov rdi, keyfile
	mov rsi, 0		;read only
	mov rdx, 0666o
	syscall

	mov r8, 0
	cmp rax, 0
	jl _error
	mov rbx,  rax

_keyfilesize:

	mov rdi, rax
	mov rax, 8 
	mov rsi, 0
	mov rdx, 2
	syscall
	mov r9, rax
	
_readkeyfile:

	mov rax, 2		;SYS_OPEN
	mov rdi, keyfile
	mov rsi, 0		;read only
	mov rdx, 0666o
	syscall
	
	mov rdi, rax
	mov rax, 0		;SYS_READ
	mov rsi, keybuffer
	mov rdx, keybuffersize
	syscall

	mov rax, 3
	mov rdi, rbx
	syscall

_getkeydata:

	mov rcx, 0		;cl init and ch numcount
	mov rdx, 0		;buffcount
	mov r11, 0		;tempnum
	mov r12, 0		;msb
	mov r13, 0
	
_dnbyte:
	
	mov bl, [keybuffer + rdx]
	inc cl
	inc rdx

	cmp bl, 100
	je _dbyte

	cmp bl, 110
	je _nbyte

	cmp r9, rdx
	je _retkeys

	jmp _dnbyte

_dbyte:

	add rdx, 3
	add cl, 3
	jmp _nlbyte

_nbyte:

	add rdx, 3
	add cl, 3
	mov r13, 1
	jmp _nlbyte 

_nlbyte:
	
	mov bl, [keybuffer + rdx]
	inc ch
	inc rdx

	cmp bl, 10
	jg _nlbyte
	push rdx
	
	dec ch
	mov bh, ch
	add bh, cl
	mov rdx, 0
	push rcx
	mov ch, 0
	mov rdx, rcx
	pop rcx


_keystr2int:

	mov bl, 1
	mov ax, 1
	mov r10, 10
	
	push rdx
	call _pow_10
	pop rdx

	dec ch
	mov rax, 0
	mov al, [keybuffer + rdx]
	sub al, 48
	
	push rdx
	mul r10
	pop rdx
	add r11, rax
	
	inc rdx

	cmp dl, bh
	jl _keystr2int

	
	pop rdx

	mov cl, dl
	mov rax, r11

	cmp r13, 1
	je _save_mod

	jmp _save_exp
	

_save_mod:

	mov [mod], ax
	mov al, 0
	mov ch, 0
	mov r11, 0		;tempnum
	jmp _dnbyte

_save_exp:
	
	mov [exp], ax
	mov al, 0
	mov ch, 0
	mov r11, 0		;tempnum
	jmp _dnbyte

_retkeys:
	ret

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
	mov r14, rbx

_readfile:

	mov rax, 2		;SYS_OPEN
	mov rdi, filename
	mov rsi, 0		;read only
	mov rdx, 0666o
	syscall

	cmp rax, 0
	jl _error

	mov rbx,  rax

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

	mov rax, 3
	mov rdi, rbx
	syscall

	call _getfullword

	cmp r9, r8
	jg _readfile	

	jmp _endprogram
	

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
	mov [base], ax
	;ret
	;jmp _funcmod

set_exp_size:

	mov rbx, r14 
	mov [exp_size], bl
	
	mov r10, 0
	mov r12, 100
	mov byte [res], 1


func_mod:

	mov eax, [exp]
	mov cl, [exp_size]
	cmp cl, 0
	jl _int2str	

	
	shr eax, cl
	
	and eax, 1		;exp temp
	
	cmp eax, 0
	je func_mod_0	

	jmp func_mod_1


func_mod_1:

	mov al, [res]
	mul rax

	mov bx, [mod]
	div rbx
	
	mov ax, [base]
	mul rdx

	div ebx
	mov bl, dl
	mov [res], bl
	
	jmp dec_counter


func_mod_0:

	mov al, [res]
	mul rax

	mov bx, [mod]
	div rbx
	
	mov bl, dl
	mov [res], bl
	
	jmp dec_counter

dec_counter:

	mov eax, [exp_size]
	dec eax
	mov [exp_size], eax
	mov rbx, 0
	jmp func_mod

_int2str:

	mov rax, 0
	mov al, [res]
	
	cmp rax, r12
	jg _divintgt

	je _divinteq

	cmp rax, 0
	jz _divintzero

	
_divexp:	

	mov bl, 10
	mov rax, r12
	div bl
	mov r12, rax

	jmp _int2str

_divintzero:
	
	cmp r12, 100
	je _zeroint

	mov bl, 10
	mov rax, r12
	div bl
	mov r12, rax
	mov rax, 0
	jmp _assignascii

_zeroint:

	mov r12, 1
	mov rax, 0
	jmp _assignascii

_divintgt:
	push rbx
	mov rbx, r12
	div bl
	mov [res], ah
	pop rbx
	jmp _assignascii

_divinteq:

	cmp r12, 1
	jg _eqval

	mov [res], al
	jmp _assignascii

_eqval:

	mov bl, 10
	mov rax, r12
	div bl
	mov r12, rax
	mov rax, 0

	mov [res], al
	mov al, 1
	jmp _assignascii
	

_assignascii:


	add al, 48
	mov [nfbuffer], al
	jmp _writefile
	


_writefile:

	mov rax, 2		;SYS_OPEN
	mov rdi, newfilename
	mov rsi, 1		;write only
	mov rdx, 0666o
	syscall

	cmp rax, 0
	jl _error

	mov rbx,  rax

	mov rdi, rax
	mov rax, 8 
	mov rsi, 0
	mov rdx, 2
	syscall
	
	mov rax, rbx
	
	mov rdi, rax
	mov rax, 1		;SYS_WRITE
	mov rsi, nfbuffer
	mov rdx, nfbuffersize
	syscall

	mov rax, 3
	mov rdi, rbx
	syscall

	jmp _bytesleft


_bytesleft:
	
	cmp r12, 1
	je _addspacebyte

	cmp r12, 0
	je _retwrite

	jmp _int2str 

_addspacebyte:
	
	mov al, 32
	mov [nfbuffer], al
	dec r12
	jmp _writefile	

_retwrite:
	ret
	

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

_print:
	mov edx, edx
	mov ecx, eax
	mov ebx, 1 		;STD_OUT
	mov eax, 4		;SYS_WRITE
	int 0x80
	ret

_endprogram:

	mov rax, 3
	mov rdi, rbx
	syscall

	mov rax, 60 ;Terminacion del programa
	pop rdi
	syscall

_error:
	mov rax, 3
	mov rdi, rbx
	syscall

	jmp _readfile

	


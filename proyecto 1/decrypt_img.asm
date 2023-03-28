section .data
	filename db "enc_img.txt", 0
	keyfile db "llave.txt", 0
	keybuffersize equ 1024
	buffersize equ 10
	newfilename db "dec_img.txt", 0
	nfbuffersize equ 1

section .bss
	keybuffer resb keybuffersize
	nfbuffer resb nfbuffersize
	buffer resb buffersize
	exp resw 2
	mod resw 2	
	base resw 1
	res resw 1
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

_filesize: 		; Obtiene el tamano del archivo encriptado y lo guarda en r9

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

_createnewfile:		; Crea el archivo donde se emteran los pixeles desencriptados 

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
	
_getkeys:		; Obtiene las llaves de d y n en llaves.txt para la desencriptacion

	mov rax, 2		;SYS_OPEN
	mov rdi, keyfile
	mov rsi, 0		;read only
	mov rdx, 0666o
	syscall

	mov r8, 0
	cmp rax, 0
	jl _error
	mov rbx,  rax

_keyfilesize:			; Obtiene el tamano del archivo llaves y lo guarda en r9

	mov rdi, rax
	mov rax, 8 
	mov rsi, 0
	mov rdx, 2
	syscall
	mov r9, rax
	
_readkeyfile:			; Lee el archivo llaves y guarda lo leido en keybuffer

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

_getkeydata:			; Resetea valores para el loop

	mov rcx, 0		;cl init and ch numcount
	mov rdx, 0		;buffcount
	mov r11, 0		;tempnum
	mov r13, 0		;flag para guardar en el modulo
	
_dnbyte:			; loop para busca el acsii de la d o la n en el archivo de llaves.txt
	
	mov bl, [keybuffer + rdx]
	inc cl
	inc rdx

	cmp bl, 100
	je _dbyte		; Si es d ir a dbyte

	cmp bl, 110
	je _nbyte		; Si es n ir a nbyte

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

_nlbyte:		; Buscar el final del numero (una newline)
	
	mov bl, [keybuffer + rdx]
	inc ch
	inc rdx

	cmp bl, 20
	jg _nlbyte
	push rdx
	
	sub ch, 1
	mov bh, ch
	add bh, cl
	mov rdx, 0
	mov dl, cl


_keystr2int:		; Pasar del ascii del numero al numero y guardarlo

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

find_exp_size:			; Encontrar el tamano en bits del exponente y guardarlo en un registro 

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

_readfile:			; Leer de 10 en 10 bits los valores del archivo encriptado (Con esto se asegura obtener los dos bytes requeridos)

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
	mov rsi, r8		; Comenzar a leer en el byte r8
	mov rdx, 0
	syscall
	
	mov rax, rbx
	mov rdi, rax
	mov rax, 0		;SYS_READ
	mov rsi, buffer		; Guarda el resultado en buffer
	mov rdx, buffersize
	syscall

	mov rax, 3
	mov rdi, rbx		; Cierra el archivo
	syscall

	call _getfullword

	cmp r9, r8		; Compara el tamano actual con el total
	jg _readfile	

	jmp _endprogram
	

_getfullword:			; Se resetean los registros utilizados para obtner los dos bytes 


	mov rcx, 0		;cl init and ch numcount
	mov rdx, 0		;buffcount
	mov r11, 0		;tempnum
	mov r12, -1		;msb
	
_spacebyte:			; Bucle para busca el byte del espacio en ascii que simboliza el final de un numero
	
	mov bl, [buffer + rdx]
	inc ch
	inc rdx

	cmp bl, 32		; ascii 32 es el espacio, arriba de eso son los numeros
	jg _spacebyte
	push rdx
	
	dec ch
	mov bh, ch
	add bh, cl
	mov rdx, 0
	push rcx
	mov ch, 0
	mov rdx, rcx		; Inicia dl en el valor donde comienza el numero
	pop rcx

_str2int:			; Bucle para convertir el ascii del numero obtenido en el numero en si 

	mov bl, 1
	mov ax, 1
	mov r10, 10
	
	push rdx
	call _pow_10		; Se eleva 10 a la n (tamano)
	pop rdx

	dec ch

	mov al, [buffer + rdx]
	sub al, 48		; Para obtener el numero se resta 48 al resultado del ascii (48 es el valor del ascii 0)
	
	push rdx
	mul r10
	pop rdx
	add r11, rax		; Se multiplica el valor por 10 a la n y se suma al resultado total en r11 (numero temporal)
	
	inc rdx

	cmp dl, bh
	jl _str2int		; Bucle hasta hacer eso con el numero completo de un byte

	cmp r12, 0
	jl _savenum		; Se guarda el MSB

	mov rbx, r12
	mov rax, r11

	mov ah, bl		; Se guarda el resultado de la base en ax
	
	pop rdx
	mov r15, r8		; r15 tiene el valor anterior por errores en la lectura de archivos
	add r8, rdx		; r8 ahora tiene el nuevo valor para comenzar a leer al final del segundo byte
	mov [base], ax

set_exp_size:			; Se guarda el valor del tamano del exponente en rbx

	mov rbx, r14 
	mov [exp_size], bl	; Se guarda en exp_size
	
	mov r10, 1
	mov r11, 0
	mov r12, 10
	mov word [res], 1


func_mod:			; Funcion FASM modular
	mov rax, 0
	mov rcx, 0
	mov ax, [exp]
	mov cl, [exp_size]
	cmp cl, 0
	jl _int2str		; Una vez que se tenga el resultado lo convierte a ascii 

	
	shr ax, cl
	
	and ax, 1		; exp temp
	
	cmp ax, 0		; Se revisa si el siguiente bit del exponente es 1 o 0
	je func_mod_0	

	jmp func_mod_1


func_mod_1:			; Caso bit 1

	mov rax, 0
	mov rbx, 0	

	mov ax, [res]		; Multiplica resultado por el mismo
	mul rax

	mov bx, [mod]		; Divide resultado por el modulo
	div rbx
	
	mov rax, 0

	mov ax, [base]		; Multiplica el residuo de la division por la base
	mul rdx

	div rbx			; Divide resultado por el modulo nuevamente
	mov bx, dx
	mov [res], bx		; Guarda resultado para proximo loop
	
	jmp dec_counter


func_mod_0:			; Caso bit 0

	mov rax, 0
	mov rbx, 0

	mov ax, [res]		; Multiplica resultado por el mismo
	mul rax

	mov bx, [mod]		; Divide resultado por el modulo
	div rbx
	
	mov bx, dx
	mov [res], bx		; Guarda resultado para proximo loop
	
	jmp dec_counter

dec_counter:			; Reduce el contador del exp

	mov rax, 0
	mov rbx, 0
	mov ax, [exp_size]
	dec ax
	mov [exp_size], ax
	jmp func_mod

_int2str:			; Arregla los valores para obtener el ascii del resultado		

	mov rax, 0
	mov al, byte [res]
	mov rbx, r12

_divloop:			; Divide por 10 hasta obtener un 0 en ax

	mov edx, 0
	div bx
	push dx			; Guarda el residuo en el stack


	cmp eax, 0
	jz _valzero

	inc r10			; Incrementa el contador

	jmp _divloop


_valzero:			; Bucle para escribir el ascii en el archivo desencriptado
	
	pop ax

	cmp r10, 1		; Caso del ultimo digito
	je _lastdig

	dec r10

	jmp _assignascii
	
_lastdig:			; Bandera para agregar un espacio despues del numero

	mov r12, 1

_assignascii:			; Agrega 48 al valor del digito (Valor del ascii 0)


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
	mov rax, 8 		; lseek
	mov rsi, 0		; Busca el final del archivo
	mov rdx, 2
	syscall
	
	mov rax, rbx
	
	mov rdi, rax
	mov rax, 1		;SYS_WRITE
	mov rsi, nfbuffer
	mov rdx, nfbuffersize
	syscall

	mov rax, 3		;SYS_CLOSE
	mov rdi, rbx
	syscall

	jmp _bytesleft


_bytesleft:			; Revisa por la bandera del espacio o del return
	
	cmp r12, 1
	je _addspacebyte

	cmp r12, 0
	je _retwrite

	jmp _valzero

_addspacebyte:			; Agrega el valor del ascii del espacio al buffer (32) y lo escribe
	
	mov al, 32
	mov [nfbuffer], al
	mov r12, 0
	jmp _writefile	

_retwrite:
	ret
	

_pow_10:			; Valor comienza en 1 y se multiplica por 10 cada loop para obtener 10 a la n

	cmp bl, ch
	je _pow_10_ret

	inc bl
	mul r10

	jmp _pow_10

_pow_10_ret:
	mov r10, rax
	ret


_savenum:		;Guarda el MSB a un registro temporal
	pop rdx
	mov cl, dl
	mov r12, r11
	mov r11, 0
	jmp _spacebyte

_print:			; Imprime el resultado (Usado en pruebas)
	mov edx, edx
	mov ecx, eax
	mov ebx, 1 		;STD_OUT
	mov eax, 4		;SYS_WRITE
	int 0x80
	ret

_endprogram:		; Terminar ejecucion

	mov rax, 3
	mov rdi, rbx
	syscall

	mov rax, 60 ;Terminacion del programa
	pop rdi
	syscall

_error:			; Error de SYS_OPEN
	mov rax, 3
	mov rdi, rbx
	syscall		; Cierrra archivo actual

	mov r8, r15	; Busca el espacio de los bytes anteriores

	jmp _readfile	; Resetea el bucle completo

	


format ELF64

public length_string
public number_to_string

section '.str_length_string' executable
; | input
; rax = string
; | output
; rbx = length
length_string:
	push rax
	xor rbx, rbx
	.next_iter:
		cmp [rax], byte 0
		je .close
		inc rbx
		inc rax
		jmp .next_iter
	.close:
		pop rax
		ret

section '.str_number_to_string' executable
; | input
; rax = number
; rbx = length 
; rsi = buffer
number_to_string:
	push rax
	push rbx
	push rsi
	mov rcx, rbx
	.next_iter:
		cmp rbx, 0
		jle .copy_number
		push rcx
		mov rcx, 10
		xor rdx, rdx
		div rcx
		pop rcx
		add rdx, '0'
		push rdx
		dec rbx
		jmp .next_iter
	.copy_number:
		cmp rcx, 0
		jle .close
		pop rax
		mov [rsi], rax
		inc rsi
		dec rcx
		jmp .copy_number
	.close:
		mov [rsi], byte 0x0
		pop rsi
		pop rbx
		pop rax
		ret

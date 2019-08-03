format ELF64

public factorial
public fibonacci

section '.mth_factorial' executable
; | input
; rax = number
; | output
; rbx = number
factorial:
	push rax
	mov rbx, rax
	dec rbx
	.next_iter:
		cmp rbx, 1
		jle .close
		mul rbx
		dec rbx
		jmp .next_iter
	.close:
		mov rbx, rax
		pop rax
		ret

section '.mth_fibonacci' executable
; | input
; rax = number
; | output
; rbx = number
fibonacci:
	push rax
	push rcx
    mov rbx, rax
    xor rax, rax
    mov rcx, 1
    .next_iter:
        cmp rbx, 0
        jle .close
        dec rbx
        push rcx
        add rcx, rax
        pop rax
        jmp .next_iter
    .close:
    	mov rbx, rax
    	pop rcx
    	pop rax
        ret

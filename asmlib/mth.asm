format ELF64

public gcd
public factorial
public fibonacci

section '.mth_gcd' executable
; | input
; rax = number 1
; rbx = number 2
; | output
; rax = number
gcd:
    push rbx
    push rcx
    push rdx
    .next_iter:
        cmp rbx, 0
        je .close
        push rbx
        xor rdx, rdx
        div rbx
        mov rbx, rdx
        pop rax
        jmp .next_iter
    .close:
        pop rdx
        pop rcx
        pop rbx
        ret


section '.mth_factorial' executable
; | input
; rax = number
; | output
; rax = number
factorial:
    push rbx
    mov rbx, rax
    dec rbx
    .next_iter:
        cmp rbx, 1
        jle .close
        mul rbx
        dec rbx
        jmp .next_iter
    .close:
        pop rbx
        ret

section '.mth_fibonacci' executable
; | input
; rax = number
; | output
; rax = number
fibonacci:
    push rbx
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
        pop rcx
        pop rbx
        ret

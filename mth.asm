format ELF64

public modulo
public pow
public powmod
public euler
public srand
public rand
public bubble_sort
public gcd
public fibonacci
public factorial

include "str.inc"

section '.data' writeable
    _next dq 1

section '.modulo' executable
; | input:
; rax = number 1
; rbx = number 2
; | output:
; rax = number
modulo:
    push rdx
    xor rdx, rdx
    div rbx
    mov rax, rdx
    pop rdx
    ret

section '.pow' executable
; | input:
; rax = number 1
; rbx = number 2
; | output:
; rax = number
pow:
    push rbx
    push rcx
    mov rcx, rax
    .next_iter:
        cmp rbx, 1
        jbe .close
        imul rax, rcx
        dec rbx
        jmp .next_iter
    .close:
        pop rcx
        pop rbx
        ret

section '.powmod' executable
; | input:
; rax = number 1 (x)
; rbx = number 2 (y)
; rcx = number 3 (n)
; | output:
; rax = number
powmod:
    push rbx
    push rdx
    mov rdx, 1
    .next_iter:
        cmp rbx, 0
        je .close
        push rbx
        and rbx, 1
        cmp rbx, 1
        je .mulpow
        jmp .next
    .mulpow:
        push rax
        imul rdx, rax
        mov rax, rdx
        mov rbx, rcx
        call modulo
        mov rdx, rax
        pop rax
    .next:
        imul rax, rax
        mov rbx, rcx
        call modulo
        pop rbx
        shr rbx, 1
        jmp .next_iter
    .close:
        mov rax, rdx
        pop rdx
        pop rbx
        ret

section '.euler' executable
; | input:
; rax = number
; | output:
; rax = number
euler:
    push rbx
    push rcx
    mov rbx, 1
    xor rcx, rcx
    ; [1:rax-1]
    .next_iter:
        cmp rbx, rax
        jae .close
        push rax
        call gcd
        cmp rax, 1
        je .is_mutually_simple
        jmp .next
    .is_mutually_simple:
        inc rcx
    .next:
        pop rax
        inc rbx
        jmp .next_iter
    .close:
        mov rax, rcx
        pop rcx
        pop rbx
        ret

section '.srand' executable
; | input:
; rax = number
srand:
    mov [_next], rax
    ret

section '.rand' executable
; | output:
; rax = number
rand:
    push rbx
    push rdx
    mov rax, [_next]
    mov rbx, 1103515245 * 12345
    mul rbx
    mov [_next], rax
    xor rdx, rdx
    mov rbx, 65536
    div rbx
    xor rdx, rdx
    mov rbx, 32768
    div rbx
    mov rax, rdx
    pop rdx
    pop rbx
    ret

section '.bubble_sort' executable
; | input:
; rax = array
; rbx = array size
bubble_sort:
    push rbx
    push rcx
    push rdx
    xor rcx, rcx ; i
    .first_iter:
        cmp rcx, rbx
        je .break_first
        xor rdx, rdx ; j
        push rbx
        sub rbx, rcx
        dec rbx
        .second_iter:
            cmp rdx, rbx
            je .break_second
            push rbx
            mov bl, [rax+rdx]
            cmp bl, [rax+rdx+1]
            jg .swap
            jmp .pass
        .swap:
            mov bh, [rax+rdx+1]
            mov [rax+rdx+1], bl
            mov [rax+rdx], bh
        .pass:
            pop rbx
            inc rdx
            jmp .second_iter
        .break_second:
            pop rbx
            inc rcx
            jmp .first_iter
    .break_first:
        pop rdx
        pop rcx
        pop rbx
        ret

; gcd(a, 0) = a
; gcd(a, b) = gcd(b, a mod b)
section '.gcd' executable
; | input:
; rax = number 1
; rbx = number 2
; | output:
; rax = number
gcd:
    push rbx
    push rdx
    .next_iter:
        cmp rbx, 0
        je .close
        xor rdx, rdx
        div rbx
        push rbx
        mov rbx, rdx
        pop rax
        jmp .next_iter
    .close:
        pop rdx
        pop rbx
        ret

; 0 1 1 2 3 5 8 13 21 ...
section '.fibonacci' executable
; | input:
; rax = number
; | output:
; rax = number
fibonacci:
    push rbx
    push rcx
    mov rbx, 0
    mov rcx, 1
    cmp rax, 0
    je .next_step
    .next_iter:
        cmp rax, 1
        jle .close
        push rcx
        add rcx, rbx
        pop rbx
        dec rax
        jmp .next_iter
    .next_step:
        xor rcx, rcx
    .close:
        mov rax, rcx
        pop rcx
        pop rbx
        ret

; 6! = 1 * 2 * 3 * 4 * 5 * 6 = 720
section '.factorial' executable
; | input:
; rax = number
; | output:
; rax = number
factorial:
    push rbx
    mov rbx, rax
    mov rax, 1
    .next_iter:
        cmp rbx, 1
        jle .close
        mul rbx
        dec rbx
        jmp .next_iter
    .close:
        pop rbx
        ret

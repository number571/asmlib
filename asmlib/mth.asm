format ELF64

public numbers_vector
public rpn_interpret
public srand
public rand
public bubble_sort
public gcd
public fibonacci
public factorial

include "str.inc"

section '.data' writeable
    _buffer_size equ 256
    _buffer rb _buffer_size
    _ABS  db "ABS", 0
    _NEG  db "NEG", 0
    _MOD  db "MOD", 0
    _FLIP db "FLIP", 0
    _next dq 1

section '.numbers_vector' executable
; | input:
; rax = string
; rbx = buffer
; | output:
; rax = length
numbers_vector:
    push rcx
    push rdx
    push rsi
    xor rsi, rsi
    mov rdx, rax
    .pass_spaces:
        cmp [rdx], byte 0
        je .close
        cmp [rdx], byte ' '
        je .pass
        cmp [rdx], byte ','
        je .pass
        jmp .read
    .pass:
        inc rdx
        jmp .pass_spaces
    .read:
        xor rcx, rcx
        .while_is_number:
            cmp [rdx+rcx], byte 0
            je .break_while
            cmp [rdx+rcx], byte ' '
            je .break_while
            cmp [rdx+rcx], byte ','
            je .break_while
            inc rcx
            jmp .while_is_number
        .break_while:
            cmp [rdx+rcx], byte 0
            je .continue
            jmp .is_not_end
        .is_not_end:
            mov [rdx+rcx], byte 0
            inc rcx
        .continue:
            xor rax, rax
            .read_line:
                cmp rax, rcx
                jge .next_step
                cmp [rdx+rax], byte '-'
                je .is_range
                inc rax
                jmp .read_line
        .is_range:
            sub rcx, 2
            push rcx
            mov [rdx+rax], byte 0
            inc rax
            push rax
            mov rax, rdx
            call string_to_number
            mov rcx, rax
            pop rax
            add rdx, rax
            mov rax, rdx
            call string_to_number
            .generate_range:
                cmp rcx, rax
                jge .close_generate
                mov [rbx+rsi*8], rcx
                inc rsi
                inc rcx
                jmp .generate_range
        .close_generate:
            pop rcx
        .next_step:
            mov rax, rdx
            call string_to_number
            mov [rbx+rsi*8], rax
            inc rsi
            add rdx, rcx
            jmp .pass_spaces
    .close:
        mov rax, rsi
        pop rsi
        pop rdx
        pop rcx
        ret

section '.rpn_interpret' executable
; | input:
; rax = string
; | output:
; rax = number
rpn_interpret:
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    mov rbx, _buffer
    xor rcx, rcx
    xor rdx, rdx
    .next_iter:
        cmp [rax], byte 0
        je .is_space
        cmp [rax], byte ' '
        je .is_space
        cmp [rax], byte '+'
        je .is_plus
        cmp [rax], byte '-'
        je .is_minus
        cmp [rax], byte '*'
        je .is_mul
        cmp [rax], byte '/'
        je .is_div
        jmp .read_char
    .is_space:
        cmp rcx, 0
        je .check_cond
        jmp .pass_cond
    .check_cond:
        cmp [rax], byte 0
        je .to_close
        jmp .next_char
    .pass_cond:
        mov [rbx+rcx], byte 0
        mov rsi, rbx
        mov rdi, _ABS
        mov rcx, 4
        repe cmpsb 
        cmp rcx, 0
        je .is_abs ; ABS
        mov rsi, rbx
        mov rdi, _NEG
        mov rcx, 4
        repe cmpsb 
        cmp rcx, 0
        je .is_neg ; NEG
        mov rsi, rbx
        mov rdi, _MOD
        mov rcx, 4
        repe cmpsb 
        cmp rcx, 0
        je .is_mod ; MOD
        mov rsi, rbx
        mov rdi, _FLIP
        mov rcx, 5
        repe cmpsb 
        cmp rcx, 0
        je .is_flip ; FLIP
        mov rcx, rax
        mov rax, rbx
        call string_to_number
        push rax
        inc rdx
        mov rax, rcx
    .back_to_parse:
        xor rcx, rcx
        cmp [rax], byte 0
        je .to_close
        jmp .next_char
    .is_abs:
        cmp rdx, 1
        jl .pop_stack
        pop rdi
        cmp rdi, 0
        jl .neg_change
        jmp .not_change
        .neg_change:
            neg rdi
        .not_change:
            push rdi
        jmp .back_to_parse
    .is_neg:
        cmp rdx, 1
        jl .pop_stack
        pop rdi
        neg rdi
        push rdi
        jmp .back_to_parse
    .is_mod:
        cmp rdx, 2
        jl .pop_stack
        pop rdi
        pop rsi
        push rax
        push rdx
        xor rdx, rdx
        mov rax, rsi
        div rdi
        mov rdi, rdx
        pop rdx
        pop rax
        push rdi
        dec rdx
        jmp .back_to_parse
    .is_flip:
        cmp rdx, 2
        jl .pop_stack
        pop rdi
        pop rsi
        push rdi
        push rsi
        jmp .back_to_parse
    .is_plus:
        cmp rdx, 2
        jl .pop_stack
        pop rdi
        pop rsi
        add rdi, rsi
        push rdi
        dec rdx
        jmp .next_char
    .is_minus:
        cmp rdx, 2
        jl .pop_stack
        pop rdi
        pop rsi
        sub rsi, rdi
        push rsi
        dec rdx
        jmp .next_char
    .is_mul:
        cmp rdx, 2
        jl .pop_stack
        pop rdi
        pop rsi
        imul rdi, rsi
        push rdi
        dec rdx
        jmp .next_char
    .is_div:
        cmp rdx, 2
        jl .pop_stack
        pop rdi
        pop rsi
        push rax
        push rdx
        xor rdx, rdx
        mov rax, rsi
        div rdi
        mov rdi, rax
        pop rdx
        pop rax
        push rdi
        dec rdx
        jmp .next_char
    .read_char:
        cmp rcx, _buffer_size
        jge .next_char
        mov rdi, [rax]
        mov [rbx+rcx], rdi
        inc rcx
        jmp .next_char
    .next_char:
        inc rax
        jmp .next_iter
    .pop_stack:
        cmp rdx, 0
        jle .set_error
        pop rax
        dec rdx
        jmp .pop_stack
    .set_error:
        push -1
        jmp .close
    .to_close:
        cmp rdx, 0
        je .set_error
        cmp rdx, 1
        jne .pop_stack
        jmp .close
    .close:
        pop rax ; save result
        pop rsi
        pop rdi
        pop rdx
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

format ELF64

public roman_numeral
public numbers_vector
public interpret_lisp
public interpret_rpn
public srand
public rand
public bubble_sort
public gcd
public fibonacci
public factorial

include "str.inc"

section '.data' writeable
    _buffer_size equ 256
    _buffer1 rb _buffer_size
    _buffer2 rq _buffer_size
    _ADD db "+", 0
    _SUB db "-", 0
    _MUL db "*", 0
    _DIV db "/", 0
    _ABS  db "ABS", 0
    _NEG  db "NEG", 0
    _MOD  db "MOD", 0
    _FLIP db "FLIP", 0
    _next dq 1

; EXAMPLE: "CMLIX" = 959
section '.roman_numeral' executable
; | input:
; rax = string
; | output:
; rax = number
roman_numeral:
    push rbx
    push rcx
    push rdx
    push 0
    xor rcx, rcx
    xor rbx, rbx ; accumulator
    .next_iter:
        cmp [rax], byte 0
        je .close
        cmp [rax], byte 'I'
        je .is_1
        cmp [rax], byte 'V'
        je .is_5
        cmp [rax], byte 'X'
        je .is_10
        cmp [rax], byte 'L'
        je .is_50
        cmp [rax], byte 'C'
        je .is_100
        cmp [rax], byte 'D'
        je .is_500
        cmp [rax], byte 'M'
        je .is_1000
        jmp .next_step
    .is_1:
        pop rdx
        push 1
        cmp rdx, 0
        je .add_1
        cmp rdx, 1
        jge .add_1
        jmp .next_step
        .add_1:
            inc rbx
        jmp .next_step
    .is_5:
        pop rdx
        push 5
        cmp rdx, 0
        je .add_5
        cmp rdx, 5
        jge .add_5
        sub rbx, rdx
        sub rbx, rdx
        .add_5:
            add rbx, 5
        jmp .next_step
    .is_10:
        pop rdx
        push 10
        cmp rdx, 0
        je .add_10
        cmp rdx, 10
        jge .add_10
        sub rbx, rdx
        sub rbx, rdx
        .add_10:
            add rbx, 10
        jmp .next_step
    .is_50:
        pop rdx
        push 50
        cmp rdx, 0
        je .add_50
        cmp rdx, 50
        jge .add_50
        sub rbx, rdx
        sub rbx, rdx
        .add_50:
            add rbx, 50
        jmp .next_step
    .is_100:
        pop rdx
        push 100
        cmp rdx, 0
        je .add_100
        cmp rdx, 100
        jge .add_100
        sub rbx, rdx
        sub rbx, rdx
        .add_100:
            add rbx, 100
        jmp .next_step
    .is_500:
        pop rdx
        push 500
        cmp rdx, 0
        je .add_500
        cmp rdx, 500
        jge .add_500
        sub rbx, rdx
        sub rbx, rdx
        .add_500:
            add rbx, 500
        jmp .next_step
    .is_1000:
        pop rdx
        push 1000
        cmp rdx, 0
        je .add_1000
        cmp rdx, 1000
        jge .add_1000
        sub rbx, rdx
        sub rbx, rdx
        .add_1000:
            add rbx, 1000
        jmp .next_step
    .next_step:
        inc rax
        jmp .next_iter
    .close:
        mov rax, rbx
        pop rdx
        pop rdx
        pop rcx
        pop rbx
        ret

; EXAMPLE: "1-5,7,9-11" = [1,2,3,4,5,7,9,10,11]
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

section '.interpret_lisp' executable
; | input:
; rax = string
; | output:
; rax = number
interpret_lisp:
    push rbx
    push rcx
    push rdx
    push rsi
    mov rsi, rax
    xor rdx, rdx ; buffers index
    .next_iter:
        cmp [rsi], byte 0
        je .close
        cmp [rsi], byte ' '
        je .next_step
        cmp [rsi], byte '('
        je .open_expression
        cmp [rsi], byte ')'
        je .close_expression
        jmp .push_value
    .open_expression:
        inc rdx
        inc rsi
        mov bl, [rsi]
        mov [_buffer2+rdx*8], 0
        mov [_buffer1+rdx], bl
        jmp .next_step
    .close_expression:
        mov rcx, [_buffer2+rdx*8]
        .next_iter_exp:
            cmp rcx, 1
            jle .close_exp
            pop rbx
            pop rax
            cmp [_buffer1+rdx], byte '+'
            je .is_add
            cmp [_buffer1+rdx], byte '*'
            je .is_mul
            cmp [_buffer1+rdx], byte '-'
            je .is_sub
            cmp [_buffer1+rdx], byte '/'
            je .is_div
            jmp .next_step_exp
        .is_add:
            add rax, rbx
            jmp .next_step_exp
        .is_mul:
            imul rax, rbx
            jmp .next_step_exp
        .is_sub:
            cmp rcx, 3
            jge .is_add
            sub rax, rbx
            jmp .next_step_exp
        .is_div:
            cmp rcx, 3
            jge .is_mul
            push rdx
            xor rdx, rdx
            div rbx
            pop rdx
            jmp .next_step_exp
        .next_step_exp:
            push rax
            dec rcx
            jmp .next_iter_exp
        .close_exp:
            dec rdx
            mov rbx, [_buffer2+rdx*8]
            inc rbx
            mov [_buffer2+rdx*8], rbx
            jmp .next_step
    .push_value:
        xor rcx, rcx
        .read_value:
            cmp [rsi+rcx], byte ' '
            je .read_close
            cmp [rsi+rcx], byte '('
            je .read_close
            cmp [rsi+rcx], byte ')'
            je .read_close
            inc rcx
            jmp .read_value
        .read_close:
            push qword [rsi+rcx]
            mov [rsi+rcx], byte 0
            mov rax, rsi
            call string_to_number
            pop qword [rsi+rcx]
            add rsi, rcx
            push rax
            mov rbx, [_buffer2+rdx*8]
            inc rbx
            mov [_buffer2+rdx*8], rbx
        jmp .next_iter
    .next_step:
        inc rsi
        jmp .next_iter
    .close:
        pop rax
        pop rsi 
        pop rdx
        pop rcx
        pop rbx
        ret

; EXAMPLE: "2 3 4 * 5 + NEG -" = 19
section '.interpret_rpn' executable
; | input:
; rax = string
; | output:
; rax = number
interpret_rpn:
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    push r8
    push r9
    mov rdx, rax
    .next_iter:
        cmp [rdx], byte 0
        je .close
        cmp [rdx], byte ' '
        je .inc_point
    xor rcx, rcx
    .read_value:
        cmp [rdx+rcx], byte 0
        je .close_read
        cmp [rdx+rcx], byte ' '
        je .close_read
        inc rcx
        jmp .read_value
    .close_read:
        mov r8b, [rdx+rcx]
        mov [rdx+rcx], byte 0
        mov r9, rcx
        inc r9
        ; ADD
        mov rsi, rdx
        mov rdi, _ADD
        mov rcx, r9
        repe cmpsb
        cmp rcx, 0
        je .is_add
        ; SUB
        mov rsi, rdx
        mov rdi, _SUB
        mov rcx, r9
        repe cmpsb
        cmp rcx, 0
        je .is_sub
        ; MUL
        mov rsi, rdx
        mov rdi, _MUL
        mov rcx, r9
        repe cmpsb
        cmp rcx, 0
        je .is_mul
        ; DIV
        mov rsi, rdx
        mov rdi, _DIV
        mov rcx, r9
        repe cmpsb
        cmp rcx, 0
        je .is_div
        ; ABS
        mov rsi, rdx
        mov rdi, _ABS
        mov rcx, r9
        repe cmpsb
        cmp rcx, 0
        je .is_abs
        ; NEG
        mov rsi, rdx
        mov rdi, _NEG
        mov rcx, r9
        repe cmpsb
        cmp rcx, 0
        je .is_neg
        ; FLIP
        mov rsi, rdx
        mov rdi, _FLIP
        mov rcx, r9
        repe cmpsb
        cmp rcx, 0
        je .is_flip
        jmp .is_num
    .is_add:
        pop rax
        pop rbx
        add rax, rbx
        jmp .next_step
    .is_sub:
        pop rbx
        pop rax
        sub rax, rbx
        jmp .next_step
    .is_mul:
        pop rax
        pop rbx
        imul rax, rbx
        jmp .next_step
    .is_div:
        pop rbx
        pop rax
        push rdx
        xor rdx, rdx
        div rbx
        pop rdx
        jmp .next_step
    .is_abs:
        pop rax
        cmp rax, 0
        jl .to_neg
        jmp .to_pass
    .to_neg:
        neg rax
    .to_pass:
        jmp .next_step
    .is_neg:
        pop rax
        neg rax
        jmp .next_step
    .is_flip:
        pop rbx
        pop rax
        push rbx
        jmp .next_step
    .is_num:
        mov rax, rdx
        call string_to_number
        jmp .next_step
    .next_step:
        push rax
        dec r9
        mov [rdx+r9], r8b
        add rdx, r9
        jmp .next_iter
    .inc_point:
        inc rdx
        jmp .next_iter
    .close:
        pop rax ; result
        pop r9
        pop r8
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

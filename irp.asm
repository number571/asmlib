format ELF64

public roman_numeral
public numbers_vector
public interpret_lisp
public interpret_rpn

include "str.inc"

section '.data' writeable
    _buffer_size equ 256
    _buffer1 rb _buffer_size
    _buffer2 rb _buffer_size
    _ADD db "+", 0
    _SUB db "-", 0
    _MUL db "*", 0
    _DIV db "/", 0
    _ABS  db "ABS", 0
    _NEG  db "NEG", 0
    _FLIP db "FLIP", 0

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
    push rdi
    push r8
    xor r8, r8
    mov rdx, rax
    .next_iter:
        cmp [rdx], byte 0
        je .close
        cmp [rdx], byte ' '
        je .inc_point
        cmp [rdx], byte '('
        je .open_expression
        cmp [rdx], byte ')'
        je .close_expression
        jmp .read_arguments
    .inc_point:
        inc rdx
        jmp .next_iter
    .open_expression:
        inc r8
        inc rdx
        call word_length_lisp
        mov bl, [rdx+rax]
        mov [rdx+rax], byte 0
        inc rax
        ; ADD
        mov rsi, rdx
        mov rdi, _ADD
        mov rcx, rax
        repe cmpsb
        cmp rcx, 0
        je .append_add
        ; SUB
        mov rsi, rdx
        mov rdi, _SUB
        mov rcx, rax
        repe cmpsb
        cmp rcx, 0
        je .append_sub
        ; MUL
        mov rsi, rdx
        mov rdi, _MUL
        mov rcx, rax
        repe cmpsb
        cmp rcx, 0
        je .append_mul
        ; DIV
        mov rsi, rdx
        mov rdi, _DIV
        mov rcx, rax
        repe cmpsb
        cmp rcx, 0
        je .append_div
    .next_step:
        dec rax
        mov [rdx+rax], bl
        mov [_buffer2+r8], 0
        add rdx, rax
        jmp .next_iter
    .append_add:
        mov [_buffer1+r8], '+'
        jmp .next_step
    .append_sub:
        mov [_buffer1+r8], '-'
        jmp .next_step
    .append_mul:
        mov [_buffer1+r8], '*'
        jmp .next_step
    .append_div:
        mov [_buffer1+r8], '/'
        jmp .next_step
    .close_expression:
        inc rdx
        mov cl, [_buffer2+r8]
        .pop_elements:
            cmp cl, 1
            jle .close_pop
            dec cl
            cmp [_buffer1+r8], '+'
            je .is_add
            cmp [_buffer1+r8], '-'
            je .is_sub
            cmp [_buffer1+r8], '*'
            je .is_mul
            cmp [_buffer1+r8], '/'
            je .is_div
            jmp .pop_elements
        .is_add:
            pop rax
            pop rbx
            add rax, rbx
            push rax
            jmp .pop_elements
        .is_sub:
            cmp cl, 1
            jle .to_sub
            jmp .is_add
            .to_sub:
                pop rbx
                pop rax
                sub rax, rbx
                push rax
            jmp .pop_elements
        .is_mul:
            pop rax
            pop rbx
            imul rax, rbx
            push rax
            jmp .pop_elements
        .is_div:
            cmp cl, 1
            jle .to_div
            jmp .is_mul
            .to_div:
                pop rbx
                pop rax
                push rdx
                xor rdx, rdx
                div rbx
                pop rdx
                push rax
            jmp .pop_elements
        .close_pop:
            dec r8
            mov cl, [_buffer2+r8]
            inc cl
            mov [_buffer2+r8], cl
        jmp .next_iter
    .read_arguments:
        mov cl, [_buffer2+r8]
        inc cl
        mov [_buffer2+r8], cl
        call word_length_lisp
        mov rcx, rax
        mov bl, [rdx+rcx]
        mov [rdx+rcx], byte 0
        mov rax, rdx
        call string_to_number
        push rax
        mov [rdx+rcx], bl
        add rdx, rcx
        jmp .next_iter
    .close:
        pop rax ; result
        pop r8
        pop rdi 
        pop rsi 
        pop rdx
        pop rcx
        pop rbx
        ret

section '.word_length_lisp' executable
; | input:
; rdx = string
; | output:
; rax = number
word_length_lisp:
    xor rax, rax
    .next_iter:
        cmp [rdx+rax], byte ' '
        je .close
        cmp [rdx+rax], byte '('
        je .close
        cmp [rdx+rax], byte ')'
        je .close
        inc rax
        jmp .next_iter
    .close:
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

format ELF64

public input_char
public input_number
public input_string
public print_bytes
public printf
public print_hex
public print_oct
public print_bin
public print_integer
public print_number
public print_string
public print_char
public print_line

include "str.inc"

section '.bss' writeable 
    _bss_char rb 1

    _buffer_char_size equ 2
    _buffer_char rb _buffer_char_size

    _buffer_number_size equ 21
    _buffer_number rb _buffer_number_size

section '.input_char' executable
; | output:
; rax = char
input_char:
    push rbx
    mov rax, _buffer_char
    mov rbx, _buffer_char_size
    call input_string
    mov rax, [rax]
    pop rbx
    ret

section '.input_number' executable
; | output:
; rax = number
input_number:
    push rbx
    mov rax, _buffer_number
    mov rbx, _buffer_number_size
    call input_string
    call string_to_number
    pop rbx
    ret

section '.input_string' executable
; | input:
; rax = buffer
; rbx = buffer size
input_string:
    push rax
    push rbx
    push rcx
    push rdx

    mov rcx, rax
    mov rdx, rbx
    mov rax, 3 ; read
    mov rbx, 2 ; stdin
    int 0x80

    ; upd
    mov [rcx+rax-1], byte 0

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

section '.print_bytes' executable
; | input:
; rax = array
; rbx = array size
print_bytes:
    push rax
    push rbx
    push rcx
    mov rcx, rax
    xor rax, rax
    mov al, '['
    call print_char
    mov al, ' '
    call print_char
    .next_iter:
        cmp rbx, 0
        je .close
        mov al, [rcx]
        call print_number
        mov al, ' '
        call print_char
        inc rcx
        dec rbx
        jmp .next_iter
    .close:
        mov al, ']'
        call print_char
        pop rcx
        pop rbx
        pop rax
        ret

section '.printf' executable
; | input:
; rax = format
; stack = values
printf:
    push rax
    push rbx
    mov rbx, 32
    .next_iter:
        cmp [rax], byte 0
        je .close
        cmp [rax], byte '%'
        je .special_char
        jmp .default_char
        .special_char:
            inc rax
            cmp [rax], byte 's'
            je .print_string
            cmp [rax], byte 'd'
            je .print_number
            cmp [rax], byte 'b'
            je .print_bin
            cmp [rax], byte 'o'
            je .print_oct
            cmp [rax], byte 'x'
            je .print_hex
            cmp [rax], byte 'c'
            je .print_char
            cmp [rax], byte '%'
            je .default_char
            jmp .next_step
        .print_string:
            push rax
            mov rax, [rsp+rbx]
            call print_string
            pop rax
            jmp .shift_stack
        .print_number:
            push rax
            mov rax, [rsp+rbx]
            call print_number
            pop rax
            jmp .shift_stack
        .print_bin:
            push rax
            mov rax, [rsp+rbx]
            call print_bin
            pop rax
            jmp .shift_stack
        .print_oct:
            push rax
            mov rax, [rsp+rbx]
            call print_oct
            pop rax
            jmp .shift_stack
        .print_hex:
            push rax
            mov rax, [rsp+rbx]
            call print_hex
            pop rax
            jmp .shift_stack
        .print_char:
            push rax
            mov rax, [rsp+rbx]
            call print_char
            pop rax
            jmp .shift_stack
        .default_char:
            push rax
            mov rax, [rax]
            call print_char
            pop rax
            jmp .next_step
        .shift_stack:
            add rbx, 8
        .next_step:
            inc rax
            jmp .next_iter
    .close:
        pop rbx
        pop rax
        ret

section '.print_hex' executable
; | input:
; rax = number
print_hex:
    push rax
    push rbx
    push rcx
    push rdx
    xor rcx, rcx
    push rax
    mov rax, '0'
    call print_char
    mov rax, 'x'
    call print_char
    pop rax
    .next_iter:
        mov rbx, 16
        xor rdx, rdx
        div rbx
        cmp rdx, 10
        jl .is_number
        jmp .is_alpha
        .is_number:
            add rdx, '0'
            jmp .next_step
        .is_alpha:
            sub rdx, 10
            add rdx, 'A'
            jmp .next_step
        .next_step:
            push rdx
            inc rcx
            cmp rax, 0
            je .print_iter
            jmp .next_iter
    .print_iter:
        cmp rcx, 0
        je .close
        pop rax
        call print_char
        dec rcx
        jmp .print_iter
    .close:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

section '.print_oct' executable
; | input:
; rax = number
print_oct:
    push rax
    push rbx
    push rcx
    push rdx
    xor rcx, rcx
    push rax
    mov rax, '0'
    call print_char
    pop rax
    .next_iter:
        mov rbx, 8
        xor rdx, rdx
        div rbx
        add rdx, '0'
        push rdx
        inc rcx
        cmp rax, 0
        je .print_iter
        jmp .next_iter
    .print_iter:
        cmp rcx, 0
        je .close
        pop rax
        call print_char
        dec rcx
        jmp .print_iter
    .close:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

section '.print_bin' executable
; | input:
; rax = number
print_bin:
    push rax
    push rbx
    push rcx
    push rdx
    xor rcx, rcx
    push rax
    mov rax, '0'
    call print_char
    mov rax, 'b'
    call print_char
    pop rax
    .next_iter:
        mov rbx, 2
        xor rdx, rdx
        div rbx
        add rdx, '0'
        push rdx
        inc rcx
        cmp rax, 0
        je .print_iter
        jmp .next_iter
    .print_iter:
        cmp rcx, 0
        je .close
        pop rax
        call print_char
        dec rcx
        jmp .print_iter
    .close:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

section '.print_integer' executable
; | input:
; rax = number
print_integer:
    push rax
    push rbx
    push rcx
    push rdx
    xor rcx, rcx
    cmp rax, 0
    jl .is_minus
    jmp .next_iter
    .is_minus:
        neg rax
        push rax
        mov rax, '-'
        call print_char
        pop rax
    .next_iter:
        mov rbx, 10
        xor rdx, rdx
        div rbx
        add rdx, '0'
        push rdx
        inc rcx
        cmp rax, 0
        je .print_iter
        jmp .next_iter
    .print_iter:
        cmp rcx, 0
        je .close
        pop rax
        call print_char
        dec rcx
        jmp .print_iter
    .close:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

section '.print_number' executable
; | input:
; rax = number
print_number:
    push rax
    push rbx
    push rcx
    push rdx
    xor rcx, rcx
    .next_iter:
        mov rbx, 10
        xor rdx, rdx
        div rbx
        add rdx, '0'
        push rdx
        inc rcx
        cmp rax, 0
        je .print_iter
        jmp .next_iter
    .print_iter:
        cmp rcx, 0
        je .close
        pop rax
        call print_char
        dec rcx
        jmp .print_iter
    .close:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

section '.print_char' executable
; | input
; rax = char
print_char:
    push rdx
    push rcx
    push rbx
    push rax

    mov [_bss_char], al

    mov rax, 4
    mov rbx, 1
    mov rcx, _bss_char
    mov rdx, 1
    int 0x80

    pop rax
    pop rbx
    pop rcx
    pop rdx
    ret

section '.print_string' executable
; | input
; rax = string
print_string:
    push rax
    push rbx
    push rcx
    push rdx

    mov rcx, rax
    call length_string

    mov rdx, rax
    mov rax, 4
    mov rbx, 1
    int 0x80

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

section '.print_line' executable
print_line:
    push rax
    mov rax, 0xA
    call print_char
    pop rax
    ret

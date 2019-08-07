format ELF64

include "str.inc"

public printf
public input_string
public input_number
public print_string
public print_number
public print_hex
public print_oct
public print_bin
public print_char
public print_line

section '.fmt_bss' writable
    fmt_buff_size equ 20
    fmt_buffer rb fmt_buff_size

section '.fmt_printf' executable
; | input
; rax = fmt
; push = args
printf:
    push rax
    push rbx
    push rcx
    push rdx
    mov rbx, 48
    xor rdx, rdx
    .next_iter:
        cmp [rax], byte 0
        je .close
        cmp [rax], byte '%'
        je .set_special_char
        cmp rdx, 1
        je .print_special
        push rax
        mov rax, [rax]
        call print_char
        pop rax
        jmp .prev_next_iter
    .set_special_char:
        cmp rdx, 1
        jne .pass_print_special_char
        push rax
        mov rax, '%'
        call print_char
        pop rax
        jmp .prev_next_iter
    .pass_print_special_char:
        mov rdx, 1
        jmp .prev_next_iter
    .print_special:
        xor rdx, rdx
        push rax
        cmp [rax], byte 's'
        je .print_string
        cmp [rax], byte 'c'
        je .print_char
        cmp [rax], byte 'd'
        je .print_number
        cmp [rax], byte 'x'
        je .print_hex
        cmp [rax], byte 'o'
        je .print_oct
        cmp [rax], byte 'b'
        je .print_bin
        jmp .print_another_char
    .print_string:
        mov rax, [rsp+rbx]
        call print_string
        jmp .shift_stack
    .print_char:
        mov rax, [rsp+rbx]
        call print_char
        jmp .shift_stack
    .print_number:
        mov rax, [rsp+rbx]
        call print_number
        jmp .shift_stack
    .print_hex:
        mov rax, [rsp+rbx]
        call print_hex
        jmp .shift_stack
    .print_oct:
        mov rax, [rsp+rbx]
        call print_oct
        jmp .shift_stack
    .print_bin:
        mov rax, [rsp+rbx]
        call print_bin
        jmp .shift_stack
    .print_another_char:
        push rax
        mov rax, '%'
        call print_char
        pop rax
        mov rax, [rax]
        call print_char
        jmp .return_address
    .shift_stack:
        add rbx, 8
    .return_address:
        pop rax
    .prev_next_iter:
        inc rax
        jmp .next_iter
    .close:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

section '.fmt_input_string' executable
; | input
; rax = buffer
; rbx = buffer size
input_string:
    push rax
    push rbx
    push rdx
    push rbx
    mov rcx, rax
    mov rbx, 2
    mov rdx, 1
    .next_iter:
        mov rax, 3
        int 0x80
        pop rbx
        cmp [rcx], byte 0xA
        je .close
        cmp rbx, 2
        jle .close
        dec rbx
        push rbx
        mov rbx, 2
        inc rcx
        jmp .next_iter
    .close:
        mov [rcx], byte 0
        pop rdx
        pop rbx
        pop rax
        ret 

section '.fmt_input_number' executable
; | output
; rax = number
input_number:
    push rbx
    mov rax, fmt_buffer
    mov rbx, fmt_buff_size
    call input_string
    call string_to_number
    mov rax, rbx
    pop rbx
    ret

section '.fmt_print_string' executable
; | input
; rax = string
print_string:
    push rax
    push rbx
    push rcx
    push rdx

    call length_string
    mov rdx, rbx
    mov rcx, rax
    mov rax, 4
    mov rbx, 1
    int 0x80

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

section '.fmt_print_number' executable
; | input
; rax = number
print_number:
    push rax
    push rbx
    push rcx
    push rdx
    xor rbx, rbx
    .next_iter:
        mov rcx, 10
        xor rdx, rdx
        div rcx
        add rdx, '0'
        push rdx
        inc rbx
        cmp rax, 0
        jle .print_iter
        jmp .next_iter
    .print_iter:
        cmp rbx, 0
        jle .close
        pop rax
        call print_char
        dec rbx
        jmp .print_iter
    .close:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

section '.fmt_print_hex' executable
; | input
; rax = number
print_hex:
    push rax
    push rbx
    push rcx
    push rdx
    xor rbx, rbx
    push rax
    mov rax, '0'
    call print_char
    mov rax, 'x'
    call print_char
    pop rax
    .next_iter:
        cmp rax, 0
        jle .print_iter
        mov rcx, 16
        xor rdx, rdx
        div rcx
        cmp rdx, 10
        jl .add_num
    .add_char:
        sub rdx, 10
        add rdx, 'A'
        jmp .prev_next_iter
    .add_num:
        add rdx, '0'
        jmp .prev_next_iter
    .prev_next_iter:
        push rdx
        inc rbx
        jmp .next_iter
    .print_iter:
        cmp rbx, 0
        jle .close
        pop rax
        call print_char
        dec rbx
        jmp .print_iter
    .close:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

section '.fmt_print_oct' executable
; | input
; rax = number
print_oct:
    push rax
    push rbx
    push rcx
    push rdx
    xor rbx, rbx
    push rax
    mov rax, '0'
    call print_char
    pop rax
    .next_iter:
        cmp rax, 0
        jle .print_iter
        mov rcx, 8
        xor rdx, rdx
        div rcx
        add rdx, '0'
        push rdx
        inc rbx
        jmp .next_iter
    .print_iter:
        cmp rbx, 0
        jle .close
        pop rax
        call print_char
        dec rbx
        jmp .print_iter
    .close:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret


section '.fmt_print_bin' executable
; | input
; rax = number
print_bin:
    push rax
    push rbx
    push rcx
    push rdx
    xor rbx, rbx
    push rax
    mov rax, '0'
    call print_char
    mov rax, 'b'
    call print_char
    pop rax
    .next_iter:
        cmp rax, 0
        jle .print_iter
        mov rcx, 2
        xor rdx, rdx
        div rcx
        add rdx, '0'
        push rdx
        inc rbx
        jmp .next_iter
    .print_iter:
        cmp rbx, 0
        jle .close
        pop rax
        call print_char
        dec rbx
        jmp .print_iter
    .close:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

section '.fmt_print_char' executable
; | input
; rax = char
print_char:
    push rdx
    push rcx
    push rax

    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 1
    syscall

    pop rax
    pop rcx
    pop rdx
    ret

section '.fmt_print_line' executable
print_line:
    mov rax, 0xA
    call print_char
    ret

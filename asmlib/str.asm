format ELF64

public length_string
public string_to_number
public number_to_string

section '.str_length_string' executable
; | input
; rax = string
; | output
; rax = length
length_string:
    push rbx
    xor rbx, rbx
    .next_iter:
        cmp [rax+rbx], byte 0
        je .close
        inc rbx
        jmp .next_iter
    .close:
        mov rax, rbx
        pop rbx
        ret

section '.str_string_to_number' executable
; | input
; rax = string
; | output
; rax = number
string_to_number:
    push rbx
    push rcx
    push rdx
    xor rdx, rdx
    .next_iter:
        cmp [rax], byte 0
        jle .next_step
        movzx rbx, byte[rax]
        sub rbx, '0'
        push rbx
        inc rdx
        inc rax
        jmp .next_iter
    .next_step:
        xor rax, rax
        mov rcx, 1
    .to_number:
        cmp rdx, 0
        jle .close
        pop rbx
        imul rbx, rcx
        imul rcx, 10
        add rax, rbx
        dec rdx
        jmp .to_number
    .close:
        pop rdx
        pop rcx
        pop rbx
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
        jle .to_string
        push rcx
        mov rcx, 10
        xor rdx, rdx
        div rcx
        pop rcx
        add rdx, '0'
        push rdx
        dec rbx
        jmp .next_iter
    .to_string:
        cmp rcx, 0
        jle .close
        pop rax
        mov [rsi], rax
        inc rsi
        dec rcx
        jmp .to_string
    .close:
        mov [rsi], byte 0x0
        pop rsi
        pop rbx
        pop rax
        ret

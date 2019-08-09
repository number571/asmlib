section '.sys_create' executable
; | input
; rax = filename
; rbx = access rights
; | output
; rax = descriptor
create:
    push rbx
    push rcx

    push rbx
    mov rbx, rax
    mov rax, sys_data_creat
    pop rcx
    int 0x80

    pop rcx
    pop rbx
    ret

section '.sys_open' executable
; | input
; rax = filename
; rbx = mode
; | output
; rax = descriptor
open:
    push rbx
    push rcx

    push rbx
    mov rbx, rax
    mov rax, sys_data_open
    pop rcx
    ; 0 = O_RDONLY
    ; 1 = O_WRONLY
    ; 2 = O_RDWR
    int 0x80

    pop rcx
    pop rbx
    ret

section '.sys_seek' executable
; | input
; rax = descriptor
; rdx = position
seek:
    push rax
    push rbx
    push rcx
    push rdx

    mov rbx, rax
    mov rax, sys_data_lseek
    mov rcx, rdx ; move cursor
    mov rdx, sys_seek_set
    ; SEEK_SET = 0
    ; SEEK_CUR = 1
    ; SEEK_END = 2
    int 0x80

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

section '.sys_read' executable
; | input
; rax = descriptor
; rbx = buffer
; rcx = buffer size
read:
    push rax
    push rbx
    push rcx
    push rdx

    mov rdx, rcx
    mov rcx, rbx
    mov rbx, rax
    mov rax, sys_data_read
    int 0x80

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

section '.sys_write' executable
; | input
; rax = descriptor
; rbx = buffer
; rcx = buffer size
write:
    push rax
    push rbx
    push rcx
    push rdx

    mov rdx, rcx
    mov rcx, rbx
    mov rbx, rax
    mov rax, sys_data_write
    int 0x80

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

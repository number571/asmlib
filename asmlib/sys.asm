format ELF64

include "sys.equ"

public fcreate
public fopen
public fread
public fwrite
public fclose
public exit

section '.sys_fcreate' executable
; | input
; rax = filename
; | output
; rax = descriptor
fcreate:
    push rbx
    push rcx
    mov rbx, rax
    mov rax, sys_creat
    mov rcx, 777o
    int 0x80
    pop rcx
    pop rbx
    ret

section '.sys_fopen' executable
; | input
; rax = filename
; | output
; rax = descriptor
fopen:
    push rbx
    push rcx
    mov rbx, rax
    mov rax, sys_open
    mov rcx, sys_rwx_rdwr
    ; 0 = O_RDONLY
    ; 1 = O_WRONLY
    ; 2 = O_RDWR
    int 0x80
    pop rcx
    pop rbx
    ret

section '.sys_fread' executable
; | input
; rax = descriptor
; rbx = buffer
; rcx = buffer size
fread:
    push rax
    push rbx
    push rcx
    push rdx
    mov rdx, rcx
    mov rcx, rbx
    mov rbx, rax
    mov rax, sys_read
    int 0x80
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

section '.sys_fwrite' executable
; | input
; rax = descriptor
; rbx = string
; rcx = length
fwrite:
    push rax
    push rbx
    push rcx
    push rdx

    push rax
    push rbx
    push rcx
    push rdx

    mov rbx, rax
    mov rax, sys_lseek
    mov rcx, 0 ; move cursor
    mov rdx, sys_seek_set
    ; SEEK_SET = 0
    ; SEEK_CUR = 1
    ; SEEK_END = 2
    int 0x80

    pop rdx
    pop rcx
    pop rbx
    pop rax

    mov rdx, rcx
    mov rcx, rbx
    mov rbx, rax
    mov rax, sys_write
    int 0x80

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

section '.sys_fclose' executable
; | input
; rax = descriptor
fclose:
    push rax
    push rbx
    mov rbx, rax
    mov rax, sys_close
    int 0x80
    pop rbx
    pop rax
    ret

section '.sys_exit' executable
exit:
    mov rax, sys_exit
    xor rbx, rbx
    int 0x80

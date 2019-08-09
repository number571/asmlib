format ELF64

include "sys_equ.inc"
include "sys_prv.inc"

public fcreate
public fcreatea
public fopen
public fopenm
public fread
public freadp
public fwrite
public fwritep
public fclose
public exit

section '.sys_fcreate' executable
; | input
; rax = filename
; | output
; rax = descriptor
fcreate:
    push rbx
    mov rbx, 777o
    call create
    pop rbx
    ret

section '.sys_fcreatea' executable
; | input
; rax = filename
; rbx = access rights
; | output
; rax = descriptor
fcreatea:
    call create
    ret

section '.sys_fopen' executable
; | input
; rax = filename
; | output
; rax = descriptor
fopen:
    push rbx
    mov rbx, sys_rwx_rdwr
    call open
    pop rbx
    ret

section '.sys_fopenm' executable
; | input
; rax = filename
; rbx = mode
; | output
; rax = descriptor
fopenm:
    call open
    ret

section '.sys_fread' executable
; | input
; rax = descriptor
; rbx = buffer
; rcx = buffer size
fread:
    push rdx
    mov rdx, 0
    call seek
    call read
    pop rdx
    ret

section '.sys_freadp' executable
; | input
; rax = descriptor
; rbx = buffer
; rcx = buffer size
; rdx = position
freadp:
    call seek
    call read
    ret

section '.sys_fwrite' executable
; | input
; rax = descriptor
; rbx = buffer
; rcx = buffer size
fwrite:
    push rdx
    mov rdx, 0
    call seek
    call write
    pop rdx
    ret

section '.sys_fwritep' executable
; | input
; rax = descriptor
; rbx = buffer
; rcx = buffer size
; rdx = position
fwritep:
    call seek
    call write
    ret

section '.sys_fclose' executable
; | input
; rax = descriptor
fclose:
    push rax
    push rbx
    mov rbx, rax
    mov rax, sys_data_close
    int 0x80
    pop rbx
    pop rax
    ret

section '.sys_exit' executable
exit:
    mov rax, sys_data_exit
    xor rbx, rbx
    int 0x80

format ELF64

public fcreate
public fdelete
public fopen
public fclose
public fwrite
public fread
public fseek
public time
public exit

section '.fcreate' executable
; | input:
; rax = filename
; rbx = permissions
; | output:
; rax = descriptor
fcreate:
    push rbx
    push rcx

    mov rcx, rbx
    mov rbx, rax
    mov rax, 8 ; creat
    int 0x80

    pop rcx
    pop rbx
    ret

section '.fdelete' executable
; | input:
; rax = filename
fdelete:
    push rax
    push rbx

    mov rbx, rax
    mov rax, 10 ; unlink
    int 0x80
    
    pop rbx
    pop rax
    ret

section '.fopen' executable
; | input:
; rax = filename
; rbx = mode
; ; O_RDONLY = 0
; ; O_WRONLY = 1
; ; O_RDWR = 2
; | output:
; rax = descriptor
fopen:
    push rbx
    push rcx

    mov rcx, rbx
    mov rbx, rax
    mov rax, 5 ; open
    int 0x80

    pop rcx
    pop rbx
    ret

section '.fclose' executable
; | input:
; rax = descriptor
fclose:
    push rbx

    mov rbx, rax
    mov rax, 6 ; close
    int 0x80

    pop rbx
    ret

section '.fwrite' executable
; | input:
; rax = descriptor
; rbx = data
; rcx = data size
fwrite:
    push rax
    push rbx
    push rcx
    push rdx

    push rbx
    push rcx

    mov rbx, 1 
    xor rcx, rcx
    call fseek

    pop rcx
    pop rbx

    mov rdx, rcx
    mov rcx, rbx
    mov rbx, rax
    mov rax, 4 ; write
    int 0x80

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

section '.fread' executable
; | input:
; rax = descriptor
; rbx = buffer
; rcx = buffer size
fread:
    push rax
    push rbx
    push rcx
    push rdx

    push rbx
    push rcx

    mov rbx, 1 
    xor rcx, rcx
    call fseek

    pop rcx
    pop rbx

    mov rdx, rcx
    mov rcx, rbx
    mov rbx, rax
    mov rax, 3 ; read
    int 0x80

    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

section '.fseek' executable
; | input:
; rax = descriptor
; rbx = mode seek
; ; SEEK_SET = 0
; ; SEEK_CUR = 1
; ; SEEK_END = 2
; rcx = position
fseek:
    push rax
    push rbx
    push rdx

    mov rdx, rbx
    ; rcx 
    mov rbx, rax
    mov rax, 19 ; seek
    int 0x80
    
    pop rdx
    pop rbx
    pop rax
    ret

section '.time' executable
; | ouput:
; rax = number
time:
	push rbx
	mov rax, 13
	xor rbx, rbx
	int 0x80
	pop rbx	
	ret

section '.exit' executable
exit:
    mov rax, 1
    mov rbx, 0
    int 0x80

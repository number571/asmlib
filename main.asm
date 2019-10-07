format ELF64
public _start

include "asmlib/fmt.inc"
include "asmlib/mth.inc"
include "asmlib/sys.inc"

section '.bss' writeable
    input_size equ 1024
    input rb input_size

section '.data' writeable
    quit db ":q", 0
    console db ">> ", 0

section '.text' executable
_start:
    .next_iter:
        mov rax, console
        call print_string

        mov rax, input
        mov rbx, input_size
        call input_string

        push rax
        call readstring
        cmp rax, 0
        je .close
        pop rax

        call rpn_interpret
        call print_integer
        call print_line
        jmp .next_iter

    .close:
        call exit

section '.readstring' executable
; | input:
; rax = string
; | output:
; rax = number
readstring:
    push rcx
    push rsi
    push rdi 
    mov rsi, rax
    mov rdi, quit
    mov rcx, 3
    repe cmpsb
    mov rax, rcx
    pop rdi
    pop rsi
    pop rcx
    ret

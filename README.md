# ASMLIB
> Little library for assembly language (dialect FASM).

### Compile library:
```
$ cd asmlib/
$ make compile
```

### Example (RPN interpret):
```asm
format ELF64
public _start

include "asmlib/fmt.inc"
include "asmlib/irp.inc"
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
        call readline
        cmp rax, 1 ; quit code
        je .close
        pop rax
        call interpret_rpn
        call print_integer
        call print_line
        jmp .next_iter
    .close:
        jmp exit

section '.readline' executable
; | input:
; rax = string
; | output:
; rax = number
; ; 0 = nothing
; ; 1 = quit
readline:
    push rcx
    push rsi
    push rdi 
    mov rsi, rax
    mov rdi, quit
    mov rcx, 3
    repe cmpsb
    cmp rcx, 0
    je .is_quit
    jmp .nothing
    .is_quit:
        mov rax, 1
        jmp .close
    .nothing:
        mov rax, 0
    .close:
        pop rdi
        pop rsi
        pop rcx
        ret
```

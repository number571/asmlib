# ASMLIB
> Little libraries for assembly language (dialect FASM).

### Library needs object files
```
$ cd asmlib/
$ fasm fmt.asm && fasm mth.asm && fasm str.asm && fasm sys.asm
$ # or just use Makefile
$ # make compile
```

### Example [RPN calculator]
```asm
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
        call readline
        cmp rax, 1 ; quit code
        je .close
        pop rax

        call rpn_interpret
        call print_integer
        call print_line
        jmp .next_iter

    .close:
        call exit

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

### Compile and Run
```
$ fasm main.asm
$ ld main.o asmlib/fmt.o asmlib/str.o asmlib/sys.o asmlib/mth.o -o main
$ ./main
$ # or just use Makefile
$ # make
>> 2 3 4 * 5 + NEG -
19
>> 137 26 MOD 3 *
21
>> 25 NEG
-25
>> :q
```

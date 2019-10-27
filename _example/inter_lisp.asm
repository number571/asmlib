format ELF64
public _start

include "asmlib/fmt.inc"
include "asmlib/mth.inc"
include "asmlib/sys.inc"

section '.data' writeable
    input db "(+ (* 3 (+ (* 2 4) (+ 3 5))) (+ (- 10 7) 6))", 0

section '.text' executable
_start:
    mov rax, input
    call interpret_lisp
    call print_integer
    call print_line
    jmp exit

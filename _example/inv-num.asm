format ELF64
public _start

include "asmlib/fmt.inc"
include "asmlib/mth.inc"
include "asmlib/sys.inc"

section '.data' writeable
	x equ 3
	n equ 26

; x^(f(n)-1) mod n = x^-1
section '.text' executable
_start:
	mov rax, n
	dec rax
	call euler
	push rax
	mov rax, x
	pop rbx
	call pow
	mov rbx, n
	call modulo
	call print_number
	call print_line
	jmp exit

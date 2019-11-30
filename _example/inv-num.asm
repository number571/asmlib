format ELF64
public _start

include "asmlib/fmt.inc"
include "asmlib/mth.inc"
include "asmlib/sys.inc"

section '.data' writeable
	x equ 5
	n equ 26

; x^(f(n)-1) mod n = x^-1
section '.text' executable
_start:
	mov rax, n
	call euler
	dec rax
	push rax
	mov rax, x
	pop rbx
	mov rcx, n
	call powmod
	call print_number
	call print_line
	jmp exit

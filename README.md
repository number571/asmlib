# ASMLIB
> Little libraries for assembly language (dialect FASM).

### Library needs object files
```
$ cd asmlib/
$ fasm fmt.asm && fasm mth.asm && fasm str.asm && fasm sys.asm
```

### Example
```asm
format ELF64
public _start

include "asmlib/fmt.inc"
include "asmlib/str.inc"
include "asmlib/sys.inc"

section '.bss' writable
	buffsize equ 20
	buff1 rb buffsize
	buff2 rb buffsize

section '.data' writable
	fmt db "[%b + %o = %x]", 0xA, 0

section '.text' executable 
_start:
	mov rbx, buffsize

	mov rax, buff1
	call input_string
	mov rax, buff2
	call input_string

	mov rax, buff1
	call string_to_number
	mov rdx, rbx
	mov rax, buff2
	call string_to_number
	mov rcx, rbx

	mov rbx, rcx
	add rbx, rdx

	push rbx
	push rcx
	push rdx
	mov rax, fmt
	call printf
	call exit
```

### Compile and Run
```
$ fasm main.asm
$ ld main.o asmlib/fmt.o asmlib/str.o asmlib/sys.o asmlib/mth.o -o main
$ ./main
$ # or just use Makefile
$ # make
> 10
> 20
> [0b1010 + 024 = 0x1E]
```

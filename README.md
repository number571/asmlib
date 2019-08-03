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
include "asmlib/sys.inc"

section '.data' writable
	fmt db "[%d + %d = %d]", 0xA, 0

section '.text' executable 
_start:
	mov rbx, 100
	mov rcx, 50
	mov rdx, rbx
	add rdx, rcx
  
	push rdx
	push rbx
	push rcx
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
```

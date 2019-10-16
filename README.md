# ASMLIB
> Little libraries for assembly language (dialect FASM).

### Library needs object files
```
$ cd asmlib/
$ fasm fmt.asm && fasm mth.asm && fasm str.asm && fasm sys.asm
$ # or just use Makefile
$ # make compile
```

### Example [LISP interpret expression]
```asm
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
```

### Compile and Run
```
$ fasm main.asm
$ ld main.o asmlib/fmt.o asmlib/str.o asmlib/sys.o asmlib/mth.o -o main
$ ./main
$ # or just use Makefile
$ # make
57
```

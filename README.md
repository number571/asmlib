# ASMLIB
> Little libraries for assembly language (dialect FASM).

### Library needs object files
```
$ cd asmlib/
$ fasm fmt.asm && fasm mth.asm && fasm str.asm && fasm sys.asm
$ # or just use Makefile
$ # make compile
```

### Example
```asm
format ELF64
public _start

include "asmlib/fmt.inc"
include "asmlib/mth.inc"
include "asmlib/sys.inc"

section '.text' executable 
_start:
    mov rax, 6
    call factorial
    call print_number
    call print_line
    call exit

```

### Compile and Run
```
$ fasm main.asm
$ ld main.o asmlib/fmt.o asmlib/str.o asmlib/sys.o asmlib/mth.o -o main
$ ./main
$ # or just use Makefile
$ # make
> 720
```

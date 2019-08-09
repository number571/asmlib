CC = fasm
LIBS = asmlib/fmt.o asmlib/str.o asmlib/sys.o asmlib/mth.o
.PHONY: default compile build once dump hex run
default: build run
compile: asmlib/fmt.asm asmlib/str.asm asmlib/sys.asm asmlib/mth.asm
	fasm asmlib/fmt.asm && fasm asmlib/str.asm && fasm asmlib/sys.asm && fasm asmlib/mth.asm
build: main.asm
	$(CC) main.asm
	ld main.o $(LIBS) -o main
once: main.asm
	$(CC) main.asm
	ld main.o -o main
dump: main
	objdump -S -M intel -d main > obj.dump
	cat obj.dump
hex: main
	hexeditor main
run: main
	./main

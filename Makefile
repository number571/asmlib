CC = fasm
LIBS = asmlib/fmt.o asmlib/str.o asmlib/sys.o asmlib/mth.o
.PHONY: default build run
default: build run
build: main.asm
	$(CC) main.asm
	ld main.o $(LIBS) -o main
once: main.asm
	$(CC) main.asm
dump: main
	objdump -S -M intel -d main > obj.dump
	cat obj.dump
hex: main
	hexeditor main
run: main
	./main
main.asm:
	$(error "main.asm undefined")

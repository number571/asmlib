CC = fasm
LIBS = asmlib/fmt.asm asmlib/mth.asm asmlib/str.asm asmlib/sys.asm
LIBS_OBJ = asmlib/fmt.o asmlib/mth.o asmlib/str.o asmlib/sys.o
.PHONY: default compile build run
default: build run
compile: $(LIBS)
	$(CC) asmlib/fmt.asm && $(CC) asmlib/mth.asm && $(CC) asmlib/str.asm && $(CC) asmlib/sys.asm
build: main.asm $(LIBS_OBJ)
	fasm main.asm
	ld main.o $(LIBS_OBJ) -o main
run: main
	./main

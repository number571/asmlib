CC = fasm
LIBS = fmt.asm mth.asm irp.asm str.asm sys.asm
.PHONY: default compile
default: compile
compile: $(LIBS)
	$(CC) fmt.asm && $(CC) mth.asm && $(CC) irp.asm && $(CC) str.asm && $(CC) sys.asm

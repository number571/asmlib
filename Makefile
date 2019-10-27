CC = fasm
LIBS = fmt.asm mth.asm str.asm sys.asm
.PHONY: default compile
default: compile
compile: $(LIBS)
	$(CC) fmt.asm && $(CC) mth.asm && $(CC) str.asm && $(CC) sys.asm

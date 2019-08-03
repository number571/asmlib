format ELF64

public exit

section '.sys_equ' writable
	sys_link 	equ 9
	sys_creat 	equ 8
	sys_waitpid equ 7
	sys_close 	equ 6
	sys_open 	equ 5
	sys_write 	equ 4
	sys_read 	equ 3
	sys_fork 	equ 2
	sys_exit 	equ 1
	sys_restart equ 0

section '.sys_exit' executable
exit:
	mov rax, sys_exit
	xor rbx, rbx
	int 0x80

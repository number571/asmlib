section '.sys_equ_data' writable
    sys_data_lseek   equ 19
    sys_data_creat   equ 8
    sys_data_close   equ 6
    sys_data_open    equ 5
    sys_data_write   equ 4
    sys_data_read    equ 3
    sys_data_exit    equ 1

section '.sys_equ_rwx' writable
    sys_rwx_rdonly equ 0
    sys_rwx_wronly equ 1
    sys_rwx_rdwr   equ 2

section '.sys_equ_seek' writable
    sys_seek_set equ 0
    sys_seek_cur equ 1
    sys_seek_end equ 2

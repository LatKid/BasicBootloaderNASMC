%define FREE_SPACE 0x9000
DEFAULT rel
;ORG 0x7c00
EXTERN Kernel
BITS 64
BITS 16
SECTION .text
GLOBAL PrintToPos
GLOBAL main
main:
    jmp 0x0000:.FlushCS
 .F:
    mov al, ah
    add al, 48
    mov ah, 0x0e
    int 0x10
    jmp $
.FlushCS:   
    xor ax, ax
    mov ss, ax
    mov sp, main
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    cld
    mov ah, 0x02
    mov al, 0x03
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02
    mov si, 0x00
    mov es, si
    mov bx, LM
    int 0x13
    jnc $+3
    call main.F
    call CheckCPU
    jc .NoLongMode
    mov edi, FREE_SPACE
    jmp SwitchToLongMode
 
 
BITS 64
.Long:
    jmp LM
 
BITS 16
 
.NoLongMode:
    mov si, NoLongMode
    call PrintRM
 
.Die:
    hlt
    jmp .Die
 
 
%include "SRC/LMSwitch.asm"
BITS 16

NoLongMode db "ERROR: CPU does not support long mode.", 0x0A, 0x0D, 0

CheckCPU:
    pushfd
    pop eax
    mov ecx, eax  
    xor eax, 0x200000 
    push eax 
    popfd
    pushfd 
    pop eax
    xor eax, ecx
    shr eax, 21 
    and eax, 1
    push ecx
    popfd
    test eax, eax
    jz .NoLongMode
    mov eax, 0x80000000   
    cpuid                 
    cmp eax, 0x80000001
    jb .NoLongMode
    mov eax, 0x80000001  
    cpuid                 
    test edx, 1 << 29
    jz .NoLongMode
    ret
 
.NoLongMode:
    stc
    ret
PrintRM:
    pushad
.PrintRMLoop:
    lodsb
    test al, al
    je .PrintRMDone                  	
    mov ah, 0x0E	
    int 0x10
    jmp .PrintRMLoop
 
.PrintRMDone:
    popad
    ret

times 510 - ($-$$) db 0
dw 0xAA55
BITS 64
LM:
jmp $
times 1024 - ($-$$) db 0
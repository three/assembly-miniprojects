; TODO: Align everything

section .text


; Enter in _start, so we don't have to rely on large and unnecessary
; dependencies like libc
global _start
_start:
    ; Make sure user provided correct number of arguments
    cmp dword [rsp], 2
    je checkpals

    ; Bad # of args, print error to stderror
    mov rax, 1
    mov rdi, 2
    mov rsi, badargs
    mov rdx, badargsl
    syscall

    ; And exit with code 1
    mov rax, 60
    mov rdi, 1
    syscall

    ; hlt signals we shouldn't hit this point, we'll segfault if we do
    hlt

checkpals:
    ; %RAX will store the lower characters (0-63) bitmap
    ; %RBX will store the upper characters (64-127) bitmap
    ; Characters above 127 are considered INVALID, and will cause an error
    ; %RSI will store the pointer to current characters
    ; %RDI will store current characters (8 at a time)
    ; %RDX will calc XOR with %RAX/%RBX
    ; %CL will be used to find set bits, and %RCX will be used for shifting
    ; Above is all the registers we can use since r8-r15 have greater
    ;  performance penalties
    xor rax, rax
    xor rbx, rbx
    mov rsi, [rsp+16]
    mov rcx, 0x80 ; %CL=0x80, upper bits should never be set

loop:
    ; Our first instinct may be to unroll the loop, but that won't do any good
    ; since the string is null-terminated

check1:
    ; Char 1
    mov rdi, [rsi]
    or dil, dil ; we need zero flag
    jz end
    and cl, dil
    jnz invchar
    mov cl, 0x40
    and cl, dil
    jnz upper1 ; We assume lower characters will be most likely (NOT TRUE, TODO!)
lower1:
    mov cl, dil
    xor rdx, rdx
    inc rdx
    shl rdx, cl
    xor rax, rdx
    jmp check2
upper1:
    mov cl, dil
    xor rdx, rdx
    and cl, 0x3f
    inc rdx
    shl rdx, cl
    xor rbx, rdx

check2:
    shr rdi, 8
check3:
    shr rdi, 8
check4:
    shr rdi, 8
check5:
    shr rdi, 8
check6:
    shr rdi, 8
check7:
    shr rdi, 8
check8:
    shr rdi, 8

afterchecks:
    mov rcx, 0x80
    add rsi, 1 ; TODO: 8 chars at a time
    jmp loop

    hlt

end:
    xor rcx, rcx
    popcnt rcx, rax
    xor rdx, rdx
    popcnt rdx, rbx
    add rcx, rdx
    cmp rcx, 1
    jle ayes

ano:
    mov rax, 1
    mov rdi, 1
    mov rsi, no
    mov rdx, nol
    syscall

    mov rax, 60
    mov rdi, 1
    syscall

ayes:
    mov rax, 1
    mov rdi, 1
    mov rsi, yes
    mov rdx, yesl
    syscall

    mov rax, 60
    mov rdi, 0
    syscall

    hlt

invchar:
    mov rax, 1
    mov rdi, 2
    mov rsi, badchar
    mov rdx, badcharl
    syscall

    mov rax, 60
    mov rdi, 3
    syscall

    hlt

section .data

badargs db "Bad arguments!",0x0a
badargsl equ $ - badargs

badchar db "Invalid character (extended ascii NOT allowed)!",0x0a
badcharl equ $ - badchar

yes db "YES!",0x0a
yesl equ $ - yes

no db "NO.",0x0a
nol equ $ - no

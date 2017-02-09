; Powerset Iterator in AMD64 Assembly

; IMPLEMENTATION NOTE:
;   This is designed more for readability than for speed. Notably, certain
;   instructions which have faster multi-instruction equivalents are used
;   and registers are all assumed to have the same access speed (and are
;   swapped when unnecessary). Additionally, instructions are not ordered
;   to maximize the processor's parallel processing ability, and loops are
;   not unrolled to stop loop checks.

; Calling Conventions
;  Follows the System V Application Binary interface, and compatible with
;  Linux/gcc ABIs

; STRUCTS
;  iterator_t stores the current value of the iterator, and private data
;  to continue the iterator
;
;  sizeof( iterator_t ) == 5*8 == 40 bytes
;  struct {
;     // Pointer to array of int-like values (eg. pointers) containing the
;     // current powerset element. If vals==NULL, iterator is done.
;     u64 *vals; (OFFSET 0)
;     // Length of val
;     int length; (OFFSET 8)
;     // Private data (used by _powerset_next)
;     int _state; (OFFSET 16)
;     int _max; (OFFSET 24)
;     int *_input; (OFFSET 32)
;  } iterator_t; 

extern malloc
extern free

global _powerset_init
global _powerset_next
global powerset_init
global powerset_next

section .text

powerset_init:
    jmp _powerset_init
powerset_next:
    jmp _powerset_next

; _powerset_init (u64 *RDI, int RSI, iterator_t *RDX) -> int RAX
; Input
;  RDI - Pointer to input list (of integer-like values)
;  RSI - Lenght of input list
;  RDX - Pointer to buffer for struct (must have 40 bytes available)
; Output
;  RAX - error code  -3 - NULL input pointer,
;                    -2 - libc error (ie. malloc returned 0),
;                    -1 - Input too large
;                     0 - no error,
;                     1 - iterator complete
align 64
_powerset_init:
    ; Save registers we want unchanged
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; Setup the Stack
    mov rbp, rsp

    ; Move inputs to known places
    mov r12, rdi
    mov r13, rsi
    mov r14, rdx

    ; Check RDI != NULL
    or rdi, rdi
    jz .error_nullptr

    ; Check RDX != NULL
    or rdx, rdx
    jz .error_nullptr

    ; Check RSI<=64
    cmp rsi, 64
    jg .error_toobig

    ; Initialize values of the struct
    ;  u64 *vals
    ;   A valid malloc implementation should never return NULL because we
    ;   asked for a 0-sized allocation.
    xor rdi, rdi
    call malloc
    or rax, rax
    jz .error_libc
    mov qword [r14], rax
    ;  int length
    mov qword [r14+8], 0
    ;  int _state
    mov qword [r14+16], 0
    ;  int _max
    mov qword [r14+24], r13
    ;  int *_input
    mov qword [r14+32], r12

    ; Return Success
    xor rax, rax
.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.error_toobig:
    mov rax, -1
    jmp .done
.error_libc:
    mov rax, -2
    jmp .done
.error_nullptr:
    mov rax, -3
    jmp .done

; _powerset_next (iterator_t *RDI) -> int RAX
; NOTE
;  This function will free RDI->vals
; Input
;  RDI - Pointer to iterator information
; Output
;  RAX - error code (see _powerset_init)
align 64
_powerset_next:
    ; Save the registers we want unchanged
    push rbp
    push rbx
    push r12
    push r13
    push r14
    push r15

    ; Setup Stack
    mov rbp, rsp

    ; Move inputs to known places
    mov r12, rdi

    ; Free current list
    mov rdi, [rdi]
    call free

    ; Check if we're done iterating ( 2^(RDI->_max)-1==RDI->_state ), and
    ; iterator counter
    mov rbx, [r12+16] ; _state -> RBX
    mov rcx, [r12+24] ; _max   -> RCX
    inc rbx
    mov r13, rbx ; _state (new) -> R13
    mov [r12+16], rbx ; RBX -> _state
    shr rbx, cl
    or rbx, rbx
    jnz .complete

    ; Allocate space for array of subset
    popcnt rcx, r13
    mov [r12+8], rcx ; RCX -> length
    sal rcx, 3
    mov rdi, rcx
    call malloc
    mov [r12], rax ; RAX -> vals

    ; Find each element in subset
    mov r14, [r12+32] ; Pointer to input
    xor rcx, rcx ; Which index of vals
    xor rdx, rdx ; Which index of input
.loop:
    ; Skip if this input is not included
    mov rbx, r13
    and rbx, 1
    jz .skip

    ; Move input location to val location, inc val
    mov r8, [r14+8*rdx]
    mov [rax+8*rcx], r8
    inc rcx

.skip:
    ; Shift state and increment input index
    shr r13, 1
    inc rdx

.loop_bottom:
    ; Check if state is 0, decide to loop
    or r13, r13
    jz .done_succ
    jmp .loop

.done_succ:
    ; Return success
    xor rax, rax
.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret
.complete:
    mov qword [r12], 0
    mov qword  [r12+8], 0
    mov qword [r12+32], 0
    mov rax, 1
    jmp .done

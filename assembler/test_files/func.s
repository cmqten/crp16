; Tests function calls and the program stack
; Program counts tribonacci numbers

setup:
    ldi     sp, 64      ; initialize stack

start:
    ldi     r0, 0
    ldi     r1, 0
    ldi     r2, 1

loop:
    ; save r1 on the stack, r2 - lr are callee saved
    sub     sp, sp, 1   
    stw     r1, sp
    
    ; r0 and r1 for first two arguments, rest of arguments go on the stack
    sub     sp, sp, 1
    stw     r2, sp
    call    trib
    
    ; move previous highest to r1
    add     r1, r2, 0
    
    ; move return value of trib to r2 because it's the new highest trib number
    ; and keep counting until the highest 16-bit trib number
    add     r2, r0, 0
    
    ; restore local variables
    ldw     r0, sp
    add     sp, sp, 1
    
    gts     r3, r2, 0
    jnz     r3, loop
    jmp     start

trib:
    ; add first two numbers by calling sum2
    sub     sp, sp, 1
    stw     lr, sp
    call    sum2
    
    ; restore local variables
    ldw     lr, sp
    add     sp, sp, 1
    ldw     r1, sp
    add     sp, sp, 1
    
    ; add the sum of the first two with the third number by calling sum2
    sub     sp, sp, 1
    stw     lr, sp
    call    sum2
    
    ; return to caller
    ldw     lr, sp
    add     sp, sp, 1
    jmp     lr

sum2:
    add     r0, r0, r1
    jmp     lr
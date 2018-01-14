; Counts all the 16-bit fibonacci numbers

start:       
        ; Initialize r0 and r1
        ldi     r0, 0
        ldi     r1, 1
        
fib_loop:
        add     r1, r0, r1
        sub     r0, r1, r0
        gts     r2, r1, 0
        jnz     r2, fib_loop
        jmp     start     
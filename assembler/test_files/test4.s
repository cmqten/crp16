; Final result
; r0: 000f    r1: 00c0    r2: 00c0    r3: 0010  

start:  
        sub     r1, r1, r1
        sub     r0, r0, r0
        sub     r3, r3, r3  ; clear r0, r1, r3
        ldi     r1, 15      ; load 15 into r1
        add     r0, r0, r1  ; set r0 to 15
        sub     r1, r1, r1  ; clear r1
        or      r1, r1, 1   ; set r1 to 1
        xor     r1, r1, -1  
        ldhi    r1, 0       ; prepare r1 for use in OR
        
loop:   
        add     r3, r0, 0   ; copy r0 to r3
        xor     r3, r3, -1
        ldhi    r3, 0       ; invert lower byte of r3
        and     r3, r3, r1
        xor     r3, r3, -1
        ldhi    r3, 0       ; nand r1 and r3
        sll     r1, r1, 9  
        srl     r1, r1, 8   ; shift value in r1 by 1 to left
        sub     r3, r3, r0
        jez     r3, loop    ; loop while subtraction results in 0
        ldi     r2, 31      
        stw     r1, r2
        ldw     r2, r2
        noop
        noop
        noop
        stop
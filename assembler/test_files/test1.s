; Final result should be
; r0: 0000    r1: 0001    r2: 0003    r3: 0000
        sub     r1, r1, r1  ; clear r1
        ldi     r0, 37      ; load 37 into r0
        srl     r0, r0, 2   ; shift 37 right by 2
        or      r1, r1, 6   ; put 6 in r1
        and     r0, r0, r1      
        xor     r0, r0, -1  ; nand r0 and r1
        sll     r0, r0, 8   ; shift r0 8 to left to clear upper byte
        srl     r0, r0, 14  ; shift r0 14 to the right
        sub     r1, r1, r1  ; clear r1
        or      r1, r1, 1   ; put 1 in r1
loop:   add     r2, r2, r1  ; increment r2
        sub     r0, r0, r1  ; decrement r0
        jnz     r0, loop    ; loop until r0 = 0
        stop
   
        
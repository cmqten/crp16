; Final result
; r0: ffff    r1: 0001    r2: ffff    r3: 0001
        sub     r1, r1, r1  ; clear r1
        ldi     r1, 30      ; address of 37
        ldw     r0, r1    ; loads 37 into r0
        srl    r0, r0, 2   ; shift right by 2
        sub     r1, r1, r1  ; clear r1
        or     r1, r1, 1
loop:   sub     r0, r0, r1  ; decrement r0
        lts    r2, r0, 0   ; check if r0 is less than 0
        jez      r2, loop    ; loop until r0 < 0
        sub     r1, r1, r1  ; clear r1
        ldi     r1, 31      
        stw     r0, r1    ; write r0 to memory
        ldw     r2, r1   ; read it to r2
        add     r3, r3, r1  ; r3 + r1
        sll    r3, r3, 3   ; shift r3 3 to the left
        sub     r1, r1, r1  ; clear r1
        or     r1, r1, 7   ; make r1 equal 7
        add     r3, r3, r1  
        and     r3, r3, r2
        xor    r3, r3, -1
        ldhi    r3, 0 
        sub     r1, r1, r1  ; clear r1
        or     r1, r1, 1   
        add     r3, r3, r1
        noop
        noop
        noop
; Final result should be
; r0: 0000    r1: 001f    r2: 0003    r3: 0003
        sub     r1, r1, r1  ; clear r1
        ldi     r1, 30      ; address of 37
        ldw     r0, r1    ; load 37 into r0
        srl    r0, r0, 2   ; shift 37 by 2 to the right
        sub     r1, r1, r1  ; clear r1
        or     r1, r1, 6   ; put 0x0110 in r1
        and     r0, r0, r1
        xor    r0, r0, -1  ; nand r0 and r1, 0xffff in r0
        ldhi    r0, 0       ; 0xff in r0
        srl    r0, r0, 6   ; shift r0 right by 6, leave 0x3
        sub     r1, r1, r1  ; clear r1
        or     r1, r1, 1   
loop:   add     r2, r2, r1  ; increment r1
        sub     r0, r0, r1  ; decrement r0
        jnz     r0, loop    ; loop until r0 = 0
        ldi     r1, 31
        stw     r2, r1    ; write r2 to memory
        ldw     r3, r1    ; read it to r3
        noop
        noop
        noop
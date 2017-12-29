# CRP16

## About

The CRP16 (Carl's RISC Processor 16-bit) is my attempt at creating a RISC architecture processor with Verilog and a DE1-SoC (5CSEMA5F31C6N) board.

## Tentative Specifications
- 16-bit instructions
- 8 16-bit general-purpose registers
- Word addressable memory
- Harvard architecture
- 4-stage pipeline with data forwarding and early branch resolve for zero pipeline bubbles

## Tentative Instruction Set

| Instruction | Description |
| - | - |
| add | Add two registers |
| addi | Add register and 4-bit zero extended immediate |
| and | Bitwise AND register and register |
| andi | Bitwise AND register and 4-bit sign extended immmediate |
| asr | Arithmetic shift right first register by unsigned least significant nibble in second register | 
| asri | Arithmetic shift right first register by unsigned 4-bit immediate | 
| call | Call subroutine at pc + 10-bit sign extended offset, and link |
| callnz | Call subroutine at pc + 7-bit sign extended offset if condition register is not zero, and link |
| callr | Call subroutine at address in register, and link |
| callrnz | Call subroutine at address in register if condition register is not zero, and link |
| callrz | Call subroutine at address in register if condition register is zero, and link |
| callz | Call subroutine at pc + 7-bit sign extended offset if condition register is zero, and link |
| div | Signed division on two registers |
| divi | Signed division on register and 4-bit sign extended immediate |
| diviu | Unsigned division on register and 4-bit zero extended immediate |
| divu | Unsigned division on two registers |
| jmp | Jump to pc + 10-bit sign extended offset |
| jmpnz | Jump to pc + 7-bit sign extended offset if condition register is not zero |
| jmpr | Jump to address in register |
| jmprnz | Jump to address in register if condition register is not zero |
| jmprz | Jump to address in register if condition register is zero |
| jmpz | Jump to pc + 7-bit sign extended offset if condition register is zero |
| ldr | Load word from memory to register |
| ldrb | Load sign-extended byte from memory to register |
| ldrbu | Load zero-extended byte from memory to register |
| ldri | Load sign-extended immediate byte to register |
| ldriu | Load zero-extended immediate byte to register |
| lsl | Logical shift left first register by unsigned least significant nibble in second register |
| lsli | Logical shift left first register by unsigned 4-bit immediate |
| lsr | Logical shift right first register by unsigned least significant nibble in second register | 
| lsri | Logical shift right first register by unsigned 4-bit immediate | 
| mul | Signed multiplication on two registers |
| muli | Signed multiplication on register and 4-bit sign extended immediate |
| muliu | Unsigned multiplication on register and 4-bit zero extended immeduate |
| mulu | Unsigned multiplication on two registers |
| noop | No operation |
| or | Bitwise OR two registers |
| ori | Bitwise OR register and 4-bit sign extended immmediate |
| sgt | Set destination to 1 if signed first register is greater than signed second register, 0 otherwise |
| sgti | Set destination to 1 if signed first register is greater than 4-bit sign extended immediate, 0 otherwise |
| sgtiu | Set destination to 1 if unsigned first register is greater than 4-bit zero extended immediate, 0 otherwise |
| sgtu | Set destination to 1 if unsigned first register is greater than unsigned second register, 0 otherwise |
| slt | Set destination to 1 if signed first register is less than signed second register, 0 otherwise |
| slti | Set destination to 1 if signed first register is less than 4-bit sign extended immediate, 0 otherwise |
| sltiu | Set destination to 1 if unsigned first register is less than 4-bit zero extended immediate, 0 otherwise |
| sltu | Set destination to 1 if unsigned first register is less than unsigned second register, 0 otherwise |
| str | Store word from register to memory |
| strb | Store sign-extended byte from register to memory |
| strbu | Store zero-extended byte from register to memory |
| sub | Subtract two registers |
| subi | Subtract register and 4-bit zero extended immediate |
| xor | Bitwise XOR two registers |
| xori | Bitwise XOR register and 4-bit sign extended immmediate |

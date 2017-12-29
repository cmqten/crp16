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
| call | Call subroutine at pc + 11-bit sign extended offset |
| callr | Call subroutine at address in register |
| gt | Set destination to 1 if unsigned first register is greater than unsigned second register, 0 otherwise |
| gti | Set destination to 1 if unsigned first register is greater than 4-bit zero extended immediate, 0 otherwise |
| gts | Set destination to 1 if signed first register is greater than signed second register, 0 otherwise |
| gtsi | Set destination to 1 if signed first register is greater than 4-bit sign extended immediate, 0 otherwise |
| j | Jump to pc + 11-bit sign extended offset |
| jnz | Jump to pc + 8-bit sign extended offset if condition register is not zero |
| jr | Jump to address in register |
| jrnz | Jump to address in register if condition register is not zero |
| jrz | Jump to address in register if condition register is zero |
| jz | Jump to pc + 8-bit sign extended offset if condition register is zero |
| ldb | Load zero-extended byte from memory to register |
| ldhi | Load immediate byte to higher byte of register while preserving lower byte |
| ldi | Load zero-extended immediate byte to register |
| ldsb | Load sign-extended byte from memory to register |
| ldsi | Load sign-extended immediate byte to register |
| ldw | Load word from memory to register |
| lsl | Logical shift left first register by unsigned least significant nibble in second register |
| lsli | Logical shift left first register by unsigned 4-bit immediate |
| lsr | Logical shift right first register by unsigned least significant nibble in second register | 
| lsri | Logical shift right first register by unsigned 4-bit immediate | 
| lt | Set destination to 1 if unsigned first register is less than unsigned second register, 0 otherwise |
| lti | Set destination to 1 if unsigned first register is less than 4-bit zero extended immediate, 0 otherwise |
| lts | Set destination to 1 if signed first register is less than signed second register, 0 otherwise |
| ltsi | Set destination to 1 if signed first register is less than 4-bit sign extended immediate, 0 otherwise |
| noop | No operation |
| or | Bitwise OR two registers |
| ori | Bitwise OR register and 4-bit sign extended immmediate |
| stb | Store byte from register to memory |
| stw | Store word from register to memory |
| sub | Subtract two registers |
| subi | Subtract register and 4-bit zero extended immediate |
| xor | Bitwise XOR two registers |
| xori | Bitwise XOR register and 4-bit sign extended immmediate |

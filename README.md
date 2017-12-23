# CRP16

## About

The CRP16 (Carl's RISC Processor 16-bit) is my attempt at creating a RISC architecture processor with Verilog and a DE1-SoC board.

## Tentative Specifications
- 16-bit instructions
- 8 16-bit general-purpose registers
- Word addressable memory
- Harvard architecture
- 4-stage pipeline with branch resolve at decode stage

## Tentative Instruction Set

| Instruction | Description |
| - | - |
| add | Add two registers |
| addi | Add register and 4-bit zero-extended immediate value |
| call | Call subroutine at pc + 10-bit sign-extended offset and link |
| callnz | Call subroutine at pc + 6-bit sign-extended offset if condition register is non-zero and link |
| callnzr | Call subroutine at address in register if condition register is non-zero and link |
| callr | Call subroutine at address in register and link |
| callz | Call subroutine at pc + 6-bit sign-extended offset if condition register is zero and link |
| callzr | Call subroutine at address in register if condition register is zero and link |
| jmp | Jump to pc + 10-bit sign-extended offset |
| jmpnz | Jump to pc + 9-bit sign-extended offset if condition register is non-zero |
| jmpnzr | Jump to address in register if condition register is non-zero |
| jmpr | Jump to address in register |
| jmpz | Jump to pc + 9-bit sign-extended offset if condition register is zero |
| jmpzr | Jump to address in register if condition register is zero |
| ldri | Load 8-bit sign-extended immediate value to register |
| ldriu | Load 8-bit zero-extended immediate value to register |
| ldrhi | Load 8-bit immediate value to higher byte of register while preserving lower byte |
| sub  | Subtract two registers |
| subi | Subtract register and 4-bit zero-extended immmediate value |
| and / andi | Perform a bitwise and on two registers / a register andd an immmediate value.  |
| or / ori | perform a bitwise or on two registers / a register and an immmediate value. |
| xor / xori | Perform a bitwise xor on two registers / a register and an immmediate value. |
| sll / slli | Shift the value left logically in the first register by a value in the second register / an immediate value mod 16. |
| srl / srli | Shift the value right logically in the first register by a value in the second register / an immediate value mod 16. |
| sra / srai | Shift the value right with sign extension in the first register by a value in the second register / an immediate value mod 16. |
| slt / slti / sltu / sltiu | Set the value of r13 to 1 if the first operand is less than the second operand, 0 otherwise. The *i* specifies that the second operand is an immediate value, the *u* specifies that both operands are unsigned. |
| sgt / sgti / sgtu / sgtiu | Set the value of r13 to 1 if the first operand is greater than the second operand, 0 otherwise. The *i* specifies that the second operand is an immediate value, the *u* specifies that both operands are unsigned. |

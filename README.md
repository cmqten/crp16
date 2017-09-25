# CRP16

## About

The CRP16 (Carl's RISC Processor 16-bit) is my attempt at creating a RISC architecture processor with Verilog and a DE2-115 board. The CRP16 architecture is based on the MIPS and ARM architectures, with a set of instructions taken from both architectures, as well as a set of instructions exclusive to CRP16 that were inspired by both.

## Tentative Specifications
- 16-bit instructions
- 16 16-bit registers, with some having special designations:

  | Register Number | Designation |
  | - | - |
  | r15 | stack pointer |
  | r14 | link register for branch instructions |
  | r13 | branch condition register for conditional branch instructions |
  | r12 | hi register, higher 2 bytes of the result of multiplication/division |
  | r11 | lo register, lower 2 bytes of the result of multiplication/division |
  
- Word addressable memory, memory is in chunks of 16 bits for easy access
- No optimizations at the moment

## Tentative Instruction Set

| Instruction | Description |
| - | - |
| add / addi* | Add two registers / a register and an immediate value. |
| sub / subi* | Subtract two registers / a register and an immmediate value. |
| and / andi | Perform a bitwise and on two registers / a register andd an immmediate value.  |
| or / ori | perform a bitwise or on two registers / a register and an immmediate value. |
| sll** / slli** | Shift the value left logically in the first register by a value in the second register / an immediate value. |
| srl** / srli** | Shift the value right logically in the first register by a value in the second register / an immediate value. |
| sra** / srai** | Shift the value right with sign extension in the first register by a value in the second register / an immediate value. |
| xor / xori | Perform a bitwise xor on two registers / a register and an immmediate value. |
| mov / movu | Move a signed / unsigned immediate  value to a register. |
| slt / slti / sltu / sltiu | Set the value of r13 to 1 if the first operand is less than the second operand, 0 otherwise. The *i* specifies that the second operand is an immediate value, the *u* specifies that both operands are unsigned. |
| sgt / sgti / sgtu / sgtiu | Set the value of r13 to 1 if the first operand is greater than the second operand, 0 otherwise. The *i* specifies that the second operand is an immediate value, the *u* specifies that both operands are unsigned. |
| b*** / bl*** / br / blr | Branch unconditionally. The *l* saves the return address in r14, the *r* specifies that the address is stored in a register. |
| bt*** / btl*** / btr / btlr | Branch if true, i.e, the value of r13 is non-zero. The *l* saves the return address in r14, the *r* specifies that the address is stored in a register. |
| bf*** / bfl*** / bfr / bflr | Branch if false, i.e, the value of r13 is zero. The *l* saves the return address in r14, the *r* specifies that the address is stored in a register. |

\* By default, immediate instructions that do not specify unsigned or signed mode sign extend the immediate value except for addi and subi, which do not sign extend the immediate values

\** Regardless of the value for the second operand of sll, slli, srl, srli, sra, and srai, they will only look at the lowest four bits. For example, specifying 17 in decimal as the second operand will result in shifting by 1 place, because 17 is 10001 in binary, and the lowest four bits are 0001, which is 1 in decimal.

\*** The immediate value that b, bl, bt, btl, bf, and bfl take is a sign extended offset rather than an absolute address

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
- No optimizations at all, not even pipelining

## Tentative Instruction Set

| Instruction | Description |
| - | - |
| add / addi | add two registers / a register and an immediate value |
| sub / subi | subtract two registers / a register and an immmediate value |
| and / andi | perform a bitwise and on two registers / a register andd an immmediate value |
| or / ori | perform a bitwise or on two registers / a register and an immmediate value |
| not / noti | perform a bitwise or on a register / an immmediate value |
| xor / ori | perform a bitwise xor on two registers / a register and an immmediate value |
| mov / movi | moves a value stored in a register / an immediate value to a register |
| slt / slti / sltu / sltiu | sets the value of r13 to 1 if the first operand is less than the second operand, 0 otherwise. The i specifies that the second operand is an immediate value, the u specifies that both operands are unsigned |

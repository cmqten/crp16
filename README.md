# CRP16

## About

The CRP16 (Carl's RISC Processor 16-bit) is my attempt at creating a RISC architecture processor with Verilog and a DE2-115 board. The CRP16 architecture is based on the MIPS architecture, with a small set of instructions exclusive to CRP16, as well as a small set of instructions omitted from the MIPS instruction set.

## Tentative Specifications

- 16-bit register instructions
- 32-bit immediate and control (branch/jump) instructions
- 16 16-bit general purpose registers
- hi/lo registers for multiplication and division
- gpio pin registers for driving 16 pins
- 64K code section
- 64K data section, with stack growing down and global data/heap growing up

# CRP16

## About

The CRP16 (Carl's RISC Processor 16-bit) is my attempt at creating a RISC architecture processor with Verilog and a DE1-SoC (5CSEMA5F31C6N) board.

## Table of Contents

* [Specifications](#specifications)
* [Instruction Encoding](#instruction-encoding)
* [Milestones](#milestones)

## Specifications
- 16-bit instructions
- 8 16-bit general-purpose registers
- Word addressable memory
- Harvard architecture *
- 4-stage pipeline with data forwarding and early branch resolve for zero pipeline bubbles *

## Instruction Encoding

| Instruction <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| ALU Operation 2 registers <td colspan=3>Rd <td colspan=3>Ra <td colspan=3>Rb <td colspan=1>X <td colspan=1>0 <td colspan=3>ALUOp <td colspan=1>1 <td colspan=1>1 |
| ALU Operation register and immediate <td colspan=3>Rd <td colspan=3>Ra <td colspan=4>4-bit immediate <td colspan=1>1 <td colspan=3>ALUOp <td colspan=1>1 <td colspan=1>1 |
| Call subroutine at address in register <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=3>Ra <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>0 <td colspan=1>1 <td colspan=1>0 <td colspan=1>1 <td colspan=1>0 |
| Call subroutine at address PC + signed offset <td colspan=11>11-bit offset <td colspan=1>1 <td colspan=1>1 <td colspan=1>0 <td colspan=1>1 <td colspan=1>0 |
| Conditional jump to address in register <td colspan=3>Rc <td colspan=3>Ra <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>0 <td colspan=1>C <td colspan=1>1 <td colspan=1>1 <td colspan=1>0 |
| Conditional jump to address PC + signed offset <td colspan=3>Rc <td colspan=8>8-bit offset <td colspan=1>1 <td colspan=1>C <td colspan=1>1 <td colspan=1>1 <td colspan=1>0 |
| Jump to address in register <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=3>Ra <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 <td colspan=1>0 |
| Jump to address PC + signed offset <td colspan=11>11-bit offset <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 <td colspan=1>0 |
| Load immediate to register <td colspan=3>Rd <td colspan=8>8-bit immediate <td colspan=1>S <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 |
| Load immediate to higher byte of register while preserving lower byte <td colspan=3>Rd <td colspan=8>8-bit immediate <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 |
| Load from memory to register <td colspan=3>Rd <td colspan=3>Ra <td colspan=1>X <td colspan=1>X <td colspan=1>S <td colspan=1>W <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 |
| Store from register to memory <td colspan=3>Rd <td colspan=3>Ra <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>W <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 |
  
| Symbol Chart | |
| - | - |
| ALUOp | ALU select bits |
| C | Condition, 0 for zero, 1 for non-zero |
| S | Signed, 0 for unsigned, 1 for signed |
| Ra | Operand A register, address A register |
| Rb | Operand B register |
| Rc | Condition register |
| Rd | Result destination register, data register |
| W | Data size, 0 for byte, 1 for word |

| ALUOp chart | |
| - | - |
| 000 | Add |
| 001 | Subtract |
| 010 | Logical shift right |
| 011 | Arithmetic shift right |
| 100 | Logical shift left |
| 101 | Bitwise AND |
| 110 | Bitwise OR | 
| 111 | Bitwise XOR |


## Milestones

### Dec 30, 2017
  - Implemented 4-stage, non-pipelined datapath
  - Instructions implemented : 
  add, subtract, logical shift right, arithmetic shift right, logical shift left, and, or, xor, call subroutine, conditional jump, unconditional jump, load immediate, load signed immediate, load immediate to high byte

### Dec 31, 2017
  - Implemented load word and store word

# CRP16

## 1. About

The CRP16 (Carl's RISC Processor 16-bit) is my attempt at creating a RISC architecture processor with Verilog and a DE1-SoC (5CSEMA5F31C6N) board.

## 2. Architecture
- 16-bit RISC with 16-bit words and instructions
- 8 general purpose word-sized registers
- Load/store architecture, register and immediate addressing modes 
- Harvard architecture, word-addressable memory

## 3. Microarchitecture
- 3-stage Fetch, Decode, Execute pipeline
- Data forwarding from Execute to Decode
- Early branch resolve at Decode stage with 0 branch penalty
- 1 cycle memory access latency
- Performance of up to 100MIPS at 100MHz

## 4. Registers
| Register | Description |
| - | - |
| r0 | subroutine parameter ; subroutine return value ; caller-saved |
| r1 | subroutine parameter ; caller-saved |
| r2 | callee-saved |
| r3 | callee-saved |
| r4 | callee-saved |
| r5 | callee-saved |
| r6 / sp | stack pointer ; callee-saved |
| r7 / lr | link register ; callee-saved |

## 5. Instruction Set

### 5.1 ALU Operation

Perform an arithmetic or logic operation on two values, and store the result in the destination register.

* #### 5.1.1 ALU operation on two registers
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
|-|
| Encoding <td colspan=3>Rd <td colspan=3>Ra <td colspan=3>Rb <td colspan=1>0 <td colspan=1>0 <td colspan=3>ALUOp <td colspan=1>1 <td colspan=1>1 |
| Assembly Syntax <td colspan=16>`op Rd, Ra, Rb` |
| Action <td colspan=16>Rd := Ra op Rb |
| Description <td colspan=16>Perform op operation on registers Ra and Rb, then store the result in register Rd |

* #### 5.1.2 ALU operation on a register and a 4-bit immediate
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
|-|
| Encoding <td colspan=3>Rd <td colspan=3>Ra <td colspan=4>4-bit immediate <td colspan=1>1 <td colspan=3>ALUOp <td colspan=1>1 <td colspan=1>1 |
| Assembly Syntax <td colspan=16>`op Rd, Ra, 4-bit immediate` |
| Action <td colspan=16>Rd := Ra op 4-bit immediate |
| Description <td colspan=16>Perform op operation on register Ra and 4-bit immediate, then store the result in register Rd |
  
* #### 5.1.3 ALUOp encoding table

| Assembly op | ALUOp encoding | Description |
| - | - | - |
| `add` | 000 | Add |
| `sub` | 001 | Subtract |
| `srl` | 010 | Logical shift right |
| `sra` | 011 | Arithmetic shift right |
| `sll` | 100 | Logical shift left |
| `and` | 101 | Bitwise AND |
| `or` | 110 | Bitwise OR | 
| `xor` | 111 | Bitwise XOR |

* #### 5.1.4 Example usage
  * `add r0, r1, r4` : Add two values stored in registers
  * `sll r0, r1, 4` : Shift value in register by a 4-bit immediate, decimal literal 
  * `sub r4, r5, 0b0110` : Subtract a value in register by a 4-bit immediate, binary literal 
  * `sub r4, r5, 0o11` : Subtract a value in register by a 4-bit immediate, octal literal 
  * `xor r4, r5, 0xf` : Bitwise XOR a value in register by a 4-bit binary immediate, hexadecimal literal

* #### 5.1.5 Additional notes
  * 4-bit immediate for add, subtract, and shift are unsigned
  * 4-bit immediate for bitwise AND, OR, and XOR are sign extended
  * Shift operations ignore the higher 12 bits, only take the lowest significant nibble and treats it as an unsigned number

### 5.2 Call subroutine

Store the address of the next instruction, which is the return address, in the link register, and jump to another address.

* #### 5.2.1 Call subroutine at address in register
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=3>Ra <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 <td colspan=1>0 <td colspan=1>1 <td colspan=1>0 |
| Assembly Syntax <td colspan=16>`call Ra` |
| Action <td colspan=16>lr := pc , pc := Ra |
| Description <td colspan=16>Store return address to lr, then jump to address in Ra |
 
* #### 5.2.2 Call subroutine at address in pc + 11-bit signed offset
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=11>11-bit offset <td colspan=1>1 <td colspan=1>1 <td colspan=1>0 <td colspan=1>1 <td colspan=1>0 |
| Assembly Syntax <td colspan=16>`call label` |
| Action <td colspan=16>lr := pc , pc := pc + label offset |
| Description <td colspan=16>Store return address to lr, then jump to pc + 11-bit offset of label from the current address |

* #### 5.2.3 Example usage
  * `call r0` : Call subroutine at address in register
  * `call subroutine_a` : Call subroutine at label

* #### 5.2.4 Additional notes
  * Label offset is calculated by the assembler and must be within the range of 11-bits signed integer

### 5.3 Compare

Compare two values. If the comparison is true, write 1 to the destination register, 0 otherwise.

* #### 5.3.1 Compare two registers
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=3>Rd <td colspan=3>Ra <td colspan=3>Rb <td colspan=1>X <td colspan=1>0 <td colspan=1>S <td colspan=1>G <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 |
| Assembly Syntax <td colspan=16>`op Rd, Ra, Rb` |
| Action <td colspan=16>Rd := Ra op Rb |
| Description <td colspan=16>Compare registers Ra and Rb, then store the result in register Rd |

* #### 5.3.2 Compare register and 4-bit immediate value
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=3>Rd <td colspan=3>Ra <td colspan=4>4-bit immediate <td colspan=1>1 <td colspan=1>S <td colspan=1>G <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 |
| Assembly Syntax <td colspan=16>`op Rd, Ra, 4-bit immediate` |
| Action <td colspan=16>Rd := Ra op 4-bit immediate |
| Description <td colspan=16>Compare register Ra and 4-bit immediate, then store the result in register Rd |

* #### 5.3.3 Encoding table

| Assembly op | S | G | Description |
| - | - | - | - |
| gt  | 0 | 1 | Unsigned greater than, 4-bit immediate is zero extended |
| gts | 1 | 1 | Signed greater than, 4-bit immediate is sign extended |
| lt  | 0 | 0 | Unsigned less than, 4-bit immediate is zero extended |
| lts | 1 | 0 | Signed less than, 4-bit immediate is sign extended |

* #### 5.3.4 Example usage
  * `lt r0, r1, r4` : Compare two values stored in registers
  * `lts r0, r1, 4` : Compare value in register and a 4-bit immediate, decimal literal 
  * `lts r4, r5, 0b0110` : Compare value in register and a 4-bit immediate, binary literal 
  * `gt r4, r5, 0o11` : Compare value in register and a 4-bit immediate, octal literal 
  * `gts r4, r5, 0xf` : Compare value in register and a 4-bit immediate, hexadecimal literal


## Instruction Encoding

| Instruction <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Conditional jump to address in register <td colspan=3>Rc <td colspan=3>Ra <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>0 <td colspan=1>C <td colspan=1>1 <td colspan=1>1 <td colspan=1>0 |
| Conditional jump to address PC + signed offset <td colspan=3>Rc <td colspan=8>8-bit offset <td colspan=1>1 <td colspan=1>C <td colspan=1>1 <td colspan=1>1 <td colspan=1>0 |
| Jump to address in register <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=3>Ra <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 <td colspan=1>0 |
| Jump to address PC + signed offset <td colspan=11>11-bit offset <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 <td colspan=1>0 |
| Load immediate to register <td colspan=3>Rd <td colspan=8>8-bit immediate <td colspan=1>S <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 |
| Load immediate to higher byte of register while preserving lower byte <td colspan=3>Rd <td colspan=8>8-bit immediate <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 |
| Load from memory to register <td colspan=3>Rd <td colspan=3>Ra <td colspan=1>X <td colspan=1>X <td colspan=1>S <td colspan=1>W <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 |
| Store from register to memory <td colspan=3>Rd <td colspan=3>Ra <td colspan=1>X <td colspan=1>X <td colspan=1>X <td colspan=1>W <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 |
| Terminate execution <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 |
  
| Symbol Chart | |
| - | - |
| ALUOp | ALU select bits |
| C | Branch condition : 0 for zero, 1 for non-zero |
| G | Compare : 0 for less than, 1 for greater than |
| Ra | Operand A register, address register |
| Rb | Operand B register |
| Rc | Condition register |
| Rd | Result destination register, data register |
| S | Signed operation : 0 for unsigned, 1 for signed |
| W | Data size : 0 for byte, 1 for word |
| X | Don't care |

## 6. Milestones

### Dec 30, 2017
  - Implemented 4-stage, non-pipelined datapath
  - Instructions implemented : 
  add, subtract, logical shift right, arithmetic shift right, logical shift left, and, or, xor, call subroutine, conditional jump, unconditional jump, load immediate, load signed immediate, load immediate to high byte

### Dec 31, 2017
  - Implemented load word and store word

### Jan 2, 2018
  - Implemented greater than and less than

### Jan 3, 2018
  - Implemented instruction pipelining
  
### Jan 14, 2018
  - Created an assembler that assembles instructions only using Python 3.6

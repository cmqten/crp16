# ITTIBT32

ITTIBT32 (**I** **T**hought of **T**his **I**SA **B**efore a **T**est,
pronounced "itty-bitty") is a 32-bit RISC ISA with the goal of being:
* Simple : Instructions that do one thing and one thing only
* Compact : 16-bit instruction encoding

## 1. Instruction Set Architecture Details

* 32-bit word size
* 16-bit instruction encoding
* Little endian byte order
* 16 32-bit general-purpose registers

## 2. Registers

| Register | Description |
| - | - |
| r0 | subroutine parameter ; subroutine return value ; caller-saved |
| r1 - r3 | subroutine parameter ; caller-saved |
| r4 - r7 | caller-saved |
| r8 - r13 | callee-saved |
| r14 / sp | stack pointer ; callee-saved |
| r15 / lr | link register ; callee-saved |

## 3. Instruction Set

<!---
# CRP16

## 0. Table of Contents
* [1. About](#1-about)
* [2. Architecture](#2-architecture)
* [3. Microarchitecture](#3-microarchitecture)
* [4. Registers](#4-registers)
* [5. Instruction Set](#5-instruction-set)
  * [5.1 ALU operation](#51-alu-operation)
  * [5.2 Call subroutine](#52-call-subroutine)
  * [5.3 Compare](#53-compare)
  * [5.4 Conditional jump](#54-conditional-jump)
  * [5.5 Jump](#55-jump)
  * [5.6 Load immediate](#56-load-immediate)
  * [5.7 Memory load/store word](#57-memory-loadstore-word)
  * [5.8 No operation](#58-no-operation)
  * [5.9 Terminate execution and lock up processor](#59-terminate-execution-and-lock-up-processor)
* [6. Milestones](#6-milestones)

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

### 5.1 ALU operation

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

| Assembly op | ALUOp | Description |
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
<br/>

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
<br/>

### 5.3 Compare

Compare two values. If the comparison is true, write 1 to the destination register, 0 otherwise.

* #### 5.3.1 Compare two registers
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=3>Rd <td colspan=3>Ra <td colspan=3>Rb <td colspan=1>0 <td colspan=1>0 <td colspan=1>S <td colspan=1>G <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 |
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
| `gt`  | 0 | 1 | Unsigned greater than, 4-bit immediate is zero extended |
| `gts` | 1 | 1 | Signed greater than, 4-bit immediate is sign extended |
| `lt`  | 0 | 0 | Unsigned less than, 4-bit immediate is zero extended |
| `lts` | 1 | 0 | Signed less than, 4-bit immediate is sign extended |

* #### 5.3.4 Example usage
  * `lt r0, r1, r4` : Compare two values stored in registers
  * `lts r0, r1, 4` : Compare value in register and a 4-bit immediate, decimal literal 
  * `lts r4, r5, 0b0110` : Compare value in register and a 4-bit immediate, binary literal 
  * `gt r4, r5, 0o11` : Compare value in register and a 4-bit immediate, octal literal 
  * `gts r4, r5, 0xf` : Compare value in register and a 4-bit immediate, hexadecimal literal
<br/>

### 5.4 Conditional jump

Jump to address if the value of a register meets the specified condition.

* #### 5.4.1 Jump to address in register if condition is zero
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=3>Rc <td colspan=3>Ra <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 <td colspan=1>1 <td colspan=1>0 |
| Assembly Syntax <td colspan=16>`jez Rc, Ra` |
| Action <td colspan=16>pc := Ra if Rc is zero |
| Description <td colspan=16>Jump to address in register Ra if register Rc is zero |
  
* #### 5.4.2 Jump to address in register if condition is not zero
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=3>Rc <td colspan=3>Ra <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 <td colspan=1>1 <td colspan=1>1 <td colspan=1>0 |
| Assembly Syntax <td colspan=16>`jnz Rc, Ra` |
| Action <td colspan=16>pc := Ra if Rc is not zero |
| Description <td colspan=16>Jump to address in register Ra if register Rc is not zero |

* #### 5.4.3 Jump to address in pc + 8-bit signed offset if condition is zero
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=3>Rc <td colspan=8>8-bit offset <td colspan=1>1 <td colspan=1>0 <td colspan=1>1 <td colspan=1>1 <td colspan=1>0 |
| Assembly Syntax <td colspan=16>`jez Rc, label` |
| Action <td colspan=16>pc := pc + label offset if Rc is zero |
| Description <td colspan=16>Jump to pc + 8-bit offset of label from the current address if register Rc is zero |
  
* #### 5.4.4 Jump to address in pc + 8-bit signed offset if condition is not zero
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=3>Rc <td colspan=8>8-bit offset <td colspan=1>1 <td colspan=1>1 <td colspan=1>1 <td colspan=1>1 <td colspan=1>0 |
| Assembly Syntax <td colspan=16>`jnz Rc, label` |
| Action <td colspan=16>pc := pc + label offset if Rc is not zero |
| Description <td colspan=16>Jump to pc + 8-bit offset of label from the current address if register Rc is not zero |

* #### 5.4.5 Example usage
  * `jez r0, lr` : Jump to address in register if condition register is zero
  * `jnz r1, label_a` : Jump to label if condition register is not zero

* #### 5.4.6 Additional notes
  * Label offset is calculated by the assembler and must be within the range of 8-bits signed integer
<br/>

### 5.5 Jump

Jump to address.

* #### 5.5.1 Jump to address in register
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=3>Ra <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 <td colspan=1>0 |
| Assembly Syntax <td colspan=16>`jmp Ra` |
| Action <td colspan=16>pc := Ra |
| Description <td colspan=16>Jump to address in register Ra |
  
* #### 5.5.2 Jump to address in pc + 11-bit signed offset
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=11>11-bit offset <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 <td colspan=1>0 |
| Assembly Syntax <td colspan=16>`jmp label` |
| Action <td colspan=16>pc := pc + label offset |
| Description <td colspan=16>Jump to pc + 11-bit offset of label from the current address |

* #### 5.5.3 Example usage
  * `jmp lr` : Jump to address in register 
  * `jmp label_a` : Jump to label 

* #### 5.5.4 Additional notes
  * Label offset is calculated by the assembler and must be within the range of 11-bits signed integer
<br/>

### 5.6 Load immediate

Load an immediate value to register.

* #### 5.6.1 Load an unsigned 8-bit immediate value 
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=3>Rd <td colspan=8>8-bit immediate <td colspan=1>0 <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 |
| Assembly Syntax <td colspan=16>`ldi Rd, 8-bit immediate` |
| Action <td colspan=16>Rd := 8-bit immediate |
| Description <td colspan=16>Load an 8-bit zero extended immediate value to register |
  
* #### 5.6.2 Load a signed 8-bit immediate value 
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=3>Rd <td colspan=8>8-bit immediate <td colspan=1>1 <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 |
| Assembly Syntax <td colspan=16>`ldsi Rd, 8-bit immediate` |
| Action <td colspan=16>Rd := 8-bit immediate |
| Description <td colspan=16>Load an 8-bit sign extended immediate value to register |

* #### 5.6.3 Load an 8-bit immediate value to the higher byte of a register
| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=3>Rd <td colspan=8>8-bit immediate <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 |
| Assembly Syntax <td colspan=16>`ldhi Rd, 8-bit immediate` |
| Action <td colspan=16>Rd := 8-bit immediate concatenated with Rd[7:0] |
| Description <td colspan=16>Load an 8-bit immediate value to the higher byte of a register while preserving the lower byte |
  
* #### 5.6.4 Example usage
  * `ldi r0, 56` : Load an 8-bit immediate, decimal literal 
  * `ldsi r0, 0b1011` : Load an 8-bit immediate, binary literal 
  * `ldhi r0, 0o77` : Load an 8-bit immediate, 0ctal literal 
  * `ldsi r0, 0xff` : Load an 8-bit immediate, hexadecimal literal  
<br/>

### 5.7 Memory load/store word

Load word from memory or store word to memory.

* #### 5.7.1 Load word from memory

| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=3>Rd <td colspan=3>Ra <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 |
| Assembly Syntax <td colspan=16>`ldw Rd, Ra` |
| Action <td colspan=16>Rd := *Ra |
| Description <td colspan=16>Load data from memory address in register Ra to register Rd |

* #### 5.7.2 Store word to memory

| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=3>Rd <td colspan=3>Ra <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>1 |
| Assembly Syntax <td colspan=16>`stw Rd, Ra` |
| Action <td colspan=16>*Ra := Rd |
| Description <td colspan=16>Store data from register Rd to memory address in register Ra |

* #### 5.7.3 Example usage
  * `ldw r0, r1` : Load word from address in r1 to r0
  * `stw r0, r1` : Store word from r0 to address in r1
<br/>

### 5.8 No operation

| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 |
| Assembly Syntax <td colspan=16>`noop` |
<br/>  

### 5.9 Terminate execution and lock up processor

| <td colspan=1>**15** <td colspan=1>**14** <td colspan=1>**13** <td colspan=1>**12** <td colspan=1>**11** <td colspan=1>**10** <td colspan=1>**9** <td colspan=1>**8** <td colspan=1>**7** <td colspan=1>**6** <td colspan=1>**5** <td colspan=1>**4** <td colspan=1>**3** <td colspan=1>**2** <td colspan=1>**1** <td colspan=1>**0** |
| - |
| Encoding <td colspan=1>1 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 <td colspan=1>0 |
| Assembly Syntax <td colspan=16>`stop` |
<br/>

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
--->

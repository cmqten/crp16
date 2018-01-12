from typing import List
import re

ARGS2_REGEX = re.compile("^\s*(\S+)\s*,\s*(\S+)\s*")
ARGS3_REGEX = re.compile("^\s*(\S+)\s*,\s*(\S+)\s*,\s*(\S+)\s*")
COMMENT_REGEX = re.compile("^\s*(.*);(.*)$")
INSTR_REGEX = re.compile("^\s*(\S+)\s+(.*)$")
LABEL_REGEX = re.compile("^\s*(\S+)\s*:(.*)$")
NOP_STOP_REGEX = re.compile("^\s*(nop|stop)\s*$")

INSTRUCTIONS = {
    "add"  : 0b00011,   
    "and"  : 0b10111, 
    "call" : 0b1010,    # call subroutine
    "gt"   : 0b01100,   # greater than unsigned
    "gts"  : 0b11100,   # greater than signed
    "jez"  : 0b0110,    # jump if zero
    "jmp"  : 0b0010,    # unconditional jump
    "jnz"  : 0b1110,    # jump if not zero
    "ldhi" : 0b10001,   # load 8-bit immediate into high byte, preserve low byte
    "ldi"  : 0b01001,   # load 8-bit immediate unsigned
    "ldsi" : 0b11001,   # load 8-bit immediate signed
    "ldw"  : 0b1000001, # load word from memory    
    "lt"   : 0b00100,   # less than unsigned
    "lts"  : 0b10100,   # less than signed
    "nop"  : 0,         # no operation
    "or"   : 0b11011, 
    "stw"  : 0b1100001, # store word to memory
    "sll"  : 0b10011,   # shift left logically
    "sra"  : 0b01111,   # shift right arithmetically
    "srl"  : 0b01011,   # shift right logically
    "stop" : 0x8000,    # terminate execution and lock up processor
    "sub"  : 0b00111,
    "xor"  : 0b11111
}

REGISTERS = {"r0": 0, "r1": 1, "r2": 2, "r3": 3, "r4": 4, "r5": 5, "r6": 6,
             "r7": 7, "sp": 6, "lr": 7}

INSTR_PARSER = {
    "add"  : lambda x, y: parse_alu_statement(x, y),   
    "and"  : lambda x, y: parse_alu_statement(x, y),
    "call" : None,
    "gt"   : lambda x, y: parse_alu_statement(x, y),
    "gts"  : lambda x, y: parse_alu_statement(x, y),
    "jez"  : None,
    "jmp"  : None,
    "jnz"  : None,
    "ldhi" : lambda x, y: parse_load_imm_statement(x, y),
    "ldi"  : lambda x, y: parse_load_imm_statement(x, y),
    "ldsi" : lambda x, y: parse_load_imm_statement(x, y),
    "ldw"  : None,  
    "lt"   : lambda x, y: parse_alu_statement(x, y),
    "lts"  : lambda x, y: parse_alu_statement(x, y),
    "nop"  : None,
    "or"   : lambda x, y: parse_alu_statement(x, y),
    "stw"  : None,
    "sll"  : lambda x, y: parse_alu_statement(x, y),
    "sra"  : lambda x, y: parse_alu_statement(x, y),
    "srl"  : lambda x, y: parse_alu_statement(x, y),
    "stop" : None,
    "sub"  : lambda x, y: parse_alu_statement(x, y),
    "xor"  : lambda x, y: parse_alu_statement(x, y)
}


def print_int_bin(num: int, n: int) -> None:
    '''
    Prints a number as an n-bit binary string.
    '''
    for i in range(n-1, 0, -1):
        print((num >> i) & 1, end="")
    print(num & 1)


def parse_int_literal(literal_str: str) -> int:
    '''
    Converts the string representation of an integer literal into an integer.
    '''
    try:
        if literal_str.startswith("0b"): return int(literal_str, base=2)

        elif literal_str.startswith("0o"): return int(literal_str, base=8)

        elif literal_str.startswith("0x"): return int(literal_str, base=16)

        else: return int(literal_str)

    except:
        return None

    
def parse_alu_statement(instr: str, args: str) -> int:
    '''
    Parses instructions that use the ALU: add, and, gt, gts, lt, lts, or, sll,
    sra, srl, sub, xor. Returns the integer representation of the machine code
    if the arguments are valid, None otherwise.
    '''
    args_match_result = ARGS3_REGEX.match(args)

    if not args_match_result:
        print("Error: invalid arguments", end="")
        return None

    dest = args_match_result.group(1)
    op_a = args_match_result.group(2)
    op_b = args_match_result.group(3)
    imm = 0  
    opcode = INSTRUCTIONS[instr]

    if dest not in REGISTERS:
        print("Error: first argument must be a valid register", end="")
        return None

    dest = REGISTERS[dest]  # Integer equivalent of the register number

    if op_a not in REGISTERS:
        print("Error: second argument must be a valid register", end="")
        return None

    op_a = REGISTERS[op_a]  # Integer equivalent of the register number

    # If the third argument is a register, it occupies the highest three bits
    # of the four bits reserved for the third argument
    if op_b in REGISTERS: op_b = REGISTERS[op_b] << 1

    # Integer literal third argument
    else:
        imm = 1
        op_b = parse_int_literal(op_b)

        if op_b is None:
            print("Error: third argument must be a register", end="")
            print(" or an integer literal", end="")
            return None

        op_b &= 15 # Only 4 bits of immediate

    return opcode | imm << 5 | dest << 13 | op_a << 10 | op_b << 6


def parse_load_imm_statement(instr: str, args: str) -> int:
    '''
    Parses ldi, ldsi, ldhi instructions.
    '''
    args_match_result = ARGS2_REGEX.match(args)

    if not args_match_result:
        print("Error: invalid arguments", end="")
        return None

    opcode = INSTRUCTIONS[instr]
    dest = args_match_result.group(1)
    immop = args_match_result.group(2)
    
    if dest not in REGISTERS:
        print("Error: first argument must be a valid register", end="")
        return None

    dest = REGISTERS[dest]  # Integer equivalent of the register number

    # Second argument is an integer literal
    immop = parse_int_literal(immop)

    if immop is None:
        print("Error: second argument must be an integer literal", end="")
        return None

    immop &= 255 # Only 8 bits of immediate

    return opcode | immop << 5 | dest << 13


def get_label(line: str) -> List[str]:
    '''
    Separates the label from statement, if there is one, and returns a list
    that contains both. If there is an error, this function returns None.
    '''
    match_result = LABEL_REGEX.match(line)

    if not match_result:
        return [None, line.strip()]

    label = match_result.group(1)

    if label in INSTRUCTIONS:
        print("Error: cannot use reserved keyword \'{}\' as label".format(label),
              end="")
        return None

    return [label, match_result.group(2).strip()]


def parse_statement(statement: str) -> int:
    '''
    Parses a statement and returns the integer representation of the machine
    code encoding if the statement is valid, None otherwise.
    '''
    instr_match_result = INSTR_REGEX.match(statement)
    nop_stop_match_result = NOP_STOP_REGEX.match(statement)

    if nop_stop_match_result:
        return INSTRUCTIONS[nop_stop_match_result.group(1)]

    elif instr_match_result:
        instr = instr_match_result.group(1)
        args = instr_match_result.group(2)
        
        if instr in INSTRUCTIONS:
            return INSTR_PARSER[instr_match_result.group(1)](instr, args)
        
        print("Error: invalid instruction \'{}\'".format(
            instr_match_result.group(1)), end="")
        return None

    print("Error: malformed statement", end="")
    return None


def remove_comment(line: str) -> str:
    '''
    Removes the comment from a line and returns the code part.
    '''
    match_result = COMMENT_REGEX.match(line)
    
    return match_result.group(1).strip() if match_result else line.strip()




        

    
    

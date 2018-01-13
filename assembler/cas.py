from typing import List, TextIO
import re, sys

ARGS2_REGEX = re.compile("^\s*([a-zA-Z0-9_-]+)\s*,\s*([a-zA-Z0-9_-]+)\s*$")
ARGS3_REGEX = re.compile(
    "^\s*([a-zA-Z0-9_-]+)\s*,\s*([a-zA-Z0-9_-]+)\s*,\s*([a-zA-Z0-9_-]+)\s*$")
COMMENT_REGEX = re.compile("^\s*(.*);(.*)$")
INSTR_REGEX = re.compile("^\s*([a-zA-Z0-9_-]+)\s+(.*)$")
LABEL_REGEX = re.compile("^\s*([a-zA-Z0-9_-]+)\s*:(.*)$")
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
    "add"  : lambda x, y, z: parse_alu_statement(x, y, z),   
    "and"  : lambda x, y, z: parse_alu_statement(x, y, z),
    "call" : lambda x, y, z: parse_unconditional_jump_statement(x, y, z),
    "gt"   : lambda x, y, z: parse_alu_statement(x, y, z),
    "gts"  : lambda x, y, z: parse_alu_statement(x, y, z),
    "jez"  : lambda x, y, z: parse_conditional_jump_statement(x, y, z),
    "jmp"  : lambda x, y, z: parse_unconditional_jump_statement(x, y, z),
    "jnz"  : lambda x, y, z: parse_conditional_jump_statement(x, y, z),
    "ldhi" : lambda x, y, z: parse_load_imm_statement(x, y, z),
    "ldi"  : lambda x, y, z: parse_load_imm_statement(x, y, z),
    "ldsi" : lambda x, y, z: parse_load_imm_statement(x, y, z),
    "ldw"  : lambda x, y, z: parse_load_store_statement(x, y, z),  
    "lt"   : lambda x, y, z: parse_alu_statement(x, y, z),
    "lts"  : lambda x, y, z: parse_alu_statement(x, y, z),
    "nop"  : None,
    "or"   : lambda x, y, z: parse_alu_statement(x, y, z),
    "stw"  : lambda x, y, z: parse_load_store_statement(x, y, z),
    "sll"  : lambda x, y, z: parse_alu_statement(x, y, z),
    "sra"  : lambda x, y, z: parse_alu_statement(x, y, z),
    "srl"  : lambda x, y, z: parse_alu_statement(x, y, z),
    "stop" : None,
    "sub"  : lambda x, y, z: parse_alu_statement(x, y, z),
    "xor"  : lambda x, y, z: parse_alu_statement(x, y, z)
}

LABELS = {}


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

    
def parse_alu_statement(instr: str, args: str, pc: int) -> int:
    '''
    Parses instructions that use the ALU: add, and, gt, gts, lt, lts, or, sll,
    sra, srl, sub, xor. Returns the integer representation of the machine code
    if the statement is valid, None otherwise.
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
        print("Error: first argument must be a register", end="")
        return None

    if op_a not in REGISTERS:
        print("Error: second argument must be a register", end="")
        return None

    # Integer representation of the register numbers
    dest = REGISTERS[dest]  
    op_a = REGISTERS[op_a]  

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


def parse_load_imm_statement(instr: str, args: str, pc: int) -> int:
    '''
    Parses ldi, ldsi, ldhi and returns the integer representation of the machine
    code if the statement is valid, None otherwise.
    '''
    args_match_result = ARGS2_REGEX.match(args)

    if not args_match_result:
        print("Error: invalid arguments", end="")
        return None

    opcode = INSTRUCTIONS[instr]
    dest = args_match_result.group(1)
    immop = args_match_result.group(2)
    
    if dest not in REGISTERS:
        print("Error: first argument must be a register", end="")
        return None

    dest = REGISTERS[dest]  # Integer representation of the register number

    # Second argument is an integer literal
    immop = parse_int_literal(immop)

    if immop is None:
        print("Error: second argument must be an integer literal", end="")
        return None

    immop &= 255 # Only 8 bits of immediate

    return opcode | immop << 5 | dest << 13


def parse_load_store_statement(instr: str, args: str, pc: int) -> int:
    '''
    Parses ldw and stw, and returns the integer representation of the machine
    code if the statement is valid, None otherwise.
    '''
    args_match_result = ARGS2_REGEX.match(args)

    if not args_match_result:
        print("Error: invalid arguments", end="")
        return None

    opcode = INSTRUCTIONS[instr]
    data = args_match_result.group(1)
    address = args_match_result.group(2)

    if data not in REGISTERS:
        print("Error: first argument must be a register", end="")
        return None

    if address not in REGISTERS:
        print("Error: second argument must be a register", end="")
        return None

    data = REGISTERS[data]
    address = REGISTERS[address]

    return opcode | data << 13 | address << 10


def parse_unconditional_jump_statement(instr: str, args: str, pc: int) -> int:
    '''
    Parses call and jmp, and returns the integer representation of the machine
    code if the statement is valid, None otherwise.
    '''
    opcode = INSTRUCTIONS[instr]
    imm = 0
    offset = 0

    if args in REGISTERS:
        return opcode | imm << 4 | REGISTERS[args] << 10

    # Jumping to a label or specifying an offset uses the jump/call immediate
    # instruction
    imm = 1

    if args in LABELS: # Jumping to label
        offset = LABELS[args] - (pc + 1)

    else: # Immediate offset
        offset = parse_int_literal(args)

        if offset is None:
            print("Error: argument must be a register, a label,", end="")
            print(" or an integer literal", end="")
            return None

        # When branching, pc + 1 is the address being added to the offset instead
        # of pc. Subtracting -1 from the offset gives the programmer the illusion
        # that pc is being added to the offset, to make it more intuitive.
        offset -= 1

    if offset > 1023 or offset < -1024: # 11-bit offset range
        print("Error: call/jump out of range", end="")
        return None

    return opcode | imm << 4 | offset << 5


def parse_conditional_jump_statement(instr: str, args: str, pc: int) -> int:
    '''
    Parses jez and jnz, and returns the integer representation of the machine
    code if the statement is valid, None otherwise.
    '''
    args_match_result = ARGS2_REGEX.match(args)

    if not args_match_result:
        print("Error: invalid arguments", end="")
        return None

    opcode = INSTRUCTIONS[instr]
    imm = 0
    cond = args_match_result.group(1)
    offset = args_match_result.group(2)

    if cond not in REGISTERS:
        print("Error: first argument must be a register", end="")
        return None

    cond = REGISTERS[cond]

    if offset in REGISTERS:
        return opcode | cond << 13 | REGISTERS[offset] << 10 | imm << 4

    imm = 1 # Jumping to label or offset uses immediate

    if offset in LABELS: # Jumping to label
        offset = LABELS[offset] - (pc + 1)

    else: # Immediate offset
        offset = parse_int_literal(offset)

        if offset is None:
            print("Error: second argument must be a register, a label,", end="")
            print(" or an integer literal", end="")
            return None

        # When branching, pc + 1 is the address being added to the offset instead
        # of pc. Subtracting -1 from the offset gives the programmer the illusion
        # that pc is being added to the offset, to make it more intuitive.
        offset -= 1

    if offset > 127 or offset < -128: # 8-bit offset range
        print("Error: jump out of range", end="")
        return None

    return opcode | imm << 4 | (offset & 255) << 5 | cond << 13
    

def get_label(line: str) -> List[str]:
    '''
    Separates the label from statement, if there is one, and returns a list
    that contains both. If there is an error, this function returns None.
    '''
    match_result = LABEL_REGEX.match(line)

    if not match_result:
        return [None, line.strip()]

    label = match_result.group(1)

    if label in INSTRUCTIONS or label in REGISTERS:
        print("Error: cannot use reserved keyword \'{}\' as label".format(label),
              end="")
        return None

    return [label, match_result.group(2).strip()]


def parse_statement(statement: str, pc: int) -> int:
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
            return INSTR_PARSER[instr_match_result.group(1)](instr, args, pc)
        
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


def collect_all_labels(file: TextIO) -> List[str]:
    '''
    First pass collects all the labels and puts all the statements into a list
    for the second pass. Returns this list if successful, None otherwise.
    '''
    line_num = 0
    pc = 0
    statements = []

    for line in file:
        line_num += 1

        no_comment = remove_comment(line)
        
        if not no_comment: continue # Line is just a comment

        label_statement = get_label(no_comment)

        if label_statement is None:
            # Prints out the line where the error occurs
            print(" at line {}".format(line_num))
            print("    {}".format(line))
            return None

        if label_statement[0] is not None:
            if label_statement[0] in LABELS:
                print("Error: duplicate label at line {}".format(line_num))
                print("    {}".format(line))
                return None

            LABELS[label_statement[0]] = pc

        if label_statement[1]:
            # PC is only incremented for every instruction statement
            pc += 1

            statements.append([label_statement[1], line, line_num])

    return statements
            

def assemble(statements: List[str]) -> List[int]:
    '''
    Converts all assembly statements gathered from the file into a list of
    machine code. Returns the list if successful, None otherwise.
    '''
    machine_code_lst = []
    pc = 0
    
    for statement in statements:
        machine_code = parse_statement(statement[0], pc)

        if machine_code is None:
            # Prints out the line where the error occurs
            print(" at line {}".format(statement[2]))
            print("    {}".format(statement[1]))
            return None

        machine_code_lst.append(machine_code & 65535)

        pc += 1

    return machine_code_lst


if __name__ == "__main__":
    file = open("test4.s")
    statements_lst = collect_all_labels(file)
    if statements_lst is None: sys.exit(1)

    machine_code_lst = assemble(statements_lst)
    if machine_code_lst is None: sys.exit(1)

    for machine_code in machine_code_lst:
        print_int_bin(machine_code, 16)

    


        
    


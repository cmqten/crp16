#!/bin/python3

from typing import List, TextIO, Tuple
import os, re, sys


class ParseException(Exception):
    pass


class SourceLine:
    '''
    A class that represent a single line in the source file
    '''
    def __init__(self, line: str, num: int):
        self.line = line
        self.num = num

    def __str__(self):
        return self.num + ":    " + self.line


class ASMStatement:
    '''
    A class that represents a single assembly statement
    '''
    def __init__(self, statement: str, source_line: SourceLine, pc: int = None):
        self.statement = statement
        self.source_line = source_line
        self.pc = pc

    def __str__(self):
        return (str(self.pc) if self.pc is not None else "x") + ":    " + \
               self.statement
               

ASMSRC_REGEX = re.compile("([a-zA-Z0-9_\-\.]+)\.s$")
ARGS2_REGEX = re.compile("^\s*([a-zA-Z0-9_\-]+)\s*,\s*([a-zA-Z0-9_\-]+)\s*$")
ARGS3_REGEX = re.compile(
    "^\s*([a-zA-Z0-9_\-]+)\s*,\s*([a-zA-Z0-9_\-]+)\s*,\s*([a-zA-Z0-9_\-]+)\s*$")
COMMENT_REGEX = re.compile("^(.*);(.*)$")
INSTR_REGEX = re.compile("^\s*([a-zA-Z0-9_\-]+)\s+(.*)$")
LABEL_REGEX = re.compile("^\s*([a-zA-Z0-9_\-]+)\s*:(.*)$")
NOP_STOP_REGEX = re.compile("^\s*(noop|stop)\s*$")


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
    "noop" : 0,         # no operation
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
    "add"  : lambda x, y, z: parse_alu_statement(x, y),   
    "and"  : lambda x, y, z: parse_alu_statement(x, y),
    "call" : lambda x, y, z: parse_unconditional_jump_statement(x, y, z),
    "gt"   : lambda x, y, z: parse_alu_statement(x, y),
    "gts"  : lambda x, y, z: parse_alu_statement(x, y),
    "jez"  : lambda x, y, z: parse_conditional_jump_statement(x, y, z),
    "jmp"  : lambda x, y, z: parse_unconditional_jump_statement(x, y, z),
    "jnz"  : lambda x, y, z: parse_conditional_jump_statement(x, y, z),
    "ldhi" : lambda x, y, z: parse_load_imm_statement(x, y),
    "ldi"  : lambda x, y, z: parse_load_imm_statement(x, y),
    "ldsi" : lambda x, y, z: parse_load_imm_statement(x, y),
    "ldw"  : lambda x, y, z: parse_load_store_statement(x, y),  
    "lt"   : lambda x, y, z: parse_alu_statement(x, y),
    "lts"  : lambda x, y, z: parse_alu_statement(x, y),
    "noop" : lambda x, y, z: INSTRUCTIONS["noop"],
    "or"   : lambda x, y, z: parse_alu_statement(x, y),
    "stw"  : lambda x, y, z: parse_load_store_statement(x, y),
    "sll"  : lambda x, y, z: parse_alu_statement(x, y),
    "sra"  : lambda x, y, z: parse_alu_statement(x, y),
    "srl"  : lambda x, y, z: parse_alu_statement(x, y),
    "stop" : lambda x, y, z: INSTRUCTIONS["stop"],
    "sub"  : lambda x, y, z: parse_alu_statement(x, y),
    "xor"  : lambda x, y, z: parse_alu_statement(x, y)
}


LABELS = {}


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


def int_bin(num: int, n: int) -> str:
    '''
    Returns a number as an n-bit binary string.
    '''
    bin_rep = ""
    for i in range(n-1, -1, -1):
        bin_rep += str((num >> i) & 1)
    return bin_rep


def int_hex(num: int, n: int) -> str:
    '''
    Returns a number as an n-digit hex string.
    '''
    hex_dict = {10: "a", 11: "b", 12: "c", 13: "d", 14: "e", 15: "f"}
    shift = 4 * (n - 1)
    hex_rep = ""
    
    for i in range(n):
        hex_num = (num >> shift) & 15
        hex_num = str(hex_num) if hex_num < 10 else hex_dict[hex_num]
        hex_rep += hex_num
        shift -= 4

    return hex_rep

    
def parse_alu_statement(instr: str, args: str) -> int:
    '''
    Parses instructions that use the ALU: add, and, gt, gts, lt, lts, or, sll,
    sra, srl, sub, xor. Returns the integer representation of the machine code of
    the statement.
    '''
    args_match_result = ARGS3_REGEX.match(args)

    if not args_match_result:
        raise ParseException("invalid arguments", end="")

    dest = args_match_result.group(1)
    op_a = args_match_result.group(2)
    op_b = args_match_result.group(3) 
    opcode = INSTRUCTIONS[instr]

    if dest not in REGISTERS:
        raise ParseException("first argument must be a register")

    if op_a not in REGISTERS:
        raise ParseException("second argument must be a register")

    # Integer representation of the register numbers
    dest = REGISTERS[dest]  
    op_a = REGISTERS[op_a]  

    if op_b in REGISTERS: # Register third argument
        return opcode | dest << 13 | op_a << 10 | REGISTERS[op_b] << 7

    op_b = parse_int_literal(op_b) # Integer literal third argument

    if op_b is None:
        raise ParseException(
            "third argument must be a register or an integer literal")

    # 1 << 5 is for specifying that the third argument is an immediate
    # & 15 masks 4 bits of the immediate
    # & 65535 masks the lowest 16 bits of the instruction
    return (opcode | 1 << 5 | dest << 13 | op_a << 10 | (op_b & 15) << 6) & 65535


def parse_load_imm_statement(instr: str, args: str) -> int:
    '''
    Parses ldi, ldsi, ldhi and returns the integer representation of the machine
    code of the statement.
    '''
    args_match_result = ARGS2_REGEX.match(args)

    if not args_match_result:
        raise ParseException("invalid arguments")

    opcode = INSTRUCTIONS[instr]
    dest = args_match_result.group(1)
    immop = args_match_result.group(2)
    
    if dest not in REGISTERS:
        raise ParseException("first argument must be a register")

    dest = REGISTERS[dest]
    immop = parse_int_literal(immop)

    if immop is None:
        raise ParseException("second argument must be an integer literal")

    # & 255 only 8 bits of immediate
    # & 65535 masks the lowest 16 bits of the instruction
    return (opcode | (immop & 255) << 5 | dest << 13) & 65535


def parse_load_store_statement(instr: str, args: str) -> int:
    '''
    Parses ldw and stw, and returns the integer representation of the machine
    code of the statement.
    '''
    args_match_result = ARGS2_REGEX.match(args)

    if not args_match_result:
        raise ParseException("invalid arguments")

    opcode = INSTRUCTIONS[instr]
    data = args_match_result.group(1)
    address = args_match_result.group(2)

    if data not in REGISTERS:
        raise ParseException("first argument must be a register")

    if address not in REGISTERS:
        raise ParseException("second argument must be a register")

    data = REGISTERS[data]
    address = REGISTERS[address]

    # & 65535 masks the lowest 16 bits
    return (opcode | data << 13 | address << 10) & 65535


def parse_conditional_jump_statement(instr: str, args: str, pc: int) -> int:
    '''
    Parses jez and jnz, and returns the integer representation of the machine
    code of the statement.
    '''
    args_match_result = ARGS2_REGEX.match(args)

    if not args_match_result:
        raise ParseException("invalid arguments")

    opcode = INSTRUCTIONS[instr]
    cond = args_match_result.group(1)
    offset = args_match_result.group(2)

    if cond not in REGISTERS:
        raise ParseException("first argument must be a register")

    if offset in REGISTERS:
        return opcode | cond << 13 | REGISTERS[offset] << 10 

    if offset not in LABELS: 
        raise ParseException("second argument must be a register or a label")

    cond = REGISTERS[cond]
    offset = LABELS[offset] - (pc + 1)

    if offset > 127 or offset < -128: # 8-bit offset range
        raise ParseException("jump out of range")

    # 1 << 4 specifies that an offset is used instead of a register
    # & 65535 masks the lowest 16 bits
    return (opcode | 1 << 4 | (offset & 255) << 5 | cond << 13) & 65535


def parse_unconditional_jump_statement(instr: str, args: str, pc: int) -> int:
    '''
    Parses call and jmp, and returns the integer representation of the machine
    code of the statement.
    '''
    opcode = INSTRUCTIONS[instr]
    offset = 0

    if args in REGISTERS:
        return opcode | REGISTERS[args] << 10

    if args not in LABELS: 
        raise ParseException("argument must be a register or a label")

    offset = LABELS[args] - (pc + 1)

    if offset > 1023 or offset < -1024: # 11-bit offset range
        raise ParseException("call/jump out of range")
    
    # 1 << 4 specifies that an offset is used instead of a register
    # & 65535 masks the lowest 16 bits
    return (opcode | 1 << 4 | offset << 5) & 65535
    

def get_label(line: str) -> Tuple[str]:
    '''
    Separates the label from statement, if there is one, and returns a tuple
    that contains both.
    '''
    match_result = LABEL_REGEX.match(line)

    if not match_result:
        return None, line.strip()

    label = match_result.group(1)

    if label in INSTRUCTIONS or label in REGISTERS:
        raise ParseException(
            "cannot use reserved keyword \'{}\' as label".format(label))

    return label, match_result.group(2).strip()


def parse_statement(statement: str, pc: int) -> int:
    '''
    Parses a statement and returns the integer representation of the machine
    code of the statement.
    '''
    instr_match_result = INSTR_REGEX.match(statement)
    noop_stop_match_result = NOP_STOP_REGEX.match(statement)

    if noop_stop_match_result:
        return INSTRUCTIONS[noop_stop_match_result.group(1)]

    elif instr_match_result:
        instr = instr_match_result.group(1)
        args = instr_match_result.group(2)
        
        if instr in INSTRUCTIONS:
            return INSTR_PARSER[instr_match_result.group(1)](instr, args, pc)
        
        raise ParseException("invalid instruction \'{}\'".format(
            instr_match_result.group(1)))
    
    raise ParseException("malformed statement")


def remove_comment(line: str) -> str:
    '''
    Removes the comment from a line and returns the code part.
    '''
    match_result = COMMENT_REGEX.match(line)
    
    return match_result.group(1).strip() if match_result else line.strip()


def collect_lines(file: TextIO) -> List[SourceLine]:
    '''
    Puts every line that's not a comment or whitespace in the file into a
    SourceLine instance, and returns a list of all SourceLine instances from the
    file.
    '''
    line_num = 0
    source_lines_lst = []

    for line in file:
        line_num += 1
        line_strip = line.strip()
        if not line_strip or line_strip.startswith(";"):
            continue
        source_lines_lst.append(SourceLine(line, line_num))

    return source_lines_lst


def remove_all_comments(lines: List[SourceLine]) -> List[ASMStatement]:
    '''
    Creates a list of ASMStatement in which every trailing comment is
    removed, and only the assembly statement is left.
    '''
    statements_lst = []
    pc = 0

    for line in lines:
        statements_lst.append(ASMStatement(remove_comment(line.line), line))

    return statements_lst


def collect_labels(statements: List[ASMStatement]) -> List[ASMStatement]:
    '''
    Apply an address to every ASMStatement, collect and remove labels, then
    return a list of ASMStatement without the labels.
    '''
    new_statements = []
    pc = 0

    for statement in statements:
        try:
            label, instr_statement = get_label(statement.statement)

            if label is not None:
                if label in LABELS:
                    raise ParseException("duplicate labels")
                
                LABELS[label] = pc

            # The only other case is if the label is by itself, do not add it to
            # the list of ASMStatement and do not increment pc
            if instr_statement:
                statement.statement = instr_statement
                statement.pc = pc
                new_statements.append(statement)
                pc += 1
            
        except ParseException as p:
            print("Error at line {}: {}".format(statement.source_line.num,
                                                str(p)))
            print("    {}".format(statement.source_line.line))
            sys.exit(1)

    return new_statements


def parse_all_statements(statements: List[ASMStatement]) -> List[int]:
    '''
    Parses all instruction statements and returns a list of integer
    representations of the machine code.
    '''
    machine_code = []

    for statement in statements:
        try:
            machine_code.append(parse_statement(statement.statement,
                                                statement.pc))
            
        except ParseException as p:
            print("Error at line {}: {}".format(statement.source_line.num,
                                                str(p)))
            print("    {}".format(statement.source_line.line))
            sys.exit(1)

    return machine_code


def to_mif_hex(machine_code: List[int], out_fname: str) -> None:
    '''
    Creates an Altera .mif file from the machine code for use with Quartus.
    Data radix is hexadecimal.
    '''
    pow2_lst = [0, 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048,
                4096, 8192, 16384, 32768]

    machine_code_len = len(machine_code)
    mem_size_words = 0
    pc = 0

    if machine_code_len > 32768:
        print("Error: program too large ({} instructions, max allowed is {})".
              format(machine_code_len, 32768))
        sys.exit(1)

    for i in pow2_lst:
        if machine_code_len <= i:
            mem_size_words = i * 2 # Give space for data by doubling memory size
            break
    
    with open(out_fname, "w") as out_fname:
        out_fname.write("DEPTH = {};\n".format(mem_size_words))
        out_fname.write("WIDTH = 16;\n")
        out_fname.write("ADDRESS_RADIX = HEX;\n")
        out_fname.write("DATA_RADIX = HEX;\n")
        out_fname.write("CONTENT\n")
        out_fname.write("BEGIN\n")
        out_fname.write("\n")

        while pc < machine_code_len:
            out_fname.write("{} : {};\n".format(int_hex(pc, 4),
                                                int_hex(machine_code[pc], 4)))
            pc += 1

        while pc < mem_size_words:
            out_fname.write("{} : 0000;\n".format(int_hex(pc, 4)))
            pc += 1

        out_fname.write("\n")
        out_fname.write("END;\n")


def main(argc, argv) -> None:
    if len(argv) != 2:
        print("Usage: cas.py SOURCE")
        sys.exit(1)
        
    # Creates an output file with the same name as the input file, but with a
    # .mif file extension
    asm_file_match = ASMSRC_REGEX.match(os.path.basename(os.path.realpath(
        argv[1])))
    
    if not asm_file_match:
        print("Error: file name must only contain {}".format(
            "alphanumeric characters, underscores, dashes, and periods"))
        sys.exit(1)

    out_fname = asm_file_match.group(1) + ".mif"

    with open(argv[1]) as file:
        lst = parse_all_statements(collect_labels(remove_all_comments(
            collect_lines(file))))
        to_mif_hex(lst, out_fname)
        

if __name__ == "__main__":
    main(len(sys.argv), sys.argv)

#!/usr/bin/env python3
import sys
import re

# ALU operations mapping.
ALU_OPS = {
    "ADD": 0x0,    # IN_A + IN_B
    "SUB": 0x1,    # IN_A - IN_B
    "MUL": 0x2,    # IN_A * IN_B
    "SHL": 0x3,    # IN_A << 1
    "SHR": 0x4,    # IN_A >> 1
    "INC_A": 0x5,  # IN_A + 1
    "AND": 0x6,  # and
    "DEC_A": 0x7,  # IN_A - 1
    "OR": 0x8,  # OR
    "EQ": 0x9,     # (IN_A == IN_B) ? 1 : 0
    "GT": 0xA,     # (IN_A > IN_B) ? 1 : 0
    "LT": 0xB      # (IN_A < IN_B) ? 1 : 0
}

# Branch condition codes.
BRANCH_CONDITIONS = {
    "beq": 0x9,
    "blt": 0xB,
    "bgt": 0xA,
}

# Instruction set definition.
INSTRUCTIONS = {
    "mova":   {"opcode": 0x00, "size": 2, "type": "addr"},    # MOVa addr
    "movb":   {"opcode": 0x01, "size": 2, "type": "addr"},    # MOVb addr
    "sba":    {"opcode": 0x02, "size": 2, "type": "addr"},    # sbA addr
    "sbb":    {"opcode": 0x03, "size": 2, "type": "addr"},    # sbB addr
    "opa":    {"opcode_fixed": 0x4, "size": 1, "type": "alu"},  # OpA <ALU_op>
    "opb":    {"opcode_fixed": 0x5, "size": 1, "type": "alu"},  # OpB <ALU_op>
    "opaddr": {"opcode_fixed": 0xF, "size": 2, "type": "alu_mem"},  # Op Addr <ALU_op> <addr>
    "beq":    {"size": 2, "type": "branch"},                 # Branch if equal
    "blt":    {"size": 2, "type": "branch"},                 # Branch if less than
    "bgt":    {"size": 2, "type": "branch"},                 # Branch if greater than
    "jal":    {"opcode": 0x07, "size": 2, "type": "addr"},     # JAL addr
    "nop":    {"opcode": 0x08, "size": 1, "type": "none"},     # NOP
    "halt":   {"opcode": 0x0D, "size": 1, "type": "none"},     # Halt
    "call":   {"opcode": 0x09, "size": 2, "type": "addr"},     # Call addr
    "ret":    {"opcode": 0x0A, "size": 1, "type": "none"},     # Ret
    "lba":    {"opcode": 0x0B, "size": 1, "type": "none"},     # lbA
    "lbb":    {"opcode": 0x0C, "size": 1, "type": "none"},     # lbB
}

def remove_comments(line):
    # Remove comments using ';', '//' or '@' as delimiters.
    return re.split(r';|//|@', line)[0]

def normalize_label(token):
    """
    Given a token that is meant to be a label (either definition or reference),
    remove any leading '#' and the trailing ':' if present.
    """
    token = token.strip()
    if token.startswith("#"):
        token = token[1:]
    if token.endswith(":"):
        token = token[:-1]
    return token.lower()

def first_pass(lines, base):
    """
    Process lines of assembly code (excluding the interrupt section) to collect labels and instruction addresses.
    Returns a tuple (labels, processed_lines) where processed_lines is a list of tuples:
    (line_no, tokens, original_line, address).
    """
    labels = {}
    processed_lines = []
    addr = base
    for line_no, line in enumerate(lines, start=1):
        line = remove_comments(line).strip()
        if not line:
            continue
        tokens = line.split()
        # Skip the "irs:" marker if it appears.
        if tokens and tokens[0].lower() == "irs:":
            continue
        # Process any label definitions.
        while tokens and (tokens[0].endswith(":") or tokens[0].startswith("#") and tokens[0].endswith(":")):
            label = normalize_label(tokens[0])
            if label == "irs":  # Reserve "irs" as a special marker.
                tokens.pop(0)
                continue
            if label in labels:
                print(f"[Error] Label '{label}' redefined at line {line_no}")
            labels[label] = addr
            print(f"[Info] label:'{label}', addr '{addr}'")
            tokens = tokens[1:]
        if not tokens:
            continue
        mnemonic = tokens[0].lower()
        if mnemonic not in INSTRUCTIONS:
            print(f"Error: Unknown instruction '{mnemonic}' at line {line_no}")
            continue
        size = INSTRUCTIONS[mnemonic]["size"]
        processed_lines.append((line_no, tokens, line, addr))
        addr += size
    return labels, processed_lines

def assemble_line(tokens, labels):
    """
    Assemble a single instruction (list of tokens) into machine code bytes.
    Supports label references prefixed with '#' (which are normalized).
    """
    mnemonic = tokens[0].lower()
    spec = INSTRUCTIONS[mnemonic]
    machine_bytes = []
    # Helper function to parse an operand token.
    def parse_operand(token):
        # Remove leading '#' if present.
        if token.startswith("#"):
            token = token[1:]
        try:
            return int(token, 0)
        except ValueError:
            if token.lower() in labels:
                return labels[token.lower()]
            else:
                raise Exception(f"Undefined label: {token}")
    if spec["type"] == "addr":
        if len(tokens) != 2:
            raise Exception(f"Instruction '{mnemonic}' expects 1 operand.")
        operand = parse_operand(tokens[1])
        if not (0 <= operand <= 0xFF):
            raise Exception(f"Operand out of range (0-255): {operand}")
        machine_bytes.append(spec["opcode"])
        machine_bytes.append(operand)
    elif spec["type"] == "none":
        if len(tokens) != 1:
            raise Exception(f"Instruction '{mnemonic}' expects no operands.")
        machine_bytes.append(spec["opcode"])
    elif spec["type"] == "alu":
        if len(tokens) != 2:
            raise Exception(f"Instruction '{mnemonic}' expects 1 operand (ALU operation).")
        alu_token = tokens[1].upper()
        if alu_token in ALU_OPS:
            alu_code = ALU_OPS[alu_token]
        else:
            try:
                alu_code = int(alu_token, 0)
            except ValueError:
                raise Exception(f"Invalid ALU operation: {tokens[1]}")
        if not (0 <= alu_code <= 0xF):
            raise Exception("ALU operation code out of range (0-15).")
        fixed = spec["opcode_fixed"]
        machine_bytes.append((alu_code << 4) | fixed)
    elif spec["type"] == "alu_mem":
        if len(tokens) != 3:
            raise Exception(f"Instruction '{mnemonic}' expects 2 operands (ALU op and address).")
        alu_token = tokens[1].upper()
        if alu_token in ALU_OPS:
            alu_code = ALU_OPS[alu_token]
        else:
            try:
                alu_code = int(alu_token, 0)
            except ValueError:
                raise Exception(f"Invalid ALU operation: {tokens[1]}")
        if not (0 <= alu_code <= 0xF):
            raise Exception("ALU operation code out of range (0-15).")
        operand = parse_operand(tokens[2])
        if not (0 <= operand <= 0xFF):
            raise Exception(f"Operand out of range (0-255): {operand}")
        fixed = spec["opcode_fixed"]
        machine_bytes.append((alu_code << 4) | fixed)
        machine_bytes.append(operand)
    elif spec["type"] == "branch":
        if len(tokens) != 2:
            raise Exception(f"Instruction '{mnemonic}' expects 1 operand (branch target).")
        operand = parse_operand(tokens[1])
        if not (0 <= operand <= 0xFF):
            raise Exception(f"Operand out of range (0-255): {operand}")
        if mnemonic not in BRANCH_CONDITIONS:
            raise Exception(f"Unknown branch instruction: {mnemonic}")
        cond = BRANCH_CONDITIONS[mnemonic]
        machine_bytes.append((cond << 4) | 0x6)
        machine_bytes.append(operand)
    else:
        raise Exception(f"Unhandled instruction type: {spec['type']}")
    return machine_bytes

def compile_asm(asm_lines, base=0):
    """
    Compile a list of assembly code lines into machine code bytes.
    """
    asm_code = "\n".join(asm_lines)
    lines = asm_code.splitlines()
    labels, processed_lines = first_pass(lines, base)
    machine_code = []
    for line_no, tokens, original_line, addr in processed_lines:
        try:
            code_bytes = assemble_line(tokens, labels)
            machine_code.extend(code_bytes)
        except Exception as e:
            raise Exception(f"Error at line {line_no} ('{original_line}'): {e}")
    return machine_code

def generate_coe(main_code, interrupt_code):
    """
    Generate COE file content with exactly 256 bytes.
    Main code occupies addresses 0-191; ISR code occupies addresses 192-255.
    """
    TOTAL_BYTES = 256
    PROGRAM_LIMIT = 16  # 128 bytes

    if len(main_code) > PROGRAM_LIMIT:
        raise Exception(f"Main code is too large ({len(main_code)} bytes). Maximum allowed is {PROGRAM_LIMIT} bytes.")
    program_section = main_code + [INSTRUCTIONS["halt"]["opcode"]] * (PROGRAM_LIMIT - len(main_code))

    if interrupt_code is None:
        interrupt_section = [INSTRUCTIONS["halt"]["opcode"]] * (TOTAL_BYTES - PROGRAM_LIMIT)
    else:
        if len(interrupt_code) > (TOTAL_BYTES - PROGRAM_LIMIT):
            raise Exception(f"Interrupt code too large ({len(interrupt_code)} bytes). Maximum allowed is {(TOTAL_BYTES - PROGRAM_LIMIT)} bytes.")
        interrupt_section = interrupt_code + [INSTRUCTIONS["halt"]["opcode"]] * ((TOTAL_BYTES - PROGRAM_LIMIT) - len(interrupt_code))

    full_memory = program_section + interrupt_section
    coe_lines = []
    coe_lines.append("memory_initialization_radix=16;")
    coe_lines.append("memory_initialization_vector=")
    byte_strings = [f"{byte:02X}" for byte in full_memory]
    for i in range(0, TOTAL_BYTES, 16):
        line_bytes = byte_strings[i:i+16]
        if i + 16 < TOTAL_BYTES:
            coe_lines.append(", ".join(line_bytes) + ",")
        else:
            coe_lines.append(", ".join(line_bytes) + ";")
    return "\n".join(coe_lines)

def main():
    if len(sys.argv) < 3:
        print("Usage: python assembler_to_coe.py <assembly_file.asm> <output_file.coe>")
        sys.exit(1)
    asm_filename = sys.argv[1]
    coe_filename = sys.argv[2]

    with open(asm_filename, "r") as f:
        all_lines = f.readlines()

    # Split lines: main program lines come before the first occurrence of "irs:"; the rest is ISR.
    main_lines = []
    interrupt_lines = []
    in_interrupt = False
    for line in all_lines:
        if not in_interrupt and line.strip().lower().startswith("irs:"):
            in_interrupt = True
            continue
        if in_interrupt:
            interrupt_lines.append(line)
        else:
            main_lines.append(line)

    try:
        main_machine_code = compile_asm(main_lines)
    except Exception as e:
        print(f"Error in main program: {e}")
        sys.exit(1)

    try:
        ISR_BASE = 16
        interrupt_machine_code = compile_asm(interrupt_lines, base=ISR_BASE) if interrupt_lines else None
    except Exception as e:
        print(f"Error in interrupt code: {e}")
        sys.exit(1)

    try:
        coe_content = generate_coe(main_machine_code, interrupt_machine_code)
        with open(coe_filename, "w") as f:
            f.write(coe_content)
        print(f"COE file generated successfully: {coe_filename}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()

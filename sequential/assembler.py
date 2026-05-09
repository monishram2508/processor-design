import re

def assemble(line):
    # Remove comments and clean up the line
    line = line.split('#')[0].strip()
    if not line: 
        return []
    
    inst = line.split()[0]
    
    # Clever trick: Extract all numbers from the line (handles negatives too!)
    # Example: "sd x6, 24(x5)" -> extracts [6, 24, 5]
    nums = [int(n) for n in re.findall(r'-?\d+', line)]
    
    # Helper to convert a value to a fixed-width binary string
    def to_bin(val, bits): 
        return format(val & ((1 << bits) - 1), f'0{bits}b')
    
    # 1. R-Type Instructions
    if inst in ['add', 'sub', 'and', 'or']:
        rd, rs1, rs2 = nums[0], nums[1], nums[2]
        f3 = {'add':'000', 'sub':'000', 'and':'111', 'or':'110'}[inst]
        f7 = '0100000' if inst == 'sub' else '0000000'
        binary = f"{f7}{to_bin(rs2,5)}{to_bin(rs1,5)}{f3}{to_bin(rd,5)}0110011"
        
    # 2. I-Type Math (addi)
    elif inst == 'addi':
        rd, rs1, imm = nums[0], nums[1], nums[2]
        binary = f"{to_bin(imm,12)}{to_bin(rs1,5)}000{to_bin(rd,5)}0010011"
        
    # 3. I-Type Load (ld)
    elif inst == 'ld':
        rd, imm, rs1 = nums[0], nums[1], nums[2]
        binary = f"{to_bin(imm,12)}{to_bin(rs1,5)}011{to_bin(rd,5)}0000011"
        
    # 4. S-Type Store (sd)
    elif inst == 'sd':
        rs2, imm, rs1 = nums[0], nums[1], nums[2]
        imm_b = to_bin(imm, 12)
        binary = f"{imm_b[:7]}{to_bin(rs2,5)}{to_bin(rs1,5)}011{imm_b[7:]}0100011"
        
    # 5. B-Type Branch (beq)
    elif inst == 'beq':
        rs1, rs2, imm = nums[0], nums[1], nums[2]
        imm_b = to_bin(imm, 13) 
        # Shuffling the immediate bits to match standard RISC-V B-format
        binary = f"{imm_b[0]}{imm_b[2:8]}{to_bin(rs2,5)}{to_bin(rs1,5)}000{imm_b[8:12]}{imm_b[1]}1100011"
        
    else:
        print(f"Skipping unknown instruction: {inst}")
        return []

    # Convert the 32-bit binary string to a Big-Endian 8-character hex string
    hex_str = format(int(binary, 2), '08x')
    
    # Split the hex string into 4 separate bytes
    return [hex_str[0:2], hex_str[2:4], hex_str[4:6], hex_str[6:8]]


# --- Main Execution ---
input_file = 'instructions_exp.txt'
output_file = 'instructions.txt'

print(f"Reading assembly from {input_file}...")
with open(input_file, 'r') as f_in, open(output_file, 'w') as f_out:
    for line in f_in:
        bytes_list = assemble(line)
        for b in bytes_list:
            f_out.write(b + '\n')

print(f"Success! Translated bytes written to {output_file}.")
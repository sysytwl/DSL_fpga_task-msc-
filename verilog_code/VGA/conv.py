import re

def coe_to_8x16(input_file, output_file):
    with open(input_file, 'r') as infile:
        content = infile.read()
    
    # Extract 2-digit hex values from the file.
    hex_values = re.findall(r'[0-9A-Fa-f]{2}', content)
    
    if not hex_values:
        print("No valid hex values found in the file.")
        return

    # Convert each hex value to an 8-bit binary string with spaces between bits.
    binary_values = [' '.join(format(int(h, 16), '08b')) for h in hex_values]

    with open(output_file, 'w') as outfile:
        # Group the binary strings into blocks of 16 rows (8x16 bitmap)
        for i in range(0, len(binary_values), 16):
            for j in range(16):
                if i + j < len(binary_values):
                    outfile.write(binary_values[i + j] + '\n')
            outfile.write('\n')  # Blank line to separate blocks

    print(f"Conversion complete! Output saved to {output_file}")

# Example usage
input_filename = "ASCII_table_8x16.coe"  # Your COE file
output_filename = "ASCII_TABLE.coe"  # Converted binary matrix

coe_to_8x16(input_filename, output_filename)

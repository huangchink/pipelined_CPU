import sys

# read file
f = open(sys.argv[1], "r")
lines = f.readlines()
f.close()

def signed_extension(s, num):
	return (num-len(s))*"0" + s # signed extension

def unsigned_extension(s, num):
	return (num-len(s))*"0" + s # signed extension

def get_register(s):
	register = bin(int(s[1:]))[2:]
	return unsigned_extension(register, 5)

def i_type(func3, dst, src1, src2):
	bin_code = ""
	immediate = ""
	if int(src2) < 0:
		immediate = bin(int(src2) & 0b111111111111)[2:]
	else:
		immediate = bin(int(src2))[2:]
	imm_extend = signed_extension(immediate, 12)
	bin_code = imm_extend[:7] + "_" + imm_extend[7:]  + "_"
	bin_code += get_register(src1) + "_"
	bin_code += func3 + "_"
	bin_code += get_register(dst) + "_"
	bin_code += "0000000"
	return bin_code

def imm_s_type (func7, func3, dst, src1, src2):
	bin_code = ""
	bin_code += func7 + "_"
	immediate = bin(int(src2))[2:]
	bin_code += signed_extension(immediate, 5) + "_"
	bin_code += get_register(src1) + "_"
	bin_code += func3 + "_"
	bin_code += get_register(dst) + "_"
	bin_code += "0000000"
	return bin_code

def r_type (func7, func3, dst, src1, src2):
	bin_code = ""
	bin_code += func7 + "_"
	bin_code += get_register(src2) + "_"
	bin_code += get_register(src1) + "_"
	bin_code += func3 + "_"
	bin_code += get_register(dst) + "_"
	bin_code += "0000001"
	return bin_code

def bra_type (func3, dst_num, src1, src2):
	bin_code = ""
	immeditate = ""
	if (dst_num < 0):
		immediate = bin(dst_num & 0b111111111111)[2:]
	else:
		immediate = bin(dst_num)[2:]
	offset = signed_extension(immediate, 12)
	bin_code += offset[:7] + "_"
	bin_code += get_register(src2) + "_"
	bin_code += get_register(src1) + "_"
	bin_code += func3 + "_"
	bin_code += offset[7:] + "_"
	bin_code += "0000010"
	return bin_code

def l_type(func7, dst, src1, src2):
	bin_code = ""
	immediate = bin(int(src2))[2:]
	imm_extend = signed_extension(immediate, 12)
	bin_code = imm_extend[:7] + "_" + imm_extend[7:]  + "_"
	bin_code += get_register(src1) + "_"
	bin_code += "000_"
	bin_code += get_register(dst) + "_"
	bin_code += func7
	return bin_code

def s_type(func7, src1, base , src2):
	bin_code = ""
	immediate = bin(int(src2))[2:]
	imm_extend = signed_extension(immediate, 12)
	bin_code = imm_extend[:7] + "_" 
	bin_code += get_register(src1) + "_"
	bin_code += get_register(base) + "_"
	bin_code += "000_"
	bin_code += imm_extend[7:]  + "_"
	bin_code += func7
	return bin_code
	
	
# first pass
instructions = []
ins_count = 0
label = {}

for i, line in enumerate(lines):
	frac = []
	frac = line.split()
	if line.strip():
		if len(frac) == 1 and frac[0][len(frac[0])-1] == ":":
			label[frac[0][:len(frac[0])-1]] = i-len(label)
		else:
			instructions.append(frac)

print(label)


# second pass
f = open(sys.argv[2], "w")
binary = ""
for i, ins in enumerate(instructions):
	op = ins[0]
	binary = ""
	# ins[1] dst
	# ins[2] src1
	# ins[2] src2
	
	# I-TYPE
	if op == "ADDI":
		binary = i_type("000", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "SLTI":
		binary = i_type("001", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "ANDI":
		binary = i_type("100", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "ORI":
		binary = i_type("101", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "XORI":
		binary = i_type("110", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "SLLI":
		binary = imm_s_type("0000000", "010", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "SRLI":
		binary = imm_s_type("0000000", "011", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "SRAI":
		binary = imm_s_type("0100000", "011", ins[1], ins[2], ins[3]);
		f.write(binary)

	# R-TYPE
	elif op == "ADD":
		binary = r_type("0000000", "000", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "SLT":
		binary = r_type("0000000", "001", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "AND":
		binary = r_type("0000000", "100", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "OR":
		binary = r_type("0000000", "101", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "XOR":
		binary = r_type("0000000", "110", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "SLL":
		binary = r_type("0000000", "010", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "SRL":
		binary = r_type("0000000", "011", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "SUB":
		binary = r_type("0100000", "001", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "SRA":
		binary = r_type("0100000", "011", ins[1], ins[2], ins[3]);
		f.write(binary)

	# BRANCH-TYPE
	elif op == "BEQ":
		dst_num = label[ins[1]] - i - 1
		binary = bra_type("111", dst_num, ins[2], ins[3]);
		f.write(binary)
	elif op == "BNE":
		dst_num = label[ins[1]] - i - 1
		binary = bra_type("101", dst_num, ins[2], ins[3]);
		f.write(binary)
	elif op == "BLT":
		dst_num = label[ins[1]] - i - 1
		binary = bra_type("001", dst_num, ins[2], ins[3]);
		f.write(binary)
	elif op == "BGE":
		dst_num = label[ins[1]] - i - 1
		binary = bra_type("011", dst_num, ins[2], ins[3]);
		f.write(binary)

	# LOAD/STORE
	elif op == "LW":
		binary = l_type("1000000", ins[1], ins[2], ins[3]);
		f.write(binary)
	elif op == "SW":
		binary = s_type("1000001", ins[1], ins[2], ins[3]);
		f.write(binary)

	# PSUEDO
	elif op == "NOP":
		f.write("0000000_00000_00000_000_00000_0000000")
	elif op == "MV":
		binary = i_type("000", ins[1], ins[2], "0");
		f.write(binary)
	elif op == "J":
		dst_num = label[ins[1]] - i - 1
		binary = bra_type("111", dst_num, "R0", "R0");
		f.write(binary)

	f.write("  //")
	s = ""
	for element in ins:
		s += element + " "
	f.write(s)
	f.write("\n")

f.close()





		
	



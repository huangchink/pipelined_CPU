---Assembler Readme---

[UPDATE]
1. New pseudo instruction J (Jump)

[UPDATE]
1. Support user defined assembly code path, binary code path
2. Revise the format of label
3. New pseudo instruction NOP, MV

[Execution]
Command: python assembler.py [assembly code path] [binary code path]
put your assembly code in the file [assembly code path] and the binary code would 
be generated in the [binary code path] file.

[Assembly code format]
OP RD RS1 RS2

Use "single space" to seperate, if RS2 is immediate type, just type the number without any prefix.
If there's any label, let it have "a seperate line" with the label name and a semicolon ":".
Feel free to change the line for your assembly code, assembler would automatically skipped it while processing.
Please contact me if you have found any problem!

[Supported pseudo instruction]
NOP
MV

[Example program]

LABEL1:
BEQ LABEL1 R15 R11
LABEL2:
ADDI R0 R0 0
NOP
ADD R5 R3 R4
BEQ LABEL3 R5 R4
SUB R10 R5 R3
SRLI R9 R11 6
LABEL3:
MV R15 R10

output result:

1111111_01011_01111_111_11111_0000010	//BEQ LABEL1 R15 R11 
000000000000_00000_000_00000_0000000	//ADDI R0 R0 0 
00000000_00000000_00000000_00000000_	//NOP 
0000000_00100_00011_000_00101_0000001	//ADD R5 R3 R4 
0000000_00100_00101_111_00010_0000010	//BEQ LABEL3 R5 R4 
0100000_00011_00101_001_01010_0000001	//SUB R10 R5 R3 
0000000_00110_01011_011_01001_0000000	//SRLI R9 R11 6 
000000000000_01010_000_01111_0000000	//MV R15 R10 


extern Sys_main
[SECTION .text]
[BITS 16]

global _start
global print_
global cls_

_start:
        call Sys_main

[SECTION .text]
[BITS 16]
cls_:
        MOV AH, 0X06
        MOV BH, 00000111B       ; color attribute 
        MOV AL, 0X00

        ; row column (x, y)
        MOV CH, 0X00
        MOV CL, 0X00
        MOV DH, 0X18
        MOV DL, 0X4F

        XCHG BX, BX

        INT 0X10

        RET

print_:
            XCHG BX, BX
            MOV AX, 0XB800
            MOV ES, AX
            MOV BX, 0X0000
            MOV BYTE [ES : BX], 'G'
            INC BX
            MOV BYTE [ES : BX], 00000111B
            INC BX
            MOV BYTE [ES : BX], 'G'
            INC BX
            MOV BYTE [ES : BX], 00000111B

            RET 

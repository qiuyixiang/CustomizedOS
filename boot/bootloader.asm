;BootLoader MBR File 
;载入 0 面 0 磁道 1 扇区到 0x7c00 位置
;Loader Address 0x7c00

;MBR For The Next File


;Initialization The Segment Register ! 

[ORG 0X7C00]
[SECTION .text]
[BITS 16]

MOV AX, CS
MOV DS, AX
MOV ES, AX
MOV SS, AX
MOV GS, AX
MOV FS, AX

XCHG BX, BX
;Call Test Func
CALL print

;Endless Loop
JMP $

;Test func
print :
        MOV AX, 0XB800
        MOV ES, AX
        MOV AX, 0X0000
        MOV DS, AX

        MOV DI, 0X0000
        MOV SI, Message
        
        _try:
                MOV AL, [DS : SI]
                CMP AL, 0X00
                JE _end
                MOV [ES : DI], AL
                INC DI
                MOV BYTE [ES : DI], 00000111B
                INC DI
                INC SI
                JMP _try
        _end:
                RET 


Message: DB "Hello OS WORLD !", 0x00

;Fill The Rest Of Memory ! 
TIMES 510 - ($ - $$) DB 0X00
DW 0XAA55
; SETUP APPLICATION
; Base Address is 0X0500
; Global Stack : Start ON 0X7C00

; Create On 2023-4-24
; FUNCTION OF :
;   1. Enter Protected-mode
;   2. Save the Hardware Status
;   3. Load to Kernel (THE REAL OPERATION SYSTEM)

; BASE ADDRESS OF DIFFERENT CODING BIN FILE 
SETUP_BASE_ADDRESS  EQU     0X0500
KERNEL_BASE_ADDRESS EQU     0x7E00
BASE_ADDR EQU 0x0000
ROW_POS             EQU     80 * 2 * 1


[SECTION .text]
[BITS 16]

; Main Entry
_set_up_start :
        ; Initialized DS To The Head Of the File : 0X0500
        ; Set New DS Address 
        MOV AX, 0X0500
        SHR AX, 0X04
        MOV DS, AX

        MOV AX, 0XB800
        MOV ES, AX

        ; Show Tip Information 
        MOV CX, [LINE_OF_TAG]
        MOV SI, TAG
        MOV DI, ROW_POS

        XCHG BX, BX
        _loop_print :
                MOV AL, [DS : SI]
                MOV [ES : DI], AL 
                INC DI
                MOV BYTE [ES : DI], 00000111B
                INC DI
                INC SI

                LOOP _loop_print

; Update the Cursor Position
        MOV AH, 0X02
        MOV BH, 0X00
        MOV DH, 0X02
        MOV DL, 0X00

        INT 0X10
        
        MOV AX, KERNEL_BASE_ADDRESS
        SHR AX, 0X04
        MOV ES, AX
        MOV BX, 0X0000 

        MOV AH, 0X02            ; 0X02 Read Disk, 0X03 Write Disk
        MOV AL, 0X02                ; 读取扇区数
                    
        MOV CH, 0X00                ; 读取柱面号
        MOV DH, 0X00                ; 读取磁头号
        MOV CL, 0X04                ; 读取扇区号
        MOV DL, 0X80                ; 驱动器号（硬盘从0x80开始,软盘从0x00开始）

        INT 0X13  
        XCHG BX, BX
        JMP DWORD BASE_ADDR : KERNEL_BASE_ADDRESS
; _endless_loop:
;         HLT
;         JMP _endless_loop

; Data Definition Here
TAG : DB "loading SetUp Successfully !", 0X00
LINE_OF_TAG : DB ($ - TAG)





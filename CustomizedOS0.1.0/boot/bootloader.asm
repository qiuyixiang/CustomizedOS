; Bootloader Version 3.0
; Created by @
; Created on 2023-4-24
; Real Mode Functional Application
; This Bootloader's Memory Address is 0x07c00

BOOTLOADER_BASE_ADDRESS EQU 0X7C00
SETUP_BASE_ADDRESS EQU 0X0500

;Initialization of the Base Segment Register


; CS was initialized in 0X0000
; SS:SP  equs to 0X0000:0X7C00
; Global DS eques to 0X07C0 (STATIC ADDRESS)
[SECTION .text]
[BITS 16]

MOV AX, CS
MOV DS, AX
MOV ES, AX
MOV FS, AX
MOV SS, AX
MOV GS, AX

; Set the Stack Address of 0X7C00
; Set the Stack Size of Unknown
MOV SP, BOOTLOADER_BASE_ADDRESS

; Set DS is The TOP of the File
; DS : 0X07C0
MOV AX, BOOTLOADER_BASE_ADDRESS
SHR AX, 0X04
MOV DS, AX

;################ Clear the Screen ################
; BIOS Called to clear the Screen
        MOV AH, 0X06
        MOV BH, 00000111B       ; color attribute 
        MOV AL, 0X00

        ; row column (x, y)
        MOV CH, 0X00
        MOV CL, 0X00
        MOV DH, 0X18
        MOV DL, 0X4F

        INT 0X10

;################ Show The Information ################
; DS : SI  -- Source            -- 0X7C00 : MESSAGE
; ES : DI  -- Destination       -- 0XB800 : 0X0000

        MOV AX, 0XB800
        MOV ES, AX

        MOV SI, MESSAGE
        MOV DI, 0X0000
        MOV CX, [LINE_OF_MESSAGE]

_loop_print_Msg:
        MOV AL, [DS : SI]
        MOV [ES : DI], AL 
        INC DI
        MOV BYTE [ES : DI], 00000111B
        INC DI
        INC SI

        LOOP _loop_print_Msg

;################ Set Cursor ################

        MOV AH, 0X02

        MOV BH, 0X00
        MOV DH, 0X00                    ; ROW
        MOV DL, [LINE_OF_MESSAGE]       ; COLUMN

        INT 0X10

;################ Write SetUp ################
; Use Int 0x13 Write Disk  (From HardDisk To Memory)
; form   0 面 0 磁道 2 扇区 
; to  Memory Address 0x0500:0x0000

; INT 0x13 :  
; Destination -- ES : BX
_read_disk:
        MOV AX, SETUP_BASE_ADDRESS
        SHR AX, 0X04
        MOV ES, AX
        MOV BX, 0X0000 

        MOV AH, 0X02            ; 0X02 Read Disk, 0X03 Write Disk
        MOV AL, 0X02                ; 读取扇区数
                    
        MOV CH, 0X00                ; 读取柱面号
        MOV DH, 0X00                ; 读取磁头号
        MOV CL, 0X02                ; 读取扇区号
        MOV DL, 0X80                ; 驱动器号（硬盘从0x80开始,软盘从0x00开始）

        INT 0X13  
; IF Error Occured Then will Carry Flag Register !
        JC _read_disk_error
        JMP _read_disk_ok

        _read_disk_error:
                ; Reset AH to 0x00 
                MOV AX, 0X00 
                MOV DL, 0X80

                INT 0X13
                JMP _read_disk
        _read_disk_ok:
                ; Nothing To Do

; Read Disk successfully !!!
; The Next Procedure will be executed

; jmp to setup.bin memory address
;XCHG BX, BX

JMP DWORD [ADDRESS]

; Data Segment
MESSAGE : DB "Booting Operation System......", 0X00
LINE_OF_MESSAGE : DB ($ - MESSAGE)

ADDRESS : DW 0X0500, 
          DW 0X0000

;Fill the Rest Of Memory 
TIMES 510 - ($ - $$) DB 0X00

;Magic Number
DW 0XAA55

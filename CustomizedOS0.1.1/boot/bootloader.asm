; Bootloader MBR Loading Application
; Bootloader Version for CustomizedOS0.1.1
; Bootloader File Base Address 0x7C00


; Function for loading SetUpto The  Sector of 0x0500
; Create On 2023-04-26

[ORG 0X7C00]
[SECTION .text]
[BITS 16]

; Some Base Address of Macro 
BOOTLOADER_BASE_ADDRESS       EQU       0x7C00
SETUP_BASE_ADDRESS            EQU       0x8000
      
; Main Procedure Start  !!!
; Initialized The Base Register
MOV AX, CS 
MOV DS, AX
MOV SS, AX
MOV ES, AX
MOV FS, AX
MOV GS, AX

; Set Stack Pointer to 0X7c00
MOV SP, 0X7C00

;  Clear The Screen
        MOV AH, 0X06
        MOV BH, 00000111B
        MOV AL, 0X00

        MOV CH, 0X00   ; Left-Top (X, Y)
        MOV CL, 0X00
        MOV DH, 0X18   ; Right-Bottom (X, Y)
        MOV DL, 0X4F

        INT 0X10

; Show Booting Message !
        MOV SI, MESSAGE
        MOV CX, [LINE_OF_MESSAGE]
        
        MOV DI, 0X0000

        CALL _show_MSG

; call _set_cursor
        MOV DH, 0X00
        MOV DL, [LINE_OF_MESSAGE]

        CALL _set_cursor

;# Read From Hard Disk 
; Use BISO (HLS) MODE READ from hard disk
; Set Memory Address
; 8000:0000 
        MOV AX, SETUP_BASE_ADDRESS
        MOV ES, AX
        MOV BX, 0X0000

        MOV AH, 0X02
        MOV AL, 0X04

        MOV CL, 0X00
        MOV DH, 0X00
        MOV CL, 0X02
        MOV DL, 0X80

        INT 0X13
        JC _read_error
        JMP _read_ok

_read_error:
        MOV AH, 0X00
        MOV DL, 0X80

        INT 0X13

_read_ok:
;        XCHG BX, BX
        MOV SI, FINISH
        MOV CX, [LINE_OF_FINISH]
        MOV DI, 80 * 2 * 1

        CALL _show_MSG

        ; Rest Cursor
        MOV DH, 0X02
        MOV DL, 0X00
        
        CALL _set_cursor

; Jump To SetUp's Memory Address 0x0800 : 0x0000  (0x80000)

JMP SETUP_BASE_ADDRESS : 0x0000

;################# Set Cursor To Proper Place #################
; @ function setCursor
; @ dh : row
; @ dl : column
_set_cursor:
        MOV AH, 0X02
        MOV BH, 0X00

        INT 0X10

        RET 

;################# Show Tips Message #################
;  @ function _show_MSG
;       DS:SI  Source
;       ES:DI  Destination
;  @  SI : Source
;  @  CX : Size Of String
;  @  DI : Position

_show_MSG:
        MOV AX, 0XB800
        MOV ES, AX
        MOV AX, 0X0000
        MOV DS, AX
        
_loop_print:
        MOV AL, [DS:SI]
        MOV [ES:DI], AL
        INC DI
        MOV BYTE [ES:DI], 00000111B
        INC DI
        INC SI

        LOOP _loop_print
        RET

; Tips Data !
MESSAGE : DB "Booting Operation System ..."
LINE_OF_MESSAGE : DB ($ - MESSAGE), 0X00

FINISH : DB "Reading Setup Successfully !!!"
LINE_OF_FINISH : DB ($ - FINISH), 0X00

; Fill The Rest Of The Memory
TIMES 510 - ($ - $$) DB 0X00

; Magic Number !
DW 0xAA55
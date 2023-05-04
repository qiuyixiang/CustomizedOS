; BootLoader Assembly 
; Do Initialization For Base Register

; Loader Setup to Proper Position
; Create on 2023-4-4


; BootLoader was Loaded By BIOS to 0X7C00
; Last Instruction is Jump to Setup's First Instruction
; Bootloader : 0X07C00
; SetUp      : 0x80000

BOOTLOADER_BASE_ADDRESS          EQU       0X7C00
VGA_BUFFER_ADDRESS               EQU       0XB800
SETUP_BASE_ADDRESS               EQU       0X8000
SETUP_OFFSET_ADDRESS             EQU       0X0000
STACK_BASE_ADDRESS               EQU       BOOTLOADER_BASE_ADDRESS


;Set Offset Of The File's Memory Distribution
[ORG BOOTLOADER_BASE_ADDRESS]

[SECTION .text]
[BITS 16]

; Initialization Base Segment Register
MOV AX, CS
MOV DS, AX
MOV SS, AX
MOV ES, AX
MOV FS, AX
MOV GS, AX

; Initialization Stack Pointer Register
MOV SP, STACK_BASE_ADDRESS

; Clear Screen
CALL _clear

; Show Looding Message

; Destination
MOV AX, VGA_BUFFER_ADDRESS
MOV ES, AX
MOV DI, 0X0000
; Source
MOV AX, 0X0000
MOV DS, AX
MOV SI, MESSAGE

MOV CX, [LINE_OF_MESSAGE]
CALL _show_message

; Set Cursor Position
MOV DH, 0X00
MOV DL, [LINE_OF_MESSAGE]
CALL _set_cursor
  
; Show Message
MOV DI, 80 * 2
MOV SI, READING_MESSAGE

MOV CX, [LINE_OF_READING_MESSAGE]
CALL _show_message

; Set Cursor Position
MOV DH, 0X01
MOV DL,  [LINE_OF_READING_MESSAGE]
CALL _set_cursor

; Reading From Harddisk (BIOS 13H)
_read_harddisk:
        MOV AX, SETUP_BASE_ADDRESS
        MOV ES, AX
        MOV BX, 0X0000

        MOV AH, 0X02
        MOV AL, 0X04

        MOV CH, 0X00
        MOV DH, 0X00
        MOV CL, 0X02
        MOV DL, 0X80
        
        INT 0X13
        JC _read_error
        JMP _read_ok
_read_error:
; Reset Status

        MOV AH, 0X00
        MOV DL, 0X80
        JMP _read_harddisk
_read_ok:
; Show Reading Successfully

        MOV AX, VGA_BUFFER_ADDRESS
        MOV ES, AX
        MOV DI, 80 * 2 * 2

        MOV AX, 0X0000
        MOV DS, AX
        MOV SI, READING_SUCCEFULLY

        MOV CX, [LINE_OF_READING_SUCCEFULLY]
        CALL _show_message

; Set Cursor Position
MOV DH, 0X03
MOV DL, 0X00
CALL _set_cursor

; Everything IS OK
; JMP TO SETUP ADDRESS

JMP SETUP_BASE_ADDRESS : SETUP_OFFSET_ADDRESS

; Procedure (FUNCTION)

; ############### Clear Screen ###############
_clear:
        MOV AH, 0X06
        MOV BH, 00000111B
        MOV AL, 0X00

        MOV CH, 0X00
        MOV CL, 0X00
        MOV DH, 0X18
        MOV DL, 0X4F

        INT 0x10
        RET
; ############### Show Message ###############
; ES:DI  : Destination
; DS:SI  : Source
; CX     : Loop Times
_show_message:
        PUSH AX
    _loop_print:
            MOV AL, [DS:SI]
            MOV [ES:DI], AL
            INC DI
            MOV BYTE [ES:DI], 00000111B
            INC DI
            INC SI
            LOOP _loop_print
;   PRINT OVER            
        POP AX
        RET 
; ############### Set Cursor ###############
; DH  :  row
; DL  :  column
_set_cursor:
        MOV AH, 0X02
        MOV BH, 0X00

        INT 0X10
        RET

; Data Segment 
MESSAGE : 
        DB "Booting Operation System ...",  0X00
LINE_OF_MESSAGE :
        DW ($ - MESSAGE)

READING_MESSAGE :
        DB "Reading From Harddisk", 0X00
LINE_OF_READING_MESSAGE:
        DW ($ - READING_MESSAGE)

READING_SUCCEFULLY :
        DB "Reading Successfully !!!", 0X00
LINE_OF_READING_SUCCEFULLY:
        DW ($ - READING_SUCCEFULLY)       
   
; Filled The Rest of the Memory with 0X00
TIMES 510 - ($ - $$) DB 0X00

; Magic number
DW 0XAA55

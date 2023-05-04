; Setup Assembly Language
; Create on 2023-4-4
; Read Kernel Binary File From Harddisk


; Setup Base Address 0X8000
; Physical Address : 0X80000
; Kernel Address : 0x00000

; Macro For Address 
SETUP_BASE_ADDRESS          EQU        0X8000
SETUP_OFFSET_ADDRESS        EQU        0X0000
KERNEL_BASE_ADDRESS         EQU        0X0008
KERNEL_OFFSET_ADDRESS       EQU        0X0000

; Macro For GDT
LIMIT_MAXIMUM               EQU        0XFFFF
LIMIT_MINIMUM               EQU        0X0000
BASE_SEGMENT_ADDRESS        EQU        0X0000
GDTR_LIMIT_COUNTS           EQU        32


[ORG BASE_SEGMENT_ADDRESS]

; Data Segment
[SECTION .data]

; GDT (Global Descriptor Table)
GDT_:
; Index = 0 DUMMY
        DW 0X0000 
        DW 0X0000 
        DW 0X0000
        DW 0X0000

; Code Segment
        DW LIMIT_MAXIMUM
        DW BASE_SEGMENT_ADDRESS

        DB 0X00
        DB 1_00_1_1010B
        
        DB 1_1_0_0_1111B
        DB 0X00

; Data Segment
        DW LIMIT_MAXIMUM    
        DW BASE_SEGMENT_ADDRESS

        DB 0X00
        DB 1_00_1_0010B

        DB 1_1_0_0_1111B
        DB 0X00

; Fill The Rest Descriptor
TIMES (GDTR_LIMIT_COUNTS - 3) DQ 0X0000

_gdtr_48:
        DW GDTR_LIMIT_COUNTS * 8                ; Segment Limit
        DD (SETUP_BASE_ADDRESS << 4) + GDT_     ; Segment Base Address

; Code Segment
[SECTION .text]
[BITS 16]

; Reset DS register
MOV AX, 0X8000
MOV DS, AX

_read_harddisk:
        MOV AX, 0X0000
        MOV ES, AX
        MOV BX, KERNEL_OFFSET_ADDRESS

        MOV AH, 0X02
        MOV AL, 0X10

        MOV CH, 0X00
        MOV DH, 0X00
        MOV CL, 0X06
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

; Enter Protected-Mode

    ; Load GDT to gdtr Register
    ;    XCHG BX, BX
        LGDT [_gdtr_48]

    ; Open A20 Main Address Thread
        MOV DX, 0X92
        IN AL, DX

        OR AL, 00000010B
        OUT DX, AL

    ; Set Cr0 Register Frist bit to 1
        MOV EAX, CR0
        OR EAX, 0X01
        MOV CR0, EAX

; JMP kernel (head) address
JMP KERNEL_BASE_ADDRESS : SETUP_OFFSET_ADDRESS


; LBA28 Reading Harddisk
; ############# LBA Read Harddisk #####################
; eax : source sector
; bx  : memory destination
; cx  : size of sector

; TODO
        
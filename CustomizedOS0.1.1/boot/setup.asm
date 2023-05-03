; SetUp Procedure 
; Main Loader Programming
; Create on 2023-04-26
; Finish on 
; CopyRight @qiuyixiang

; Base Address 0x8000
; Physical Address 0x80000

; Macro For Base Address 
SETUP_BASE_ADDRESS      EQU         0X8000
KERNEL_BASE_ADDRESS     EQU         0X0000
DESCRIPTOR_COUNT        EQU         0X03

[SECTION .data]
; Declare For GDT 
; Global Descriptor Table

_gdtr_48 :
        DW 0X0100,                                 ; limit : 256 byte  (the amount of descriptor is 32)
        DD _GDT + (SETUP_BASE_ADDRESS << 4)        ; Base Address of GDT

Message : db "Hello World !"
_GDT:
        ; Index = 0 Just As a Flag (Unused Value)
        DW 0X0000, 0X0000, 0X0000, 0X0000

        ; System Code Descriptor
        DW      0XFFFF           ; Segment Limit
        DW      0X0000           ; Base Address
        DB      0X00             ; Base Address
        DB      1_00_1_1010B      ; P  DPL  S  Type 
        DB      1_1_0_0_1111B     ; G  D/B  L  AVL Limit
        DB      0X00             ; Base Address

        ; System Data Descriptor
        DW      0XFFFF          
        DW      0X0000  
        DB      0X00
        DB      1_00_1_0010B
        DB      1_1_0_0_1111B
        DB      0X00

TIMES (32 - DESCRIPTOR_COUNT) DQ 0X0000     

; GDTR (Global Descriptor Table Register)
; 48 bit register (point at GDT)


; Main Procedure
[SECTION .text]
[BITS 16]

; Enter Protected-Mode 
MOV AX, 0X8000
MOV DS, AX


; Close Interrupt
cli  
; 1. load _gdtr_48 (48 bits) to gdtr register
XCHG BX, BX
LGDT [_gdtr_48]

; 2. open A20 Main Thread 
MOV DX, 0X92

IN AL, DX
OR AL, 00000010B
OUT DX, AL

; 3. Set CR0 First Bit to 1
MOV EAX, CR0
OR EAX, 0X01
MOV CR0, EAX

; JMPI 0X00 , 8
; 0X00 :  Offset Address
; 8 (0000 0000 0000 1000)  : Index of Selector = 1
XCHG BX, BX
JMP 0x0008:0x0000 
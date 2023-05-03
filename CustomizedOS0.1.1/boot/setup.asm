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

[ORG 0x0000]
[SECTION .data]
; Declare For GDT 
; Global Descriptor Table

_gdtr_48 :
        DW 0XAAAA       ; limit : 256 byte  (the amount of descriptor is 32)
        DD 0XAAAAAAAA         ; Base Address of GDT

Message : db "Hello World !"
_GDT:
        DW 0X00, 0X00, 0X00, 0X00

        ; Code Descriptor
        DW 0X00, 0X00, 0X00, 0X00
        ; Data Descriptor
        DW 0X00, 0X00, 0X00, 0X00

TIMES (32 - DESCRIPTOR_COUNT) DQ 0X0000      

; GDTR (Global Descriptor Table Register)
; 48 bit register (point at GDT)


; Main Procedure
[SECTION .text]
[BITS 16]

; Enter Protected-Mode 
MOV AX, 0X8000
MOV DS, AX

; 1. load _gdtr_48 (48 bits) to gdtr register
XCHG BX, BX
mov ax, [DS:_gdtr_48]
LGDT [DS:_gdtr_48]


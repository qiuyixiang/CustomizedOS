; SetUp Procedure 
; Main Loader Programming
; Create on 2023-04-26
; Finish on 
; CopyRight @qiuyixiang

; Base Address 0x0500

; Macro For Base Address 
SETUP_BASE_ADDRESS      EQU         0x0500
KERNEL_BASE_ADDRESS     EQU         0x7E00

; Macro For GDT (Global Descriptor Table)





; Main Procedure

[ORG 0x0500]
[SECTION .text]
[BITS 16]



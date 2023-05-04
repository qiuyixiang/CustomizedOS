; Head Assembly Language
; Entry For Kernel !!!

; Has already been entered into the Protected-Mode
; 32-Bits Coding 

; The Kernel Header !

KERNEL_BASE_ADDRESS        EQU       0X0000
DATA_DESCRIPTOR_VALUE      EQU       0X0008

[GLOBAL _start]
[EXTERN _kernel_main]

[SECTION .text]
[BITS 32]

_start:
        XCHG BX, BX
        MOV EAX, DATA_DESCRIPTOR_VALUE

        MOV DS, AX
        MOV ES, AX
        MOV FS, AX
        MOV GS, AX

        CALL _kernel_main

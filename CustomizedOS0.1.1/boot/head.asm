[ORG 0X0000]
[SECTION .text]
[BITS 32]

EXTERN kernel_main
GLOBAL _start

_start:
        CALL kernel_main
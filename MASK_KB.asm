[BITS 16]
[ORG 0x100]

jmp start         

section .data
    msg_mask   DB "IRQ1 enmascarado (teclado deshabilitado)...$", 0Dh, 0Ah
    msg_unmask DB 0Dh, 0Ah, "IRQ1 restaurado.$"

section .text
start:
    MOV AH, 09h
    MOV DX, msg_mask
    INT 21h

    IN AL, 21h
    PUSH AX               

    OR AL, 02h            
    OUT 21h, AL

    MOV AH, 00h
    INT 1Ah               
    MOV BX, DX
    ADD BX, 55            

.wait:
    MOV AH, 00h
    INT 1Ah
    CMP DX, BX
    JL .wait

    POP AX
    OUT 21h, AL

    MOV AH, 09h
    MOV DX, msg_unmask
    INT 21h

    MOV AX, 4C00h
    INT 21h
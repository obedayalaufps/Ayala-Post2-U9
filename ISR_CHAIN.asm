[BITS 16]
[ORG 0x100]

jmp start         

section .data
    contador  DW 0        
    MAX_KEYS  EQU 5       
    old_isr   DD 0        
    msg_fin   DB 0Dh, 0Ah, "Chaining terminado. Handler restaurado.$"

section .text
start:
    MOV AX, 3509h         
    INT 21h               
    MOV WORD [old_isr], BX
    MOV WORD [old_isr+2], ES

    PUSH DS
    MOV AX, CS
    MOV DS, AX
    MOV DX, mi_isr_chain  
    MOV AX, 2509h         
    INT 21h
    POP DS
    
    STI                   

.esperar:
    MOV AX, [contador]
    CMP AX, MAX_KEYS
    JL .esperar           

    CLI
    LDS DX, [old_isr]     
    MOV AX, 2509h
    INT 21h
    STI

    MOV AH, 09h
    MOV DX, msg_fin
    INT 21h
    
    MOV AX, 4C00h
    INT 21h

mi_isr_chain:
    PUSH AX
    PUSH DS

    MOV AX, CS
    MOV DS, AX

    INC WORD [contador]

    POP DS
    POP AX

    PUSHF
    CALL FAR [CS:old_isr] 
    IRET
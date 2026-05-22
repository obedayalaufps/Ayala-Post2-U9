[BITS 16]
[ORG 0x100]

jmp start

; =========================================
; VARIABLES (Sin directivas de sección)
; =========================================
contador  DW 0
MAX_KEYS  EQU 5
old_isr   DD 0
msg_tecla DB 0Dh, 0Ah, "Tecla detectada por ISR propio$"
msg_fin   DB 0Dh, 0Ah, "ISR restaurado. Fin del programa.$"

; =========================================
; CÓDIGO PRINCIPAL
; =========================================
start:
    ; Guardar vector original INT 09h [cite: 45-47]
    MOV AX, 3509h
    INT 21h
    MOV WORD [old_isr], BX
    MOV WORD [old_isr+2], ES

    ; Instalar ISR propio [cite: 48]
    PUSH DS
    MOV AX, CS
    MOV DS, AX
    MOV DX, mi_isr
    MOV AX, 2509h
    INT 21h
    POP DS
    
    STI

.esperar:
    MOV AX, [contador]
    CMP AX, MAX_KEYS
    JL .esperar

    ; Restaurar handler original [cite: 67-69]
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

; ISR propio [cite: 78-79]
mi_isr:
    PUSH AX
    PUSH DX
    PUSH DS

    MOV AX, CS
    MOV DS, AX

    ; Leer y descartar el scancode del buffer del teclado [cite: 92-93]
    IN AL, 60h

    ; Mostrar mensaje [cite: 94-97]
    MOV AH, 09h
    MOV DX, msg_tecla
    INT 21h

    ; Incrementar contador [cite: 98-99]
    INC WORD [contador]

    ; Enviar EOI al PIC maestro [cite: 100-102]
    MOV AL, 20h
    OUT 20h, AL

    POP DS
    POP DX
    POP AX
    IRET
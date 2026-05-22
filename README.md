# Arquitectura de Computadores - Unidad 9: Post-Contenido 2

## Datos del Estudiante
* **Nombre:** Obed Ayala
* **Institución:** Universidad Francisco de Paula Santander (UFPS)
* **Programa:** Ingeniería de Sistemas
* **Año:** 2026

## Descripción del Laboratorio
Implementación y análisis de Rutinas de Servicio de Interrupción (ISR) personalizadas en ensamblador x86 (modo real de 16 bits). Se evalúa el reemplazo temporal del handler de la interrupción de hardware IRQ1 (teclado), la manipulación del registro IMR del PIC 8259A para enmascaramiento dinámico, y la técnica de encadenamiento de vectores (chaining).

## Estructura de Archivos
```text
Ayala-Post2-U9/
├── capturas/               # Evidencias de ejecución en DOSBox
├── ISR_KB.ASM              # Captura exclusiva de IRQ1
├── MASK_KB.ASM             # Enmascaramiento mediante IMR
├── ISR_CHAIN.ASM            # Encadenamiento de handler original
└── README.md               # Documentación formal (Este archivo)

```

---

## Análisis Técnico de los Checkpoints

### Checkpoint 1: ISR Exclusiva para Teclado (`ISR_KB.ASM`)

El programa intercepta la entrada `09h` de la Tabla de Vectores de Interrupción (IVT), desviando la atención del procesador hacia un manejador propio ante cualquier estímulo en el periférico. La rutina lee directamente el puerto de datos `60h` del controlador 8042 y envía la señal de fin de interrupción (EOI) con el valor `20h` al puerto de control `20h` del PIC maestro.

* **Comportamiento:** Al pulsar las teclas, el sistema suspende el eco ordinario de DOS e imprime textualmente el mensaje de detección. Tras contabilizar 5 pulsaciones consecutivas en memoria, el programa restaura de forma segura el puntero original de la IVT y finaliza.

### Checkpoint 2: Enmascaramiento Eléctrico con el IMR (`MASK_KB.ASM`)

A diferencia del checkpoint anterior, este módulo interactúa con las máscaras del PIC 8259A a través del puerto `21h`. Al aplicar una operación lógica `OR AL, 02h`, se inhabilita el Bit 1 de forma selectiva, aislando las señales eléctricas provenientes de la línea IRQ1 sin afectar otros componentes del sistema como el temporizador (IRQ0).

* **Comportamiento:** Durante un intervalo de 3 segundos (controlado mediante la lectura de 55 ticks del temporizador usando la `INT 1Ah`), el teclado permanece completamente inactivo y no produce eventos gráficos en el sistema. Al concluir el tiempo, se recupera el valor original del IMR desde la pila, restaurando la normalidad operativa.

### Checkpoint 3: Monitoreo Pasivo por Encadenamiento (`ISR_CHAIN.ASM`)

Se implementa la técnica de encadenamiento (*chaining*) modificando el vector de interrupción, pero sin romper el flujo del sistema operativo. La rutina propia registra la pulsación incrementando un contador local y, acto seguido, ejecuta una instrucción `PUSHF` complementada con un `CALL FAR` hacia la dirección previamente respaldada del manejador nativo.

* **Comportamiento:** El programa registra internamente el volumen de eventos establecidos (5 pulsaciones) de manera pasiva. Al transferir el flujo al manejador base de DOSBox, los caracteres ingresados se reflejan normalmente en la interfaz (eco nativo activo), validando la coexistencia de múltiples manejadores de software sobre el mismo recurso de hardware.

---

## Conclusiones Técnicas

1. **Peligro de Reentrada:** El desarrollo de manejadores de hardware exige rutinas de ejecución atómicas y veloces en memoria RAM. Invocar servicios del sistema operativo de alto nivel (como la `INT 21h`) dentro del contexto de una interrupción física vulnera la estabilidad de la pila (*Stack*) en entornos emulados.
2. **Modularidad del PIC 8259A:** El uso del registro IMR demuestra las capacidades de la arquitectura x86 para segregar y priorizar canales de comunicación periférica por hardware, aislando componentes de entrada sin congelar las funciones nucleares del procesador.

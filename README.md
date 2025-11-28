# Proyecto CPU RISC-V en Verilog - Arquitectura de Computadores

Este proyecto implementa un procesador monociclo compatible con el subconjunto de instrucciones **RV32I** de RISC-V, desarrollado completamente en **SystemVerilog** y con soporte para instrucciones tipo R, I, S, B, U y J. 
Incluye módulos como unidad de control, ALU, generador de inmediatos, PC, memoria de instrucciones, memoria de datos, unidad de registros y lógica de branch.
Además, el diseño fue probado tanto a través de simulaciones en Visual Studio como en la FPGA a través de Quartus Prime, verificando su funcionamiento con un programa cargado desde un archivo .mem.

## Objetivo del Proyecto

El objetivo principal es:

- Diseñar una arquitectura simple estilo monociclo.
- Implementar los módulos fundamentales: PC, Instruction Memory, ALU, Register Unit, Immediate Generator, Control Unit, Data Memory, etc.
- Simular y verificar el funcionamiento del cada uno de los módulos y del procesador mediante testbenches y archivos VPP y VCD.
- Cargar un programa real desde un archivo .mem
- Sintetizar el diseño en Quartus Prime
- Ejecutarlo físicamente en la DE1-SoC, utilizando botones, switches y displays HEX para observación del resultado


## Estructura del repositorio
```text
Monociclo_final/
│
├── src/               # Módulos del procesador en SystemVerilog
│   ├── alu.sv
│   ├── branch_unit.sv
│   ├── cpu_top.sv
│   ├── cu.sv
│   ├── datamemory.sv
│   ├── hex7seg.sv
│   ├── immediategenerator.sv
│   ├── instruction_memory.sv
│   ├── pc.sv
│   └── registers_unit.sv
│
├── tb/                # Testbenches
│   ├── alu_tb.sv
│   ├── branch_unit_tb.sv
│   ├── cpu_top_tb.sv
│   ├── cu_tb.sv
│   ├── datamemory_tb.sv
│   ├── immediategenerator_tb.sv
│   ├── instruction_memory_tb.sv
│   ├── pc_tb.sv
│   └── registers_unit_tb.sv
│
├── instrucciones_verilog.mem        # Programa usado por la CPU
├── sim_files.f                      # Archivo opcional para simulación
├── .gitignore                       # Ignora archivos .vcd y .vvp
└── README.md
```
Nota:
Los archivos generados por simulación como .vcd (señales) y .vvp (binario de simulación) sí fueron generados dentro de una carpeta "sim/", pero no aparecen en el repositorio porque están incluidos en .gitignore, lo cual es una práctica recomendada para evitar subir archivos pesados o temporales generados automáticamente.

  
## Cómo compilar y simular

La simulación se realizó en Visual Studio Code usando el complemento WaveTrace, que integra:

- Compilación con Icarus Verilog

- Ejecución con vvp

- Visualizador de señales .vcd

**_1. Compilar la simulación_**

Ubicarse en la carpeta principal del proyecto y ejecutar: 

**iverilog -g2012 -o sim/cpu_top_tb.vvp -f sim_files.f**

**_2. Ejecutar la simulación_**

con:<br>
**vvp sim\cpu_top_tb.vvp** <br>
(Esto generará automáticamente un archivo cpu_top_tb.vpp y un archivo cpu_top_tb.vcd donde se pueden visualizar las señales generadas)


## Síntesis y prueba física en FPGA (Quartus Prime)

La implementación física se realizó en la DE1-SoC, utilizando Quartus Prime.

El flujo seguido fue:

**1. Crear un proyecto nuevo en Quartus**

Importar todos los archivos del directorio src/.

**2. Seleccionar el Top Level**
cpu_top.sv

**3. Asignar pines según el manual de la DE1-SoC**
- Señal	FPGA
- CLOCK_50	PIN del reloj de 50 MHz
- KEY: Botones KEY[0] y KEY[1]
- SW: Switches SW[0]-SW[3]
- HEX0–HEX5:	Displays de 7 segmentos

**4. Compilar con "Start Compilation"**

Quartus sintetizará todo el procesador y generará el archivo .sof.

**5. Cargar el diseño a la FPGA**

Usar Quartus Programmer:

- Seleccionar el archivo .sof

- Cargar en la FPGA

**6. Ejecución del programa en hardware real**

El procesador ejecuta automáticamente el contenido de "instrucciones_verilog.mem" donde está contenido el programa y los resultados se visualizan en los displays 7 segmentos según la programación de los switches y botones.


## Dependencias

- Icarus Verilog

- WaveTrace (extensión de VS Code)

- Visual Studio Code

- Quartus Prime Lite

- FPGA DE1-SoC

## Reproducción de Resultados
Para reproducir los resultados se debe: 

1. Clonar el repositorio.
2. Abrirlo en VS Code.
3. Compilar y simular con WaveTrace.
4. Modificar instrucciones_verilog.mem según el programa deseado.
5. Sintetizar en Quartus y cargar el .sof en la DE1-SoC.
6. Observar el comportamiento en los displays HEX y entradas físicas.



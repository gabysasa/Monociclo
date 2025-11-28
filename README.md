# Proyecto CPU RISC-V en Verilog

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

_1. Compilar la simulación_

Ubicarse en la carpeta principal del proyecto y ejecutar: 

<dd>iverilog -g2012 -o sim/cpu_top_tb.vvp -f sim_files.f</dd>

_2.Ejecutar la simulación_

con:
vvp sim\cpu_top_tb.vvp
(Esto generará automáticamente un archivo cpu_top_tb.vpp y un archivo cpu_top_tb.vcd donde se pueden visualizar las señales generadas)






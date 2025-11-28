## Decisiones de diseño principales:

**1. Correspondencia nombre de archivo ↔ nombre de módulo:**
Inicialmente algunos archivos tenían nombres diferentes al de su módulo interno, lo que generaba confusión y advertencias en herramientas de simulación.
Se decidió uniformar los nombres, manteniendo:

 archivo.sv  ==  nombre_del_modulo 
 
Esto mejoró la organización y permitió una integración más limpia en sim_files.f y en Quartus.

**2. Carga de instrucciones desde archivo:**

Se optó por usar un archivo externo .mem, llamado:

instrucciones_verilog.mem <bd>

y cargado dentro de instruction_memory usando:

**$readmemh("instrucciones_verilog.mem", mem);**<bd>

Esto permitió modificar programas sin recompilar la CPU.

**3.Formato VCD ignorado en git**

Los archivos .vcd y .vvp se agregaron al .gitignore porque:
- Son generados automáticamente.
- Son pesados.
- No aportan información útil al repositorio.

## Cambios realizados durante el desarrollo

**1. Corrección de nombres inconsistentes:** <bd>

Durante el desarrollo, se identificó que algunos módulos estaban declarados con nombres distintos a sus archivos correspondientes.
Esto se corrigió archivo por archivo, renombrando tanto el archivo ó módulo para mantener coherencia total. <bd>

_Ejemplo del cambio realizado:_<bd>

Antes: <bd>

**registers.sv → módulo register_file_v2** <bd>


Ahora: <bd>

**register_file.sv → módulo register_file**


**2. Evolución del diseño del cpu_top** <bd>

 _Versión 1 / implementación mínima:_
 
  La primera versión mostraba únicamente el Program Counter (PC), útil para hacer una validación básica.

 _Versión 2 / versión extendida:_

Se integraron más señales internas para depuración:<bd>

- PC
- instrucción actual
- señales de control (BrOp, DMWr, RUWr, ALUOp)
- outputs del ALU
- valores de registros
  
y se realizaron las adaptaciones para FPGA.


`timescale 1ns / 1ps
module instruction_memory_tb();

    reg  [31:0] addr;
    wire [31:0] instruction;

    // Instanciamos el módulo bajo prueba
    instruction_memory uut(
        .addr(addr),
        .instruction(instruction)
    );

    initial begin
        $dumpfile("instruction_memory_tb.vcd");
        $dumpvars(0, instruction_memory_tb);

        // Inicialización
        addr = 0;
        #10;

        // Hacemos varias lecturas
        $display("ADDR: %h  -> INSTR: %b", addr, instruction);

        addr = 4;
        #10;
        $display("ADDR: %h  -> INSTR: %b", addr, instruction);

        addr = 8;
        #10;
        $display("ADDR: %h  -> INSTR: %b", addr, instruction);

        addr = 12;
        #10;
        $display("ADDR: %h  -> INSTR: %b", addr, instruction);

        addr = 16;
        #10;
        $display("ADDR: %h  -> INSTR: %b", addr, instruction);

        addr = 20;
        #10;
        $display("ADDR: %h  -> INSTR: %b", addr, instruction);

        #20;
        $finish;
    end

endmodule

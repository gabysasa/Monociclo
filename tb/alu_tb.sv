`timescale 1ns/1ps

module ALU_tb;

    // Cables de conexión con el módulo
    logic signed [31:0] A, B;
    logic [3:0] ALUOp;
    logic signed [31:0] ALURes;

    // Instancia de la ALU (conexión al módulo real)
    ALU dut (
        .A(A),
        .B(B),
        .ALUOp(ALUOp),
        .ALURes(ALURes)
    );

    // Generación de archivo VCD para visualizar ondas
    initial begin
        $dumpfile("sim/alu_tb.vcd");   // guarda el archivo en la carpeta sim
        $dumpvars(0, ALU_tb);          // registra todas las señales
    end

 // Muestra por consola los valores cada vez que cambian
    initial begin
        $monitor("t=%0t | A=%0d | B=%0d | ALUOp=%b | ALURes=%0d", $time, A, B, ALUOp, ALURes);
    end

    // Pruebas básicas
    initial begin
        // ADD
        A = 0;  B = 0;  ALUOp = 4'b0000; #10;  
        // ADD
        A = 3;  B = 5;  ALUOp = 4'b0000; #10;  
        // SUB
        A = 3;  B = 5;  ALUOp = 4'b1000; #10;  
        // SLL
        A = 1;  B = 2;  ALUOp = 4'b0001; #10;  
        // SLT
        A = -2; B = 3;  ALUOp = 4'b0010; #10;  
        // SLTU
        A = 2;  B = 3;  ALUOp = 4'b0011; #10;  

        #10 $finish; // termina simulación
    end

endmodule

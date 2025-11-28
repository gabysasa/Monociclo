`timescale 1ns / 1ps

module cpu_top_tb;

    // Entradas
    reg CLOCK_50;
    reg [3:0] KEY;
    reg [3:0] SW;

    // Salidas
    wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    // DUT
    cpu_top DUT (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SW(SW),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );

    //-----------------------------------------------------------
    // Generación del CLOCK_50 (50 MHz → periodo 20 ns)
    //-----------------------------------------------------------
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
    $dumpfile("cpu_top_tb.vcd");
    $dumpvars(0, cpu_top_tb);
    end


    //-----------------------------------------------------------
    // TAREA para generar pulso en KEY[1] (reloj manual)
    //-----------------------------------------------------------
    task pulse_manual_clock;
    begin
        KEY[1] = 1;
        #5;
        KEY[1] = 0; // flanco de bajada → clk_manual
        #5;
        KEY[1] = 1;
        #20;
    end
    endtask

    //-----------------------------------------------------------
    // MONITOR para ver evolución del PC e instrucción
    //-----------------------------------------------------------
    initial begin
        $display("TIME\tPC\tInstruction\tHEX0");
        $monitor("%g\t%h\t%h\t%b",
                  $time,
                  DUT.pc,
                  DUT.instr,
                  HEX0);
    end

    //-----------------------------------------------------------
    // SECUENCIA PRINCIPAL
    //-----------------------------------------------------------
    initial begin
        // --------- Inicialización ----------
        KEY = 4'b1111;   // KEY[0]=1 → RESET INACTIVO
        SW  = 3'b000;    // Mostrar PC

        // Activa reset por 2 ciclos
        #20;
        KEY[0] = 0;      // RESET ACTIVO
        #40;
        KEY[0] = 1;      // RESET FUERA

        //-------------------------------------------------------
        // Ejecutar varias instrucciones con reloj manual
        //-------------------------------------------------------

        pulse_manual_clock();  // PC = 0
        pulse_manual_clock();  // PC = 4
        pulse_manual_clock();  // PC = 8
        pulse_manual_clock();  // PC = 12
        pulse_manual_clock();  // PC = 16
        pulse_manual_clock();  // PC = 20
        pulse_manual_clock();  // PC = 24
        pulse_manual_clock();  // PC = 28
        pulse_manual_clock();  // PC = 32
        pulse_manual_clock();  // PC = 36

        //-------------------------------------------------------
        // Mostrar instrucción completa en displays
        //-------------------------------------------------------
        SW = 3'b001; // Parte baja de la instrucción
        #100;

        SW = 3'b010; // Parte alta de la instrucción
        #100;

        SW = 3'b011; // Mostrar Rs1 y Rs2
        #100;

        SW = 3'b100; // Immediate y ALUOp
        #100;

        SW = 3'b101; // ALU result y RUWr
        #100;

        //-------------------------------------------------------
        // Termina simulación
        //-------------------------------------------------------
        #200;
        $finish;
    end

endmodule

`timescale 1ns/1ps
module registers_unit_tb();

    reg clk;
    reg RUWr;
    reg [4:0] Rs1, Rs2, Rd;
    reg [31:0] DataWr;
    wire [31:0] RURs1;
    wire [31:0] RURs2;

    // Instancia del módulo
    registers_unit uut (
        .clk(clk),
        .RUWr(RUWr),
        .Rs1(Rs1),
        .Rs2(Rs2),
        .Rd(Rd),
        .DataWr(DataWr),
        .RURs1(RURs1),
        .RURs2(RURs2)
    );

    // Clock: 100 MHz
    always #5 clk = ~clk;

    initial begin
        $dumpfile("registers_unit_tb.vcd");
        $dumpvars(0, registers_unit_tb);

        $display("=== INICIO TESTBENCH DE UNIDAD DE REGISTROS ===");

        clk = 0;
        RUWr = 0;
        Rs1 = 0;
        Rs2 = 0;
        Rd = 0;
        DataWr = 0;

        #10;

        // Comprobar que x0 siempre es 0
        Rs1 = 0;
        Rs2 = 0;
        #1;
        $display("Leer R0 → RURs1=%d RURs2=%d (esperado 0 y 0)", RURs1, RURs2);

        // Comprobar que R2 tiene 1024 desde initial
        Rs1 = 2;
        Rs2 = 0;
        #1;
        $display("Leer R2 → %d (esperado 1024)", RURs1);

        // =============================
        // ESCRIBIR EN UN REGISTRO
        // Rd = 5, DataWr = 123
        // =============================
        RUWr = 1;
        Rd = 5;
        DataWr = 32'd123;
        #10; // posedge clk para escribir

        RUWr = 0;
        Rs1 = 5;
        #1;
        $display("Leer R5 → %d (esperado 123)", RURs1);

        // =============================
        // FORWARDING!
        // Rs1 = Rd antes del flanco de reloj
        // =============================
        Rs1 = 10;     
        Rs2 = 0;
        RUWr = 1;
        Rd = 10;
        DataWr = 999;
        #1; // aún no ha llegado flanco de clk

        // Aquí el valor sale por forwarding directo
        $display("FORWARDING inmediato → RURs1=%d (esperado 999)", RURs1);

        // ahora hacer el flanco de clk real
        #10; // posedge
        RUWr = 0;

        // ahora leer desde banco de registros
        Rs1 = 10;
        Rs2 = 0;
        #1;
        $display("Leer R10 después de write → %d (esperado 999)", RURs1);

        // =============================
        // Intento de escribir a x0 — NO DEBE ESCRIBIR
        // =============================
        RUWr = 1;
        Rd = 0;
        DataWr = 777;
        #10; // posedge
        RUWr = 0;

        Rs1 = 0;
        #1;
        $display("Leer R0 (intentando escribir 777) → %d (esperado 0)", RURs1);

        $display("=== FIN SIMULACIÓN ===");
        $finish;
    end

endmodule

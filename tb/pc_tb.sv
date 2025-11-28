`timescale 1ns / 1ps
module pc_tb();

    reg clk;
    reg rst;
    reg [31:0] pc_in;
    wire [31:0] pc_out;

    // Instanciamos el módulo PC
    pc uut (
        .clk(clk),
        .rst(rst),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    // Reloj 100 MHz
    always #5 clk = ~clk;

    initial begin
        $dumpfile("pc_tb.vcd");
        $dumpvars(0, pc_tb);

        $display("=== INICIO SIMULACIÓN PC ===");

        clk = 0;
        rst = 1;
        pc_in = 32'h0;
        #20;

        $display("[RESET] pc_out = %h (esperado 00000000)", pc_out);

        rst = 0;

        // Ejecutando instrucciones secuenciales normales (suma 4)
        pc_in = 32'h00000004;  #10;
        $display("pc_out = %h", pc_out);

        pc_in = 32'h00000008;  #10;
        $display("pc_out = %h", pc_out);

        pc_in = 32'h0000000C;  #10;
        $display("pc_out = %h", pc_out);

        pc_in = 32'h00000010;  #10;
        $display("pc_out = %h", pc_out);

        // Simulando un salto / branch real
        pc_in = 32'h00000040;  #10;
        $display("[JUMP/BRANCH] pc_out = %h (debería saltar a 0x40)", pc_out);

        // Continúa ejecución normal
        pc_in = 32'h00000044; #10;
        $display("pc_out = %h", pc_out);

        pc_in = 32'h00000048; #10;
        $display("pc_out = %h", pc_out);

        // Reset durante ejecución
        rst = 1; #10;
        $display("[RESET DURANTE EJECUCIÓN] pc_out = %h (esperado 00000000)", pc_out);
        rst = 0;

        // Ejecución después del reset
        pc_in = 32'h00000004; #10;
        $display("pc_out = %h", pc_out);

        pc_in = 32'h00000008; #10;
        $display("pc_out = %h", pc_out);

        pc_in = 32'h0000000C; #10;
        $display("pc_out = %h", pc_out);

        $display("=== FIN SIMULACIÓN PC ===");
        $finish;
    end

endmodule


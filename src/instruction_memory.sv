`timescale 1ns / 1ps
module instruction_memory(
    input  wire [31:0] addr,          // Dirección de byte
    output reg  [31:0] instruction
);
    // Memoria de 256 palabras (cada una de 32 bits)
    reg [31:0] mem [0:255];

    initial begin
        // Lee el archivo binario con una instrucción (32 bits) por línea
        $readmemb("instrucciones_verilog.mem", mem);
        instruction = 32'b0;
    end

    always @(*) begin
        // Tomar la dirección alineada a palabra (dividir addr entre 4)
        instruction = mem[addr[9:2]];
    end
endmodule


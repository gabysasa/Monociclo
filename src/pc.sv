`timescale 1ns / 1ps
module pc(
    input  wire clk,
    input  wire rst,
    input  wire [31:0] pc_in,
    output reg  [31:0] pc_out
);

    // Reset síncrono/asincrono: aquí uso asincrono para que reset sea inmediato
    always @(posedge clk or posedge rst) begin
        if (rst)
            pc_out <= 32'h00000000;
        else
            pc_out <= pc_in;
    end
endmodule
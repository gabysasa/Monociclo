`timescale 1ns / 1ps
module ALU(
  input  logic signed [31:0] A,
  input  logic signed [31:0] B,
  input  logic       [3:0]  ALUOp,
  output logic signed [31:0] ALURes
);

  always_comb begin
    // default
    ALURes = 32'sd0;
    case(ALUOp)
      4'b0000 : ALURes = A + B;                             // ADD
      4'b1000 : ALURes = A - B;                             // SUB
      4'b0001 : ALURes = A <<< (B[4:0]);                    // SLL (mask shift)
      4'b0010 : ALURes = (A < B) ? 32'sd1 : 32'sd0;         // SLT (signed)
      4'b0011 : ALURes = ($unsigned(A) < $unsigned(B)) ? 32'd1 : 32'd0; // SLTU
      4'b0100 : ALURes = A ^ B;                             // XOR
      4'b0101 : ALURes = $unsigned(A) >> (B[4:0]);         // SRL logical
      4'b1101 : ALURes = A >>> (B[4:0]);                    // SRA arithmetic
      4'b0110 : ALURes = A | B;                             // OR
      4'b0111 : ALURes = A & B;                             // AND
      4'b1001 : ALURes = B;                                 // pass B (uso interno)
      default : ALURes = 32'sd0;
    endcase
  end
endmodule

`timescale 1ns / 1ps
module branch_unit (
    input  wire [4:0]  BrOp,
    input  wire [31:0] A,
    input  wire [31:0] B,
    output reg         NextPCSrc
);
    always @(*) begin
        // default
        NextPCSrc = 1'b0;
        if (BrOp[4] == 1'b1) begin
            // saltos incondicionales JAL/JALR
            NextPCSrc = 1'b1;
        end else if (BrOp[4:3] == 2'b00) begin
            NextPCSrc = 1'b0;
        end else begin
            case (BrOp)
                5'b01000: NextPCSrc = (A == B);                     // BEQ
                5'b01001: NextPCSrc = (A != B);                     // BNE
                5'b01100: NextPCSrc = ($signed(A) < $signed(B));    // BLT
                5'b01101: NextPCSrc = ($signed(A) >= $signed(B));   // BGE
                5'b01110: NextPCSrc = (A < B);                      // BLTU
                5'b01111: NextPCSrc = (A >= B);                     // BGEU
                default:  NextPCSrc = 1'b0;
            endcase
        end
    end
endmodule

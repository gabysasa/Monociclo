`timescale 1ns / 1ps
module immediate_generator(
    input  wire [24:0] instruction_31_7, // instruction[31:7] (25 bits)
    input  wire [2:0]  ImmSrc,
    output reg  [31:0] imm_ext
);
    always @* begin
        imm_ext = 32'h0;
        case (ImmSrc)
            3'b000: begin // I-type (12 bits) -> instruction[24:13]
                // imm[11:0] = instruction[24:13]
                imm_ext[11:0] = instruction_31_7[24:13];
                imm_ext[31:12] = {20{imm_ext[11]}};
            end
            3'b001: begin // S-type (12 bits) -> imm[11:0] = instr[24:18] ++ instr[4:0]
                imm_ext[11:0] = { instruction_31_7[24:18], instruction_31_7[4:0] };
                imm_ext[31:12] = {20{imm_ext[11]}};
            end
            3'b010: begin // U-type (20 bits) -> instruction[24:5]
                imm_ext[31:12] = instruction_31_7[24:5];
                imm_ext[11:0]  = 12'h000;
            end
            3'b101: begin // B-type branch (imm[12|10:5|4:1|0])
                imm_ext[12:0] = { instruction_31_7[24], instruction_31_7[0], instruction_31_7[23:18], instruction_31_7[4:1], 1'b0 };
                imm_ext[31:13] = {19{imm_ext[12]}};
            end
            3'b110: begin // J-type (imm[20|10:1|11|19:12])
                imm_ext[20:0] = { instruction_31_7[24], instruction_31_7[12:5], instruction_31_7[13], instruction_31_7[23:14], 1'b0 };
                imm_ext[31:21] = {11{imm_ext[20]}};
            end
            default: imm_ext = 32'h0;
        endcase
    end
endmodule

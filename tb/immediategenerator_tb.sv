`timescale 1ns / 1ps

module immediategenerator_tb;

    reg  [24:0] instruction_31_7;
    reg  [2:0]  ImmSrc;
    wire [31:0] imm_ext;

    // Instancia del DUT
    immediategenerator uut (
        .instruction_31_7(instruction_31_7),
        .ImmSrc(ImmSrc),
        .imm_ext(imm_ext)
    );

    initial begin
    $dumpfile("sim/immediategenerator_tb.vcd");
    $dumpvars(0, immediategenerator_tb);
    end

    initial begin
        // I-type
        ImmSrc = 3'b000;
        instruction_31_7 = 25'b1_00000000000_000000000000;
        #10;

        // S-type
        ImmSrc = 3'b001;
        instruction_31_7 = 25'b1010101_00000000000_11111;
        #10;

        // U-type
        ImmSrc = 3'b010;
        instruction_31_7 = 25'hABCDE;
        #10;

        // B-type
        ImmSrc = 3'b101;
        instruction_31_7 = 25'b1_000001_0001_000001_0;
        #10;

        // J-type  **(ESTE ES EL QUE NO TE APARECE)**
        ImmSrc = 3'b110;
        instruction_31_7 = 25'b1_00000000_1_1111111111;
        #10;   // Delay obligatorio para que aparezca en VCD

        #20;
        $finish;
    end
endmodule
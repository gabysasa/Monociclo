`timescale 1ns/1ps

module cu_tb;

    // Entradas
    reg [6:0] OpCode;
    reg [2:0] Funct3;
    reg [6:0] Funct7;

    // Salidas
    wire [4:0] BrOp;
    wire [2:0] DMCtrl;
    wire DMWr;
    wire [3:0] ALUOp;
    wire ALUASrc, ALUBSrc;
    wire RUWr;
    wire [1:0] RUDataWrSrc;
    wire [2:0] ImmSrc;

    // Instancia del módulo CU
    cu dut (
        .OpCode(OpCode),
        .Funct3(Funct3),
        .Funct7(Funct7),
        .BrOp(BrOp),
        .DMCtrl(DMCtrl),
        .DMWr(DMWr),
        .ALUOp(ALUOp),
        .ALUASrc(ALUASrc),
        .ALUBSrc(ALUBSrc),
        .RUWr(RUWr),
        .RUDataWrSrc(RUDataWrSrc),
        .ImmSrc(ImmSrc)
    );

    initial begin
        $dumpfile("sim/cu_tb.vcd");
        $dumpvars(0, cu_tb);

        $display("=== Iniciando testbench de CU ===");

        // =========================
        // 1. Tipo R (ADD)
        // =========================
        OpCode = 7'b0110011; Funct3 = 3'b000; Funct7 = 7'b0000000; #5;
        $display("\n[TEST] Tipo R (ADD)");
        if (RUWr !== 1'b1 || ALUASrc !== 1'b0 || ALUBSrc !== 1'b0)
            $error(" Error en señales tipo R");
        else
            $display("Señales correctas para tipo R");

        // =========================
        // 2. Tipo I (ADDI)
        // =========================
        OpCode = 7'b0010011; Funct3 = 3'b000; Funct7 = 7'b0000000; #5;
        $display("\n[TEST] Tipo I (ADDI)");
        if (RUWr !== 1'b1 || ALUBSrc !== 1'b1 || ImmSrc !== 3'b000)
            $error("Error en señales tipo I");
        else
            $display("Señales correctas para tipo I");

        // =========================
        // 3. LOAD (LW)
        // =========================
        OpCode = 7'b0000011; Funct3 = 3'b010; #5;
        $display("\n[TEST] LOAD (LW)");
        if (RUWr !== 1'b1 || DMWr !== 1'b0 || RUDataWrSrc !== 2'b01)
            $error("Error en señales LOAD");
        else
            $display("Señales correctas para LOAD");

        // =========================
        // 4. STORE (SW)
        // =========================
        OpCode = 7'b0100011; Funct3 = 3'b010; #5;
        $display("\n[TEST] STORE (SW)");
        if (DMWr !== 1'b1 || RUWr !== 1'b0)
            $error("Error en señales STORE");
        else
            $display("Señales correctas para STORE");

        // =========================
        // 5. BRANCH (BEQ)
        // =========================
        OpCode = 7'b1100011; Funct3 = 3'b000; #5;
        $display("\n[TEST] BRANCH (BEQ)");
        if (BrOp[4:3] !== 2'b01 || RUWr !== 1'b0)
            $error(" Error en señales BRANCH");
        else
            $display("Señales correctas para BRANCH");

        // =========================
        // 6. JUMP (JAL)
        // =========================
        OpCode = 7'b1101111; #5;
        $display("\n[TEST] JAL");
        if (RUWr !== 1'b1 || BrOp[4] !== 1'b1 || RUDataWrSrc !== 2'b10)
            $error(" Error en señales JAL");
        else
            $display(" Señales correctas para JAL");

        // =========================
        // 7. LUI
        // =========================
        OpCode = 7'b0110111; #5;
        $display("\n[TEST] LUI");
        if (RUWr !== 1'b1 || ImmSrc !== 3'b010)
            $error(" Error en señales LUI");
        else
            $display(" Señales correctas para LUI");

        // =========================
        // 8. AUIPC
        // =========================
        OpCode = 7'b0010111; #5;
        $display("\n[TEST] AUIPC");
        if (RUWr !== 1'b1 || ALUASrc !== 1'b1)
            $error(" Error en señales AUIPC");
        else
            $display(" Señales correctas para AUIPC");

        $display("\n=== Testbench finalizado correctamente ===");
        $finish;
    end

endmodule

module cu(
    input  wire [6:0] OpCode,   // Código de operación principal
    input  wire [2:0] Funct3,   // Campo funct3 (para operaciones ALU)
    input  wire [6:0] Funct7,   // Campo funct7 (para distinguir operaciones)
    
    output reg [4:0] BrOp,      // Control de ramas y saltos
    output reg [2:0] DMCtrl,    // Control de acceso a memoria
    output reg       DMWr,      // Escritura en memoria de datos
    output reg [3:0] ALUOp,     // Operación de la ALU
    output reg       ALUASrc,   // Fuente A para ALU
    output reg       ALUBSrc,   // Fuente B para ALU
    output reg       RUWr,      // Escritura en banco de registros
    output reg [1:0] RUDataWrSrc, // Fuente de datos para RU
    output reg [2:0] ImmSrc     // Tipo de inmediato
);

always @(*) begin
    // Valores por defecto para evitar latches
    BrOp        = 5'b00000;
    DMCtrl      = 3'b000;
    DMWr        = 1'b0;
    ALUOp       = 4'b0000;
    ALUASrc     = 1'b0;
    ALUBSrc     = 1'b0;
    RUWr        = 1'b0;
    RUDataWrSrc = 2'b00;
    ImmSrc      = 3'b000;

    case (OpCode)
        // =============================
        // Tipo R (operaciones ALU reg-reg)
        // =============================
        7'b0110011: begin
            ALUOp = (Funct7 == 7'b0000001 && Funct3 == 3'b000) ? 4'b1001 : {Funct7[5], Funct3};
            RUWr = 1'b1;
            ALUASrc = 1'b0;
            ALUBSrc = 1'b0;
            RUDataWrSrc = 2'b00;
        end

        // =============================
        // Tipo I (operaciones ALU reg-inmediato)
        // =============================
        7'b0010011: begin
            ALUOp = (Funct3 == 3'b101) ? {Funct7[5], Funct3} : {1'b0, Funct3};
            RUWr = 1'b1;
            ALUASrc = 1'b0;
            ALUBSrc = 1'b1;
            RUDataWrSrc = 2'b00;
            ImmSrc = 3'b000;
        end

        // =============================
        // Tipo I (carga desde memoria)
        // =============================
        7'b0000011: begin
            ALUOp = 4'b0000; // Suma para calcular dirección
            RUWr = 1'b1;
            ALUASrc = 1'b0;
            ALUBSrc = 1'b1;
            ImmSrc = 3'b000;
            DMCtrl = Funct3;
            DMWr = 1'b0;
            RUDataWrSrc = 2'b01; // Datos vienen de memoria
        end

        // =============================
        // Tipo S (almacenamiento en memoria)
        // =============================
        7'b0100011: begin
            ALUOp = 4'b0000;
            RUWr = 1'b0;
            ALUASrc = 1'b0;
            ALUBSrc = 1'b1;
            ImmSrc = 3'b001;
            DMCtrl = Funct3;
            DMWr = 1'b1; // Escribe en memoria
        end

        // =============================
        // Tipo B (ramas condicionales)
        // =============================
        7'b1100011: begin
            ALUOp = 4'b0000;
            RUWr = 1'b0;
            ALUASrc = 1'b1;
            ALUBSrc = 1'b1;
            ImmSrc = 3'b101;
            BrOp = {2'b01, Funct3}; // Define el tipo de rama
        end

        // =============================
        // Tipo J (JAL - salto incondicional)
        // =============================
        7'b1101111: begin
            ALUOp = 4'b0000;
            RUWr = 1'b1;
            ALUASrc = 1'b1;
            ALUBSrc = 1'b1;
            ImmSrc = 3'b110;
            BrOp = 5'b10000;
            RUDataWrSrc = 2'b10; // PC + 4
        end

        // =============================
        // Tipo I (JALR - salto con registro)
        // =============================
        7'b1100111: begin
            ALUOp = 4'b0000;
            RUWr = 1'b1;
            ALUASrc = 1'b0;
            ALUBSrc = 1'b1;
            ImmSrc = 3'b000;
            BrOp = 5'b10000;
            RUDataWrSrc = 2'b10;
        end

        // =============================
        // Tipo U (LUI)
        // =============================
        7'b0110111: begin
            ALUOp = 4'b1111; // Operación especial para LUI
            RUWr = 1'b1;
            ALUASrc = 1'b0;
            ALUBSrc = 1'b1;
            ImmSrc = 3'b010;
            RUDataWrSrc = 2'b00;
        end

        // =============================
        // Tipo U (AUIPC)
        // =============================
        7'b0010111: begin
            ALUOp = 4'b0000;
            RUWr = 1'b1;
            ALUASrc = 1'b1; // Usa PC como operando A
            ALUBSrc = 1'b1;
            ImmSrc = 3'b010;
            RUDataWrSrc = 2'b00;
        end

        // =============================
        // Por defecto
        // =============================
        default: begin
            // Tod0s los valores ya están en su estado por defecto
        end
    endcase
end

endmodule
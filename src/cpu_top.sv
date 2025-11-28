`timescale 1ns / 1ps
module cpu_top (
    input  wire        clk,
    input  wire        rst
);
    // Wires principales
    wire [31:0] pc, pc_next, pc_plus4, instr;
    wire [31:0] imm_ext;
    wire [31:0] reg_rs1, reg_rs2;
    wire [31:0] alu_a, alu_b, alu_res;
    wire [31:0] data_rd;
    wire [31:0] write_back_data;
    wire [6:0]  opcode;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [4:0]  BrOp;
    wire [2:0]  DMCtrl;
    wire        DMWr;
    wire [3:0]  ALUOp;
    wire        ALUASrc, ALUBSrc, RUWr;
    wire [1:0]  RUDataWrSrc;
    wire [2:0]  ImmSrc;
    wire        branch_taken;

    // PC
    pc PC (
        .clk(clk),
        .rst(rst),
        .pc_in(pc_next),
        .pc_out(pc)
    );

    // Instruction memory (reads instr at pc)
    instruction_memory IM (
        .addr(pc),
        .instruction(instr)
    );

    // Decode fields
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    // Control Unit (se espera que el módulo se llame CU y tenga estas señales)
    cu CU_u (
    .OpCode(opcode),
    .Funct3(funct3),
    .Funct7(funct7),
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

    // Immediate generator: le pasamos instr[31:7] (25 bits)
    immediategenerator IMM (
        .instruction_31_7(instr[31:7]),
        .ImmSrc(ImmSrc),
        .imm_ext(imm_ext)
    );

    // Register file (Rs1 = instr[19:15], Rs2 = instr[24:20], Rd = instr[11:7])
    registers_unit RF (
        .clk(clk),
        .RUWr(RUWr),
        .Rs1(instr[19:15]),
        .Rs2(instr[24:20]),
        .Rd(instr[11:7]),
        .DataWr(write_back_data),
        .RURs1(reg_rs1),
        .RURs2(reg_rs2)
    );

    // ALU operands selection
    assign alu_a = (ALUASrc) ? pc : reg_rs1;
    assign alu_b = (ALUBSrc) ? imm_ext : reg_rs2;

    // ALU
    ALU ALU_u (
        .A(alu_a),
        .B(alu_b),
        .ALUOp(ALUOp),
        .ALURes(alu_res)
    );

    // Data memory
    datamemory DM (
        .clk(clk),
        .DMWr(DMWr),
        .DMCtrl(DMCtrl),
        .addr(alu_res),      // dirección calculada por ALU
        .DataWr(reg_rs2),
        .DataRd(data_rd)
    );

    // Branch unit: decide si tomar o no la ruta
    branch_unit BRU (
        .BrOp(BrOp),
        .A(reg_rs1),
        .B(reg_rs2),
        .NextPCSrc(branch_taken)
    );

    // PC + 4
    assign pc_plus4 = pc + 32'd4;

    // Next PC mux:
    // - if branch_taken: for JALR use (reg_rs1 + imm_ext) & ~1, else (pc + imm_ext)
    wire [31:0] jalr_target;
    assign jalr_target = (reg_rs1 + imm_ext) & ~32'd1;
    wire is_jalr = (opcode == 7'b1100111);

    assign pc_next = (branch_taken) ?
                        ((is_jalr) ? jalr_target : (pc + imm_ext)) :
                        pc_plus4;

    // Write-back multiplexer (RUDataWrSrc):
    // 00 = ALU result
    // 01 = Data memory (load)
    // 10 = PC + 4 (for JAL/JALR)
    assign write_back_data = (RUDataWrSrc == 2'b00) ? alu_res :
                             (RUDataWrSrc == 2'b01) ? data_rd :
                             (RUDataWrSrc == 2'b10) ? pc_plus4 :
                             32'h0;

    // DMWr must be driven by CU; we connect DMCtrl as well (CU must provide them)
    // If your CU does not provide DMWr and DMCtrl, adapta la instancia de CU.
    // Aquí asumimos DMWr y DMCtrl salientes del CU; si no, conéctalas en CU.

endmodule

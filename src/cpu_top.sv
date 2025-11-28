`timescale 1ns / 1ps

module cpu_top (
    input  wire CLOCK_50,        
    input  wire [3:0] KEY,       // KEY[0]=reset, KEY[1]=clock manual
    input  wire [3:0] SW,        // SW[2:0] para seleccionar qué mostrar
    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3, 
    output wire [6:0] HEX4,
    output wire [6:0] HEX5
);

  
    // Detectar flanco de bajada en KEY[1] (cuando se presiona)
    reg key1_prev;
    wire clk_manual;
    
    always @(posedge CLOCK_50) begin
        key1_prev <= KEY[1];
    end
    
    // Genera un pulso cuando KEY[1] pasa de alto a bajo (presionado)
    assign clk_manual = key1_prev & ~KEY[1];
    
    wire clk = clk_manual;        // Reloj manual con KEY[1]
    wire rst = ~KEY[0];           // Reset con KEY[0] (activo bajo)

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

    // Instruction memory
    instruction_memory IM (
        .addr(pc),
        .instruction(instr)
    );

    // Decode fields
    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    // Control Unit
    cu CU_u (
        .OpCode(opcode),
        .Funct3(funct3),
        .Funct7(funct7),
        .ImmSrc(ImmSrc),
        .ALUASrc(ALUASrc),
        .ALUBSrc(ALUBSrc),
        .ALUOp(ALUOp),
        .RUDataWrSrc(RUDataWrSrc),
        .RUWr(RUWr),
        .BrOp(BrOp),
		  .DMWr(DMWr),       
        .DMCtrl(DMCtrl)
    );

    // Immediate generator
    immediategenerator IMM (
        .instruction_31_7(instr[31:7]),
        .ImmSrc(ImmSrc),
        .imm_ext(imm_ext)
    );

    // Register file
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
        .addr(alu_res),
        .DataWr(reg_rs2),
        .DataRd(data_rd)
    ); 

    // Branch unit
    branch_unit BRU (
        .BrOp(BrOp),
        .A(reg_rs1),
        .B(reg_rs2),
        .NextPCSrc(branch_taken)
    );

    // PC + 4
    assign pc_plus4 = pc + 32'd4;

    // Next PC mux
    wire [31:0] jalr_target;
    assign jalr_target = (reg_rs1 + imm_ext) & ~32'd1;
    wire is_jalr = (opcode == 7'b1100111);

    assign pc_next = (branch_taken) ?
                        ((is_jalr) ? jalr_target : (pc + imm_ext)) :
                        pc_plus4;

    // Write-back multiplexer
    assign write_back_data = (RUDataWrSrc == 2'b00) ? alu_res :
                             (RUDataWrSrc == 2'b01) ? data_rd :
                             (RUDataWrSrc == 2'b10) ? pc_plus4 :
                             32'h0;

    //-------------------------------------------------------------
    // MULTIPLEXADO DE DISPLAYS SEGÚN SWITCHES
    //-------------------------------------------------------------
    // SW[2:0] selecciona qué mostrar:
    // 000 = PC (24 bits)
    // 001 = Instrucción bits 23:0 (parte baja)
    // 010 = Instrucción bits 31:8 (parte alta)
    // 011 = Rs1 (HEX2-0) y Rs2 (HEX5-3) - 12 bits cada uno
    // 100 = imm_ext (20 bits) + ALUOp en HEX5
    // 101 = alu_res (20 bits) + RUWr en HEX5
    // 110 = BrOp completo (HEX4-0) + DMWr en HEX5

    wire [3:0] disp0, disp1, disp2, disp3, disp4, disp5;

    // Caso 000: PC (24 bits)
    wire [3:0] pc_d0 = pc[3:0];
    wire [3:0] pc_d1 = pc[7:4];
    wire [3:0] pc_d2 = pc[11:8];
    wire [3:0] pc_d3 = pc[15:12];
    wire [3:0] pc_d4 = pc[19:16];
    wire [3:0] pc_d5 = pc[23:20];

    // Caso 001: Instrucción bits 23:0 (parte baja)
    wire [3:0] instr_low_d0 = instr[3:0];
    wire [3:0] instr_low_d1 = instr[7:4];
    wire [3:0] instr_low_d2 = instr[11:8];
    wire [3:0] instr_low_d3 = instr[15:12];
    wire [3:0] instr_low_d4 = instr[19:16];
    wire [3:0] instr_low_d5 = instr[23:20];

    // Caso 010: Instrucción bits 31:8 (parte alta)
    wire [3:0] instr_high_d0 = instr[11:8];
    wire [3:0] instr_high_d1 = instr[15:12];
    wire [3:0] instr_high_d2 = instr[19:16];
    wire [3:0] instr_high_d3 = instr[23:20];
    wire [3:0] instr_high_d4 = instr[27:24];
    wire [3:0] instr_high_d5 = instr[31:28];

    // Caso 011: Rs1 (HEX2-0) y Rs2 (HEX5-3) - 12 bits c/u
    wire [3:0] rs_d0 = reg_rs1[3:0];
    wire [3:0] rs_d1 = reg_rs1[7:4];
    wire [3:0] rs_d2 = reg_rs1[11:8];
    wire [3:0] rs_d3 = reg_rs2[3:0];
    wire [3:0] rs_d4 = reg_rs2[7:4];
    wire [3:0] rs_d5 = reg_rs2[11:8];

    // Caso 100: imm_ext (20 bits) + ALUOp en HEX5
    wire [3:0] imm_d0 = imm_ext[3:0];
    wire [3:0] imm_d1 = imm_ext[7:4];
    wire [3:0] imm_d2 = imm_ext[11:8];
    wire [3:0] imm_d3 = imm_ext[15:12];
    wire [3:0] imm_d4 = imm_ext[19:16];
    wire [3:0] imm_d5 = ALUOp;

    // Caso 101: alu_res (20 bits) + RUWr en HEX5
    wire [3:0] alu_d0 = alu_res[3:0];
    wire [3:0] alu_d1 = alu_res[7:4];
    wire [3:0] alu_d2 = alu_res[11:8];
    wire [3:0] alu_d3 = alu_res[15:12];
    wire [3:0] alu_d4 = alu_res[19:16];
    wire [3:0] alu_d5 = {3'b0, RUWr};

    // Caso 110: BrOp completo + DMWr
    wire [3:0] br_d0 = {3'b0, BrOp[0]};
    wire [3:0] br_d1 = {3'b0, BrOp[1]};
    wire [3:0] br_d2 = {3'b0, BrOp[2]};
    wire [3:0] br_d3 = {3'b0, BrOp[3]};
    wire [3:0] br_d4 = {3'b0, BrOp[4]};
    wire [3:0] br_d5 = {3'b0, DMWr};

    // Multiplexores finales
    assign disp0 = (SW[2:0] == 3'b000) ? pc_d0 :
                   (SW[2:0] == 3'b001) ? instr_low_d0 :
                   (SW[2:0] == 3'b010) ? instr_high_d0 :
                   (SW[2:0] == 3'b011) ? rs_d0 :
                   (SW[2:0] == 3'b100) ? imm_d0 :
                   (SW[2:0] == 3'b101) ? alu_d0 :
                   (SW[2:0] == 3'b110) ? br_d0 : pc_d0;

    assign disp1 = (SW[2:0] == 3'b000) ? pc_d1 :
                   (SW[2:0] == 3'b001) ? instr_low_d1 :
                   (SW[2:0] == 3'b010) ? instr_high_d1 :
                   (SW[2:0] == 3'b011) ? rs_d1 :
                   (SW[2:0] == 3'b100) ? imm_d1 :
                   (SW[2:0] == 3'b101) ? alu_d1 :
                   (SW[2:0] == 3'b110) ? br_d1 : pc_d1;

    assign disp2 = (SW[2:0] == 3'b000) ? pc_d2 :
                   (SW[2:0] == 3'b001) ? instr_low_d2 :
                   (SW[2:0] == 3'b010) ? instr_high_d2 :
                   (SW[2:0] == 3'b011) ? rs_d2 :
                   (SW[2:0] == 3'b100) ? imm_d2 :
                   (SW[2:0] == 3'b101) ? alu_d2 :
                   (SW[2:0] == 3'b110) ? br_d2 : pc_d2;

    assign disp3 = (SW[2:0] == 3'b000) ? pc_d3 :
                   (SW[2:0] == 3'b001) ? instr_low_d3 :
                   (SW[2:0] == 3'b010) ? instr_high_d3 :
                   (SW[2:0] == 3'b011) ? rs_d3 :
                   (SW[2:0] == 3'b100) ? imm_d3 :
                   (SW[2:0] == 3'b101) ? alu_d3 :
                   (SW[2:0] == 3'b110) ? br_d3 : pc_d3;

    assign disp4 = (SW[2:0] == 3'b000) ? pc_d4 :
                   (SW[2:0] == 3'b001) ? instr_low_d4 :
                   (SW[2:0] == 3'b010) ? instr_high_d4 :
                   (SW[2:0] == 3'b011) ? rs_d4 :
                   (SW[2:0] == 3'b100) ? imm_d4 :
                   (SW[2:0] == 3'b101) ? alu_d4 :
                   (SW[2:0] == 3'b110) ? br_d4 : pc_d4;

    assign disp5 = (SW[2:0] == 3'b000) ? pc_d5 :
                   (SW[2:0] == 3'b001) ? instr_low_d5 :
                   (SW[2:0] == 3'b010) ? instr_high_d5 :
                   (SW[2:0] == 3'b011) ? rs_d5 :
                   (SW[2:0] == 3'b100) ? imm_d5 :
                   (SW[2:0] == 3'b101) ? alu_d5 :
                   (SW[2:0] == 3'b110) ? br_d5 : pc_d5;

    // Instancias de decodificadores hex
    hex7seg h0(.hex(disp0), .segments(HEX0));
    hex7seg h1(.hex(disp1), .segments(HEX1));
    hex7seg h2(.hex(disp2), .segments(HEX2));
    hex7seg h3(.hex(disp3), .segments(HEX3));
    hex7seg h4(.hex(disp4), .segments(HEX4));
    hex7seg h5(.hex(disp5), .segments(HEX5));

endmodule
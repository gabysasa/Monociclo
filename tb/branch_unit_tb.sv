`timescale 1ns / 1ps

module branch_unit_tb;

    reg [4:0] BrOp;
    reg [31:0] A, B;
    wire NextPCSrc;
    
    // Instanciar módulo
    branch_unit uut (
        .BrOp(BrOp),
        .A(A),
        .B(B),
        .NextPCSrc(NextPCSrc)
    );

    initial begin
    $dumpfile("sim/branch_unit_tb.vcd");
    $dumpvars(0, branch_unit_tb);
    end
    
    initial begin
        $display("=== Branch Unit Test ===\n");
        
        // Test 1: JAL (salto incondicional)
        BrOp = 5'b10000; A = 32'h10; B = 32'h20; #10;
        $display("JAL: NextPCSrc=%b (esperado 1)", NextPCSrc);
        
        // Test 2: BEQ - iguales
        BrOp = 5'b01000; A = 32'h5; B = 32'h5; #10;
        $display("BEQ (A==B): NextPCSrc=%b (esperado 1)", NextPCSrc);
        
        // Test 3: BEQ - diferentes
        A = 32'h5; B = 32'h10; #10;
        $display("BEQ (A!=B): NextPCSrc=%b (esperado 0)", NextPCSrc);
        
        // Test 4: BNE
        BrOp = 5'b01001; A = 32'h5; B = 32'h10; #10;
        $display("BNE (A!=B): NextPCSrc=%b (esperado 1)", NextPCSrc);
        
        // Test 5: BLT (signed)
        BrOp = 5'b01100; A = 32'h5; B = 32'hA; #10;
        $display("BLT (5<10): NextPCSrc=%b (esperado 1)", NextPCSrc);
        
        // Test 6: BLT negativo
        A = 32'hFFFFFFFE; B = 32'h1; #10;
        $display("BLT (-2<1): NextPCSrc=%b (esperado 1)", NextPCSrc);
        
        // Test 7: BGE
        BrOp = 5'b01101; A = 32'hA; B = 32'h5; #10;
        $display("BGE (10>=5): NextPCSrc=%b (esperado 1)", NextPCSrc);
        
        // Test 8: BLTU (unsigned)
        BrOp = 5'b01110; A = 32'h5; B = 32'hA; #10;
        $display("BLTU (5<10): NextPCSrc=%b (esperado 1)", NextPCSrc);
        
        // Test 9: BGEU
        BrOp = 5'b01111; A = 32'hA; B = 32'h5; #10;
        $display("BGEU (10>=5): NextPCSrc=%b (esperado 1)", NextPCSrc);
        
        // Test 10: No branch
        BrOp = 5'b00000; A = 32'h1; B = 32'h2; #10;
        $display("No Branch: NextPCSrc=%b (esperado 0)", NextPCSrc);
        
        $display("\n=== Test Complete ===");
        $finish;
    end

endmodule
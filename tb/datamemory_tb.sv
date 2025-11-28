`timescale 1ns / 1ps

module datamemory_tb;

    reg clk;
    reg DMWr;
    reg [2:0] DMCtrl;
    reg [31:0] addr;
    reg [31:0] DataWr;
    wire [31:0] DataRd;
    
    // Instanciar módulo
    datamemory uut (
        .clk(clk),
        .DMWr(DMWr),
        .DMCtrl(DMCtrl),
        .addr(addr),
        .DataWr(DataWr),
        .DataRd(DataRd)
    );
    
    // Generar clock
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
    $dumpfile("sim/datamemory_tb.vcd");
    $dumpvars(0, datamemory_tb);
    end
    
    initial begin
        $display("=== Data Memory Test ===\n");
        
        DMWr = 0; DMCtrl = 3'b000; addr = 0; DataWr = 0;
        #10;
        
        // Test 1: SW - Store Word
        $display("Test 1: SW (Store Word)");
        addr = 32'h00000000;
        DataWr = 32'h5;
        DMCtrl = 3'b010;  // SW
        DMWr = 1;
        #10;
        DMWr = 0;
        #10;
        DMCtrl = 3'b010;  // LW
        $display("  Wrote: 0x%h, Read: 0x%h", 32'h5, DataRd);
        
        // Test 2: SH - Store Halfword
        $display("\nTest 2: SH (Store Halfword)");
        addr = 32'h00000010;
        DataWr = 32'h0000ABCD;
        DMCtrl = 3'b001;  // SH
        DMWr = 1;
        #10;
        DMWr = 0;
        #10;
        DMCtrl = 3'b101;  // LHU
        $display("  Wrote: 0xABCD, Read: 0x%h", DataRd);
        
        // Test 3: SB - Store Byte
        $display("\nTest 3: SB (Store Byte)");
        addr = 32'h00000020;
        DataWr = 32'h000000FF;
        DMCtrl = 3'b000;  // SB
        DMWr = 1;
        #10;
        DMWr = 0;
        #10;
        DMCtrl = 3'b100;  // LBU
        $display("  Wrote: 0xFF, Read: 0x%h", DataRd);
        
        // Test 4: LB - Load Byte (signed)
        $display("\nTest 4: LB (Load Byte Signed)");
        addr = 32'h00000030;
        DataWr = 32'h000000FF;  // -1 en signed byte
        DMCtrl = 3'b000;  // SB
        DMWr = 1;
        #10;
        DMWr = 0;
        #10;
        DMCtrl = 3'b000;  // LB
        $display("  Stored: 0xFF, Read signed: 0x%h (should be 0xFFFFFFFF)", DataRd);
        
        // Test 5: LH - Load Halfword (signed)
        $display("\nTest 5: LH (Load Halfword Signed)");
        addr = 32'h00000040;
        DataWr = 32'h0000FFFF;  // -1 en signed halfword
        DMCtrl = 3'b001;  // SH
        DMWr = 1;
        #10;
        DMWr = 0;
        #10;
        DMCtrl = 3'b001;  // LH
        $display("  Stored: 0xFFFF, Read signed: 0x%h (should be 0xFFFFFFFF)", DataRd);
        
        // Test 6: Múltiples writes a diferentes direcciones
        $display("\nTest 6: Multiple addresses");
        addr = 32'h00000100;
        DataWr = 32'h11111111;
        DMCtrl = 3'b010; DMWr = 1; #10; DMWr = 0; #10;
        
        addr = 32'h00000104;
        DataWr = 32'h22222222;
        DMCtrl = 3'b010; DMWr = 1; #10; DMWr = 0; #10;
        
        // Leer ambas
        addr = 32'h00000100; DMCtrl = 3'b010; #10;
        $display("  Addr 0x100: 0x%h (expected 0x11111111)", DataRd);
        
        addr = 32'h00000104; DMCtrl = 3'b010; #10;
        $display("  Addr 0x104: 0x%h (expected 0x22222222)", DataRd);
        
        $display("\n=== Test Complete ===");
        $finish;
    end

endmodule
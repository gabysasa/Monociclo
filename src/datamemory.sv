`timescale 1ns / 1ps
module datamemory(
    input  wire         clk,
    input  wire         DMWr,
    input  wire  [2:0]  DMCtrl,
    input  wire [31:0]  addr,        // byte address
    input  wire [31:0]  DataWr,
    output reg  [31:0]  DataRd
);
    // Implementación byte-addressable: memoria como array de bytes
    reg [7:0] mem [0:4095]; // 4KB data memory (ajusta según tu necesidad)

    integer idx;
    initial begin
        DataRd = 32'h0;
        for (idx = 0; idx < 4096; idx = idx + 1) mem[idx] = 8'h00;
    end

    // Lectura combinacional (ensamblar según DMCtrl)
    always @(*) begin
        integer base;
        base = addr[11:0]; // byte address (limitado a 12 bits -> 4096 bytes)
        case (DMCtrl)
            3'b000: begin // LB (signed byte)
                DataRd = {{24{mem[base][7]}}, mem[base]};
            end
            3'b001: begin // LH (signed halfword)
                DataRd = {{16{mem[base+1][7]}}, mem[base+1], mem[base]};
            end
            3'b010: begin // LW (word)
                DataRd = { mem[base+3], mem[base+2], mem[base+1], mem[base] };
            end
            3'b100: begin // LBU
                DataRd = { 24'h0, mem[base] };
            end
            3'b101: begin // LHU
                DataRd = { 16'h0, mem[base+1], mem[base] };
            end
            default: DataRd = 32'h0;
        endcase
    end

    // Escritura secuencial por byte (DMWr activo)
    always_ff @(posedge clk) begin
        if (DMWr) begin
            integer b0;
            b0 = addr[11:0];
            case (DMCtrl)
                3'b000: mem[b0]     <= DataWr[7:0];               // SB
                3'b001: begin                                       // SH
                    mem[b0]     <= DataWr[7:0];
                    mem[b0+1]   <= DataWr[15:8];
                end
                3'b010: begin                                       // SW
                    mem[b0]     <= DataWr[7:0];
                    mem[b0+1]   <= DataWr[15:8];
                    mem[b0+2]   <= DataWr[23:16];
                    mem[b0+3]   <= DataWr[31:24];
                end
                default: ; // no write for loads
            endcase
        end
    end
endmodule
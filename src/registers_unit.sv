module registers_unit(
    input  logic clk, RUWr,
    input  logic [4:0] Rs1, Rs2, Rd,
    input  logic [31:0] DataWr,
    output logic [31:0] RURs1,
    output logic [31:0] RURs2
);
    logic [31:0] ru [31:0];

    initial begin
        integer i;
        for (i = 0; i < 32; i = i + 1)
            ru[i] = 32'd0;
        ru[2] = 32'd1024;
    end

    // ✅ Forwarding logic
    assign RURs1 = (Rs1 == 5'd0) ? 32'd0 :
                   ((RUWr && (Rd == Rs1) && (Rd != 5'd0)) ? DataWr : ru[Rs1]);

    assign RURs2 = (Rs2 == 5'd0) ? 32'd0 :
                   ((RUWr && (Rd == Rs2) && (Rd != 5'd0)) ? DataWr : ru[Rs2]);

    always_ff @(posedge clk) begin
        if (RUWr && (Rd != 5'd0))
            ru[Rd] <= DataWr;
    end
endmodule

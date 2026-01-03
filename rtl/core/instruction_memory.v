module instruction_memory #(
    parameter PC_W = 4   // 4-bit PC → 16 instructions
)(
    input  wire [PC_W-1:0] pc_addr,
    output reg  [8:0]      instr_out
);

    // -----------------------------------------
    // Instruction ROM
    // -----------------------------------------
    reg [8:0] rom [0:(1<<PC_W)-1];
    integer i;   // ✅ DECLARED AT MODULE LEVEL (Vivado-safe)

    // -----------------------------------------
    // Program initialization
    // -----------------------------------------
    initial begin
        // Default: NOP
        for (i = 0; i < (1<<PC_W); i = i + 1)
            rom[i] = 9'b000_00_00_00;

        // -------------------------------------
        // Example program
        // -------------------------------------

        // R0 = R0 + R0
        rom[0] = 9'b000_00_00_00;

        // R1 = R1 + R1
        rom[1] = 9'b000_01_01_01;

        // R2 = R0 + R1
        rom[2] = 9'b000_10_00_01;

        // R3 = popcount(R2)
        rom[3] = 9'b010_11_10_00;

        // CMP R2, R3
        rom[4] = 9'b011_00_10_11;
    end

    // -----------------------------------------
    // Combinational read
    // -----------------------------------------
    always @(*) begin
        instr_out = rom[pc_addr];
    end

endmodule


module instruction_register (
    input  wire        clk,
    input  wire        ir_we,        // instruction register write enable
    input  wire [8:0]  instr_in,     // instruction from instruction memory

    output reg  [2:0]  opcode,
    output reg  [1:0]  rd,
    output reg  [1:0]  rs1,
    output reg  [1:0]  rs2
);

    // -----------------------------------------
    // Latch instruction fields on clock
    // -----------------------------------------
    always @(posedge clk) begin
        if (ir_we) begin
            opcode <= instr_in[8:6];
            rd     <= instr_in[5:4];
            rs1    <= instr_in[3:2];
            rs2    <= instr_in[1:0];
        end
    end

endmodule

module slice_interconnect #(
    parameter S   = 4,   // slice width
    parameter N_A = 2    // number of slices
)(
    input  wire [2:0]         op,

    // From ALU slices
    input  wire [N_A*S-1:0]   slice_out,   // concatenated slice outputs
    input  wire [N_A-1:0]     slice_nc,    // n_c from each slice
    input  wire [2*N_A-1:0]   slice_cmp,   // 2 bits per slice

    // To ALU slices
    output reg  [N_A-1:0]     slice_pc,    // p_c for each slice

    // Final outputs
    output reg  [N_A*S-1:0]   final_out,
    output reg  [1:0]         final_cmp
);

    integer i;

    always @(*) begin
        // -------------------------
        // DEFAULTS
        // -------------------------
        slice_pc  = {N_A{1'b0}};
        final_out = slice_out;
        final_cmp = 2'b00;

        case (op)

            // -------------------------
            // ADD (carry chaining)
            // -------------------------
            3'b000: begin
                slice_pc[0] = 1'b0;
                for (i = 1; i < N_A; i = i + 1)
                    slice_pc[i] = slice_nc[i-1];
            end

            // -------------------------
            // RIGHT SHIFT (bit propagation)
            // -------------------------
            3'b001: begin
                slice_pc[N_A-1] = 1'b0;
                for (i = 0; i < N_A-1; i = i + 1)
                    slice_pc[i] = slice_out[(i+1)*S]; // LSB of higher slice
            end

            // -------------------------
            // POPCOUNT (accumulation - Phase 1)
            // -------------------------
            3'b010: begin
                slice_pc[0] = 1'b0;
                for (i = 1; i < N_A; i = i + 1)
                    slice_pc[i] = slice_out[(i-1)*S]; // accumulate
            end

            // -------------------------
            // COMPARE (early-exit, Vivado-safe)
            // -------------------------
            3'b011: begin
                final_cmp = 2'b00; // EQ by default
                for (i = 0; i < N_A; i = i + 1) begin
                    if (final_cmp == 2'b00 && slice_cmp[2*i +: 2] != 2'b00)
                        final_cmp = slice_cmp[2*i +: 2];
                end
            end

            // -------------------------
            // DEFAULT
            // -------------------------
            default: begin
                slice_pc  = {N_A{1'b0}};
                final_out = slice_out;
                final_cmp = 2'b00;
            end

        endcase
    end

endmodule


module top_simple_cpu #(
    parameter S   = 4,   // slice width
    parameter N_A = 2    // number of slices
)(
    input  wire [N_A*S-1:0] A,
    input  wire [N_A*S-1:0] B,
    input  wire [2:0]       op,

    output wire [N_A*S-1:0] RESULT,
    output wire [1:0]       CMP
);

    // -------------------------------------------------
    // Internal wires
    // -------------------------------------------------
    wire reverse;

    wire [N_A*S-1:0] A_arr;
    wire [N_A*S-1:0] B_arr;

    wire [N_A*S-1:0] slice_out;
    wire [N_A-1:0]   slice_nc;
    wire [N_A-1:0]   slice_pc;
    wire [2*N_A-1:0] slice_cmp;

    // -------------------------------------------------
    // Reverse control
    // -------------------------------------------------
    // Reverse for:
    // - COMPARE
    // - LEFT SHIFT (future extension)
    assign reverse = (op == 3'b011);

    // -------------------------------------------------
    // Input Arranger
    // -------------------------------------------------
    input_arranger #(
        .S(S),
        .N_A(N_A)
    ) IA (
        .A(A),
        .B(B),
        .reverse(reverse),
        .A_out(A_arr),
        .B_out(B_arr)
    );

    // -------------------------------------------------
    // ALU Slices
    // -------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < N_A; i = i + 1) begin : ALU_SLICES

            alu_slice #(
                .S(S)
            ) SLICE (
                .a   (A_arr[(i+1)*S-1 : i*S]),
                .b   (B_arr[(i+1)*S-1 : i*S]),
                .op  (op),
                .p_c (slice_pc[i]),

                .out (slice_out[(i+1)*S-1 : i*S]),
                .n_c (slice_nc[i]),
                .cmp (slice_cmp[2*i +: 2])
            );

        end
    endgenerate

    // -------------------------------------------------
    // Slice Interconnect
    // -------------------------------------------------
    slice_interconnect #(
        .S(S),
        .N_A(N_A)
    ) SI (
        .op        (op),
        .slice_out (slice_out),
        .slice_nc  (slice_nc),
        .slice_cmp (slice_cmp),
        .slice_pc  (slice_pc),
        .final_out (RESULT),
        .final_cmp (CMP)
    );

endmodule

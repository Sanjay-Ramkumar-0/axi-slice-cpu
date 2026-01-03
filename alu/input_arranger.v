module input_arranger #(
    parameter S   = 4,   // slice width
    parameter N_A = 2    // number of slices
)(
    input  wire [N_A*S-1:0] A,
    input  wire [N_A*S-1:0] B,
    input  wire             reverse,

    output wire [N_A*S-1:0] A_out,
    output wire [N_A*S-1:0] B_out
);

    genvar i;
    generate
        for (i = 0; i < N_A; i = i + 1) begin : ARRANGE
            wire [S-1:0] a_norm = A[(i+1)*S-1 : i*S];
            wire [S-1:0] b_norm = B[(i+1)*S-1 : i*S];

            wire [S-1:0] a_rev  = A[(N_A-i)*S-1 : (N_A-i-1)*S];
            wire [S-1:0] b_rev  = B[(N_A-i)*S-1 : (N_A-i-1)*S];

            assign A_out[(i+1)*S-1 : i*S] = reverse ? a_rev : a_norm;
            assign B_out[(i+1)*S-1 : i*S] = reverse ? b_rev : b_norm;
        end
    endgenerate

endmodule

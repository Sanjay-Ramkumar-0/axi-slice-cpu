module alu_slice #(
    parameter S = 4
)(
    input  wire [S-1:0] a,
    input  wire [S-1:0] b,
    input  wire [2:0]   op,
    input  wire         p_c,      // previous carry / shift bit / count seed

    output reg  [S-1:0] out,
    output reg          n_c,      // next carry / shift bit
    output reg  [1:0]   cmp       // 01: GT, 00: EQ, 10: LT
);

    integer i;
    reg [S:0] temp;              // for ADD
    reg [S-1:0] count;           // for POPCOUNT (FIXED WIDTH)

    always @(*) begin
        // defaults
        out  = {S{1'b0}};
        n_c  = 1'b0;
        cmp  = 2'b00;             // EQ by default

        case (op)

            // -------------------------
            // ADD (slice-based)
            // -------------------------
            3'b000: begin
                temp = a + b + p_c;
                out  = temp[S-1:0];
                n_c  = temp[S];   // carry out
            end

            // -------------------------
            // RIGHT SHIFT (local slice)
            // -------------------------
            3'b001: begin
                out[S-1] = p_c;           // incoming bit from higher slice
                for (i = 0; i < S-1; i = i + 1)
                    out[i] = a[i+1];
                n_c = a[0];               // bit passed to next slice
            end

            // -------------------------
            // POPCOUNT (local)
            // -------------------------
            3'b010: begin
                count = {S{1'b0}};
                for (i = 0; i < S; i = i + 1)
                    if (a[i])
                        count = count + 1;
                out = count;
                n_c = 1'b0;               // not used in Phase-1
            end

            // -------------------------
            // COMPARE (local)
            // -------------------------
            3'b011: begin
                if (a > b)
                    cmp = 2'b01;          // GT
                else if (a < b)
                    cmp = 2'b10;          // LT
                else
                    cmp = 2'b00;          // EQ
            end

            default: begin
                out = {S{1'b0}};
                n_c = 1'b0;
                cmp = 2'b00;
            end
        endcase
    end
endmodule

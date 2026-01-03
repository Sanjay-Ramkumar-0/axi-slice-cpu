`timescale 1ns / 1ps

module tb_alu_slice;

    // Parameters
    parameter S = 4;

    // DUT signals
    reg  [S-1:0] a;
    reg  [S-1:0] b;
    reg  [2:0]   op;
    reg          p_c;

    wire [S-1:0] out;
    wire         n_c;
    wire [1:0]   cmp;

    // Instantiate DUT
    alu_slice #(
        .S(S)
    ) dut (
        .a(a),
        .b(b),
        .op(op),
        .p_c(p_c),
        .out(out),
        .n_c(n_c),
        .cmp(cmp)
    );

    // Task for displaying results
    task show;
        begin
            $display("TIME=%0t | op=%b | a=%b b=%b p_c=%b | out=%b n_c=%b cmp=%b",
                     $time, op, a, b, p_c, out, n_c, cmp);
        end
    endtask

    initial begin
        $display("==== ALU SLICE TESTBENCH START ====");

        // -------------------------
        // ADD TESTS
        // -------------------------
        op  = 3'b000;

        a   = 4'b0011;  // 3
        b   = 4'b0101;  // 5
        p_c = 0;
        #10; show();    // Expect out=1000, n_c=0

        a   = 4'b1111;  // 15
        b   = 4'b0001;  // 1
        p_c = 0;
        #10; show();    // Expect out=0000, n_c=1

        a   = 4'b1111;
        b   = 4'b0000;
        p_c = 1;
        #10; show();    // Expect out=0000, n_c=1

        // -------------------------
        // RIGHT SHIFT TESTS
        // -------------------------
        op  = 3'b001;

        a   = 4'b1011;
        b   = 4'b0000;
        p_c = 0;
        #10; show();    // Expect out=0101, n_c=1

        a   = 4'b1011;
        p_c = 1;
        #10; show();    // Expect out=1101, n_c=1

        // -------------------------
        // POPCOUNT TESTS
        // -------------------------
        op  = 3'b010;

        a   = 4'b0000;
        p_c = 0;
        #10; show();    // Expect out=0000

        a   = 4'b1111;
        #10; show();    // Expect out=0100 (4)

        a   = 4'b1011;
        #10; show();    // Expect out=0011 (3)

        // -------------------------
        // COMPARE TESTS
        // -------------------------
        op  = 3'b011;

        a   = 4'b0101;
        b   = 4'b0011;
        #10; show();    // Expect cmp=01 (GT)

        a   = 4'b0011;
        b   = 4'b0101;
        #10; show();    // Expect cmp=10 (LT)

        a   = 4'b0110;
        b   = 4'b0110;
        #10; show();    // Expect cmp=00 (EQ)

        $display("==== ALU SLICE TESTBENCH END ====");
        $stop;
    end

endmodule

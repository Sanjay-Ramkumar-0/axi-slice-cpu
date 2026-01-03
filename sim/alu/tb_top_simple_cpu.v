`timescale 1ns / 1ps

module tb_top_simple_cpu;

    // Parameters (must match DUT)
    parameter S   = 4;
    parameter N_A = 2;   // 2 slices → 8-bit CPU

    // DUT inputs
    reg  [N_A*S-1:0] A;
    reg  [N_A*S-1:0] B;
    reg  [2:0]       op;

    // DUT outputs
    wire [N_A*S-1:0] RESULT;
    wire [1:0]       CMP;

    // Instantiate DUT
    top_simple_cpu #(
        .S(S),
        .N_A(N_A)
    ) dut (
        .A(A),
        .B(B),
        .op(op),
        .RESULT(RESULT),
        .CMP(CMP)
    );

    // Display helper
    task show;
        begin
            $display("TIME=%0t | op=%b | A=%0d B=%0d | RESULT=%0d CMP=%b",
                     $time, op, A, B, RESULT, CMP);
        end
    endtask

    initial begin
        $display("======================================");
        $display(" STARTING top_simple_cpu TESTBENCH ");
        $display("======================================");

        // -------------------------
        // ADD TESTS
        // -------------------------
        op = 3'b000;

        A = 8'd10; B = 8'd22; #10; show();  // 10 + 22 = 32
        A = 8'd255; B = 8'd1;  #10; show(); // overflow case (wraps)
        A = 8'd100; B = 8'd50; #10; show(); // 150

        // -------------------------
        // RIGHT SHIFT TESTS
        // -------------------------
        op = 3'b001;

        A = 8'b10110011; B = 0; #10; show(); // expect logical right shift
        A = 8'b00000001; B = 0; #10; show();

        // -------------------------
        // POPCOUNT TESTS
        // -------------------------
        op = 3'b010;

        A = 8'b00000000; B = 0; #10; show(); // 0
        A = 8'b11111111; B = 0; #10; show(); // 8
        A = 8'b10101101; B = 0; #10; show(); // 5

        // -------------------------
        // COMPARE TESTS
        // -------------------------
        op = 3'b011;

        A = 8'd50;  B = 8'd50;  #10; show(); // EQ → 00
        A = 8'd200; B = 8'd100; #10; show(); // GT → 01
        A = 8'd10;  B = 8'd20;  #10; show(); // LT → 10

        $display("======================================");
        $display(" TESTBENCH COMPLETE ");
        $display("======================================");

        $stop;
    end

endmodule

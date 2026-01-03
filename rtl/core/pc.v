module pc #(
    parameter PC_W = 4   // width of PC (e.g., 4 bits → 16 instructions)
)(
    input  wire           clk,
    input  wire           rst,

    input  wire           pc_en,     // enable PC increment
    input  wire           pc_load,   // load PC directly (future use)
    input  wire [PC_W-1:0] pc_in,    // value to load

    output reg  [PC_W-1:0] pc_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= {PC_W{1'b0}};   // PC = 0 on reset
        end
        else if (pc_load) begin
            pc_out <= pc_in;          // jump / branch (future)
        end
        else if (pc_en) begin
            pc_out <= pc_out + 1'b1;  // next instruction
        end
    end

endmodule

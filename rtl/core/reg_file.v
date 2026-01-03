module reg_file #(
    parameter DATA_W = 8   // register width (matches CPU width)
)(
    input  wire             clk,
    input  wire             we,        // write enable

    // Read addresses
    input  wire [1:0]       rs1_addr,
    input  wire [1:0]       rs2_addr,

    // Write address
    input  wire [1:0]       rd_addr,

    // Write data
    input  wire [DATA_W-1:0] rd_data,

    // Read data outputs
    output wire [DATA_W-1:0] rs1_data,
    output wire [DATA_W-1:0] rs2_data
);

    // -----------------------------------------
    // Register storage
    // -----------------------------------------
    reg [DATA_W-1:0] regs [0:3];

    // -----------------------------------------
    // Combinational reads
    // -----------------------------------------
    assign rs1_data = regs[rs1_addr];
    assign rs2_data = regs[rs2_addr];

    // -----------------------------------------
    // Synchronous write
    // -----------------------------------------
    always @(posedge clk) begin
        if (we) begin
            regs[rd_addr] <= rd_data;
        end
    end

endmodule

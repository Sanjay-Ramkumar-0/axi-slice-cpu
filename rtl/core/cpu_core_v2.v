module cpu_core_v2 #(
    parameter S    = 4,
    parameter N_A  = 2,
    parameter PC_W = 4
)(
    input  wire             clk,
    input  wire             rst,

    // Debug / observation outputs
    output wire [PC_W-1:0]  pc_dbg,
    output wire [N_A*S-1:0] alu_result_dbg,
    output wire [1:0]       cmp_dbg,
    output wire [1:0]       state_dbg
);

    // -------------------------------------------------
    // Internal wires
    // -------------------------------------------------

    // PC
    wire [PC_W-1:0] pc_out;

    // Instruction fetch
    wire [8:0] instr;

    // Instruction fields
    wire [2:0] opcode;
    wire [1:0] rd, rs1, rs2;

    // Control signals
    wire ir_we;
    wire reg_we;
    wire alu_en;
    wire pc_en;

    // Register file data
    wire [N_A*S-1:0] rs1_data;
    wire [N_A*S-1:0] rs2_data;

    // ALU outputs
    wire [N_A*S-1:0] alu_result;
    wire [1:0]       cmp_result;

    // -------------------------------------------------
    // Program Counter
    // -------------------------------------------------
    pc #(
        .PC_W(PC_W)
    ) PC (
        .clk     (clk),
        .rst     (rst),
        .pc_en   (pc_en),
        .pc_load (1'b0),     // no branching yet
        .pc_in   ({PC_W{1'b0}}),
        .pc_out  (pc_out)
    );

    assign pc_dbg = pc_out;

    // -------------------------------------------------
    // Instruction Memory
    // -------------------------------------------------
    instruction_memory #(
        .PC_W(PC_W)
    ) IMEM (
        .pc_addr  (pc_out),
        .instr_out(instr)
    );

    // -------------------------------------------------
    // Instruction Register
    // -------------------------------------------------
    instruction_register IR (
        .clk      (clk),
        .ir_we    (ir_we),
        .instr_in (instr),
        .opcode   (opcode),
        .rd       (rd),
        .rs1      (rs1),
        .rs2      (rs2)
    );

    // -------------------------------------------------
    // Control FSM
    // -------------------------------------------------
    control_fsm FSM (
        .clk       (clk),
        .rst       (rst),
        .opcode    (opcode),
        .ir_we     (ir_we),
        .reg_we    (reg_we),
        .alu_en    (alu_en),
        .state_dbg (state_dbg)
    );

    // -------------------------------------------------
    // PC enable logic
    // -------------------------------------------------
    // Increment PC once per instruction (WRITEBACK)
    assign pc_en = (state_dbg == 2'b11); // S_WB

    // -------------------------------------------------
    // Register File
    // -------------------------------------------------
    reg_file #(
        .DATA_W(N_A*S)
    ) RF (
        .clk       (clk),
        .we        (reg_we),
        .rs1_addr  (rs1),
        .rs2_addr  (rs2),
        .rd_addr   (rd),
        .rd_data   (alu_result),
        .rs1_data  (rs1_data),
        .rs2_data  (rs2_data)
    );

    // -------------------------------------------------
    // Expandable ALU Core (Phase-1)
    // -------------------------------------------------
    top_simple_cpu #(
        .S(S),
        .N_A(N_A)
    ) ALU_CORE (
        .A      (rs1_data),
        .B      (rs2_data),
        .op     (opcode),
        .RESULT (alu_result),
        .CMP    (cmp_result)
    );

    assign alu_result_dbg = alu_result;
    assign cmp_dbg        = cmp_result;

endmodule

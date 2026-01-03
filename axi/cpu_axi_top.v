module cpu_axi_top #(
    parameter S    = 4,
    parameter N_A  = 2,
    parameter PC_W = 4
)(
    // ---------------------------------
    // AXI-Lite Interface
    // ---------------------------------
    input  wire         ACLK,
    input  wire         ARESETn,

    input  wire [31:0]  S_AXI_AWADDR,
    input  wire         S_AXI_AWVALID,
    output wire         S_AXI_AWREADY,

    input  wire [31:0]  S_AXI_WDATA,
    input  wire [3:0]   S_AXI_WSTRB,
    input  wire         S_AXI_WVALID,
    output wire         S_AXI_WREADY,

    output wire [1:0]   S_AXI_BRESP,
    output wire         S_AXI_BVALID,
    input  wire         S_AXI_BREADY,

    input  wire [31:0]  S_AXI_ARADDR,
    input  wire         S_AXI_ARVALID,
    output wire         S_AXI_ARREADY,

    output wire [31:0]  S_AXI_RDATA,
    output wire [1:0]   S_AXI_RRESP,
    output wire         S_AXI_RVALID,
    input  wire         S_AXI_RREADY
);

    // ---------------------------------
    // Internal AXI registers
    // ---------------------------------
    wire [31:0] reg_ctrl;
    wire [31:0] reg_status;
    wire [31:0] reg_pc;
    wire [31:0] reg_alu_result;
    wire [31:0] reg_cmp;

    // ---------------------------------
    // CPU control signals
    // ---------------------------------
    wire cpu_start;
    wire cpu_reset;

    assign cpu_start = reg_ctrl[0];
    assign cpu_reset = reg_ctrl[1];

    // ---------------------------------
    // CPU debug outputs
    // ---------------------------------
    wire [PC_W-1:0]  pc_dbg;
    wire [N_A*S-1:0] alu_dbg;
    wire [1:0]       cmp_dbg;
    wire [1:0]       state_dbg;

    // ---------------------------------
    // CPU instance
    // ---------------------------------
    cpu_core_v2 #(
        .S   (S),
        .N_A (N_A),
        .PC_W(PC_W)
    ) CPU (
        .clk            (ACLK),
        .rst            (~ARESETn | cpu_reset),

        .pc_dbg         (pc_dbg),
        .alu_result_dbg (alu_dbg),
        .cmp_dbg        (cmp_dbg),
        .state_dbg      (state_dbg)
    );

    // ---------------------------------
    // Status mapping
    // ---------------------------------
    assign reg_status = {
        28'b0,
        state_dbg
    };

    assign reg_alu_result = alu_dbg;
    assign reg_cmp        = {30'b0, cmp_dbg};
    assign reg_pc         = {{(32-PC_W){1'b0}}, pc_dbg};

    // ---------------------------------
    // AXI-Lite Slave
    // ---------------------------------
    axi_lite_slave AXI (
        .ACLK           (ACLK),
        .ARESETn        (ARESETn),

        .S_AXI_AWADDR   (S_AXI_AWADDR),
        .S_AXI_AWVALID  (S_AXI_AWVALID),
        .S_AXI_AWREADY  (S_AXI_AWREADY),

        .S_AXI_WDATA    (S_AXI_WDATA),
        .S_AXI_WSTRB    (S_AXI_WSTRB),
        .S_AXI_WVALID   (S_AXI_WVALID),
        .S_AXI_WREADY   (S_AXI_WREADY),

        .S_AXI_BRESP    (S_AXI_BRESP),
        .S_AXI_BVALID   (S_AXI_BVALID),
        .S_AXI_BREADY   (S_AXI_BREADY),

        .S_AXI_ARADDR   (S_AXI_ARADDR),
        .S_AXI_ARVALID  (S_AXI_ARVALID),
        .S_AXI_ARREADY  (S_AXI_ARREADY),

        .S_AXI_RDATA    (S_AXI_RDATA),
        .S_AXI_RRESP    (S_AXI_RRESP),
        .S_AXI_RVALID   (S_AXI_RVALID),
        .S_AXI_RREADY   (S_AXI_RREADY),

        // Internal register hookups
        .reg_ctrl       (reg_ctrl),
        .reg_status     (reg_status),
        .reg_pc         (reg_pc),
        .reg_alu_result (reg_alu_result),
        .reg_cmp        (reg_cmp)
    );

endmodule

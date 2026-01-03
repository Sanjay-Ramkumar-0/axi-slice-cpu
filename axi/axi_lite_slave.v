module axi_lite_slave #(
    parameter ADDR_W = 32,
    parameter DATA_W = 32
)(
    input  wire                  ACLK,
    input  wire                  ARESETn,

    // =============================
    // AXI WRITE ADDRESS CHANNEL
    // =============================
    input  wire [ADDR_W-1:0]     S_AXI_AWADDR,
    input  wire                  S_AXI_AWVALID,
    output reg                   S_AXI_AWREADY,

    // =============================
    // AXI WRITE DATA CHANNEL
    // =============================
    input  wire [DATA_W-1:0]     S_AXI_WDATA,
    input  wire [DATA_W/8-1:0]   S_AXI_WSTRB,
    input  wire                  S_AXI_WVALID,
    output reg                   S_AXI_WREADY,

    // =============================
    // AXI WRITE RESPONSE CHANNEL
    // =============================
    output reg  [1:0]            S_AXI_BRESP,
    output reg                   S_AXI_BVALID,
    input  wire                  S_AXI_BREADY,

    // =============================
    // AXI READ ADDRESS CHANNEL
    // =============================
    input  wire [ADDR_W-1:0]     S_AXI_ARADDR,
    input  wire                  S_AXI_ARVALID,
    output reg                   S_AXI_ARREADY,

    // =============================
    // AXI READ DATA CHANNEL
    // =============================
    output reg  [DATA_W-1:0]     S_AXI_RDATA,
    output reg  [1:0]            S_AXI_RRESP,
    output reg                   S_AXI_RVALID,
    input  wire                  S_AXI_RREADY,

    // =============================
    // EXPOSED REGISTERS (to wrapper)
    // =============================
    output reg  [31:0]           reg_ctrl,
    output reg  [31:0]           reg_pc,
    output reg  [31:0]           reg_instr,
    output reg  [31:0]           reg_r0,
    output reg  [31:0]           reg_r1,
    output reg  [31:0]           reg_r2,
    output reg  [31:0]           reg_r3,

    input  wire [31:0]           reg_status,
    input  wire [31:0]           reg_alu_result,
    input  wire [31:0]           reg_cmp
);

    // =================================
    // RESET
    // =================================
    always @(posedge ACLK) begin
        if (!ARESETn) begin
            S_AXI_AWREADY <= 1'b0;
            S_AXI_WREADY  <= 1'b0;
            S_AXI_BVALID  <= 1'b0;
            S_AXI_BRESP   <= 2'b00;

            S_AXI_ARREADY <= 1'b0;
            S_AXI_RVALID  <= 1'b0;
            S_AXI_RRESP   <= 2'b00;
            S_AXI_RDATA   <= 32'b0;

            reg_ctrl  <= 32'b0;
            reg_pc    <= 32'b0;
            reg_instr <= 32'b0;
            reg_r0    <= 32'b0;
            reg_r1    <= 32'b0;
            reg_r2    <= 32'b0;
            reg_r3    <= 32'b0;
        end
        else begin
            // =================================
            // WRITE ADDRESS / DATA HANDSHAKE
            // =================================
            S_AXI_AWREADY <= S_AXI_AWVALID && !S_AXI_AWREADY;
            S_AXI_WREADY  <= S_AXI_WVALID  && !S_AXI_WREADY;

            if (S_AXI_AWVALID && S_AXI_WVALID && !S_AXI_BVALID) begin
                case (S_AXI_AWADDR[7:0])
                    8'h00: reg_ctrl  <= S_AXI_WDATA;
                    8'h08: reg_pc    <= S_AXI_WDATA;
                    8'h0C: reg_instr <= S_AXI_WDATA;
                    8'h10: reg_r0    <= S_AXI_WDATA;
                    8'h14: reg_r1    <= S_AXI_WDATA;
                    8'h18: reg_r2    <= S_AXI_WDATA;
                    8'h1C: reg_r3    <= S_AXI_WDATA;
                    default: ;
                endcase

                S_AXI_BVALID <= 1'b1;
                S_AXI_BRESP  <= 2'b00; // OKAY
            end

            if (S_AXI_BVALID && S_AXI_BREADY)
                S_AXI_BVALID <= 1'b0;

            // =================================
            // READ ADDRESS / DATA HANDSHAKE
            // =================================
            S_AXI_ARREADY <= S_AXI_ARVALID && !S_AXI_ARREADY;

            if (S_AXI_ARVALID && !S_AXI_RVALID) begin
                case (S_AXI_ARADDR[7:0])
                    8'h00: S_AXI_RDATA <= reg_ctrl;
                    8'h04: S_AXI_RDATA <= reg_status;
                    8'h08: S_AXI_RDATA <= reg_pc;
                    8'h10: S_AXI_RDATA <= reg_r0;
                    8'h14: S_AXI_RDATA <= reg_r1;
                    8'h18: S_AXI_RDATA <= reg_r2;
                    8'h1C: S_AXI_RDATA <= reg_r3;
                    8'h20: S_AXI_RDATA <= reg_alu_result;
                    8'h24: S_AXI_RDATA <= reg_cmp;
                    default: S_AXI_RDATA <= 32'b0;
                endcase

                S_AXI_RVALID <= 1'b1;
                S_AXI_RRESP  <= 2'b00; // OKAY
            end

            if (S_AXI_RVALID && S_AXI_RREADY)
                S_AXI_RVALID <= 1'b0;
        end
    end

endmodule

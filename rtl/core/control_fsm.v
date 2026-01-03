module control_fsm (
    input  wire       clk,
    input  wire       rst,

    // From instruction register
    input  wire [2:0] opcode,

    // Control outputs
    output reg        ir_we,
    output reg        reg_we,
    output reg        alu_en,

    // Debug (optional)
    output reg [1:0]  state_dbg
);

    // -----------------------------------------
    // State encoding
    // -----------------------------------------
    localparam S_FETCH  = 2'b00;
    localparam S_DECODE = 2'b01;
    localparam S_EXEC   = 2'b10;
    localparam S_WB     = 2'b11;

    reg [1:0] state, next_state;

    // -----------------------------------------
    // State register
    // -----------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= S_FETCH;
        else
            state <= next_state;
    end

    // -----------------------------------------
    // Next-state logic
    // -----------------------------------------
    always @(*) begin
        case (state)
            S_FETCH:   next_state = S_DECODE;
            S_DECODE:  next_state = S_EXEC;
            S_EXEC:    next_state = S_WB;
            S_WB:      next_state = S_FETCH;
            default:   next_state = S_FETCH;
        endcase
    end

    // -----------------------------------------
    // Output control logic
    // -----------------------------------------
    always @(*) begin
        // Defaults
        ir_we   = 1'b0;
        reg_we  = 1'b0;
        alu_en  = 1'b0;
        state_dbg = state;

        case (state)

            // -------------------------
            // FETCH
            // -------------------------
            S_FETCH: begin
                ir_we = 1'b1;   // load instruction
            end

            // -------------------------
            // DECODE
            // -------------------------
            S_DECODE: begin
                // no control action
            end

            // -------------------------
            // EXECUTE
            // -------------------------
            S_EXEC: begin
                alu_en = 1'b1;  // perform ALU operation
            end

            // -------------------------
            // WRITE BACK
            // -------------------------
            S_WB: begin
                // write back only for ALU ops
                case (opcode)
                    3'b000, // ADD
                    3'b001, // RIGHT SHIFT
                    3'b010: // POPCOUNT
                        reg_we = 1'b1;
                    default:
                        reg_we = 1'b0; // COMPARE has no writeback
                endcase
            end

        endcase
    end

module barrido# (
    // number of clk cycles between steps (adjust to change speed)
    parameter int WAIT_TIME = 10,
    // number of columns
    parameter int WIDTH     = 4,
    // set to 1 to make the physical columns active-low (invert output)
    parameter bit ACTIVE_LOW = 1'b0
)(
    input  logic             clk,
    output logic [WIDTH-1:0] col
);

    // simple free-running clock divider / step timer
    int clockCounter = 0;

    // one-hot shift register that holds which column is active
    logic [WIDTH-1:0] col_reg = { { (WIDTH-1){1'b0} }, 1'b1 };

    // rotate the one-hot bit each time clockCounter reaches WAIT_TIME
    always_ff @(posedge clk) begin
        // rotate left: move MSB into LSB
        if (clockCounter >= WAIT_TIME) begin
            clockCounter <= 0;
            //rotate left: move MSB into LSB
            col_reg <= { col_reg[WIDTH-2:0], col_reg[WIDTH-1] };
        end else begin
        clockCounter <= clockCounter + 1;
        end
    end

    // apply active-low if requested
    assign col = ACTIVE_LOW ? ~col_reg : col_reg;

endmodule


module register# (
    // optional instance identifier: users can pass an instance number
    // and WIDTH will default to that value when non-zero.
    parameter int INST_ID = 0,
    // WIDTH can depend on INST_ID; by default use INST_ID when non-zero,
    // otherwise fall back to a sensible default (8).
    parameter int WIDTH = (INST_ID != 0) ? INST_ID : 8
)(
    input  logic             clk,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

    always_ff @(posedge clk) begin
        q <= d;
    end
endmodule


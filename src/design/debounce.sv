// Simple parameterizable vector debouncer.
// - INPUT:  pb_1   : raw (async) inputs (vector)
// - INPUT:  clk    : sampling clock (same domain as consumers)
// - OUTPUT: pb_out : debounced stable level per bit
//
// Algorithm: two-stage synchronizer per bit, then per-bit small counter that
// waits THRESH consecutive samples of a new level before updating output.
module debounce #(
    parameter int WIDTH  = 4,
    parameter int THRESH = 3  // number of consecutive samples required to accept a change
)(
    input  logic [WIDTH-1:0] pb_1,
    input  logic            clk,
    output logic [WIDTH-1:0] pb_out
);

    // two-stage sync
    logic [WIDTH-1:0] sync1;
    logic [WIDTH-1:0] sync2;
    always_ff @(posedge clk) begin
        sync1 <= pb_1;
        sync2 <= sync1;
    end

    // counter width (at least 1)
    localparam int CNT_W = (THRESH <= 1) ? 1 : $clog2(THRESH + 1);

    // per-bit counters and output register
    logic [CNT_W-1:0] cnt [WIDTH-1:0];
    logic [WIDTH-1:0] out_reg;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_DEB
            always_ff @(posedge clk) begin
                // if sync2 equals current output, reset counter
                if (sync2[i] == out_reg[i]) begin
                    cnt[i] <= '0;
                end else begin
                    // count toward threshold
                    if (cnt[i] >= THRESH - 1) begin
                        out_reg[i] <= sync2[i];
                        cnt[i] <= '0;
                    end else begin
                        cnt[i] <= cnt[i] + 1'b1;
                    end
                end
            end
        end
    endgenerate

    assign pb_out = out_reg;

endmodule
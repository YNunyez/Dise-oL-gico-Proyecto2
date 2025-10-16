// sistema_de_lectura.sv
// Top-level system module that demonstrates using registers of different sizes
// and the existing `barrido` module.

//`include "sizes_pkg.sv"

module sistema_de_lectura #(
    parameter int WIDTH = 4,
    parameter int DEBOUNCE_PULSES = 3
)(
    input  logic              clk,
    output logic [WIDTH-1:0]  col,
    input  logic  [WIDTH-1:0] fil,
    // new capture interface
    output logic [WIDTH-1:0]  pressed_col_out, // one-hot column of last accepted press
    output logic [WIDTH-1:0]  pressed_row_out, // one-hot row of last accepted press
    output logic              pressed_valid,   // asserted when a captured press is available
    input  logic              ack_read         // consumer pulses this to clear pressed_valid
);

    // instantiate barrido to drive 'col'
    barrido #(.WIDTH(WIDTH)) barrido (
        .clk(clk),
        .col(col)
    );

    // --- synchronize raw inputs into clk domain (2-stage) ---
    logic [WIDTH-1:0] fil_sync1, fil_sync2, fil_prev;
    always_ff @(posedge clk) begin
        fil_sync1 <= fil;
        fil_sync2 <= fil_sync1;
        fil_prev  <= fil_sync2;
    end

    // edge detect (rising edges on rows)
    logic [WIDTH-1:0] fil_rise;
    assign fil_rise = fil_sync2 & ~fil_prev;

    // --- press capture + debounce across rotations ---
    logic                press_pending = 1'b0;
    logic [WIDTH-1:0]    pressed_row_oh;
    logic [WIDTH-1:0]    pressed_col_oh;      // snapshot of col at first detection
    int unsigned         confirm_count = 0;

    // outputs / status
    logic                debounced_event;
    logic [WIDTH-1:0]    last_pressed_col;
    logic [WIDTH-1:0]    last_pressed_row;

    // initialize capture outputs
    initial begin
        pressed_col_out = '0;
        pressed_row_out = '0;
        pressed_valid   = 1'b0;
    end

    always_ff @(posedge clk) begin
        debounced_event <= 1'b0;

        if (!press_pending) begin
            if (|fil_rise) begin
                // capture which row rose and which column was active right now
                press_pending    <= 1'b1;
                pressed_row_oh   <= fil_rise;
                pressed_col_oh   <= col;
                confirm_count    <= 0;
            end
        end else begin
            // when the captured column comes around, check the row input
            if (|(pressed_col_oh & col)) begin
                if (|(pressed_row_oh & fil_sync2)) begin
                    // confirmation: at this column visit the row reads high
                    confirm_count <= confirm_count + 1;
                    if (confirm_count + 1 >= DEBOUNCE_PULSES) begin
                        // debounced press accepted
                        debounced_event   <= 1'b1;
                        last_pressed_col  <= pressed_col_oh;
                        last_pressed_row  <= pressed_row_oh;
                        press_pending     <= 1'b0;
                        confirm_count     <= 0;

                        // latch outward (only if consumer hasn't read previous)
                        if (!pressed_valid) begin
                            pressed_col_out <= pressed_col_oh;
                            pressed_row_out <= pressed_row_oh;
                            pressed_valid   <= 1'b1;
                        end
                    end
                end else begin
                    // failed confirmation for this visit -> reset count and keep waiting
                    confirm_count <= 0;
                end
            end

            // optional: if the row is released completely before confirmation, cancel
            if (!(|(
                pressed_row_oh & fil_sync2
            ))) begin
                // if the row is stable low for a long period you may want to cancel;
                // left simple: we only clear on explicit acceptance or external logic
            end
        end

        // ack clears valid (synchronous)
        if (ack_read)
            pressed_valid <= 1'b0;
    end

    // (optional) expose debounced_event as an output or hook into other logic

    // capture outputs (latched using register module)
    logic [WIDTH-1:0] pressed_col_out /* driven by register q */;
    logic [WIDTH-1:0] pressed_row_out /* driven by register q */;
    logic             pressed_valid;

    // prepare register data: load new value when debounced_event, otherwise hold current q
    logic [WIDTH-1:0] reg_col_d;
    logic [WIDTH-1:0] reg_row_d;

    always_comb begin
        reg_col_d = debounced_event ? pressed_col_oh : pressed_col_out;
        reg_row_d = debounced_event ? pressed_row_oh : pressed_row_out;
    end

    // instantiate parameterized registers (reuse your register module)
    register #(.WIDTH(WIDTH)) reg_col (
        .clk(clk),
        .d(reg_col_d),
        .q(pressed_col_out)
    );

    register #(.WIDTH(WIDTH)) reg_row (
        .clk(clk),
        .d(reg_row_d),
        .q(pressed_row_out)
    );

    // valid flag and ack handling (synchronous)
    always_ff @(posedge clk) begin
        if (debounced_event)
            pressed_valid <= 1'b1;
        else if (ack_read)
            pressed_valid <= 1'b0;
    end

endmodule

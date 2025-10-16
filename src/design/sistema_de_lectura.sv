// sistema_de_lectura.sv
// Top-level system module that demonstrates using registers of different sizes
// and the existing `barrido` module.

//`include "sizes_pkg.sv"

module sistema_de_lectura #(
    parameter int WIDTH = 4,                // must match barrido WIDTH
    parameter int DEBOUNCE_PULSES = 3       // number of successful column visits to accept
)(
    input  logic           clk,
    output logic [WIDTH-1:0] col,          // scanned column outputs (one-hot)
    input  logic  [WIDTH-1:0] fil           // raw row inputs (from pins)
);

    // instantiate barrido to drive 'col'
    barrido #(.WIDTH(WIDTH)) my_barrido (
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
    end

    // (optional) expose debounced_event as an output or hook into other logic
    // ...existing code...

endmodule

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
    input  logic              ack_read,        // consumer pulses this to clear pressed_valid
    output integer                numero,
    output logic              reset,
    output logic              save
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
        numero = 0;
        reset = 1'b0;
        save = 1'b0;
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
    
    always_ff @(posedge clk) begin
        // Reset flags by default
    //    reset <= 1'b0;
    //    save <= 1'b0;
        case({pressed_col_oh, pressed_row_oh})
            8'b1000_1000 : numero <= 1; // columna 0, fila 0 = 1
            8'b0100_1000 : numero <= 2; // columna 1, fila 0 = 2
            8'b0010_1000 : numero <= 3; // columna 2, fila 0 = 3

            8'b1000_0100 : numero <= 4; // columna 0, fila 1 = 4
            8'b0100_0100 : numero <= 5; // columna 1, fila 1 = 5
            8'b0010_0100 : numero <= 6; // columna 2, fila 1 = 6

            8'b1000_0010 : numero <= 7; // columna 0, fila 2 = 7
            8'b0100_0010 : numero <= 8; // columna 1, fila 2 = 8
            8'b0010_0010 : numero <= 9; // columna 2, fila 2 = 9

            8'b1000_0001 : reset <= 1'b1; // columna 0, fila 3 = * 
            8'b0100_0001 : numero <= 0; // columna 1, fila 3 = 0
            8'b0010_0001 : save <= 1'b1; // columna 2, fila 3 = # 
            default      : begin
                // No action for invalid combinations
            end
        endcase
        //if (debounced_event) begin
        //end
        // Only update when a valid press is detected
    end
    // (optional) expose debounced_event as an output or hook into other logic
    // ...existing code...
endmodule

`timescale 1ns / 1ps

module sistema_de_lectura_tb;

    localparam WIDTH = 4;
    localparam DB_PULSES = 3;

    reg                 clk;
    reg  [WIDTH-1:0]    fil;
    wire [WIDTH-1:0]    col;
    wire [WIDTH-1:0]    pressed_col_out;
    wire [WIDTH-1:0]    pressed_row_out;
    wire                pressed_valid;
    reg                 ack_read;

    // Instantiate DUT
    sistema_de_lectura #(
        .WIDTH(WIDTH),
        .DEBOUNCE_PULSES(DB_PULSES)
    ) DUT (
        .clk(clk),
        .col(col),
        .fil(fil),
        .pressed_col_out(pressed_col_out),
        .pressed_row_out(pressed_row_out),
        .pressed_valid(pressed_valid),
        .ack_read(ack_read)
    );

    // clock 50 MHz -> period 20 ns
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // waveform dump and monitor header
    initial begin
        $dumpfile("sistema_de_lectura_tb.vcd");
        $dumpvars(0, sistema_de_lectura_tb);
        $display("TIME(ns)\tclk col   fil   pcol  prow  valid");
    end

    // print registers and signals every clock edge
    always @(posedge clk) begin
        $display("%0t\t%b   %b %b %b %b %b",
                 $time, clk, col, fil, pressed_col_out, pressed_row_out, pressed_valid);
    end

    // task: wait for a column then assert a row for hold_cycles
    task press_at_col(input integer row, input integer col_idx, input integer hold_cycles);
        reg [WIDTH-1:0] target;
        reg [WIDTH-1:0] target_row;
        integer i;
    begin
        // build one-hot target column
        target = {WIDTH{1'b0}};
        for (i = 0; i < WIDTH; i = i + 1) target[i] = (i == col_idx);
        // wait until that column is active
        @(posedge clk);
        while (col !== target) @(posedge clk);
        // build one-hot for row and assert
        target_row = {WIDTH{1'b0}};
        for (i = 0; i < WIDTH; i = i + 1) target_row[i] = (i == row);
        fil = target_row;
        repeat (hold_cycles) @(posedge clk);
        fil = {WIDTH{1'b0}};
        @(posedge clk);
        $display("Pressed row %0d at %0t when col=%b (held %0d cycles)", row, $time, target, hold_cycles);
    end
    endtask

    // stimulus: several presses, read latched register and ack
    initial begin
        ack_read = 0;
        fil = {WIDTH{1'b0}};
        // let scanner run a few cycles
        repeat (10) @(posedge clk);

        // long press on row0 when col0 appears
        press_at_col(0, 0, 50);
        // wait a bit to allow debounce to complete
        repeat (40) @(posedge clk);

        // if DUT latched a press, show and ack it
        if (pressed_valid) begin
            $display("TB: read latched -> pcol=%b prow=%b at %0t", pressed_col_out, pressed_row_out, $time);
            // ack to clear
            ack_read = 1;
            @(posedge clk);
            ack_read = 0;
        end

        // medium press on row1 when col1 appears
        press_at_col(1, 1, 30);
        repeat (40) @(posedge clk);
        if (pressed_valid) begin
            $display("TB: read latched -> pcol=%b prow=%b at %0t", pressed_col_out, pressed_row_out, $time);
            ack_read = 1;
            @(posedge clk);
            ack_read = 0;
        end

        // short press on row2 (may or may not pass debounce)
        press_at_col(2, 2, 10);
        repeat (40) @(posedge clk);
        if (pressed_valid) begin
            $display("TB: read latched -> pcol=%b prow=%b at %0t", pressed_col_out, pressed_row_out, $time);
            ack_read = 1;
            @(posedge clk);
            ack_read = 0;
        end

        // finish
        repeat (20) @(posedge clk);
        $display("Testbench finished at %0t", $time);
        $finish;
    end

endmodule
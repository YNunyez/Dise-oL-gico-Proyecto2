`timescale 1ns / 1ps

module sistema_de_lectura_tb;

    localparam WIDTH = 4;
    localparam DB_CYCLES = 3;

    reg                 clk;
    wire [WIDTH-1:0]    col;
    reg  [WIDTH-1:0]    fil;

    // Instantiate DUT (connect ports and set parameters)
    sistema_de_lectura #(
        .WIDTH(WIDTH),
        .DEBOUNCE_PULSES(DB_CYCLES)
    ) DUT (
        .clk(clk),
        .col(col),
        .fil(fil)
    );

    // clock: 50 MHz -> period 20 ns (half-period 10 ns)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // monitor: print time, col and fil whenever they change
    initial begin
        $display("Time(ns)\tcol\t fil");
        $monitor("%0t\t%b\t%b", $time, col, fil);
    end

    // waveform dump
    initial begin
        $dumpfile("sistema_de_lectura_tb.vcd");
        $dumpvars(0, sistema_de_lectura_tb);
    end

    // helper task: wait until DUT drives a specific column, then assert fil[row] for hold_cycles
    task press_at_col(input integer row, input integer col_idx, input integer hold_cycles);
        reg [WIDTH-1:0] target;
        reg [WIDTH-1:0] target_row;
        integer i;
        // build one-hot target for column (avoid shifts)
        target = {WIDTH{1'b0}};
        for (i = 0; i < WIDTH; i = i + 1)
            target[i] = (i == col_idx) ? 1'b1 : 1'b0;
        // wait for target column to be active
        @(posedge clk);
        while (col !== target) @(posedge clk);
        // build one-hot for the row to drive
        target_row = {WIDTH{1'b0}};
        for (i = 0; i < WIDTH; i = i + 1)
            target_row[i] = (i == row) ? 1'b1 : 1'b0;
        // assert fil (simulate button press) for hold_cycles clock edges
        fil = target_row;          // assign whole vector (portable)
        repeat (hold_cycles) @(posedge clk);
        fil = {WIDTH{1'b0}};       // release (whole-vector assign)
        // allow one cycle for system to register release
        @(posedge clk);
        $display("Pressed row %0d at time %0t when col=%b (held %0d cycles)", row, $time, target, hold_cycles);
    endtask

    // simulation helper counters (declare at module scope for portability)
    integer long_hold = 100;
    integer medium_hold = 40;
    integer short_hold = 10;

    // stimulus: use long holds (many rotations) to simulate human press
    initial begin
        fil = {WIDTH{1'b0}};
        // let system start and col begin rotating
        repeat (10) @(posedge clk);

        // press row0 at col0, hold long
        press_at_col(0, 0, long_hold);
        repeat (20) @(posedge clk);

        // press row1 at col1, hold medium
        press_at_col(1, 1, medium_hold);
        repeat (20) @(posedge clk);

        // press row2 at col2, hold very long
        press_at_col(2, 2, long_hold);
        repeat (20) @(posedge clk);

        // quick press on row3 at col3
        press_at_col(3, 3, short_hold);

        // finish after some time
        repeat (200) @(posedge clk);
        $display("Testbench finished at time %0t", $time);
        $finish;
    end

    // print when the DUT signals a debounced event (hierarchical access)
    initial begin
        forever begin
            @(posedge DUT.debounced_event);
            $display("Debounced event at %0t: col=%b row=%b", $time, DUT.last_pressed_col, DUT.last_pressed_row);
        end
    end

endmodule
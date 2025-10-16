`timescale 1ns / 1ps


module barrido_tb;

    // Testbench signals
    logic clk;
    // match the DUT width (default WIDTH = 8)
    logic [3:0] col;

    // Instantiate the Unit Under Test (barrido)
    barrido #(1) DUT (
        .clk(clk),
        .col(col)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #20 clk = ~clk;  // 50 MHz clock (period = 20ns)
    end

    // Simulation control
    initial begin
        // Initialize
        $display("Starting simulation...");
        
        // Wait for some time to observe behavior
        #1000;  // Simulate for a sufficient amount of time to see LED changes

        // End simulation
        $display("Ending simulation...");
        $finish;
    end

    // Monitor LED changes
    initial begin
        $monitor("Time: %0dns, COLUMNA: %b", $time, col);
    end

    initial begin
        $dumpfile("barrido_tb.vcd");  // For waveform viewing
        $dumpvars(0, barrido_tb);
    end

endmodule

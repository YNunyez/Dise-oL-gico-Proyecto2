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

    // conteos usados por el stimulus: declarar en ámbito de módulo (portátil)
    integer long_hold;
    integer medium_hold;
    integer short_hold;

    // señales expuestas por el DUT
    wire integer    numero;
    wire            reset;
    wire            save;

    // Instanciar DUT
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
        .ack_read(ack_read),
        .numero(numero),
        .reset(reset),
        .save(save)
    );

    // reloj 50 MHz -> período 20 ns
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // volcado de formas de onda y encabezado
    initial begin
        $dumpfile("sistema_de_lectura_tb.vcd");
        $dumpvars(0, sistema_de_lectura_tb);
        $display("TIME(ns)\tcol    fil    pcol   prow   valid   numero reset save");
    end

    // imprimir registros y señales en cada flanco de reloj
    always @(posedge clk) begin
        $display("%0t\t%b %b %b %b %b    %0d     %b    %b",
                 $time, col, fil, pressed_col_out, pressed_row_out, pressed_valid,
                 numero, reset, save);
    end

    // tarea auxiliar
    task press_at_col(input integer row, input integer col_idx, input integer hold_cycles);
        reg [WIDTH-1:0] target;
        reg [WIDTH-1:0] target_row;
        integer i;
    begin
        target = {WIDTH{1'b0}};
        for (i = 0; i < WIDTH; i = i + 1) target[i] = (i == col_idx) ? 1'b1 : 1'b0;
        @(posedge clk);
        while (col !== target) @(posedge clk);
        target_row = {WIDTH{1'b0}};
        for (i = 0; i < WIDTH; i = i + 1) target_row[i] = (i == row) ? 1'b1 : 1'b0;
        fil = target_row;
        $display("TB: assert fil row=%0d at %0t (col target=%b)", row, $time, target);
        repeat (hold_cycles) @(posedge clk);
        fil = {WIDTH{1'b0}};
        @(posedge clk);
        $display("TB: release fil row=%0d at %0t", row, $time);
    end
    endtask

    // estímulo
    initial begin
        ack_read = 0;
        fil = {WIDTH{1'b0}};
        repeat (10) @(posedge clk);

        // inicializar contadores
        long_hold   = 100;
        medium_hold = 40;
        short_hold  = 10;

        press_at_col(2, 0, long_hold);
        repeat (50) @(posedge clk);
        if (pressed_valid) begin
            $display("TB: latched -> pcol=%b prow=%b numero=%0d reset=%b save=%b at %0t",
                     pressed_col_out, pressed_row_out, numero, reset, save, $time);
            ack_read = 1;
            @(posedge clk);
            ack_read = 0;
        end

        press_at_col(0, 0, medium_hold);
        repeat (50) @(posedge clk);
        if (pressed_valid) begin
            $display("TB: latched -> pcol=%b prow=%b numero=%0d reset=%b save=%b at %0t",
                     pressed_col_out, pressed_row_out, numero, reset, save, $time);
            ack_read = 1; @(posedge clk); ack_read = 0;
        end

        // finalizar
        repeat (50) @(posedge clk);
        $display("Testbench finished at %0t", $time);
        $finish;
    end

    // timeout de seguridad (initial separado)
    initial begin
        #5000000;
        $display("TB: timeout at %0t", $time);
        $finish;
    end

endmodule
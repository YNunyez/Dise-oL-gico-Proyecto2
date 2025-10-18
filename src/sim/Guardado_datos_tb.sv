`timescale 1ns/1ps

module Guardado_datos_tb;

    logic        clk;          // Señal de reloj
    logic [3:0][3:0] numero;
    logic        guardar;
    logic [3:0][3:0] numero_sv;
    logic        rst;
    logic        rst_sv;
    logic        suma;


    // Instancia del decodificador
    Guardado_datos uut (
        .clk(clk),
        .guardar(guardar),
        .rst(rst),
        .rst_sv(rst_sv),
        .numero(numero),
        .suma(suma),
        .numero_sv(numero_sv)

    );

    // Reloj
    initial clk = 0;
    always #5 clk = ~clk;

    // Secuencia de prueba
    initial begin
        $display("=========== Test Guardado ===========");

        // Valores iniciales
        guardar = 0;
        rst_sv = 0;
        numero = '{4'd0, 4'd0, 4'd0, 4'd0};

        // Espera unos ciclos
        repeat (2) @(posedge clk); #1;

        // Primer guardado
        numero  = '{4'd2, 4'd1, 4'd6, 4'd5};  // número 2165
        guardar = 1; @(posedge clk); #1; guardar = 0;
        $display("Guardado 1    -> numero_sv=%b, suma=%b", numero_sv, suma);

        // Espera algunos ciclos
        repeat (2) @(posedge clk);

        // Segundo guardado
        numero  = '{4'd9, 4'd3, 4'd4, 4'd1};  // número 9341
        guardar = 1; @(posedge clk); #1; guardar = 0;
        $display("Guardado 2    -> numero_sv=%b, suma=%b", numero_sv, suma);

        rst_sv = 1; @(posedge clk); #1; rst_sv = 0;
        $display("Reseteo       -> numero_sv=%b, suma=%b", numero_sv, suma);

        repeat (3) @(posedge clk); #1;
        $finish;
    end

endmodule
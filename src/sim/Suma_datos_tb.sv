`timescale 1ns/1ps

module Suma_datos_tb;

    // Señales
    logic clk;
    logic suma;
    logic finalizar;
    logic ent;
    logic [3:0][3:0] numero_sv;
    logic [3:0][3:0] numero;
    logic [3:0][3:0] resultado;
    logic rst_sv;
    logic rst;

    // Instancia del módulo
    Suma_datos uut (
        .clk(clk),
        .suma(suma),
        .finalizar(finalizar),
        .numero_sv(numero_sv),
        .numero(numero),
        .resultado(resultado),
        .rst_sv(rst_sv),
        .rst(rst),
        .ent(ent)
    );

    // Generador de reloj
    initial clk = 0;
    always #5 clk = ~clk; // período de 10ns

    initial begin
        // Inicializar
        suma = 0;
        finalizar = 0;
        numero_sv = '{0, 5, 6, 7};   // ejemplo de número 4567
        numero = '{0, 1, 3, 5};   // ejemplo de número 1234

        @(posedge clk);
        $display("=========== Test Suma BCD ===========");
        $display("numero_sv = %b, %b, %b, %b", numero_sv[3], numero_sv[2], numero_sv[1], numero_sv[0]);
        $display("numero    = %b, %b, %b, %b", numero[3], numero[2], numero[1], numero[0]);

        // Activar la suma
        suma = 1;
        @(posedge clk); // esperar un ciclo
        suma = 0;

        @(posedge clk);
        $display("Resultado = %b, %b, %b, %b", resultado[3], resultado[2], resultado[1], resultado[0]);
        $display("Dato mux = %b", ent);
        $display("rst_sv = %b", rst_sv);

        // Activar reset

        $display("Finalizar");

        finalizar = 1;
        @(posedge clk);

        $display("rst_sv = %b", rst_sv);
        $display("Dato mux = %b", ent);

        $finish;
    end

endmodule

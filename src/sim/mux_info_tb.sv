`timescale 1ns/1ps

module mux_info_tb;

    // Señales de prueba
    logic clk;
    logic ent;
    logic [3:0][3:0] numero;
    logic [3:0][3:0] resultado;
    logic [3:0][3:0] s_mux;

    // Instancia del módulo a probar
    mux_info uut (
        .clk(clk),
        .ent(ent),
        .numero(numero),
        .numero_sv(numero_sv),
        .s_mux(s_mux)
    );

    // Generador de reloj (periodo de 10 ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Estímulos de prueba
    initial begin
        // Inicialización
        ent = 0;
        @(posedge clk);

        // Cargar valores de ejemplo
        numero    = '{4'd2, 4'd6, 4'd0, 4'd5}; // 2605 visualmente
        numero_sv = '{4'd1, 4'd0, 4'd4, 4'd6}; // 1046 visualmente

        // Esperar un ciclo para ver el primer valor
        @(posedge clk);
        $display("Tiempo=%0t | ent=%0b | s_mux=%b %b %b %b", $time, ent, s_mux[3], s_mux[2], s_mux[1], s_mux[0]);

        // Cambiar a la otra entrada
        ent = 1;
        @(posedge clk);
        @(posedge clk);
        $display("Tiempo=%0t | ent=%0b | s_mux=%b %b %b %b", $time, ent, s_mux[3], s_mux[2], s_mux[1], s_mux[0]);

        // Cambiar otra vez para confirmar
        ent = 0;
        @(posedge clk);
        @(posedge clk);
        $display("Tiempo=%0t | ent=%0b | s_mux=%b %b %b %b", $time, ent, s_mux[3], s_mux[2], s_mux[1], s_mux[0]);

        // Fin de simulación
        $finish;
    end

endmodule

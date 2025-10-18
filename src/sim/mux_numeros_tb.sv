`timescale 1ns/1ps

module mux_numeros_tb;

    // Señales de prueba
    logic clk;
    logic [3:0][3:0] s_mux;
    logic [3:0] s_muxfue;

    // Instancia del módulo a probar
    mux_numeros uut (
        .clk(clk),
        .s_mux(s_mux),
        .s_muxfue(s_muxfue)
    );

    // Generador de reloj (periodo de 10 ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Estímulos de prueba
    initial begin
        // Valores iniciales
        s_mux    = '{4'd2, 4'd6, 4'd0, 4'd5}; // 2605 visualmente

        // Mostrar encabezado
        $display("Tiempo | i | s_mux");
        $display("--------------------");
        $monitor("%4t | %b | %b", $time, uut.i, s_muxfue);

        // Ejecutar por 10 ciclos de reloj
        #30;
        $finish;
    end

endmodule

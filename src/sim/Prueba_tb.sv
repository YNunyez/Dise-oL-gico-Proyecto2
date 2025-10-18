`timescale 1ns/1ps

module Prueba_tb;

    // =====================================================
    // Señales del DUT (Dispositivo Bajo Prueba)
    // =====================================================
    logic clk;
    logic rst;
    logic push;
    logic guardar;
    logic [3:0] entrada;

    // =====================================================
    // Instancia del módulo principal de prueba
    // =====================================================
    Prueba DUT (
        .clk(clk),
        .rst(rst),
        .push(push),
        .guardar(guardar),
        .entrada(entrada)
    );

    // =====================================================
    // Generación de reloj
    // =====================================================
    initial clk = 0;
    always #5 clk = ~clk;  // Periodo de 10 ns

    // =====================================================
    // Proceso principal de simulación
    // =====================================================
    initial begin
        // Inicialización
        rst = 1;
        push = 0;
        guardar = 0;
        entrada = 0;
        DUT.finalizar = 0;

        @(posedge clk); #10;
        rst = 0;

        $display("[%0t] Iniciando simulacion...", $time);

        // ===================== Primer grupo =====================
        push_dato(4'd3);
        push_dato(4'd5);
        push_dato(4'd7);

        $display("[%0t] Guardando primer grupo...", $time);
        guardar_pulso();
        #40;
        // ===================== Segundo grupo =====================
        push_dato(4'd4);
        push_dato(4'd2);
        push_dato(4'd1);

        $display("[%0t] Guardando segundo grupo (activa suma)...", $time);
        guardar_pulso();
        #100;

        // ===================== Finalizar simulación =====================
        DUT.finalizar = 1;
        @(posedge clk);
        DUT.finalizar = 0;

        #50;
        $display("[%0t] Fin de simulacion.", $time);
        $finish;
    end

    // =====================================================
    // Tareas auxiliares
    // =====================================================
    // Pulso de push
    task push_dato(input logic [3:0] val);
        begin
            entrada = val;
            push = 1;
            @(posedge clk); #10;
            push = 0;
            #10;
            $display("[%0t] Push: dato ingresado = %0d", $time, val);
        end
    endtask

    // Pulso de guardar (ajustado para asegurar duración de rst_dat)
    task guardar_pulso();
        begin
            guardar = 1;
            @(posedge clk); #2;
            guardar = 0;
            #10;
        end
    endtask

    // =====================================================
    // Monitoreo de señales internas
    // =====================================================
    always @(posedge clk) begin
        $display("[%0t] numero=%b  numero_sv=%b  resultado=%b  suma=%b  ent=%b  rst_dat=%b  rst_sv=%b",
                 $time,
                 DUT.numero,
                 DUT.numero_sv,
                 DUT.resultado,
                 DUT.suma,
                 DUT.ent,
                 DUT.rst_dat,
                 DUT.rst_sv);
    end

endmodule
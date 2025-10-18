`timescale 1ns/1ps

module top_tb;

    // Señales del DUT
    logic clk;
    logic rst;
    logic push;
    logic guardar;
    logic finalizar;
    logic [3:0] entrada;
    logic [6:0] seg;

    // Instancia del módulo top
    top DUT (
        .clk(clk),
        .rst(rst),
        .push(push),
        .guardar(guardar),
        .finalizar(finalizar),
        .entrada(entrada),
        .seg(seg)
    );

    // =================== Generación de reloj ===================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Periodo = 10 ns
    end

    // =================== Proceso principal ===================
    initial begin
        // Inicialización
        rst = 1; push = 0; guardar = 0; finalizar = 0; entrada = 0;
        $display("[%0t] Iniciando simulacion, aplicando reset...", $time);
        #20;
        rst = 0;

        // =================== PRIMER GRUPO ===================
        $display("[%0t] Ingresando primer grupo de datos...", $time);
        push_dato(4'd3);
        push_dato(4'd5);
        push_dato(4'd7);

        // Guardar primer grupo
        #10;
        $display("[%0t] Guardando primer grupo...", $time);
        guardar_pulso();

        // =================== SEGUNDO GRUPO ===================
        #20; // espera a que Guardado_datos registre correctamente
        $display("[%0t] Ingresando segundo grupo de datos...", $time);
        push_dato(4'd4);
        push_dato(4'd2);
        push_dato(4'd1);

        // Guardar segundo grupo y activar suma
        #10;
        $display("[%0t] Activando suma de datos guardados...", $time);
        guardar_pulso();

        // =================== Finalización ===================
        #50;
        $display("[%0t] Finalizando operacion...", $time);
        finalizar_pulso();

        // Espera final y salida
        #50;
        $display("[%0t] Fin de simulacion.", $time);
        $finish;
    end

    // =================== Tareas auxiliares ===================

    // Pulso de push (2 ciclos de reloj para asegurar captura)
    task push_dato(input logic [3:0] val);
        begin
            entrada = val;
            push = 1;
            #20;       // dos ciclos
            push = 0;
            #10;
            $display("[%0t] Push: Dato ingresado = %0d", $time, val);
        end
    endtask

    task guardar_pulso();
        begin
            guardar = 1;
            #20;
            guardar = 0;
        end
    endtask

    task finalizar_pulso();
        begin
            finalizar = 1;
            #20;
            finalizar = 0;
        end
    endtask


    // =================== Monitoreo ===================
    // Observa los cambios de display
    always @(seg) begin
        $display("[%0t] Display (seg) cambio: %b", $time, seg);
    end

endmodule
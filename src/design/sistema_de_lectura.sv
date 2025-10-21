// sistema_de_lectura.sv
// Módulo de sistema de nivel superior que demuestra el uso de registros de diferentes tamaños
// y el módulo `barrido` existente.

//`include "sizes_pkg.sv"

module sistema_de_lectura #(
    parameter int WIDTH = 4,
    parameter int DEBOUNCE_PULSES = 3
)(
    input  logic              clk,
    output logic [WIDTH-1:0]  col,
    input  logic  [WIDTH-1:0] fil,
    // nueva interfaz de captura
    output logic [WIDTH-1:0]  pressed_col_out, // salida one-hot de la última columna aceptada
    output logic [WIDTH-1:0]  pressed_row_out, // salida one-hot de la última fila aceptada
    output logic              pressed_valid,   // activa cuando hay una pulsación capturada disponible
    input  logic              ack_read,        // el consumidor pulsa esto para limpiar pressed_valid
    output integer                numero,
    output logic              reset,
    output logic              save
);

    // barrido de columnas
    barrido #(.WIDTH(WIDTH)) barrido (
        .clk(clk),
        .col(col)
    );

    // --- sincronizar entradas en bruto al dominio de clk (2 etapas) ---
    logic [WIDTH-1:0] fil_sync1, fil_sync2, fil_prev;
    always_ff @(posedge clk) begin
        fil_sync1 <= fil;
        fil_sync2 <= fil_sync1;
        fil_prev  <= fil_sync2;
    end

    // detección de flancos (flancos ascendentes en filas)
    logic [WIDTH-1:0] fil_rise;
    assign fil_rise = fil_sync2 & ~fil_prev;

    // --- captura de pulsación + antirrebote entre rotaciones ---
    logic                press_pending = 1'b0;
    logic [WIDTH-1:0]    pressed_row_oh;
    logic [WIDTH-1:0]    pressed_col_oh;      // instantánea de col en la primera detección
    int unsigned         confirm_count = 0;

    // salidas / estado
    logic                debounced_event;
    logic [WIDTH-1:0]    last_pressed_col;
    logic [WIDTH-1:0]    last_pressed_row;

    // inicializar salidas de captura
    initial begin
        pressed_col_out = '0;
        pressed_row_out = '0;
        pressed_valid   = 1'b0;
        numero = 0;
        reset = 1'b0;
        save = 1'b0;
    end

    always_ff @(posedge clk) begin
        debounced_event <= 1'b0;

        if (!press_pending) begin
            if (|fil_rise) begin
                // capturar qué fila subió y qué columna estaba activa en ese momento
                press_pending    <= 1'b1;
                pressed_row_oh   <= fil_rise;
                pressed_col_oh   <= col;
                confirm_count    <= 0;
            end
        end else begin
            // cuando la columna capturada aparece, verificar la entrada de fila
            if (|(pressed_col_oh & col)) begin
                if (|(pressed_row_oh & fil_sync2)) begin
                    // confirmación: en esta visita de columna la fila lee alto
                    confirm_count <= confirm_count + 1;
                    if (confirm_count + 1 >= DEBOUNCE_PULSES) begin
                        // pulsación aceptada después del antirrebote
                        debounced_event   <= 1'b1;
                        last_pressed_col  <= pressed_col_oh;
                        last_pressed_row  <= pressed_row_oh;
                        press_pending     <= 1'b0;
                        confirm_count     <= 0;

                        // activar hacia afuera (solo si el consumidor no ha leído el anterior)
                        if (!pressed_valid) begin
                            pressed_col_out <= pressed_col_oh;
                            pressed_row_out <= pressed_row_oh;
                            pressed_valid   <= 1'b1;
                        end
                    end
                end else begin
                    // confirmación fallida para esta visita -> resetear contador y seguir esperando
                    confirm_count <= 0;
                end
            end

            // opcional: si la fila se libera completamente antes de la confirmación, cancelar
            if (!(|(
                pressed_row_oh & fil_sync2
            ))) begin
                // si la fila está estable en bajo por un período largo puedes cancelar;
                // dejado simple: solo limpiamos en aceptación explícita o lógica externa
            end
        end

        // ack limpia valid (síncrono)
        if (ack_read)
            pressed_valid <= 1'b0;
    end
    
    always_ff @(posedge clk) begin
        // Resetear banderas por defecto
    //    reset <= 1'b0;
    //    save <= 1'b0;
        case({pressed_col_oh, pressed_row_oh})
            8'b1000_1000 : numero <= 1; // columna 0, fila 0 = 1
            8'b0100_1000 : numero <= 2; // columna 1, fila 0 = 2
            8'b0010_1000 : numero <= 3; // columna 2, fila 0 = 3

            8'b1000_0100 : numero <= 4; // columna 0, fila 1 = 4
            8'b0100_0100 : numero <= 5; // columna 1, fila 1 = 5
            8'b0010_0100 : numero <= 6; // columna 2, fila 1 = 6

            8'b1000_0010 : numero <= 7; // columna 0, fila 2 = 7
            8'b0100_0010 : numero <= 8; // columna 1, fila 2 = 8
            8'b0010_0010 : numero <= 9; // columna 2, fila 2 = 9

            8'b1000_0001 : reset <= 1'b1; // columna 0, fila 3 = * 
            8'b0100_0001 : numero <= 0; // columna 1, fila 3 = 0
            8'b0010_0001 : save <= 1'b1; // columna 2, fila 3 = # 
            default      : begin
                // No hay acción para combinaciones inválidas
            end
        endcase
        //if (debounced_event) begin
        //end
        // Solo actualizar cuando se detecta una pulsación válida
    end
    // (opcional) exponer debounced_event como salida o conectar a otra lógica
    // ...código existente...
endmodule

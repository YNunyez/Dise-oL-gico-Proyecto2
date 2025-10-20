// sistema_de_lectura.sv
// Top-level system module that demonstrates using registers of different sizes
// and the existing `barrido` module.

//`include "sizes_pkg.sv"

module sistema_de_lectura #(
    parameter int WIDTH = 4,
    parameter int DEBOUNCE_PULSES = 3
)(
    input  logic              clk,
    output logic [WIDTH-1:0]  col,
    input  logic  [WIDTH-1:0] fil,
    output logic [WIDTH-1:0]  pressed_col_out,
    output logic [WIDTH-1:0]  pressed_row_out,
    output logic              pressed_valid,
    input  logic              ack_read
);

    // scanner (barrido) -- debe existir el módulo barrido en el proyecto
    barrido #(.WIDTH(WIDTH)) u_barrido (
        .clk(clk),
        .col(col)
    );

    // --- sincronizador 2 etapas para 'fil' (por bit) ---
    logic [WIDTH-1:0] fil_sync1, fil_sync2, fil_prev;
    always_ff @(posedge clk) begin
        fil_sync1 <= fil;
        fil_sync2 <= fil_sync1;
        fil_prev  <= fil_sync2;
    end
    // flanco 0->1 detectado por bit
    logic [WIDTH-1:0] fil_rise = fil_sync2 & ~fil_prev;

    // --- captura inicial (detectar qué fila subió y qué columna estaba activa) ---
    logic press_pending;
    logic [WIDTH-1:0] pressed_row_oh;   // one-hot row detected at first edge
    logic [WIDTH-1:0] pressed_col_oh;   // snapshot of col at detection
    integer confirm_count;

    // registros latched (salida)
    initial begin
        pressed_col_out = '0;
        pressed_row_out = '0;
        pressed_valid   = 1'b0;
        press_pending   = 1'b0;
        confirm_count   = 0;
    end
//    logic DB_out;
//DeBounce_v deBounce_v_inst (
//    .clk(clk),
//    .button_in(|(pressed_row_oh)),
//    .DB_out(DB_out)
//);
    // FSM: 1) detectar primer flanco, 2) confirmar sólo la fila capturada
    always_ff @(posedge clk) begin
        if (!press_pending) begin
            // primera detección de subida en cualquiera de las filas
            if (|fil_rise) begin
                press_pending    <= 1'b1;
                pressed_row_oh   <= fil_rise; // which row rose
                pressed_col_oh   <= col;      // which column was active
                confirm_count    <= 0;
            end
        end else begin
            // cuando la columna capturada vuelve a aparecer evaluamos la fila capturada
            if (|(pressed_col_oh & col)) begin
                // comprueba sólo la fila capturada: si está alta en esta visita cuenta como confirmación
                if (|(pressed_row_oh & fil_sync2)) begin
                    confirm_count <= confirm_count + 1;
                    if (confirm_count + 1 >= DEBOUNCE_PULSES) begin
                        // aceptación: latch de salida si no hay dato vigente
                        if (!pressed_valid) begin
                            pressed_col_out <= pressed_col_oh;
                            pressed_row_out <= pressed_row_oh;
                            pressed_valid   <= 1'b1;
                        end
                        press_pending <= 1'b0;
                        confirm_count <= 0;
                    end
                end else begin  
                    // falla confirmación en esta visita -> reset contador
                    confirm_count <= 0;
                end
            end
            // opcional: añadir timeout o cancelación si la fila baja permanentemente
        end

        // ack limpia la validez (consumer)
        if (ack_read)
            pressed_valid <= 1'b0;
    end

endmodule

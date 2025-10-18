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
    output logic [WIDTH-1:0]  pressed_col_out, // puerto -- NO redeclarar internamente
    output logic [WIDTH-1:0]  pressed_row_out, // puerto -- NO redeclarar internamente
    output logic              pressed_valid,   // puerto -- NO redeclarar internamente
    input  logic              ack_read         // consumer pulses this to clear pressed_valid
);

    // barrido instancia (debe existir en el proyecto)
    barrido #(.WIDTH(WIDTH)) u_barrido (
        .clk(clk),
        .col(col)
    );

    // --- reemplazo: usar el módulo `debounce` para obtener niveles estables por fila ---
    // Debouncer vectorial: entrega niveles estables por bit en el dominio 'clk'
    logic [WIDTH-1:0] pb_db;       // debounced level per row
    debounce #(.WIDTH(WIDTH), .THRESH(DEBOUNCE_PULSES)) u_debounce (
        .pb_1(fil),
        .clk(clk),
        .pb_out(pb_db)
    );

    // detectar flanco 0->1 sobre la salida debounced
    logic [WIDTH-1:0] pb_prev;
    always_ff @(posedge clk) pb_prev <= pb_db;
    logic [WIDTH-1:0] pb_rise = pb_db & ~pb_prev;

    // estado de captura / debounce (se usan directamente los puertos de salida)
    logic press_pending;
    logic [WIDTH-1:0] pressed_row_oh;
    logic [WIDTH-1:0] pressed_col_oh;
    integer confirm_count;

    // inicialización para simulación (opcional pero útil)
    initial begin
        pressed_col_out = '0;
        pressed_row_out = '0;
        pressed_valid   = 1'b0;
        press_pending   = 1'b0;
        confirm_count   = 0;
    end

    // --- reemplazo: usar módulos `register` para guardar la columna/fila aceptadas ---
    // señales d (entrada) para los registros
    logic [WIDTH-1:0] reg_col_d;
    logic [WIDTH-1:0] reg_row_d;

    // Al aceptar la pulsación, cargamos las entradas de los registros en lugar de
    // asignar directamente a los puertos pressed_col_out/pressed_row_out.
    // (Aquí solo se muestra la modificación en la rama de aceptación)
    always_ff @(posedge clk) begin
        // por defecto no generar evento transitorio
        if (!press_pending) begin
            if (|pb_rise) begin
                press_pending  <= 1'b1;
                pressed_row_oh <= pb_rise;
                pressed_col_oh <= col;
                confirm_count  <= 0;
            end
        end else begin
            // cuando el column snapshot aparece, confirmar el row
            if (|(pressed_col_oh & col)) begin
                if (|(pressed_row_oh & pb_db)) begin
                    confirm_count <= confirm_count + 1;
                    if (confirm_count + 1 >= DEBOUNCE_PULSES) begin
                        // aceptar: cargar d's para los registros y señalizar valid
                        if (!pressed_valid) begin
                            reg_col_d    <= pressed_col_oh;   // nueva carga al registro de columna
                            reg_row_d    <= pressed_row_oh;   // nueva carga al registro de fila
                            pressed_valid<= 1'b1;
                        end
                        press_pending <= 1'b0;
                        confirm_count <= 0;
                    end
                end else begin
                    confirm_count <= 0;
                end
            end
        end

        // ack del consumidor limpia la bandera
        if (ack_read)
            pressed_valid <= 1'b0;
    end

    // instanciar los registros que mantienen el valor latched
    // Asumo que tu módulo `register` tiene la interfaz (clk, d, q).
    // Si la firma real difiere, ajusta los nombres de puerto.
    register #(.WIDTH(WIDTH)) reg_col (
        .clk(clk),
        .d(reg_col_d),
        .q(pressed_col_out)
    );

    register #(.WIDTH(WIDTH)) reg_row (
        .clk(clk),
        .d(reg_row_d),
        .q(pressed_row_out)
    );

endmodule

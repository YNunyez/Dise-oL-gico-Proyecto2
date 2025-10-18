module Guardado_datos (
    input  logic        clk,
    input  logic        rst,         // reset global
    input  logic [3:0][3:0] numero,
    input  logic        guardar,
    input  logic        rst_sv,
    output logic [3:0][3:0] numero_sv,
    output logic        suma,
    output logic        rst_dat
);

    logic conteo; // 0 = espera primer guardar, 1 = espera segundo guardar
    logic conteo1; //señal de rst dure 2 ciclos

    initial begin
        conteo <= 0;
        conteo1 <= 1;
        rst_dat <= 0;
        suma <= 0;
        numero_sv <= 0;
    end

    always_ff @(posedge clk) begin
        if (rst || rst_sv) begin
            numero_sv <= 0;
            suma <= 0;
            conteo <= 0;
            rst_dat <= 0;
        end
        else if (guardar) begin
            if (conteo == 0) begin // Primer pulso de guardar (captura datos)
                numero_sv <= numero;
                rst_dat <= 1;  // pulso para Push_datos
                conteo <= 1;
                suma <= 0;
            end
            else begin // Segundo pulso de guardar (activa suma)
                suma <= 1;
                conteo <= 0;   // lista para siguiente ciclo de guardar
            end
        end
        else begin // Reset de señales cuando no hay guardar
            suma <= 0;
            rst_dat <= 0;
        end
    end
endmodule


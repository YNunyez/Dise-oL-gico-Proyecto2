module Suma_datos (
    input  logic        clk,          // Señal de reloj
    input  logic        suma,
    input  logic        finalizar,
    input  logic [3:0][3:0] numero_sv,
    input  logic [3:0][3:0] numero,
    output logic [3:0][3:0] resultado,
    output logic        rst_sv,
    output logic        ent
    
);

    logic [4:0] calc;
    integer i;
    logic carreo;

    initial begin
        for (i = 0; i < 4; i = i + 1)
            resultado[i] = 4'd0;
        ent <= 0;
    end

    always_ff @(posedge clk) begin

        if(finalizar) begin
            rst_sv <= 1;
            ent <= 0;
            for (i = 0; i < 4; i = i + 1)
                resultado[i] = 4'd0;
        end
        else begin
            rst_sv <= 0;
        end
        if (suma) begin
            carreo = 0;
            for(i = 0; i < 4; i++) begin
                calc = numero_sv[i] + numero[i] + carreo;
                if (calc >= 10) begin
                    calc = calc - 10;
                    carreo = 1;
                end
                else begin
                    carreo = 0;
                end
                resultado[i] <= calc[3:0];
            end
            ent <= 1;  // marca el resultado listo un ciclo
        end

    end
endmodule
module Push_datos (
    input  logic        clk,
    input  logic        rst,        // reset global
    input  logic        rst_dat,
    input  logic        push,
    input  logic [3:0]  entrada,
    output logic [3:0][3:0] numero
);

    logic [3:0] celdas [2:0];   // flip-flops en serie
    logic [1:0] conteo;          // limita a 3 pushes
    integer i;

    initial begin
        conteo = 0;
        numero[3] = 0; //Nunca va a ser un valor diferente a 0 salvo en suma
        for (i = 0; i < 3; i = i + 1)
            celdas[i] = 0;
    end

    always_ff @(posedge clk) begin
        if (rst || rst_dat) begin
            conteo <= 0;
            for (i = 0; i < 3; i = i + 1)
                celdas[i] <= 0;
        end
        else if (push && conteo < 3) begin // desplazamiento de dato
            for (i = 2; i > 0; i = i - 1)
                celdas[i] <= celdas[i-1];
            celdas[0] <= entrada;
            conteo <= conteo + 1;
        end
    end

    // salida refleja las celdas
    assign numero[0] = celdas[0];
    assign numero[1] = celdas[1];
    assign numero[2] = celdas[2];

endmodule
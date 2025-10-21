module Prueba (
    input  logic        clk,
    input  logic        rst,
    input  logic        push,
    input  logic        guardar,
    input  logic [3:0]  entrada
);

    logic [3:0][3:0] numero;        
    logic [3:0][3:0] numero_sv;        
    logic suma;                           
    logic rst_dat;           
    logic rst_sv;
    logic [3:0][3:0] resultado;
    logic ent;
    logic finalizar;

    //=======================================================
    // Instancia: Push_datos
    //=======================================================
    Push_datos Push_datos (
        .clk      (clk),
        .rst      (rst),
        .push     (push),
        .entrada  (entrada),
        .rst_dat  (rst_dat),
        .numero   (numero)
    );

    //=======================================================
    // Instancia: Guardado_datos
    //=======================================================
    Guardado_datos Guardado_datos (
        .clk       (clk),
        .numero    (numero),
        .guardar   (guardar),
        .rst_sv    (rst_sv),    
        .numero_sv (numero_sv),
        .suma      (suma),
        .rst_dat   (rst_dat),
        .rst       (rst)
    );

    //=======================================================
    // Instancia: Suma_datos
    //=======================================================
    Suma_datos Suma_datos (
        .clk        (clk),
        .suma       (suma),
        .numero_sv  (numero_sv),
        .numero     (numero),
        .resultado  (resultado),
        .rst_sv     (rst_sv),
        .ent        (ent)
    );

endmodule
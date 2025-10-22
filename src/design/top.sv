module top (
    input  logic        clk,
    input  logic        rst,
    input  logic        push,
    input  logic        guardar,
    input  logic [3:0]  entrada,
    output logic [6:0]  seg,
    input  logic        fil
);

    logic [3:0][3:0] numero;        
    logic [3:0][3:0] numero_sv;     
    logic [3:0][3:0] resultado;     
    logic [3:0][3:0] s_mux;         
    logic [3:0]      s_muxfue;      

    logic suma;                  
    logic rst_sv_g;            
    logic rst_sv_s;           
    logic rst_s;           
    logic ent;             

    //=======================================================
        // Instancia: Push_datos
        //=======================================================
        sistema_de_lectura sistema_de_lectura (
            .clk      (clk),
            .ack_read (rst),
            .fil      (fil),
            .rst      (rst)
        );


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
        .finalizar  (finalizar),
        .numero_sv  (numero_sv),
        .numero     (numero),
        .resultado  (resultado),
        .rst_sv     (rst_sv),
        .ent        (ent)
    );

    //=======================================================
    // Instancia: mux_info
    //=======================================================
    mux_info mux_info (
        .clk        (clk),
        .ent        (ent),
        .numero     (numero),
        .resultado  (resultado),
        .s_mux      (s_mux)
    );

    //=======================================================
    // Instancia: mux_numeros
    //=======================================================
    logic [3:0][3:0] s_mux_vec;  // para simulación

    mux_numeros mux_numeros (
        .clk(clk),
        .s_mux(s_mux),
        .s_muxfue(s_muxfue)
    );


    //=======================================================
    // Instancia: display7
    //=======================================================
    display7 display7 (
        .s_muxfue   (s_muxfue),  // muestra un dígito (puedes cambiar el índice si quieres otro)
        .seg        (seg)
    );

endmodule
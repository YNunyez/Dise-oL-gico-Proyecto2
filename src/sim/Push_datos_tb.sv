`timescale 1ns/1ps

module Push_datos_tb;

    logic clk;
    logic [3:0] entrada;
    logic       rst;
    logic       rst_dat;    
    logic       push;         
    logic [3:0][3:0] numero;
    logic       guardado;

    // Instancia del codificador
    Push_datos uut (
        .clk(clk),
        .entrada(entrada),
        .push(push),
        .rst(rst),
        .rst_dat(rst_dat),
        .numero(numero)
    );

    // Generador de reloj
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin

        $display("=========== Test Push ===========");
        rst = 1; 
        @(posedge clk); #1; 
        rst = 0;
        @(posedge clk); #1; 
        entrada = 4'b1010; push = 1; @(posedge clk); #1; push = 0;
        $display("Entrada=%b | salida=%b, %b, %b, %b", entrada, numero[3], numero[2], numero[1], numero[0]);
        entrada = 4'b0010; push = 1; @(posedge clk); #1; push = 0;
        $display("Entrada=%b | salida=%b, %b, %b, %b", entrada, numero[3], numero[2], numero[1], numero[0]);
        entrada = 4'b1101; push = 1; @(posedge clk); #1; push = 0;
        $display("Entrada=%b | salida=%b, %b, %b, %b", entrada, numero[3], numero[2], numero[1], numero[0]);
        guardado = 1; @(posedge clk); #1; guardado = 0;
        entrada = 4'b1001; push = 1; @(posedge clk); #1; push = 0;
        $display("Entrada=%b | salida=%b, %b, %b, %b", entrada, numero[3], numero[2], numero[1], numero[0]);
        rst_dat = 1; 
        @(posedge clk); #1;
        rst_dat = 0;
        @(posedge clk); #1;
        $display("Entrada= -   | salida=%b, %b, %b, %b", numero[3], numero[2], numero[1], numero[0]);

        entrada = 4'b1000; push = 1; @(posedge clk); #1; push = 0;
        $display("Entrada=%b | salida=%b, %b, %b, %b", entrada, numero[3], numero[2], numero[1], numero[0]);
        entrada = 4'b0000; push = 1; @(posedge clk); #1; push = 0;
        $display("Entrada=%b | salida=%b, %b, %b, %b", entrada, numero[3], numero[2], numero[1], numero[0]);
        entrada = 4'b1101; push = 1; @(posedge clk); #1; push = 0;
        $display("Entrada=%b | salida=%b, %b, %b, %b", entrada, numero[3], numero[2], numero[1], numero[0]);
        guardado = 1; @(posedge clk); #1; guardado = 0;
        entrada = 4'b1111; push = 1; @(posedge clk); #1; push = 0;
        $display("Entrada=%b | salida=%b, %b, %b, %b", entrada, numero[3], numero[2], numero[1], numero[0]);


        $finish;
    end

endmodule

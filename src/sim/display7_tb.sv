`timescale 1ns/1ns

module display7_tb;

    reg [3:0] p;
    wire [6:0] seg;

    display7 dut (
        .s_mux(p),
        .seg(seg)
    );

// Generación de estímulos
    initial begin
        $monitor("Tiempo = %tns, Entrada = %b, Salida = %b", $time , p, seg);
        p = 4'b0000; #10; // Caso 0
        p = 4'b0001; #10; // Caso 1
        p = 4'b0010; #10; // Caso 2
        p = 4'b0011; #10; // Caso 3
        p = 4'b0100; #10; // Caso 4
        p = 4'b0101; #10; // Caso 5
        p = 4'b0110; #10; // Caso 6
        p = 4'b0111; #10; // Caso 7
        p = 4'b1000; #10; // Caso 8
        p = 4'b1001; #10; // Caso 9
        p = 4'b1010; #10; // Caso A
        p = 4'b1011; #10; // Caso B
        p = 4'b1100; #10; // Caso C
        p = 4'b1101; #10; // Caso D
        p = 4'b1110; #10; // Caso E
        p = 4'b1111; #10; // Caso F

    end

     initial begin
        $dumpfile("display7_tb.vcd");
        $dumpvars(0, display7_tb);
    end
endmodule
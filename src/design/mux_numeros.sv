module mux_numeros (
    input  logic clk,
    input  logic [3:0][3:0] s_mux,
    output logic [3:0]      s_muxfue
);

    logic [1:0] i;

    initial i = 0;
    initial s_muxfue = 0;

    always_ff @(posedge clk) begin
        // Rotar índice
        if (i == 2'b11)
            i <= 0;
        else
            i <= i + 1;

        // Selección del dígito
        case(i)
            2'b00: s_muxfue <= s_mux[3]; // MSB
            2'b01: s_muxfue <= s_mux[2];
            2'b10: s_muxfue <= s_mux[1];
            2'b11: s_muxfue <= s_mux[0]; // LSB
        endcase
    end
endmodule


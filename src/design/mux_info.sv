// module mux_info (
//     input  logic clk,
//     input  logic ent,
//     input  logic [3:0][3:0] numero,
//     input  logic [3:0][3:0] resultado,
//     output logic [3:0][3:0] s_mux
// );

//     // Inicialización compatible con cualquier simulador
//     initial begin
//         s_mux[0] = 4'd0;
//         s_mux[1] = 4'd0;
//         s_mux[2] = 4'd0;
//         s_mux[3] = 4'd0;
//     end

//     // Multiplexor síncrono
//     integer i;
//     always_ff @(posedge clk) begin
//         if (ent == 0) begin
//             for (i = 0; i < 4; i++) 
//                 s_mux[i] <= numero[i];
//         end 
//         else if (ent == 1) begin
//             for (i = 0; i < 4; i++) 
//                 s_mux[i] <= resultado[i];
//         end 
//         else begin
//             s_mux[0] <= 4'd0;
//             s_mux[1] <= 4'd0;
//             s_mux[2] <= 4'd0;
//             s_mux[3] <= 4'd0;
//         end
//     end

// endmodule

module mux_info (
    input  logic clk,
    input  logic ent,
    input  logic [3:0][3:0] numero,
    input  logic [3:0][3:0] resultado,
    output logic [3:0][3:0] s_mux
);

    logic [3:0][3:0] s_mux_next;
    integer i;

    always_comb begin
        if (ent == 0) begin
            for(i=0;i<4;i=i+1)
                s_mux_next[i] = numero[i];
        end else begin
            for(i=0;i<4;i=i+1)
                s_mux_next[i] = resultado[i];
        end
    end

    always_ff @(posedge clk) begin
        for(i=0;i<4;i=i+1)
            s_mux[i] <= s_mux_next[i];
    end
endmodule

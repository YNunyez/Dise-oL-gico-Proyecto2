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

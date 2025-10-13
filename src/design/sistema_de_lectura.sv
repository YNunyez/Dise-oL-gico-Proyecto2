// sistema_de_lectura.sv
// Top-level system module that demonstrates using registers of different sizes
// and the existing `barrido` module.

`include "sizes_pkg.sv"

module sistema_de_lectura (
    input  logic clk
);

    import sizes_pkg::*;

    // Example register instances with widths taken from the package
    logic [REG_WIDTH_0-1:0] d0, q0;
    logic [REG_WIDTH_1-1:0] d1, q1;
    logic [REG_WIDTH_2-1:0] d2, q2;

    // Instantiate register modules using explicit parameter for WIDTH
    register #(.WIDTH(REG_WIDTH_0)) reg0 (
        .clk(clk),
        .d(d0),
        .q(q0)
    );

    register #(.WIDTH(REG_WIDTH_1)) reg1 (
        .clk(clk),
        .d(d1),
        .q(q1)
    );

    register #(.WIDTH(REG_WIDTH_2)) reg2 (
        .clk(clk),
        .d(d2),
        .q(q2)
    );

    // Example usage of `barrido` with a width taken from one of the registers
    barrido #(.WIDTH(REG_WIDTH_2)) my_barrido (
        .clk(clk),
        .col() // left unconnected for now
    );

endmodule

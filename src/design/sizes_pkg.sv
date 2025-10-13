// sizes_pkg.sv
// Centralized package for register widths used by the system.

package sizes_pkg;

    // Default register widths for different channels/elements in the system.
    // Users can edit these constants to change sizes across the whole system.
    // Alternatively, these can be overridden at compile/synthesis time.
    localparam int REG_WIDTH_0 = 8;   // default width for register 0
    localparam int REG_WIDTH_1 = 16;  // default width for register 1
    localparam int REG_WIDTH_2 = 4;   // default width for register 2
    localparam int REG_WIDTH_3 = 32;  // default width for register 3

endpackage : sizes_pkg

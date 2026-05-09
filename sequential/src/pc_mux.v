module pc_mux(
    input  [63:0] pc_plus4,
    input  [63:0] branch_target,
    input pc_src,
    output [63:0] next_pc
);

assign next_pc = (pc_src) ? branch_target : pc_plus4;

endmodule
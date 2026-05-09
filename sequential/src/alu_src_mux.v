module alu_src_mux(
    input  [63:0] reg_data,
    input  [63:0] imm_data,
    input         ALUSrc,
    output [63:0] alu_input2
);

assign alu_input2 = (ALUSrc) ? imm_data : reg_data;

endmodule
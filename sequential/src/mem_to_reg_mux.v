module mem_to_reg_mux (
    input  [63:0] alu_result,
    input  [63:0] mem_data,
    input MemtoReg,
    output [63:0] write_back_data
);

assign write_back_data = (MemtoReg) ? mem_data : alu_result;

endmodule
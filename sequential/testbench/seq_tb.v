`timescale 1ns/1ps

`include "processor.v"
`include "pc.v"
`include "instruction_mem.v"
`include "register_file.v"
`include "data_mem.v"
`include "cu.v"
`include "alu_control.v"
`include "alu.v"
`include "alu_src_mux.v"
`include "pc_mux.v"
`include "fulladder.v"
`include "add64.v"
`include "sub64.v"
`include "and64.v"
`include "or64.v"
`include "imm_gen.v"

module seq_tb;

reg clk;
reg reset;
integer cycle_count;

processor uut (
    .clk(clk),
    .reset(reset)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1;
    cycle_count = 0;
    repeat (2) @(posedge clk);
    reset = 0;
end

always @(posedge clk) begin
    if (reset)
        cycle_count = 0;
    else
        cycle_count = cycle_count + 1;
end

always @(posedge clk) begin
    if (!reset && uut.instruction== 32'b0) begin
        uut.rf.dump_registers;
        append_cycles;
        $finish;
    end
end

task append_cycles;
    integer f;
    begin
        f = $fopen("register file.txt", "a");
        $fdisplay(f, "%0d", cycle_count);
        $fclose(f);
    end
endtask

endmodule
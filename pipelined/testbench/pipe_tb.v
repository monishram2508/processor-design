`timescale 1ns/1ns

`include "fulladder.v"
`include "add64.v"
`include "sub64.v"
`include "and64.v"
`include "or64.v"

`include "alu.v"
`include "alu_control.v"

`include "imm_gen.v"
`include "pc.v"

`include "instruction_mem.v"
`include "data_mem.v"
`include "register_file.v"

`include "cu.v"

`include "hazard_detection_unit.v"
`include "ForwardingUnit.v"

`include "IF_ID.v"
`include "ID_EX.v"
`include "EX_MEM.v"
`include "MEM_WB.v"

`include "processor.v"


module pipe_tb;

reg clk;
reg reset;
integer cycles;
integer f;
integer i;
integer k;

reg [63:0] prev_pc;

processor uut (
    .clk(clk),
    .reset(reset)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("waveforms.vcd");
    $dumpvars(0, pipe_tb);
end

initial begin
    clk = 0;
    reset = 1;
    cycles = 0;
    prev_pc = 64'hFFFFFFFFFFFFFFFF;

    #20;
    reset = 0;
end

always @(posedge clk) begin
    if (reset == 1'b0) begin
        cycles = cycles + 1;
    end
end

always @(negedge clk) begin
    if (reset == 1'b0) begin

        if (uut.instruction === 32'h00000000) begin
            cycles = cycles + 1;
            dump_and_finish();
        end

        prev_pc = uut.PC;

    end
end

task dump_and_finish;
begin

    f = $fopen("register_file.txt","w");

    for (i = 0; i < 32; i = i + 1) begin
        $fdisplay(f,"%016x", uut.RF.registers[i]);
    end

    $fdisplay(f,"%0d", cycles);

    $fclose(f);

    $finish;

end
endtask

endmodule
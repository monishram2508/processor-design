`timescale 1ns/1ps
`include "alu.v"
`include "add64.v" 
`include "sub64.v"
`include "and64.v"
`include "or64.v"
`include "fulladder.v"

module alu_tb;

    reg  [63:0] input1, input2;
    reg  [3:0]  control_signal;
    wire [63:0] result;
    wire        zero_flag;

    integer pass_count = 0;
    integer total_tests = 4;

    localparam AND_Oper = 4'b0000,
               OR_Oper  = 4'b0001,
               ADD_Oper = 4'b0010,
               SUB_Oper = 4'b0110;

    alu uut (
        .input1(input1),
        .input2(input2),
        .control_signal(control_signal),
        .result(result),
        .zero_flag(zero_flag)
    );

    task run_test;
        input [4:0] test_number;
        input [63:0] test_a, test_b, expected_result;
        input [3:0] test_control;
        input expected_zero;
        begin
            input1 = test_a;
            input2 = test_b;
            control_signal = test_control;
            #10;

            $display("Test %0d", test_number);
            $display("A = %016h", input1);
            $display("B = %016h", input2);
            $display("Result = %016h", result);
            $display("Zero Flag = %b\n", zero_flag);

            if (result === expected_result && zero_flag === expected_zero) begin
                pass_count = pass_count + 1;
                $display("Status: PASS\n");
            end
            else begin
                $display("Status: FAIL");
                $display("Expected Result = %016h", expected_result);
                $display("Expected Zero = %b\n", expected_zero);
            end
        end
    endtask

    initial begin

        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);

        pass_count = 0;

        run_test(1,
                 64'd10,
                 64'd5,
                 64'd15,
                 ADD_Oper,
                 0);

        run_test(2,
                 64'd20,
                 64'd5,
                 64'd15,
                 SUB_Oper,
                 0);

        run_test(3,
                 64'd10,
                 64'd10,
                 64'd0,
                 SUB_Oper,
                 1);

        run_test(4,
                 64'hFF00FF00FF00FF00,
                 64'h0F0F0F0F0F0F0F0F,
                 64'h0F000F000F000F00,
                 AND_Oper,
                 0);

        $display("Passed %0d/%0d tests", pass_count, total_tests);
        #10 $finish;
    end

endmodule
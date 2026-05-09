`timescale 1ns/1ps
`include "alu.v"

module alu_tb;

  reg  [63:0] a,b;
  reg  [3:0]  opcode;
  wire [63:0] result;
  wire cout, carry_flag, overflow_flag, zero_flag;


  alu_64_bit uut(
    .a(a),
    .b(b),
    .opcode(opcode),
    .result(result),
    .cout(cout),
    .carry_flag(carry_flag),
    .overflow_flag(overflow_flag),
    .zero_flag(zero_flag)
);

  localparam ADD=4'b0000;
  localparam SUB=4'b0001;
  localparam SLT=4'b0010;
  localparam SLTU=4'b0011;
  localparam XOR=4'b0100;
  localparam SRL=4'b0101;
  localparam OR=4'b0110;
  localparam AND=4'b0111;
  localparam SLL=4'b1000;
  localparam SRA=4'b1101;

  integer i;
  task check;
    input [63:0] exp;
    begin
      #1;
      if(result!==exp) begin
        $display(
          "FAIL opcode=%b (%0d) a=%h b=%h got=%h exp=%h",
          opcode,opcode,a,b,result,exp
        );
        $fatal;
      end
    end
  endtask

  initial begin
    $display("alu test start");
    a=0; b=0; opcode=ADD;  check(0);
    a=64'h7FFF_FFFF_FFFF_FFFF; b=1; opcode=ADD; check(64'h8000_0000_0000_0000);
    a=64'h8000_0000_0000_0000; b=1; opcode=SUB; check(64'h7FFF_FFFF_FFFF_FFFF);

    a=-1; b=1; opcode=SLT;  check(1);
    a=-1; b=1; opcode=SLTU; check(0);
    a=5; b=-3; opcode=SLT;  check(0);
    a=5; b=-3; opcode=SLTU; check(1);

    a=64'hF0F0; b=64'h0FF0;
    opcode=AND; check(64'h00F0);
    opcode=OR;  check(64'hFFF0);
    opcode=XOR; check(64'hFF00);

    a=64'h1;
    b=1; opcode=SLL; check(2);
    b=4; opcode=SLL; check(16);

    a=64'h8000_0000_0000_0000;
    b=1; opcode=SRL; check(64'h4000_0000_0000_0000);
    b=1; opcode=SRA; check(64'hC000_0000_0000_0000);

    a=5; b=5; opcode=SUB; #1;
    if (!zero_flag) begin
      $display("FAIL zero flag");
      $fatal;
    end

    for(i=0;i<200;i=i+1) begin
      a=$random;
      b=$random;

      opcode=ADD;  check(a+b);
      opcode=SUB;  check(a-b);
      opcode=AND;  check(a&b);
      opcode=OR;   check(a|b);
      opcode=XOR;  check(a^b);
      opcode=SLL;  check(a<<b[5:0]);
      opcode=SRL;  check(a>>b[5:0]);
      opcode=SRA;  check($signed(a)>>>b[5:0]);
      opcode=SLT;  check(($signed(a)<$signed(b))?1:0);
      opcode=SLTU; check((a<b)?1:0);
    end

    $display("all tests passed");
    $finish;
  end

endmodule
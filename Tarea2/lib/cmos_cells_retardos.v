module BUF_R(A, Y);
  input A;
  output Y;
  assign #0.001 Y = A;
endmodule

module NOT_R(A, Y);
  input A;
  output Y;
  assign #0.0117 Y = ~A;
endmodule

module NAND_R(A, B, Y);
  input A, B;
  output Y;
  assign #0.05 Y = ~(A & B);
endmodule

module NOR_R(A, B, Y);
  input A, B;
  output Y;
  assign #0.07 Y = ~(A | B);
endmodule

module DFF_R(C, D, Q);
  input C, D;
  output reg Q;
  always @(posedge C) #0.8 Q <= D;
endmodule
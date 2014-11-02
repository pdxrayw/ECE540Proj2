// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module nexys4fpga(clk, btnL, btnR, btnU, btnD, btnC, btnCpuReset, sw, led, seg, dp, an, JA, Hsync, Vsync, vgaRed, vgaGreen, vgaBlue);
  input clk;
  input btnL;
  input btnR;
  input btnU;
  input btnD;
  input btnC;
  input btnCpuReset;
  input [15:0]sw;
  output [15:0]led;
  output [6:0]seg;
  output dp;
  output [7:0]an;
  output [7:0]JA;
  output Hsync;
  output Vsync;
  output [3:0]vgaRed;
  output [3:0]vgaGreen;
  output [3:0]vgaBlue;
endmodule

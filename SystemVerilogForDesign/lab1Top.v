`include "memoryModule.v"
`include "LC3.v"
//`default_nettype none

module top(clk, rst);

input clk, rst;

wire [15:0] Buss;
wire ldMAR, memWE, selMDR, ldMDR, enaMDR;

//Bus is in multiple locations because we are reading from it and writing to it
//Probably a better way to simulate this, but this works for now
LC3 lc3_0(clk, rst, Buss, Buss, Buss, Buss, ldMAR, memWE, selMDR, ldMDR, enaMDR);
Memory mem0(Buss, Buss, clk, rst, ldMAR, ldMDR, selMDR, memWE, enaMDR);

endmodule 
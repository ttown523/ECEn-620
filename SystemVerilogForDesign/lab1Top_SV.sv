//`default_nettype none
`include "LC3_SV.sv"
`include "memoryModule_SV.sv"

module top_sv(clk, rst);

input clk, rst;

wire [15:0] Buss;
logic ldMAR, memWE, selMDR, ldMDR, enaMDR;

//Bus is in multiple locations because we are reading from it and writing to it
//Probably a better way to simulate this, but this works for now
LC3_sv lc3_0(clk, rst, Buss, Buss, Buss, Buss, ldMAR, memWE, selMDR, ldMDR, enaMDR);
Memory_sv mem0(Buss, Buss, clk, rst, ldMAR, ldMDR, selMDR, memWE, enaMDR);

endmodule 

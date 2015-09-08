//`default_nettype none
module Memory_sv(mdrOut, Buss, clk, reset, ldMAR, ldMDR, selMDR, memWE, enaMDR);

input [15:0] Buss;
input clk, reset, ldMAR, selMDR, ldMDR, memWE, enaMDR;

output [15:0] mdrOut;				 
logic [15:0] MARReg, memOut, mdrReg;

MAR_sv MAR0(Buss, clk, reset, ldMAR, MARReg);	  
MDR_sv MDR0(Buss, memOut, selMDR, clk, reset, ldMDR, mdrReg);

ts_driver tsMDR ( mdrReg, mdrOut, enaMDR );

//Make a typedef for this as well?
logic [15:0] my_memory [0:255];		

initial
begin  
$readmemb("Memory_fill.v", my_memory); 
end 
assign memOut = my_memory[MARReg]; 	   
always_ff @(posedge clk) 
begin		  	 
	 if (memWE == 1)
		my_memory[MARReg] <= mdrReg; 

end

endmodule
   

module MAR_sv(Buss, clk, reset, ldMAR, MAR);

input [15:0] Buss;
input clk, reset, ldMAR;
output logic [15:0] MAR;
 
  always_ff @(posedge clk or posedge reset) 
    if (reset == 1'b1) 										   
			MAR = 0; 
	else if (ldMAR)
			MAR = Buss;								 					
endmodule				


module MDR_sv(Buss, memOut, selMDR, clk, reset, ldMDR, MDR);

input [15:0] Buss, memOut;
input clk, reset, ldMDR, selMDR;
output logic [15:0] MDR;

  always_ff @(posedge clk or posedge reset) 
    if (reset == 1'b1) 										   
			MDR = 0; 
	else if (ldMDR)
			MDR = selMDR ? memOut : Buss;		
endmodule

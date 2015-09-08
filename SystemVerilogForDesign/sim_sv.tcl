#compile the verilog files, and open the simulator 
vlog -novopt lab1Top_SV.sv 
vsim -novopt top_sv

#script to add signals that we want to view during simulation
do wave_sv.do

#set clk and rst signals (these are in the top level)
force clk 0 0ns, 1 5ns -repeat 10ns
force rst 1 0ns, 0 30ns 

#run through the LC3 instructions found in Memory_fill.v 
run 900 ns

#set the zoom settings to the beginning of the simulation
WaveRestoreZoom {0 ns} {128 ns}
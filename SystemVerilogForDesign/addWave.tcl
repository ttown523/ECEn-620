#add top level waveforms
add wave clk
add wave rst
add wave Buss

#state machine waveforms
add wave top_sv/lc3_0/curState
add wave top_sv/lc3_0/nextState

#Waveforms for fetching instructions as well as memory operations 
add wave top_sv/lc3_0/IR
add wave top_sv/lc3_0/PC
add wave top_sv/mem0/MDR0/MDR
add wave top_sv/mem0/MARReg

#add ALU waveforms
add wave top_sv/lc3_0/alu0/sr2mux
add wave top_sv/lc3_0/alu0/aluControl
add wave top_sv/lc3_0/alu0/aluOut

#register file waveforms
add wave top_sv/lc3_0/reg0/Rb
add wave top_sv/lc3_0/reg0/Ra
add wave top_sv/lc3_0/reg0/DR
add wave top_sv/lc3_0/reg0/SR1
add wave top_sv/lc3_0/reg0/SR2
add wave top_sv/lc3_0/reg0/regWE

#eab waveforms
add wave top_sv/lc3_0/eab0/eabOut
add wave top_sv/lc3_0/eab0/selEAB1
add wave top_sv/lc3_0/eab0/selEAB2
add wave top_sv/lc3_0/eab0/addr1mux
add wave top_sv/lc3_0/eab0/addr2mux

#PC waveforms
add wave top_sv/lc3_0/pc0/selPC

#NZP waveforms
add wave top_sv/lc3_0/nzp0/N
add wave top_sv/lc3_0/nzp0/Z
add wave top_sv/lc3_0/nzp0/P
add wave top_sv/lc3_0/nzp0/flagWE

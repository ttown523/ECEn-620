onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_sv/clk
add wave -noupdate /top_sv/rst
add wave -noupdate /top_sv/Buss
add wave -noupdate /top_sv/lc3_0/curState
add wave -noupdate /top_sv/lc3_0/nextState
add wave -noupdate /top_sv/lc3_0/IR
add wave -noupdate /top_sv/lc3_0/PC
add wave -noupdate /top_sv/mem0/MDR0/MDR
add wave -noupdate /top_sv/mem0/MARReg
add wave -noupdate /top_sv/lc3_0/alu0/sr2mux
add wave -noupdate /top_sv/lc3_0/alu0/aluControl
add wave -noupdate /top_sv/lc3_0/alu0/aluOut
add wave -noupdate /top_sv/lc3_0/reg0/Rb
add wave -noupdate /top_sv/lc3_0/reg0/Ra
add wave -noupdate /top_sv/lc3_0/reg0/DR
add wave -noupdate /top_sv/lc3_0/reg0/SR1
add wave -noupdate /top_sv/lc3_0/reg0/SR2
add wave -noupdate /top_sv/lc3_0/reg0/regWE
add wave -noupdate /top_sv/lc3_0/eab0/eabOut
add wave -noupdate /top_sv/lc3_0/eab0/selEAB1
add wave -noupdate /top_sv/lc3_0/eab0/selEAB2
add wave -noupdate /top_sv/lc3_0/eab0/addr1mux
add wave -noupdate /top_sv/lc3_0/eab0/addr2mux
add wave -noupdate /top_sv/lc3_0/pc0/selPC
add wave -noupdate /top_sv/lc3_0/nzp0/N
add wave -noupdate /top_sv/lc3_0/nzp0/Z
add wave -noupdate /top_sv/lc3_0/nzp0/P
add wave -noupdate /top_sv/lc3_0/nzp0/flagWE
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 197
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
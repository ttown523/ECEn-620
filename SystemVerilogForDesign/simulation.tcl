restart
add wave clk
add wave rst
add wave Buss
add wave top/lc3_0/curState
add wave top/lc3_0/nextState
add wave top/lc3_0/IR
add wave top/mem0/MDR0/MDR
add wave top/lc3_0/reg0/Rb
add wave top/lc3_0/reg0/Ra
add wave top/lc3_0/alu0/Ra
add wave top/lc3_0/alu0/Rb


force clk 0 0ns, 1 5ns -repeat 10ns
force rst 1 0ns, 0 30ns 

run 500 ns


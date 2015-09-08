#Add these once the testbench is finished  
#vsim -novopt EAB_sv ;
#view wave

delete wave *
add wave *

set testFailed 0 

force IR 11'b00011001100 
force PC 16'hAAAA 
force Ra 16'h5555 

puts "Selecting PC + 0..."
force selEAB1 0
force selEAB2 2'b00
run 10ns
set expected aaaa
set recieved [examine -radix hex eabOut]
if { $recieved != $expected } {
	set testFailed 1
}

if { $testFailed == 0 } {
	puts "Selecting Ra + 0..."
	force selEAB1 1
	force selEAB2 2'b00
	run 10ns
	set expected 5555
	set recieved [examine -radix hex eabOut]
	if { $recieved != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Selecting PC + IR(5:0)..."
	force selEAB1 0
	force selEAB2 2'b01
	run 10ns
	set expected aab6
	set recieved [examine -radix hex eabOut]
	if { $recieved != $expected } {
		#set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Selecting Ra + IR(5:0)..."
	force selEAB1 1
	force selEAB2 2'b01
	run 10ns
	set expected 5561
	set recieved [examine -radix hex eabOut]
	if { $recieved != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Selecting PC + IR(8:0)..."
	force selEAB1 0
	force selEAB2 2'b10
	run 10ns
	set expected ab76
	set recieved [examine -radix hex eabOut]
	if { $recieved != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Selecting Ra + IR(8:0)..."
	force selEAB1 1
	force selEAB2 2'b10
	run 10ns
	set expected 5621
	set recieved [examine -radix hex eabOut]
	if { $recieved != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Selecting PC + IR(10:0)..."
	force selEAB1 0
	force selEAB2 2'b11
	run 10ns
	set expected ab76
	set recieved [examine -radix hex eabOut]
	if { $recieved != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Selecting Ra + (10:0)..."
	force selEAB1 1
	force selEAB2 2'b11
	run 10ns
	set expected 5621
	set recieved [examine -radix hex eabOut]
	if { $recieved != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 1 } {
	puts "Error! Simulation failed
	Expected Result = $expected 
	Obtained Result = $received";
} else {
	puts "All Tests Passed!"
}




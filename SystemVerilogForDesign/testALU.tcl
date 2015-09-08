#Add these once the testbench is finished  
#vsim -novopt ALU_sv ;
#view wave

delete wave * 
add wave *

set testFailed 0
puts "Setting Ra = 0x0000, Rb = 0x0000, IR = 000000..."
 
force Ra 16'h0000 
force Rb 16'h0000 
force IR 000000
force aluControl 00
run 10ns

puts "Performing ALU PASS..." 
set expected 0x0000
set received [examine aluOut] 

if { $received != $expected } {
	testFailed = 1;
}

if { $testFailed == 0 } {
	force aluControl 01
	run 10ns
	puts "Performing ALU ADD..." 
	set expected 0x0000
	set received [examine aluOut] 

	if { $received != $expected } {
		testFailed = 1;
	}
}

if { $testFailed == 0 } {
	force aluControl 10
	run 10ns
	puts "Performing ALU AND..." 
	set expected 0x0000
	set received [examine aluOut] 

	if { $received != $expected } {
		testFailed = 1;
	}
}

if { $testFailed == 0 } {
	force aluControl 11
	run 10ns
	puts "Performing ALU NOT..." 
	set expected ffff
	set received [examine -radix hex aluOut] 

	if { $received != $expected } {
		testFailed = 1;
	}
}

if { $testFailed == 0 } {
	puts "Setting Ra = 0xA5A5, Rb = 0x0055..."

	force Ra 16'hA5A5 
	force Rb 16'h0055 
	force aluControl 00
	run 10ns

	puts "Performing ALU PASS..." 
	set expected a5a5
	set received [examine -radix hex aluOut] 

	if { $received != $expected } {
		testFailed = 1;
	}
}

if { $testFailed == 0 } {
	force aluControl 01
	run 10ns
	puts "Performing ALU ADD..." 
	set expected a5fa
	set received [examine -radix hex aluOut] 

	if { $received != $expected } {
		testFailed = 1;
	}
}

if { $testFailed == 0 } {
	force aluControl 10
	run 10ns
	puts "Performing ALU AND..." 
	set expected 0005
	set received [examine -radix hex aluOut] 

	if { $received != $expected } {
		testFailed = 1;
	}
}


if { $testFailed == 0 } {
	force aluControl 11
	run 10ns
	puts "Performing ALU NOT..." 
	set expected 5a5a
	set received [examine -radix hex aluOut] 

	if { $received != $expected } {
		testFailed = 1;
	}
}

if { $testFailed == 0 } {
	puts "Setting IR = 100011..."
	force IR 100011
	force aluControl 00
	run 10ns
	puts "Performing ALU PASS..." 
	set expected a5a5
	set received [examine -radix hex aluOut] 

	if { $received != $expected } {
		testFailed = 1;
	}
}

if { $testFailed == 0 } {
	force aluControl 01
	run 10ns
	puts "Performing ALU ADD..." 
	set expected a5a8
	set received [examine -radix hex aluOut] 

	if { $received != $expected } {
		testFailed = 1;
	}
}

if { $testFailed == 0 } {
	force aluControl 10
	run 10ns
	puts "Performing ALU AND..." 
	set expected 0001
	set received [examine -radix hex aluOut] 

	if { $received != $expected } {
		testFailed = 1;
	}
}

if { $testFailed == 0 } {
	force aluControl 11
	run 10ns
	puts "Performing ALU PASS..." 
	set expected 5a5a
	set received [examine -radix hex aluOut] 

	if { $received != $expected } {
		testFailed = 1;
	}
}

if { $testFailed } {
	puts "Error! Simulation failed
	Expected Result = $expected 
	Obtained Result = $received"; 
} else {
	puts "All Tests Passed!"
}
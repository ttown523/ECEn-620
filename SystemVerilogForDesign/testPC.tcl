delete wave *
add wave *

set testFailed 0

force clk 0 0ns, 1 5ns -repeat 10ns
force rst 1 0ns, 0 15ns  
force eabOut 16'h248A 
force Buss 16'hB190 
force ldPC 0
force selPC 2'b00
run 20ns   

puts "Setting Load PC to 0..."
set expected 0000
set actual [examine -radix hex PC]

if { $actual != $expected } {
	set testFailed 1;
}

#puts [examine -radix hex PC]; #test PC 0000 -radix hex

if { $testFailed == 0 } {
	puts "Setting Load PC to 1, selecting PC + 1..."
	force ldPC 1
	run 10ns
	set expected 0001
	set actual [examine -radix hex PC]

	if { $actual != $expected } {
		set testFailed 1;
	}
	#puts [examine -radix hex PC]; #test PC 0001 -radix hex
}

if { $testFailed == 0 } {
	puts "Setting Load PC to 1, selecting PC + 1..."
	run 10ns
	set expected 0002
	set actual [examine -radix hex PC]

	if { $actual != $expected } {
		set testFailed 1;
	}	
	#puts [examine -radix hex PC]; #test PC 0002 -radix hex
}


if { $testFailed == 0 } {
	puts "Setting Load PC to 0, selecting eabOut..."
	force selPC 2'b01 
	force ldPC 0
	run 20ns	
	set expected 0002
	set actual [examine -radix hex PC]

	if { $actual != $expected } {
		set testFailed 1;
	}	
	#puts [examine -radix hex PC]; #test PC 0002 -radix hex
}

if { $testFailed == 0 } {
	puts "Setting Load PC to 1, selecting eabOut..."
	force ldPC 1
	run 20ns
	set expected 248a
	set actual [examine -radix hex PC]

	if { $actual != $expected } {
		set testFailed 1;
	}	
	#puts [examine -radix hex PC]; #test PC 248A -radix hex
}

if { $testFailed == 0 } {
	puts "Setting Load PC to 0, selecting value on the bus..."
	force selPC 2'b10 
	force ldPC 0
	run 20ns
	set expected 248a
	set actual [examine -radix hex PC]

	if { $actual != $expected } {
		set testFailed 1;
	}	
	#puts [examine -radix hex PC]; #test PC 248A -radix hex
}

if { $testFailed == 0 } {
	puts "Setting Load PC to 1, selecting value on the bus..."
	force ldPC 1
	run 20ns
	set expected b190
	set actual [examine -radix hex PC]

	if { $actual != $expected } {
		set testFailed 1;
	}	
	#puts [examine -radix hex PC]; #test PC B190 -radix hex
}

#check results
if { $testFailed == 1 } {
	puts "Error! Simulation failed
	Expected Result: $expected 
	Obtained Result: $actual";
} else {
	puts "All Tests Passed!"
}

delete wave *
add wave * 

set testFailed 0 

force clk 0 0ns, 1 5ns -repeat 10ns
force rst 1 0ns, 0 15ns  
force Buss 16'hA5A5
force flagWE 0
run 20ns 

puts "Setting flagWE = 0, negative number on bus..."

set expected 000
set actual "[examine N][examine Z][examine P]"

if { $actual != $expected } {
	set testFailed 1
}

if { $testFailed == 0 } {
	puts "Setting flagWE = 1, negative number on bus..."
	force flagWE 1
	run 20ns

	set expected 100
	set actual "[examine N][examine Z][examine P]"

	if { $actual != $expected } {
		set testFailed 1
	}
} 

if { $testFailed == 0 } {
	puts "Setting flagWE = 0, positive number on bus..."
	force Buss 16'h0001
	force flagWE 0
	run 20ns	
	
	set expected 100
	set actual "[examine N][examine Z][examine P]"

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Setting flagWE = 1, positive number on bus..."
	force flagWE 1
	run 20ns
	
	set expected 001
	set actual "[examine N][examine Z][examine P]"

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Setting flagWE = 0, zero on bus..."
	force Buss 16'h0000
	force flagWE 0
	run 20ns
	
	set expected 001
	set actual "[examine N][examine Z][examine P]"

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Setting flagWE = 1, zero on bus..."
	force flagWE 1
	run 20ns

	set expected 010
	set actual "[examine N][examine Z][examine P]"

	if { $actual != $expected } {
		set testFailed 1
	}
}

#check results
if { $testFailed == 1 } {
	puts "Error! Simulation failed
	Expected Result: $expected 
	Obtained Result: $actual";
} else {
	puts "All Tests Passed!"
}
delete wave *
add wave *

set testFailed 0 

force clk 0 0ns, 1 5ns -repeat 10ns
force rst 1 0ns, 0 15ns 
	
force regWE 0
force SR1 3'b000
force SR2 3'b000
run 20ns

puts "Writing to Registers and Reading from register 0..."

#puts "[examine -radix hex Ra] [examine -radix hex Rb]"
set expected 00000000
set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

if { $actual != $expected } {
	set testFailed 1
}

if { $testFailed == 0 } {
	puts "Writing value 0xFF00 to register R0, reading from register R0..."
	force DR 3'b000 
	force regWE 1
	force Buss 16'hFF00
	run 10ns

	set expected ff00ff00
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Writing value 0xFF00 to register R1, reading from register R0..."
	force DR 3'b001
	force Buss 16'hFF01
	run 10ns
	set expected ff00ff00
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Writing value 0xFF00 to register R2, reading from register R0..."
	force DR 3'b010
	force Buss 16'hFF02
	run 10ns
	set expected ff00ff00
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}
 
if { $testFailed == 0 } { 
	puts "Writing value 0xFF00 to register R3, reading from register R0..."
	force DR 3'b011
	force Buss 16'hFF03 
	run 10ns
	
	set expected ff00ff00
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Writing value 0xFF00 to register R4, reading from register R0..."
	force DR 3'b100
	force Buss 16'hFF04 
	run 10ns
	
	set expected ff00ff00
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Writing value 0xFF00 to register R5, reading from register R0..."
	force DR 3'b101
	force Buss 16'hFF05 
	run 10ns
	
	set expected ff00ff00
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Writing value 0xFF00 to register R6, reading from register R0..."
	force DR 3'b110
	force Buss 16'hFF06 
	run 10ns
	
	set expected ff00ff00
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Writing value 0xFF00 to register R7, reading from register R0..."
	force DR 3'b111
	force Buss 16'hFF07 
	run 10ns
	
	set expected ff00ff00
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Reading from register R0->Ra and R7->Rb..."
	force regWE 0
	force SR1 3'b000
	force SR2 3'b111
	run 20ns	
	
	set expected ff00ff07
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Reading from register R1->Ra and R6->Rb..."
	force SR1 3'b001
	force SR2 3'b110
	run 20ns
	
	set expected ff01ff06
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Reading from register R2->Ra and R5->Rb..."
	force SR1 3'b010
	force SR2 3'b101
	run 20ns
	
	set expected ff02ff05
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Reading from register R3->Ra and R4->Rb..."
	force SR1 3'b011
	force SR2 3'b100
	run 20ns
	
	set expected ff03ff04
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Reading from register R4->Ra and R3->Rb..."
	force SR1 3'b100
	force SR2 3'b011
	run 20ns
	
	set expected ff04ff03
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Reading from register R5->Ra and R2->Rb..."
	force SR1 3'b101
	force SR2 3'b010
	run 20ns
	
	set expected ff05ff02
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Reading from register R6->Ra and R1->Rb..."
	force SR1 3'b110
	force SR2 3'b001
	run 20ns
	
	set expected ff06ff01
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}

if { $testFailed == 0 } {
	puts "Reading from register R7->Ra and R0->Rb..."
	force SR1 3'b111
	force SR2 3'b000
	run 20ns
	
	set expected ff07ff00
	set actual "[examine -radix hex Ra][examine -radix hex Rb]" 

	if { $actual != $expected } {
		set testFailed 1
	}
}

#check to see if test passed
if { $testFailed == 1 } {
	puts "Error! Simulation failed
	Expected Result: $expected 
	Obtained Result: $actual";
} else {
	puts "All Tests Passed!"
}
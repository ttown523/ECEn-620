//used to make sure that we don't have any uninitialized variables in our design
//`default_nettype none //may not be able to use this with modelsim 
/*
* Name: ALU
* Description:
*	Implements a simple 2 bit Arithmetic Logic Unit. The output gets:
*	00 -> Pass input Ra
*	01 -> Add inputs Ra and Rb
*	10 -> Bitwise AND of Ra and Rb
*	11-> NOT Ra
*/
module ALU(Ra, Rb, IR, aluControl, aluOut);

	input [15:0] Ra, Rb;
	input [5:0] IR;
	input [1:0] aluControl;
	output [15:0] aluOut;
	
	wire [15:0]  sr2mux, IR4;
	
	assign IR4 = { {11{IR[4]}}, IR[4:0] }; //sign extend

	assign sr2mux = (IR[5] == 1) ? IR4 : Rb; //choose between immediate and register value

	assign aluOut = (aluControl == 2'b00) ? Ra:
					(aluControl == 2'b01) ? Ra + sr2mux:
					(aluControl == 2'b10) ? Ra & sr2mux:
					~Ra;
endmodule

/*
* Name: EAB
* Description:
*	Implements the Effective Address Block of the LC3 datapath.
*/
module EAB(PC, Ra, IR, selEAB1, selEAB2, eabOut);
	input [15:0] PC, Ra, IR;
	input selEAB1;
	input [1:0] selEAB2;
	output [15:0] eabOut;
	
	wire [15:0] addr2mux, addr1mux, IR5, IR8, IR10;
	
	//Sign extending the IR
	assign IR5 = { {10{IR[5]}}, IR[5:0] }; //holds 
	assign IR8 = { {7{IR[8]}},  IR[8:0] }; //holds PC offset
	assign IR10 = { {5{IR[10]}}, IR[10:0]}; 
	
	//Selects which bits of the IR to use for addressing   
	assign addr2mux =   (selEAB2 == 2'b00) ? 0 : 
						(selEAB2 == 2'b01) ? IR5 : 
						(selEAB2 == 2'b10) ? IR8: 
						IR10;	
	//selects whether to use the output of the register file or the current PC for addressing
	assign addr1mux = (selEAB1) ? Ra : PC;

	assign eabOut = addr2mux + addr1mux;
endmodule


/*
* Name: ProgramCounter
* Description:
*	Implements the Program Counter Logic for the LC3 data path 
*/
module ProgramCounter(clk, rst, Buss, eabOut, selPC, ldPC, PC);

input clk, rst, ldPC;
input [15:0] Buss, eabOut;
input [1:0] selPC;
output [15:0] PC;

reg [15:0] PC;
wire [15:0]pcmux;

//Register holding the current instruction location
always @(posedge clk) 
begin
	if(rst) 
		PC <= 0; 
	else if (ldPC == 1) //only update PC if load PC is enabled
		PC <= pcmux; 
end

//Next state logic for the program counter
assign pcmux =	(selPC == 2'b00) ? PC + 1: //standard next instruction
				(selPC == 2'b01) ? eabOut: //relative offset of PC 
				(selPC == 2'b10) ? Buss: 0; //address read from MAR Mux 
endmodule

/*
* Name: NZP
* Description:
*	Implements the flag logic used in the LC3. If flagWE is high, it reads the 
*	value currently on the bus determines if it is positive(P), negative(N), or zero(Z)
*	and sets the corresponding flag to 1. This is used for branching instructions. 
*/
module NZP (clk, rst, flagWE, Buss, N, Z, P);
	input clk, rst, flagWE;
	input [15:0] Buss;
	output N, Z, P;
	
	reg N, Z, P;
	wire N_next, P_next, Z_next;
	
	//Registers for the N, Z, and P outputs
	always @(posedge clk)
	begin
		if(rst == 1) begin
			N <= 0;
			Z <= 0;
			P <= 0;
		end else if(flagWE == 1) begin
			N <= N_next;
			Z <= Z_next;
			P <= P_next;
		end
	end
	
	//next state logic for each register
	assign N_next = (Buss < 0)? 1 : 0;
	assign P_next = (Buss > 0)? 1 : 0;  
	assign Z_next = (Buss == 0)? 1 : 0;  	
endmodule


/*
* Name: ts_driver
* Description:
*	Implements a tri-state buffer used to allow signals to drive the data on the bus.
*/
module ts_driver ( din, dout, ctrl );

input [15:0] din;
input ctrl;
output [15:0] dout;

assign dout = (ctrl)? din:(16'bZZZZZZZZZZZZZZZZ);

endmodule

/*
* Name: regFile
* Description:
*	Implements a 16-bit, 8 deep register file. There is one synchronous write port,
*	and two asynchronous read ports.
*/
module regFile(clk, rst, regWE, DR, SR1, SR2, Buss, Ra, Rb);
	input clk, rst, regWE;
	input [2:0] DR, SR1, SR2;
	input [15:0] Buss;
	output [15:0] Ra, Rb;

	reg [15:0] registers [7:0];
	
	always @(posedge clk)
	begin
		if (rst == 1) begin
			registers[0] <= 0;
			registers[1] <= 0;
			registers[2] <= 0;
			registers[3] <= 0;
			registers[4] <= 0;
			registers[5] <= 0;
			registers[6] <= 0;
			registers[7] <= 0;
		end
		else
			if (regWE == 1) // synchronous write
				registers[DR] <= Buss;
	end
	
	//asynchronous read
	assign Ra = registers[SR1];
	assign Rb = registers[SR2];

endmodule

/*
* Name: LC3
* Description:
*	Implements the state machine controlling the LC3 
*/
module LC3(clk, rst, Buss, enaALUOut, enaMarmOut, enaPcOut, ldMAR, memWE, selMDR, ldMDR, enaMDR);

input clk, rst; 
input [15:0] Buss;
output reg ldMAR, memWE, selMDR, ldMDR, enaMDR; //outputs going to the memory module
output [15:0] enaALUOut, enaMarmOut, enaPcOut; //outputs driving the bus

//State machine state encoding
parameter FETCH0 = 4'b0000; 
parameter FETCH1 = 4'b0001;
parameter FETCH2 = 4'b0010;
parameter DECODE = 4'b0011;
parameter AND  = 4'b0100, ADD = 4'b0101, NOT = 4'b0110, JSR = 4'b0111;
parameter BR  = 4'b1000, JMP_RET = 4'b1001;
parameter LD0 = 4'b1010, LD1 = 4'b1011, LD2 = 4'b1100;
parameter ST0 = 4'b1101, ST1 = 4'b1110, ST2 = 4'b1111;

reg [3:0] curState, nextState;
reg [15:0] IR;

reg ldIR, ldPC, regWE, flagWE, enaMARM, enaPC, enaALU, selMAR, selEAB1;  
reg [1:0] selPC, aluControl, selEAB2;
reg [2:0] SR1, SR2, DR;

wire N, Z, P;
wire [15:0] MARMuxOut, Ra, Rb, aluOut, eabOut, PC;


//State machine and Instruction register
always @(posedge clk)
begin 
	if (rst) begin
		curState <= FETCH0;
		IR <= 0;		
	end else begin
		curState <= nextState;
		if(ldIR)
			IR <= Buss;
	end
end

//Next state and output forming logic
always @(*)
begin
	//Default values for all variables assigned in this process.
	//Used to prevent latches and unwanted behavior
	nextState = FETCH0;
	 
	ldMAR = 0;
	ldMDR = 0;
	ldIR = 0;
	ldPC = 0;
	
	selMDR = 0;
	selMAR = 0;
	selPC = 2'b00; 
	selEAB1 = 0;
	selEAB2 = 0; 
	aluControl = 2'b00;
	
	regWE = 0;	
	memWE = 0;
	flagWE = 0;
	
	SR1 = 3'b000;
	SR2 = 3'b000;
	DR = 3'b000;
	
	//tri state enables
	enaMARM = 0;
	enaALU = 0;
	enaPC = 0;
	enaMDR = 0; 

	//Next state and output forming logic
	case(curState)
		(FETCH0): begin //Load MAR with memory address of next instruction
			nextState = FETCH1;
			enaPC = 1;
			ldMAR = 1;
		end
		(FETCH1): begin //Load fetched memory into MDR
			nextState = FETCH2;
			selMDR = 1;
			ldMDR = 1;
			selPC = 2'b00; //load PC + 1 into the program counter
			ldPC = 1;
		end
		(FETCH2): begin //Drive the bus with the instruction from memory, load this into the IR. 
			nextState = DECODE;
			enaMDR = 1; 
			ldIR = 1;
		end
		(DECODE): begin //decode the instruction in the IR, and move to the corresponding state
			case(IR[15:12]) //the opcode of an instruction is found in bits 15-12 of the IR
				(4'b0001): nextState = ADD;
				(4'b0101): nextState = AND;
				(4'b1001): nextState = NOT;
				(4'b0100): nextState = JSR;
				(4'b0000): nextState = BR;
				(4'b0010): nextState = LD0;
				(4'b0011): nextState = ST0;
				(4'b1100): nextState = JMP_RET;
			endcase
		end
		(ADD): begin 	
			SR1 = IR[8:6]; //Could also assign SR1, SR2, and DR in the decode stage...but I'm not sure if this is any better
			SR2 = IR[2:0];
			DR = IR[11:9];
			enaALU = 1;
			regWE = 1;
			aluControl = 2'b01;
			nextState = FETCH0;
			flagWE = 1;
		end
		(AND): begin 
			SR1 = IR[8:6];
			SR2 = IR[2:0];
			DR = IR[11:9];
			enaALU = 1;
			regWE = 1;
			aluControl = 2'b10;
			nextState = FETCH0;
			flagWE = 1;
		end
		(NOT): begin
			SR1 = IR[8:6];
			DR = IR[11:9];
			enaALU = 1;
			regWE = 1;
			aluControl = 2'b11;
			nextState = FETCH0;
			flagWE = 1;
		end
		(JMP_RET): begin //Jump to another instruction: PC<-register Value
			SR1 = IR[8:6];
			selEAB1 = 1;
			selEAB2 = 0;
			selPC = 2'b01;
			ldPC = 1;	
			nextState = FETCH0;			
		end
		(JSR): begin //Jump to subroutine...TODO: have to load current PC into register 7.
			selEAB2 = 2'b11;
			selEAB1 = 0;
			selPC = 2'b01;
			ldPC = 1;
			nextState = FETCH0;
			//save return address in register 7
			regWE = 1;
			enaPC = 1;
			DR = 3'b111;
		end
		(BR): begin //Branch command (relative branch)
			if ((IR[11] & N) + (IR[10] & Z) + (IR[9] & P))
				selEAB2 = 2'b10; //branch taken				
			else
				selEAB2 = 0; //branch not taken...increment PC as normal
			
			selEAB1 = 0;
			selPC = 2'b01;
			ldPC = 1;
			nextState = FETCH0;
		end
		(LD0): begin //load a value from memory into a register
			nextState = LD1;
			selEAB2 = 2'b10;
			selEAB1 = 0;
			selMAR = 0;
			enaMARM = 1;
			ldMAR = 1;
		end
		(LD1): begin
			nextState = LD2;
			selMDR = 1;
			ldMDR = 1;
		end
		(LD2): begin
			nextState = FETCH0;
			enaMDR = 1;
			DR = IR[11:9];
			regWE = 1;
			flagWE = 1; //also update the flags register
		end
		(ST0): begin //store a value into memory
			nextState = ST1;
			selEAB2 = 2'b10;
			selEAB1 = 0;
			selMAR = 0;
			enaMARM = 1;
			ldMAR = 1;
		end
		(ST1): begin
			nextState = ST2;
			SR1 = IR[11:9];
			aluControl = 2'b00;
			enaALU = 1;
			selMDR = 0;
			ldMDR = 1;
		end
		(ST2): begin
			nextState = FETCH0;
			memWE = 1;
		end
	endcase	
end

	//LC3 datapath modules interfacing with the state machine controller
	regFile reg0(clk, rst, regWE, DR, SR1, SR2, Buss, Ra, Rb);
	
	ALU alu0(Ra, Rb, IR[5:0], aluControl, aluOut);
	ts_driver tsALU ( aluOut, enaALUOut, enaALU );
	
	NZP nzp0(clk, rst, flagWE, Buss, N, Z, P);
	
	EAB eab0(PC, Ra, IR, selEAB1, selEAB2, eabOut);
	
	ProgramCounter pc0(clk, rst, Buss, eabOut, selPC, ldPC, PC);
	ts_driver tsPC ( PC, enaPcOut, enaPC );
	
	assign MARMuxOut = (selMAR) ? {8'h00, IR} : eabOut;  
	ts_driver tsMarm ( MARMuxOut, enaMarmOut, enaMARM );
endmodule



//`default_nettype none
`include "LC3pkg.sv"

import types::*;
import constants::*;

/*
* Name: ALU
* Description:
*	Implements a simple 2 bit Arithmetic Logic Unit. The output gets:
*	00 -> Pass input Ra
*	01 -> Add inputs Ra and Rb
*	10 -> Bitwise AND of Ra and Rb
*	11-> NOT Ra
*/
module ALU_sv(Ra, Rb, IR, aluControl, aluOut);

	input [15:0] Ra, Rb;
	input [5:0] IR;
	input aluOp aluControl;
	output [15:0] aluOut;
	
	logic [15:0]  sr2mux, IR4;
	
	assign IR4 = { {11{IR[4]}}, IR[4:0] }; //sign extend IR bits which hold the immediate value

	assign sr2mux = (IR[5] == 1) ? IR4 : Rb; //choose between immediate and register value

	assign aluOut = (aluControl == ALU_PASS) ? Ra:
					(aluControl == ALU_ADD) ? $signed(Ra) + $signed(sr2mux):
					(aluControl == ALU_AND) ? Ra & sr2mux:
					 ~Ra; //ALU_NOT
endmodule

/*
* Name: EAB
* Description:
*	Implements the Effective Address Block of the LC3 datapath.
*/
module EAB_sv(PC, Ra, IR, selEAB1, selEAB2, eabOut);
	input [15:0] PC, Ra;
	input [10:0] IR; 
	input selEAB1;
	input [1:0] selEAB2;
	output [15:0] eabOut;
	
	logic [15:0] addr2mux, addr1mux, IR5, IR8, IR10;
	
	//Sign extending the IR
	assign IR5 = { {10{IR[5]}}, IR[5:0] }; 
	assign IR8 = { {7{IR[8]}},  IR[8:0] }; //holds PC offset
	assign IR10 = { {5{IR[10]}}, IR[10:0]}; 
	
	//Selects which bits of the IR to use for addressing   
	assign addr2mux =   (selEAB2 == 2'b00) ? 0 : 
						(selEAB2 == 2'b01) ? IR5 : 
						(selEAB2 == 2'b10) ? IR8: 
						IR10;	
	//selects whether to use the output of the register file or the current PC for addressing
	assign addr1mux = (selEAB1==1) ? Ra : PC;

	assign eabOut = addr2mux + addr1mux;
endmodule

/*
* Name: ProgramCounter
* Description:
*	Implements the Program Counter Logic for the LC3 data path 
*/
module ProgramCounter_sv(clk, rst, Buss, eabOut, selPC, ldPC, PC);

input clk, rst, ldPC;
input [15:0] Buss, eabOut;
input [1:0] selPC;
output [15:0] PC;

logic [15:0] PC, PC_next;

//Register holding the current instruction location
always_ff @(posedge clk) 
begin
	if(rst == 1) 
		PC <= 0; 
	else if (ldPC == 1) //only update PC if load PC is enabled
		PC <= PC_next; 
end

//Next state logic for the program counter
assign PC_next = (selPC == 2'b00) ? PC + 1: //standard next instruction
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
module NZP_sv (clk, rst, flagWE, Buss, N, Z, P);
	input clk, rst, flagWE;
	input [15:0] Buss;
	output N, Z, P;
	
	logic N, Z, P, N_next, P_next, Z_next;
	
	//Registers for the N, Z, and P outputs
	always_ff @(posedge clk)
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
	// TODO: what should these be driven to if flagWE = 0? 0, or keep old value
	assign N_next = ($signed(Buss) < 0) ? 1 : 0; //set negative flag to true
	assign P_next = ($signed(Buss) > 0) ? 1 : 0; //set positive flag to true 
	assign Z_next = ($signed(Buss) == 0)? 1 : 0; //set zero flag to true  	
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

assign dout = (ctrl) ? din : HIGH_Z;

endmodule

/*
* Name: regFile
* Description:
*	Implements a 16-bit, 8 deep register file. There is one synchronous write port,
*	and two asynchronous read ports.
*/
module regFile_sv(clk, rst, regWE, DR, SR1, SR2, Buss, Ra, Rb);
	input clk, rst, regWE;
	input [2:0] DR, SR1, SR2;
	input [15:0] Buss;
	output [15:0] Ra, Rb;

	logic [15:0] registers [7:0];
	
	always_ff @(posedge clk)
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
*/module LC3_sv(clk, rst, Buss, enaALUOut, enaMarmOut, enaPcOut, ldMAR, memWE, selMDR, ldMDR, enaMDR);

input clk, rst; 
input [15:0] Buss;
output logic ldMAR, memWE, selMDR, ldMDR, enaMDR;
output [15:0] enaALUOut, enaMarmOut, enaPcOut;
 
logic ldIR, ldPC, regWE, flagWE, enaMARM, enaPC, enaALU, selMAR, selEAB1, N, Z, P;  
logic [1:0] selPC, selEAB2;
logic [2:0] SR1, SR2, DR;
logic [15:0] MARMuxOut, Ra, Rb, aluOut, eabOut, PC, IR;

aluOp aluControl;
state curState, nextState;

//state machine and instruction register
always_ff @(posedge clk)
begin 
	if (rst == 1) begin 
		curState <= FETCH0;
		IR <= 0;		
	end else begin 
		curState <= nextState;
		if (ldIR == 1)
			IR <= Buss;
	end 
end

//next state and output forming logic 
always_comb
begin
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
	aluControl = ALU_PASS;
	
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
	
	//Next state and output forming logic is in this case statement
	unique case(curState)
		(FETCH0): begin //load MAR with memory address of instruction to get
			nextState = FETCH1;
			enaPC = 1;
			ldMAR = 1;
		end
		(FETCH1): begin //load fetched memory into MDR
			nextState = FETCH2;
			selMDR = 1;
			ldMDR = 1;
			selPC = 2'b00;
			ldPC = 1;
		end
		(FETCH2): begin //Drive the bus with the instruction from memory, load this into the IR. 
			nextState = DECODE;
			enaMDR = 1; 
			ldIR = 1;
		end
		(DECODE): begin
			unique case(IR[15:12]) //the opcode of an instruction is found in bits 15-12 of the IR
				(OP_ADD): nextState = ADD;
				(OP_AND): nextState = AND;
				(OP_NOT): nextState = NOT;
				(OP_JSR): nextState = JSR;
				(OP_BR): nextState = BR;
				(OP_LD): nextState = LD0;
				(OP_ST): nextState = ST0;
				(OP_JMP_RET): nextState = JMP_RET;
				default: nextState = FETCH0;
			endcase
		end
		(ADD): begin //could collapse ADD, AND, and NOT into one state...look into doing this later
			SR1 = IR[8:6];//Could also assign SR1, SR2, and DR in the decode stage...is this the correct thing to do?
			SR2 = IR[2:0];
			DR = IR[11:9];
			enaALU = 1;
			regWE = 1;
			aluControl = ALU_ADD;
			nextState = FETCH0;
			flagWE = 1;
		end
		(AND): begin
			SR1 = IR[8:6];
			SR2 = IR[2:0];
			DR = IR[11:9];
			enaALU = 1;
			regWE = 1;
			aluControl = ALU_AND;
			nextState = FETCH0;
			flagWE = 1;
		end
		(NOT): begin
			SR1 = IR[8:6];
			DR = IR[11:9];
			enaALU = 1;
			regWE = 1;
			aluControl = ALU_NOT;
			nextState = FETCH0;
			flagWE = 1;
		end
		(JMP_RET): begin 
			SR1 = IR[8:6];
			selEAB1 = 1;
			selEAB2 = 0;
			selPC = 2'b01;
			ldPC = 1;	
			nextState = FETCH0;			
		end
		(JSR): begin
			selEAB2 = 2'b11;
			selEAB1 = 0;
			selPC = 2'b01;
			ldPC = 1;
			nextState = FETCH0;
			//save return address in register 7
			regWE = 1;
			enaPC = 1; //put current PC value on the buss to write to 
			DR = 3'b111;
		end
		(BR): begin
			if ((IR[11] & N) + (IR[10] & Z) + (IR[9] & P)) 
				selEAB2 = 2'b10; //branch taken				
			else
				selEAB2 = 0;
			
			selEAB1 = 0;
			selPC = 2'b01;
			ldPC = 1;
			nextState = FETCH0;
		end
		(LD0): begin
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
			flagWE = 1;
		end
		(ST0): begin
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
			aluControl = ALU_PASS;
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

	regFile_sv reg0(clk, rst, regWE, DR, SR1, SR2, Buss, Ra, Rb);
	
	ALU_sv alu0(Ra, Rb, IR[5:0], aluControl, aluOut);
	ts_driver tsALU ( aluOut, enaALUOut, enaALU );
	
	NZP_sv nzp0(clk, rst, flagWE, Buss, N, Z, P);
	
	EAB_sv eab0(PC, Ra, IR[10:0], selEAB1, selEAB2, eabOut);
	
	ProgramCounter_sv pc0(clk, rst, Buss, eabOut, selPC, ldPC, PC);
	ts_driver tsPC ( PC, enaPcOut, enaPC );
	
	assign MARMuxOut = (selMAR) ? {8'h00, IR} : eabOut;  
	ts_driver tsMarm ( MARMuxOut, enaMarmOut, enaMARM );

endmodule

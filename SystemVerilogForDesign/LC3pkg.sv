//`ifndef _LC3PKG_ 
//`define _LC3PKG_
package types;
	typedef enum {FETCH0, FETCH1, FETCH2, DECODE, AND, ADD, NOT, JSR, BR, JMP_RET, LD0, LD1, LD2, ST0, ST1, ST2} state;
	typedef enum logic [1:0] {ALU_PASS, ALU_ADD, ALU_AND, ALU_NOT} aluOp;
		
endpackage: types	

package constants;
	enum logic[3:0] {OP_AND = 4'b0101 , OP_ADD = 4'b0001, OP_NOT = 4'b1001, OP_JSR = 4'b0100, 
				  OP_BR = 4'b0000, OP_JMP_RET = 4'b1100, OP_LD = 4'b0010, OP_ST = 4'b0011} opCode;
	
	logic [15:0] HIGH_Z = 16'bZZZZZZZZZZZZZZZZ; 
	
	
endpackage: constants

//package 
//`endif
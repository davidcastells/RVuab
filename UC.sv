`default_nettype none

localparam IT_EXE = 2'b00;
localparam IT_IF = 2'b01;
localparam IT_GOTO = 2'b10;
localparam IT_GMP = 2'b11;

localparam OP_ALU_ADD = 4'b0010;

/*typedef struct packed {
			logic slALUi1;
			logic slALUi2;
			logic [3:0] opALU;
			logic slAddi1;
			logic RW_IM;
			logic [1:0] slDinRD;
			logic ldRD;
			logic RW_DM;
			logic ldIR;
			logic ldPC;
			logic slPCin;
			logic ldRFlags;
    } uop_t;*/

/*
typedef struct packed {
	logic [1:0] cond;	// Condition
	logic [1:0] it;	// instruction type
	logic [9:0] add;	// address
	uop_t uop;			// micro-orders
} rom_row;*/

module UC(input logic clk, reset, 
	// IR
	input logic [6:0] IR_op,
	input logic [2:0] IR_f3,
	input logic [6:0] IR_f7,
	// Computing Resources
	output logic slALUi1, slALUi2,
	output logic [3:0] opALU,
	output logic slAddi1,
	// Storage Resources
	output logic RW_IM, 
	output logic [1:0] slDinRD,
	output logic ldRD, RW_DM,
	output logic ldIR, ldPC, slPCin, ldRFlags,
	// Flags
	input logic gt, lt, eq, zero,
	
	// To Debug in Quartus Simulator we have to export signals to the top entity
	output logic [9:0] add,
	output logic [9:0] DirStartuP
);
	
	logic enable;
	// logic [9:0] add;
	//logic [9:0] DirStartuP;
	logic [1:0] SnA;
	
	logic [1:0] row_cond;
	logic [1:0] row_it;
	logic [9:0] row_add;
	//uop_t row_uop;
	logic row_slALUi1;
	logic row_slALUi2;
	logic [3:0] row_opALU;
	logic row_slAddi1;
	logic row_RW_IM;
	logic [1:0] row_slDinRD;
	logic row_ldRD;
	logic row_RW_DM;
	logic row_ldIR;
	logic row_ldPC;
	logic row_slPCin;
	logic row_ldRFlags;

	logic cond;
	
	assign cond = 0;
	
	IUPD IUPD(.iupd_op(IR_op), .iupd_f3(IR_f3), .iupd_f7(IR_f7), .iupd_start(DirStartuP));
	CtrlSeq CtrlSeq(.it(row_it), .cond(cond), .SnA(SnA), .enable(enable));
	Sequencer Sequencer(.clk(clk), .reset(reset), .SnA(SnA), .rom_add(row_add), .DirStartuP(DirStartuP), .add(add));

	ROM ROM(.rom_add(add), .row_cond(row_cond), .row_it(row_it), .row_add(row_add),
		.slALUi1(row_slALUi1), .slALUi2(row_slALUi2),
		.opALU(row_opALU), .slAddi1(row_slAddi1),  .RW_IM(row_RW_IM), .slDinRD(row_slDinRD),
		.ldRD(row_ldRD), .RW_DM(row_RW_DM), .ldIR(row_ldIR), .ldPC(row_ldPC),
		.slPCin(row_slPCin), .ldRFlags(row_ldRFlags) );	

	// Computing Resources
	assign slALUi1 = row_slALUi1;
	assign slALUi2 = row_slALUi2;
	assign opALU = row_opALU;
	assign slAddi1 = row_slAddi1;

	// Storage Resources
	assign slDinRD = row_slDinRD;
	assign RW_IM = row_RW_IM & enable; 
	assign ldRD = row_ldRD & enable;
	assign RW_DM = row_RW_DM & enable;
	assign ldIR = row_ldIR & enable;
	assign ldPC = row_ldPC & enable;
	assign slPCin = row_slPCin;
	assign ldRFlags = row_ldRFlags & enable;
	
endmodule


// Assign start of subprograms for every instruction
module IUPD(input logic [6:0] iupd_op, 
				input logic [2:0] iupd_f3,
				input logic [6:0] iupd_f7, 
				output logic [9:0] iupd_start);
	always_comb begin
		iupd_start = 10'd128;
		case (iupd_op)
			7'h13:
				case (iupd_f3)
					3'h0: iupd_start = 10'd132;	// ADDI
				endcase 
			7'h33: 
				case (iupd_f3)
					3'h0: iupd_start = 10'd130;	// ADD
				endcase
		endcase
	end
endmodule

// Sequence Control
module CtrlSeq(input logic [1:0] it, input logic cond, output logic [1:0] SnA, output logic enable);
	always_comb begin
	case (it)
	IT_EXE: begin SnA = 2'b00; enable = 1; end 									// EXE
	IT_IF: begin SnA = (cond == 1'b1) ? 2'b01 : 2'b00; enable = 0; end 	// IF GOTO
	IT_GOTO: begin SnA = 2'b01; enable = 0; end 									// GOTO
	IT_GMP: begin SnA = 2'b10; enable = 0; end 									// GMP
	endcase
	end
endmodule

// Sequencer
module Sequencer(input logic clk, input logic reset, 
	input logic [1:0] SnA, 
	input logic [9:0] rom_add, 
	input logic [9:0] DirStartuP, 
	output logic [9:0] add);
	
	initial add = 10'd128;
	
	always_ff @(posedge clk or posedge reset) 
		begin
			if (reset) 
				begin
					add <= 10'd128;
				end
			else
				begin
					case (SnA)
						2'b00: add <= add + 10'b1;
						2'b01: add <= rom_add;
						2'b10: add <= DirStartuP;
						2'b11: add <= 10'b0; // Invalid
					endcase
				end
		end
endmodule

module ROM(input logic [9:0] rom_add, 
	output logic [1:0] row_cond, 
	output logic [1:0] row_it,  
	output logic [9:0] row_add, 
	output logic slALUi1, slALUi2,
	output logic [3:0] opALU,
	output logic slAddi1, RW_IM,
	output logic [1:0] slDinRD,
	output logic ldRD, RW_DM, ldIR, ldPC, slPCin, ldRFlags);


	always_comb begin
		row_cond = 0;
		row_it = 0;
		
		row_add = 0;
		slALUi1 = 0;
		slALUi2 = 0;
		opALU = 0;
		slAddi1 = 0; 
		RW_IM = 0;
		slDinRD = 0;
		ldRD = 0; 
		RW_DM = 0; 
		ldIR = 0; 
		ldPC = 0; 
		slPCin = 0; 
		ldRFlags = 0;
		
		case (rom_add)
			128: begin row_it = IT_EXE; ldIR = 1; end 				// Fetch instruction
			129: begin row_it = IT_GMP; end								// Jump to instruction microprogram
			
			// ADD
			130: begin row_it = IT_EXE; ldRD = 1; opALU = OP_ALU_ADD; slALUi1 = 1'b0; slALUi2 = 1'b0; ldPC = 1; end
			131: begin row_it = IT_GOTO; row_add = 10'd128; end
			
			// ADDI
			132: begin row_it = IT_EXE; ldRD = 1; opALU = OP_ALU_ADD; slALUi1 = 1'b0; slALUi2 = 1'b1; ldPC = 1; end
			133: begin row_it = IT_GOTO; row_add = 10'd128; end
			
		endcase
	end


endmodule
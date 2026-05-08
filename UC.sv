localparam IT_EXE = 2'b00;
localparam IT_IF = 2'b01;
localparam IT_GOTO = 2'b10;
localparam IT_GMP = 2'b11;

typedef struct packed {
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
    } uop_t;


typedef struct packed {
	logic [1:0] cond;	// Condition
	logic [1:0] it;	// instruction type
	logic [9:0] add;	// address
	uop_t uop;			// micro-orders
} rom_row;

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
	input logic gt, lt, eq, zero);
	
logic enable;
logic [9:0] add, DirStartuP;
logic [1:0] SnA;
rom_row row;

IUPD IUPD(IR_op, IR_f3, IR_f7, DirStartuP);
CtrlSeq CtrlSeq(.it(row.it), .cond(cond), .SnA(SnA), .enable(enable));
Sequencer Sequencer(.clk(clk), .reset(reset), .SnA(SnA), .rom_add(row.add), .DirStartuP(DirStartuP), .add(add));

ROM ROM(.add(add), .row(row));	

// Computing Resources
assign slALUi1 = row.uop.slALUi1;
assign slALUi2 = row.uop.slALUi2;
assign opALU = row.uop.opALU;
assign slAddi1 = row.uop.slAddi1;

// Storage Resources
assign slDinRD = row.uop.slDinRD;
assign RW_IM = row.uop.RW_IM & enable; 
assign 	output logic ldRD, RW_DM,
	output logic ldIR, ldPC, slPCin, ldRFlags,
	
endmodule


// Assign start of subprograms for every instruction
module IUPD(input logic [6:0] IR_op, input logic [2:0] IR_f3, input logic [6:0] IR_f7, output logic [9:0] DirStartuP);
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

module ROM(input logic [9:0] add, output rom_row row );

always_comb begin
	row = 0;
	
	case (add)
		128: begin row.it = IT_EXE; row.uop.ldIR = 1; end 				// Fetch instruction
	endcase
end


endmodule
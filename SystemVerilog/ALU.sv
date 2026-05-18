`default_nettype none

// localparam OP_ALU_ADD 	= 4'b0010;
// localparam OP_ALU_NONE 	= 4'b1111;

module ALU (
	input logic [3:0] op,
	input logic [31:0] i1, 
	input logic [31:0] i2, 	
	output logic [31:0] out, 
	output logic gt, lt, eq, zero ) ;

	logic [31:0] r_and, r_or, r_xor, r_add_sub, r_comp, r_sr, r_sra, r_sl, r_unsigned_lt, r_signed_lt;
	logic sign_extend;

	assign r_or = i1 | i2;

	logic inv, align2, shift_right;

	assign inv = op[2];
	assign align2 = op[0];
	assign sign_extend = op[1];

	SR SR(i1, i2, inv, align2, r_add_sub, r_and, r_xor);

	SHIFT SHIFT(.i1(i1), .i2(i2), .sign_extend(sign_extend), .sr(r_sr), .sra(r_sra), .sl(r_sl) );

	COMP COMP(.i1(i1), .i2(i2), .unsigned_lt(r_unsigned_lt), .signed_lt(r_signed_lt), .lt(lt), .gt(gt), .eq(eq));

	assign zero = (out == 32'b0);

	Mux4 Mux4( .d0(r_and),
				.d1(r_or),
				.d2(r_add_sub),
				.d3(r_add_sub), 
				.d4(r_unsigned_lt), .d5(r_signed_lt), 
				.d6(r_add_sub), .d7(0), .d8(0), .d9(r_xor),
				.d10(i1), .d11(i2),
				.d12(r_sr), .d13(r_sra), .d14(r_sl),
				.d15(0), 
				.sel(op), .y(out));
	
endmodule
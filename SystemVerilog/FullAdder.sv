module FullAdder(input logic i1, i2, ci, inv_i2, output logic  r, co, r_and, r_xor );

logic i2_eff, xori;

assign i2_eff = inv_i2 ^ i2;

assign r_xor = i1 ^ i2_eff;
assign r_and = i1 & i2_eff;

assign r = r_xor ^ ci;
assign co = (ci & r_xor) | r_and;
	
endmodule

module SR(input logic [31:0] i1,i2, input logic inv, zero_i20, output logic [31:0] r, r_and, r_xor);
    
logic [31:0] co_internal;
logic [31:0] r_internal;
    
genvar i;
 generate
	  for (i = 0; i < 32; i++) begin : bit_slice
			FullAdder fa (
				 .i1     (i1[i]),
				 .i2     (i2[i]),
				 .ci     (i == 0 ? inv : co_internal[i-1]),
				 .inv_i2 (inv),
				 .r      (r_internal[i]),
				 .co     (co_internal[i]),
				 .r_and  (r_and[i]),
				 .r_xor  (r_xor[i])
			);
	  end
endgenerate

assign r = zero_i20 ? {r_internal[31:1],1'b0} : r_internal;    
    
endmodule
	

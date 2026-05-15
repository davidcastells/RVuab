module COMP (input logic [31:0] i1, i2, output logic [31:0] unsigned_lt, output logic [31:0] signed_lt, output logic lt, gt, eq);
	// @todo check if lt, gt, eq should treat i1, i2 as signed or unsigned
	
	// Compare the two inputs
	assign eq = (i1 == i2);

	 
	assign unsigned_lt  = (i1 < i2) ? 32'b1 : 32'b0 ;
	assign signed_lt = ($signed(i1) < $signed(i2)) ? 32'b1 : 32'b0;

    assign lt = ($signed(i1) < $signed(i2));
    assign gt = ($signed(i1) > $signed(i2));
 
endmodule
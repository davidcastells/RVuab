module COMP (input logic [31:0] i1, i2, output logic [31:0] unsigned_lt, output logic [31:0] signed_lt, output logic lt, gt, eq);

 // Compare the two inputs
 assign lt = (i1 <  i2);
 assign gt = (i1 >  i2);
 assign eq = (i1 == i2);

 
 assign unsigned_lt  = (i1 < i2) ? 32'b1 : 32'b0 ;
 assign signed_lt = ($signed(i1) < $signed(i2)) ? 32'b1 : 32'b0;
 
endmodule
`default_nettype none

module RegFile(input logic clk, input logic reset, 
	input logic [4:0] rs1_addr, rs2_addr, rd_addr, 
	input logic ld_rd, input logic [31:0] rd, 
	output logic [31:0] rs1, rs2,
	// Debug wires
	output logic [31:0] x10
	);

	logic [31:0] q[0:31];

	assign q[0] = 32'b0;

	genvar i;
	 generate
		  for (i = 1; i < 32; i++) begin : bit_slice
				
				Reg32 r(.clk(clk), .reset(reset), .load(ld_rd && (rd_addr == i)), .d(rd), .q(q[i]));
		  end
	endgenerate

	assign rs1 = q[rs1_addr];
	assign rs2 = q[rs2_addr];

	assign x10 = q[10];

endmodule
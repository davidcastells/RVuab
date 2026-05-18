`default_nettype none

module SHIFT(input logic [31:0] i1, input logic [5:0] i2, input logic sign_extend, output logic [31:0] sr, sra, sl );

logic [4:0] shamt;
//logic       arith;

assign shamt = i2[4:0];
//assign arith = i2[5];

    always_comb begin
		// Arithmetic Right Shift (SRA / SRAI) - Preserves sign bit
		sra = $signed(i1) >>> shamt;
		// Logical Right Shift (SRL / SRLI) - Pads with zeros
		sr = i1 >> shamt;
		// Logical Left Shift (SLL / SLLI)
		sl = i1 << shamt;
    end
	 
endmodule
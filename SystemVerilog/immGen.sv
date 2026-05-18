`default_nettype none

module immGen(input logic [31:0] ir, output logic [31:0] imm);
logic [2:0] imm_typ;
logic [6:0] opcode;

assign opcode = ir[6:0];

SelectType SelectType(opcode, imm_typ);

always_comb
begin
case (imm_typ)
0: imm = {{20{ir[31]}}, ir[31:20]}; 											// I type
1: imm = {{20{ir[31]}}, ir[31:25], ir[11:7]}; 								// S type
2: imm = {{19{ir[31]}}, ir[31], ir[7], ir[30:25], ir[11:8], 1'b0};	// B type
3: imm = {ir[31:12], 12'b0};														// U type
4: imm = {{11{ir[31]}}, ir[31], ir[19:12], ir[20], ir[30:21], 1'b0};	// J type	
default: imm = 32'b0;
endcase
end

endmodule


module SelectType(input logic [6:0] opcode, output logic [2:0] imm_typ);
logic [2:0] a;
logic [3:0] b;

assign a = opcode[6:4];
assign b = opcode[3:0];

always_comb
begin
case (a)
3'b000: imm_typ = 3'b000;
3'b001: imm_typ = (b == 3)? 3'b000 : 3'b011;
3'b010: imm_typ = 3'b001;
3'b011: imm_typ = 3'b011;
3'b110: case (b)
     4'b0011: imm_typ = 3'b010;
	  4'b0111: imm_typ = 3'b000;
	  4'b1111: imm_typ = 3'b100;
	  default: imm_typ = 3'b111;
   endcase
default: imm_typ = 3'b111;
endcase 
end

endmodule 
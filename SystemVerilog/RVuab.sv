module RVuab(input logic clk, input logic reset, 
	// To Debug in Quartus Simulator we have to export signals to the top entity
	output logic [31:0] PC_q,
	output logic [9:0] microprogram_add
);

	logic [31:0] IR_d;
	logic [31:0] IR_q;
	logic  ldIR;

	logic [6:0] IR_op;
	logic [2:0] IR_f3;
	logic [6:0] IR_f7;

	logic [31:0] PC_d;
	// logic [31:0] PC_q;
	logic  ldPC;

	logic [31:0] DAdr_q;
	logic ldDAdr;

	logic [31:0] alu_i1;
	logic [31:0] alu_i2;
	logic [31:0] alu_out;
	logic [3:0] opALU;

	logic [31:0] imm;

	logic [4:0] rs1_addr;
	logic [4:0] rs2_addr;
	logic [4:0] rd_addr;

	logic ldRD;
	logic [31:0] rd_d;
	logic [31:0] rs1_q;
	logic [31:0] rs2_q;

	logic gt_d, lt_d, eq_d, zero_d; 
	logic gt_q, lt_q, eq_q, zero_q; 
	logic ldRFlags;

	logic [31:0] adder_i1;
	logic [31:0] adder_out;
	logic slPCin;
	logic slAddi1;

	logic [31:0] DM_q;

	logic RW_DM;
	logic RW_IM; // This is never used

	logic slALUi1;
	logic slALUi2;
	logic [1:0] slDinRD;

	// Registers
	Mux1 sel_pc(.d0(adder_out), .d1(alu_out), .sel(slPCin), .y(PC_d));

	Reg32 IR(.clk(clk), .reset(reset), .load(ldIR), .d(IR_d), .q(IR_q));
	Reg32 PC(.clk(clk), .reset(reset), .load(ldPC), .d(PC_d), .q(PC_q));
	Reg32 DAdr(.clk(clk), .reset(reset), .load(ldDAdr), .d(alu_out), .q(DAdr_q));

	Reg1 r_gt(.clk(clk), .reset(reset), .load(ldRFlags), .d(gt_d), .q(gt_q));
	Reg1 r_lt(.clk(clk), .reset(reset), .load(ldRFlags), .d(lt_d), .q(lt_q));
	Reg1 r_eq(.clk(clk), .reset(reset), .load(ldRFlags), .d(eq_d), .q(eq_q));
	Reg1 r_zero(.clk(clk), .reset(reset), .load(ldRFlags), .d(zero_d), .q(zero_q));

	// immGen
	immGen immGen(.ir(IR_q), .imm(imm));

	// Reg File
	assign rd_addr = IR_q[11:7];
	assign rs1_addr = IR_q[19:15];
	assign rs2_addr = IR_q[24:20];

	RegFile RegFile(.clk(clk), .reset(reset), .rs1_addr(rs1_addr), .rs2_addr(rs2_addr), .rd_addr(rd_addr),
		.ld_rd(ldRD), .rd(rd_d), .rs1(rs1_q), .rs2(rs2_q));

	// ALU
	Mux1 alu_i1_d(.d0(rs1_q), .d1(PC_q), .sel(slALUi1), .y(alu_i1));
	Mux1 alu_i2_d(.d0(rs2_q), .d1(imm), .sel(slALUi2), .y(alu_i2));

	ALU ALU(.op(opALU), .i1(alu_i1), .i2(alu_i2), .out(alu_out), .gt(gt_d), .lt(lt_d), .eq(eq_d), .zero(zero_d));

	// Adder
	Mux1 sel_adder_i1(.d0(32'd4), .d1(imm), .sel(slAddi1), .y(adder_i1));

	Adder Adder(.i1(adder_i1), .i2(PC_q), .out(adder_out));


	// UC

	assign IR_op = IR_q[6:0];
	assign IR_f3 = IR_q[14:12];
	assign IR_f7 = IR_q[31:25];

	UC UC(.clk(clk), .reset(reset), 
		//
		.IR_op(IR_op), .IR_f3(IR_f3), .IR_f7(IR_f7),
		// Computing Units
		.slALUi1(slALUi1), .slALUi2(slALUi2), .opALU(opALU),
		.slAddi1(slAddi1),
		// Storage Units
		.RW_IM(RW_IM),
		.slDinRD(slDinRD), .ldRD(ldRD),
		.RW_DM(RW_DM),
		.ldIR(ldIR), 
		.ldPC(ldPC), .slPCin(slPCin),
		.ldRFlags(ldRFlags),
		.ldDAdr(ldDAdr),
		// Flags
		.gt(gt_q), .lt(lt_q), .eq(eq_q), .zero(zero_q),
		// Debug
		.add(microprogram_add)
		);

	// Memories	
	Mux2 iSelRD(.d0(adder_out), .d1(DM_q), .d2(alu_out), .d3(32'b0), .sel(slDinRD), .y(rd_d));
		 
	IM IM (.clk(clk), .address(PC_q), .data_in(32'b0), .be(4'b1111), .read(1'b1), .write(1'b0), .data_out(IR_d));
	DM DM (.clk(clk), .address(DAdr_q), .data_in(rs2_q), .be(4'b1111), .read(1'b1), .write(RW_DM), .data_out(DM_q));

endmodule
import py4hw

class RVuab(py4hw.Logic):
    def __init__(self, parent, name, clk, reset):
        super().__init__(parent, name)

        # Ports
        self.addIn('clk', clk)
        self.addIn('reset', reset)

        # ── Internal wires ──────────────────────────────────────────────────

        IR_d          = self.wire('IR_d', 32)
        IR_q          = self.wire('IR_q', 32)
        ldIR          = self.wire('ldIR', 1)

        IR_op         = self.wire('IR_op', 7)
        IR_f3         = self.wire('IR_f3', 3)
        IR_f7         = self.wire('IR_f7', 7)

        PC_d          = self.wire('PC_d', 32)
        ldPC          = self.wire('ldPC', 1)

        DAdr_q        = self.wire('DAdr_q', 32)

        alu_i1        = self.wire('alu_i1', 32)
        alu_i2        = self.wire('alu_i2', 32)
        alu_out       = self.wire('alu_out', 32)
        opALU         = self.wire('opALU', 4)

        imm           = self.wire('imm', 32)

        rs1_addr      = self.wire('rs1_addr', 5)
        rs2_addr      = self.wire('rs2_addr', 5)
        rd_addr       = self.wire('rd_addr', 5)

        ldRD          = self.wire('ldRD', 1)
        rd_d          = self.wire('rd_d', 32)
        rs1_q         = self.wire('rs1_q', 32)
        rs2_q         = self.wire('rs2_q', 32)

        gt_d          = self.wire('gt_d', 1)
        lt_d          = self.wire('lt_d', 1)
        eq_d          = self.wire('eq_d', 1)
        zero_d        = self.wire('zero_d', 1)
        gt_q          = self.wire('gt_q', 1)
        lt_q          = self.wire('lt_q', 1)
        eq_q          = self.wire('eq_q', 1)
        zero_q        = self.wire('zero_q', 1)
        ldRFlags      = self.wire('ldRFlags', 1)
        ldDadr        = self.wire('ldDAdr', 1)
        
        adder_i1      = self.wire('adder_i1', 32)
        adder_out     = self.wire('adder_out', 32)
        slPCin        = self.wire('slPCin', 1)
        slAddi1       = self.wire('slAddi1', 1)

        DM_q          = self.wire('DM_q', 32)

        RW_DM         = self.wire('RW_DM', 1)
        RW_IM         = self.wire('RW_IM', 1)   # driven by UC, never used

        slALUi1       = self.wire('slALUi1', 1)
        slALUi2       = self.wire('slALUi2', 1)
        slDinRD       = self.wire('slDinRD', 2)

        const4        = self.wire('const4', 32)
        const0_32     = self.wire('const0_32', 32)

        py4hw.Constant(self, 'c4',    4, 32, const4)
        py4hw.Constant(self, 'c0_32', 0, 32, const0_32)

        # ── PC mux: PC_d = slPCin ? alu_out : adder_out ─────────────────────
        Mux1(self, 'sel_pc', d0=adder_out, d1=alu_out, sel=slPCin, y=PC_d)

        # ── Registers ────────────────────────────────────────────────────────
        Reg32(self, 'IR',   clk=clk, reset=reset, load=ldIR,     d=IR_d,   q=IR_q)
        Reg32(self, 'PC',   clk=clk, reset=reset, load=ldPC,     d=PC_d,   q=PC_q)
        Reg32(self, 'DAdr', clk=clk, reset=reset, load=ldDAdr,   d=alu_out, q=DAdr_q)

        Reg1(self, 'r_gt',   clk=clk, reset=reset, load=ldRFlags, d=gt_d,   q=gt_q)
        Reg1(self, 'r_lt',   clk=clk, reset=reset, load=ldRFlags, d=lt_d,   q=lt_q)
        Reg1(self, 'r_eq',   clk=clk, reset=reset, load=ldRFlags, d=eq_d,   q=eq_q)
        Reg1(self, 'r_zero', clk=clk, reset=reset, load=ldRFlags, d=zero_d, q=zero_q)

        # ── immGen ───────────────────────────────────────────────────────────
        immGen(self, 'immGen', ir=IR_q, imm=imm)

        # ── Register file address slices ─────────────────────────────────────
        # assign rs1_addr = IR_q[11:7]
        # assign rs2_addr = IR_q[19:15]
        # assign rd_addr  = IR_q[24:20]
        py4hw.Range(self, 'get_rs1_addr', IR_q,  11, 7, rs1_addr)
        py4hw.Range(self, 'get_rs2_addr', IR_q, 15, 19, rs2_addr)
        py4hw.Range(self, 'get_rd_addr',  IR_q, 20, 24, rd_addr)

        # ── Register file ────────────────────────────────────────────────────
        RegFile(self, 'RegFile',
                clk=clk, reset=reset,
                rs1_addr=rs1_addr, rs2_addr=rs2_addr, rd_addr=rd_addr,
                ld_rd=ldRD, rd=rd_d, rs1=rs1_q, rs2=rs2_q)

        # ── ALU input muxes ──────────────────────────────────────────────────
        Mux1(self, 'alu_i1_d', d0=rs1_q, d1=PC_q,  sel=slALUi1, y=alu_i1)
        Mux1(self, 'alu_i2_d', d0=rs2_q, d1=imm,   sel=slALUi2, y=alu_i2)

        # ── ALU ──────────────────────────────────────────────────────────────
        ALU(self, 'ALU',
            op=opALU, i1=alu_i1, i2=alu_i2, out=alu_out,
            gt=gt_d, lt=lt_d, eq=eq_d, zero=zero_d)

        # ── Adder ────────────────────────────────────────────────────────────
        Mux1(self, 'sel_adder_i1', d0=const4, d1=imm, sel=slAddi1, y=adder_i1)
        Adder(self, 'Adder', i1=adder_i1, i2=PC_q, out=adder_out)

        # ── IR field slices ──────────────────────────────────────────────────
        # assign IR_op = IR_q[6:0]
        # assign IR_f3 = IR_q[14:12]
        # assign IR_f7 = IR_q[31:25]
        py4hw.GetBits(self, 'get_IR_op', IR_q,  0,  6, IR_op)
        py4hw.GetBits(self, 'get_IR_f3', IR_q, 12, 14, IR_f3)
        py4hw.GetBits(self, 'get_IR_f7', IR_q, 25, 31, IR_f7)

        # ── Control unit ─────────────────────────────────────────────────────
        UC(self, 'UC',
           clk=clk, reset=reset,
           IR_op=IR_op, IR_f3=IR_f3, IR_f7=IR_f7,
           slALUi1=slALUi1, slALUi2=slALUi2, opALU=opALU,
           slAddi1=slAddi1,
           RW_IM=RW_IM,
           slDinRD=slDinRD, ldRD=ldRD,
           RW_DM=RW_DM,
           ldIR=ldIR,
           ldPC=ldPC, slPCin=slPCin,
           ldRFlags=ldRFlags,
           gt=gt_q, lt=lt_q, eq=eq_q, zero=zero_q,
           add=microprogram_add)

        # ── rd_d mux (4-input, 2-bit sel) ───────────────────────────────────
        # Mux2 iSelRD: d0=adder_out, d1=DM_q, d2=alu_out, d3=0
        Mux2(self, 'iSelRD',
             d0=adder_out, d1=DM_q, d2=alu_out, d3=const0_32,
             sel=slDinRD, y=rd_d)

        # ── Memories ─────────────────────────────────────────────────────────
        writeIM  = self.wire('writeIM')
        readDM    = self.wire('readDM')
        be    = self.wire('be',    4)   

        py4hw.Constant(self, 'writeIM', 0, 1, writeIM)
        py4hw.Constant(self, 'readDM', 1, 1, readDM)
        py4hw.Constant(self, 'be',   0xF, 4, be)

        IM(self, 'IM',
           clk=clk,
           address=PC_q,
           data_in=const0_32,
           be=be,
           read=const1,
           write=writeIM,      
           data_out=IR_d)

        DM(self, 'DM',
           clk=clk,
           address=DAdr_q,
           data_in=rs2_q,
           be=be,
           read=readDM,
           write=RW_DM,
           data_out=DM_q)

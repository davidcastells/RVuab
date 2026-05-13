import py4hw

class ALU(py4hw.Logic):
    def __init__(self, parent, name, op, i1, i2, out, gt, lt, eq, zero):
        super().__init__(parent, name)

        # Input ports
        self.addIn('op', op)
        self.addIn('i1', i1)
        self.addIn('i2', i2)

        # Output ports
        self.addOut('out', out)
        self.addOut('gt', gt)
        self.addOut('lt', lt)
        self.addOut('eq', eq)
        self.addOut('zero', zero)

        # Internal wires
        r_and     = self.wire('r_and', 32)
        r_or      = self.wire('r_or', 32)
        r_xor     = self.wire('r_xor', 32)
        r_add_sub = self.wire('r_add_sub', 32)
        r_sr      = self.wire('r_sr', 32)
        r_sra     = self.wire('r_sra', 32)
        r_sl      = self.wire('r_sl', 32)
        r_unsigned_lt = self.wire('r_unsigned_lt', 32)
        r_signed_lt   = self.wire('r_signed_lt', 32)

        inv          = self.wire('inv')
        align2       = self.wire('align2')
        sign_extend  = self.wire('sign_extend')

        # Bit extractions: inv = op[2], align2 = op[0], sign_extend = op[1]
        py4hw.Bit(self, 'get_inv',         op, 2, inv)
        py4hw.Bit(self, 'get_align2',      op, 0, align2)
        py4hw.Bit(self, 'get_sign_extend', op, 1, sign_extend)

        # r_or = i1 | i2
        py4hw.Or2(self, 'or_gate', i1, i2, r_or)

        # Submodule instantiations
        SR(self,    'SR',    i1, i2, inv, align2, r_add_sub, r_and, r_xor)
        SHIFT(self, 'SHIFT', i1, i2, sign_extend, r_sr, r_sra, r_sl)
        COMP(self,  'COMP',  i1, i2, r_unsigned_lt, r_signed_lt, lt, gt, eq)

        # Mux4 (16-input mux selected by 4-bit op)
        zero_32 = self.wire('zero_32', 32)
        py4hw.Constant(self, 'const_zero', 0, 32, zero_32)

        Mux4(self, 'Mux4',
             d0=r_and,
             d1=r_or,
             d2=r_add_sub,
             d3=r_add_sub,
             d4=r_unsigned_lt,
             d5=r_signed_lt,
             d6=r_add_sub,
             d7=zero_32,
             d8=zero_32,
             d9=r_xor,
             d10=i1,
             d11=i2,
             d12=r_sr,
             d13=r_sra,
             d14=r_sl,
             d15=zero_32,
             sel=op,
             y=out)

        # zero = (out == 32'b0)
        py4hw.Eq(self, 'zero_check', out, zero_32, zero)

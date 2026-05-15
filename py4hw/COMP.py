import py4hw

class COMP(py4hw.Logic):
    def __init__(self, parent, name,  i1, i2, unsigned_lt, signed_lt, lt, gt, eq):
        super().__init__(parent, name)

        # Input ports
        self.addIn('i1', i1)
        self.addIn('i2', i2)

        # Output ports
        self.addOut('unsigned_lt', unsigned_lt)
        self.addOut('signed_lt', signed_lt)
        self.addOut('gt', gt)
        self.addOut('lt', lt)
        self.addOut('eq', eq)

        gtu = self.wire('gtu')
        ltu = self.wire('ltu')

        py4hw.ComparatorSignedUnsigned(self, 'cmp', i1, i2, gtu, eq, ltu, gt, lt)

        py4hw.ZeroExtend(self, 'signed_lt', lt, signed_lt)
        py4hw.ZeroExtend(self, 'unsigned_lt', ltu, unsigned_lt)
        

import py4hw

class SelectType(py4hw.Logic):
    def __init__(self, parent, name, opcode, imm_type):
        super().__init__(parent, name)

        assert(opcode.getWidth() == 7)
        
        self.opcode = self.addIn ('opcode',  opcode)
        self.imm_type = self.addOut('imm_type', imm_type)

    def propagate(self):
        a = (self.opcode.get() >> 4)  & ((1<<3)-1);
        b = (self.opcode.get() )  & ((1<<4)-1);

        if (a == 0): self.imm_type.put(0) # I Type
        elif (a == 1): 
            if (b == 3): self.imm_type.put(0) # I Type
            else: self.imm_type.put(3)
        elif (a == 2):
            self.imm_type.put(1)
        elif (a == 3):
            self.imm_type.put(3)
        elif (a == 6):
            if (b == 3): self.imm_type.put(2)
            elif (b==7): self.imm_type.put(0)
            elif (b==0xF): self.imm_type.put(4)
            else: self.imm_type.put(7)                
        else:
            self.imm_type.put(7)                

class immGen(py4hw.Logic):
    def __init__(self, parent, name, ir, imm):
        super().__init__(parent, name)

        self.addIn ('ir',  ir)
        self.addOut('imm', imm)

        opcode  = self.wire('opcode',  7)
        imm_typ = self.wire('imm_typ', 3)

        py4hw.Range(self, 'opcode', ir, 6, 0, opcode)
        SelectType(self, 'imm_type', opcode, imm_typ)

        imm_I = self.wire('imm_I', 32)
        imm_S = self.wire('imm_S', 32)
        imm_B = self.wire('imm_B', 32)
        imm_U = self.wire('imm_U', 32)
        imm_J = self.wire('imm_J', 32)
        zero = self.wire('zero', 32)

        hlp = py4hw.LogicHelper(self)

        zero_1 = hlp.hw_constant(1, 0)
        zero_12 = hlp.hw_constant(12, 0)
        
        ir_31 = hlp.hw_bit(ir, 31)
        ir_31_20 = hlp.hw_range(ir, 31, 20)
        ir_31_12 = hlp.hw_range(ir, 31, 12)
        ir_31_25 = hlp.hw_range(ir, 31, 25)
        ir_30_25 = hlp.hw_range(ir, 30, 25)
        ir_30_21 = hlp.hw_range(ir, 30, 21)
        ir_20 = hlp.hw_bit(ir, 20)
        ir_19_12 = hlp.hw_range(ir, 19, 12)
        ir_11_8 = hlp.hw_range(ir, 11, 8)
        ir_11_7 = hlp.hw_range(ir, 11, 7)
        ir_7 = hlp.hw_bit(ir, 7)

        py4hw.SignExtend(self, 'imm_I', ir_31_20, imm_I)
        py4hw.SignExtend(self, 'imm_S', hlp.hw_concatenate_msbf([ir_31_25, ir_11_7]), imm_S)
        py4hw.SignExtend(self, 'imm_B', hlp.hw_concatenate_msbf([ir_31, ir_7, ir_30_25, ir_11_8, zero_1]), imm_B)
        py4hw.ConcatenateMSBF(self, 'imm_U', [ ir_31_12, zero_12], imm_U)
        py4hw.SignExtend(self, 'imm_J', hlp.hw_concatenate_msbf([ir_31, ir_19_12, ir_20, ir_30_21, zero_1]), imm_J)
        py4hw.Constant(self, 'zero', 0, zero)
        
        py4hw.Mux(self, 'imm', imm_typ, [imm_I, imm_S, imm_B, imm_U, imm_J, zero, zero, zero], imm)
        

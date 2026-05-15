import py4hw

class RegFile(py4hw.Logic):
    def __init__(self, parent, name,  reset, rs1_addr, rs2_addr, rd_addr, ld_rd, rd, rs1, rs2):
        super().__init__(parent, name)
        
        reset = self.addIn('reset', reset)
        rs1_addr = self.addIn('rs1_addr', rs1_addr)
        rs2_addr = self.addIn('rs2_addr', rs2_addr)
        rd_addr = self.addIn('rd_addr', rd_addr)
        ld_rd = self.addIn('ld_rd', ld_rd)
        rd = self.addIn('rd', rd)
        rs1 = self.addOut('rs1', rs1)
        rs2 = self.addOut('rs2', rs2)
        
        # Internal register outputs, q[0] is hardwired to 0
        q = []
        
        zero = self.wire('q0', 32)
        py4hw.Constant(self, 'zero', 0, zero)
        q.append(zero)
        
        # Instantiate 31 registers for q[1..31]
        for i in range(1, 32):
            qi = self.wire(f'q{i}', 32)
            load_i = self.wire(f'load_{i}')
            addr_i = self.wire(f'addr_eq_{i}', 5)
            
            # load_i = ld_rd AND (rd_addr == i)
            
            py4hw.EqualConstant(self, f'eq_{i}', rd_addr, i, addr_i)  
            py4hw.And2(self, f'and_{i}', ld_rd, addr_i, load_i)
            
            py4hw.Reg(self, f'r{i}', reset=reset, enable=load_i, d=rd, q=qi)
            q.append(qi)
        
        # rs1 = q[rs1_addr], rs2 = q[rs2_addr]
        py4hw.Mux(self, 'mux_rs1', rs1_addr, q, rs1)
        py4hw.Mux(self, 'mux_rs2', rs2_addr, q, rs2)
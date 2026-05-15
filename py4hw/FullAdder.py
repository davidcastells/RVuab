import py4hw

class FullAdder(py4hw.Logic):
    """
    1-bit Full-Adder with optional i2 inversion and AND/XOR side outputs.
 
    Parameters
    ----------
    parent  : Logic
    name    : str
    i1      : Wire(1)   – bit from operand 1
    i2      : Wire(1)   – bit from operand 2
    ci      : Wire(1)   – carry in
    inv_i2  : Wire(1)   – when 1, invert i2 before the adder (enables subtraction)
    r       : Wire(1)   – sum output
    co      : Wire(1)   – carry out
    r_and   : Wire(1)   – i1 & i2  (raw i2, not inverted)
    r_xor   : Wire(1)   – i1 ^ i2  (raw i2, not inverted)
    """
 
    def __init__(self, parent: Logic, name: str, i1: Wire, i2: Wire, ci: Wire, inv_i2: Wire, r: Wire, co: Wire, r_and: Wire, r_xor: Wire):
        super().__init__(parent, name)
 
        self.i1     = self.addIn("i1",     i1)
        self.i2     = self.addIn("i2",     i2)
        self.ci     = self.addIn("ci",     ci)
        self.inv_i2 = self.addIn("inv_i2", inv_i2)
        self.r      = self.addOut("r",     r)
        self.co     = self.addOut("co",    co)
        self.r_and  = self.addOut("r_and", r_and)
        self.r_xor  = self.addOut("r_xor", r_xor)
 
        # ── internal wires ────────────────────────────────────────────────
        i2_eff   = self.wire("i2_eff",   1)   # i2 ^ inv_i2
        xor_tmp  = self.wire("xor_tmp",  1)   # i1 ^ i2_eff  (partial sum)
        and1     = self.wire("and1",     1)   # i1 & i2_eff
        and2     = self.wire("and2",     1)   # ci & (i1 ^ i2_eff)
 
        # i2_eff = i2 XOR inv_i2
        py4hw.Xor2(self, "xor_inv", i2, inv_i2, i2_eff)
 
        # sum = i1 ^ i2_eff ^ ci  →  r
        py4hw.Xor2(self, "xor_sum_a", i1, i2_eff, xor_tmp)
        py4hw.Xor2(self, "xor_sum_b", xor_tmp, ci, r)
 
        # carry = (i1 & i2_eff) | (ci & (i1 ^ i2_eff))
        py4hw.And2(self, "and_carry1", i1, i2_eff, and1)
        py4hw.And2(self, "and_carry2", ci, xor_tmp, and2)
        # OR of two 1-bit signals via Xor2 trick won't work – use Or2
        py4hw.Or2(self, "or_carry", and1, and2, co)
 
        # r_and = i1 & i2  (original i2)
        py4hw.And2(self, "and_out", i1, i2, r_and)
 
        # r_xor = i1 ^ i2  (original i2)
        py4hw.Xor2(self, "xor_out", i1, i2, r_xor)

    def structureName(self):
        return 'fa'
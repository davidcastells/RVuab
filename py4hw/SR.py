import py4hw
import FullAdder

class SR(py4hw.Logic):
    """
    py4hw equivalent of the SR module.
 
    Ports
    -----
    i1, i2      : Wire(32) – operands
    inv         : Wire(1)  – invert i2 (subtraction) and use as initial carry-in
    zero_i20    : Wire(1)  – force LSB of result to 0
    r           : Wire(32) – sum / difference result
    r_and       : Wire(32) – bitwise AND of i1 & i2
    r_xor       : Wire(32) – bitwise XOR of i1 ^ i2
    """
 
    def __init__(self, parent: Logic, name: str,
                 i1: Wire, i2: Wire, inv: Wire, zero_i20: Wire,
                 r: Wire, r_and: Wire, r_xor: Wire):
        super().__init__(parent, name)
 
        self.i1       = self.addIn("i1",       i1)
        self.i2       = self.addIn("i2",       i2)
        self.inv      = self.addIn("inv",      inv)
        self.zero_i20 = self.addIn("zero_i20", zero_i20)
        self.r        = self.addOut("r",       r)
        self.r_and    = self.addOut("r_and",   r_and)
        self.r_xor    = self.addOut("r_xor",   r_xor)
 
        # ── per-bit internal wires ─────────────────────────────────────────
        # co_internal[i] – carry out of bit i
        co   = [self.wire(f"co_{i}",    1) for i in range(32)]
        # r_internal[i]  – raw sum bit i (before zero_i20 masking)
        ri   = [self.wire(f"ri_{i}",    1) for i in range(32)]
        # individual bits of outputs r_and, r_xor
        ra   = [self.wire(f"ra_{i}",    1) for i in range(32)]
        rx   = [self.wire(f"rx_{i}",    1) for i in range(32)]
        # individual 1-bit slices of i1, i2
        a    = [self.wire(f"a_{i}",     1) for i in range(32)]
        b    = [self.wire(f"b_{i}",     1) for i in range(32)]
 
        # Slice i1 and i2 into individual bits
        for i in range(32):
            py4hw.Bit(self, f"bit_i1_{i}", i1, i, a[i])
            py4hw.Bit(self, f"bit_i2_{i}", i2, i, b[i])
 
        # ── generate loop: 32 FullAdder instances ─────────────────────────
        #   ci for bit 0  = inv  (adds 1 when subtracting, giving 2's complement)
        #   ci for bit i  = co[i-1]
        for i in range(32):
            ci_wire = inv if i == 0 else co[i - 1]
            FullAdder.FullAdder(self, f"fa_{i}",
                      a[i], b[i], ci_wire, inv,
                      ri[i], co[i], ra[i], rx[i])
 
        # ── assemble 32-bit outputs ────────────────────────────────────────
        # r_and and r_xor are straightforward concatenations (LSB first)
        py4hw.ConcatenateLSBF(self, "concat_rand", ra, r_and)
        py4hw.ConcatenateLSBF(self, "concat_rxor", rx, r_xor)
 
        # r = zero_i20 ? {r_internal[31:1], 1'b0} : r_internal
        #   → if zero_i20=1 : bit 0 of output = 0, bits 31:1 = ri[31:1]
        #   → if zero_i20=0 : all bits from ri[]
        #
        # Strategy: always build r_internal as a 32-bit bus, then apply the
        # LSB mask with a Mux2 on bit 0 and concatenate.
        zero_bit = self.wire("zero_bit", 1)
        py4hw.Constant(self, "const0", 0, zero_bit)
        lsb_out = self.wire("lsb_out", 1)
        py4hw.Mux2(self, "mux_lsb", zero_i20, ri[0], zero_bit, lsb_out)
        
        prer = [lsb_out]
        prer.extend(ri[1:])
        py4hw.ConcatenateLSBF(self, "concat_ri", prer, r)
 
        
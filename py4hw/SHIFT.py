import py4hw

class SHIFT(py4hw.Logic):
    
    def __init__(self, parent: Logic, name: str,
                 i1: Wire, i2: Wire, sign_extend: Wire,
                 sr: Wire, sra: Wire, sl: Wire):
        super().__init__(parent, name)
 
        # ── primary ports ────────────────────────────────────────────────
        i1          = self.addIn("i1",          i1)
        i2          = self.addIn("i2",          i2)
        sign_extend = self.addIn("sign_extend", sign_extend)
        sr          = self.addOut("sr",  sr)
        sra         = self.addOut("sra", sra)
        sl          = self.addOut("sl",  sl)
 
        # ── internal wires ───────────────────────────────────────────────
        shamt = self.wire("shamt", 5)   # i2[4:0]
 
        # Slice i2[4:0] → shamt  (Range: wire, high_bit, low_bit, out)
        py4hw.Range(self, "shamt", i2, 4, 0, shamt)
 
        # ── shift sub-cells ──────────────────────────────────────────────
        py4hw.ShiftRight(self, "sr",  i1, shamt, sr, False)
        py4hw.ShiftRight(self, "sra", i1, shamt, sra, True)
        py4hw.ShiftLeft(self,  "sl",  i1, shamt, sl)
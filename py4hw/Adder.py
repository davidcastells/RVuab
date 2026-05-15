import py4hw

class Adder(py4hw.Logic):
    def __init__(self, parent, name, i1, i2, out):
        super().__init__(parent, name)

        self.addIn('i1', i1)
        self.addIn('i2', i2)

        # Output ports
        self.addOut('out', out)

        py4hw.Add(self, 'add', i1, i2, out)

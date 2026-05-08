module IM (
    input  logic        clk,
    input  logic [31:0] address,
    input  logic [31:0] data_in,
    input  logic [3:0]  be,          // byte enable: bit0->byte0, bit1->byte1, etc.
    input  logic        read,
    input  logic        write,
    output logic [31:0] data_out
);

    // Memory size: 2^10 bytes = 1024 bytes = 256 words (32-bit each)
    localparam DEPTH = 256;
    localparam ADDR_WIDTH = $clog2(DEPTH);  // 8 bits for word addressing

    // Memory array: 256 words of 32 bits each
    logic [31:0] memory [0:DEPTH-1];

    // Word-aligned address: ignore lower 2 bits
    wire [ADDR_WIDTH-1:0] word_addr = address[ADDR_WIDTH+1:2];

    // Read operation (combinational)
    always_comb begin
        if (read) begin
            data_out = memory[word_addr];
        end else begin
            data_out = 32'b0;
        end
    end

    // Write operation (sequential)
    integer i;
    always_ff @(posedge clk ) begin
            // Byte-enable write
            if (be[0]) memory[word_addr][7:0]   <= data_in[7:0];
            if (be[1]) memory[word_addr][15:8]  <= data_in[15:8];
            if (be[2]) memory[word_addr][23:16] <= data_in[23:16];
            if (be[3]) memory[word_addr][31:24] <= data_in[31:24];
    end

endmodule
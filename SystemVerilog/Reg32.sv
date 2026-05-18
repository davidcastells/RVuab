`default_nettype none

module Reg32 (
    input  logic        clk,      // Clock
    input  logic        reset,    // Active-low asynchronous reset
    input  logic        load,     // Load enable (write enable)
    input  logic [31:0] d,        // Data input
    output logic [31:0] q         // Data output
);
    
    logic [31:0] reg_data;
    
    // Asynchronous reset, synchronous load
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_data <= 32'd0;
        end
        else if (load) begin
            reg_data <= d;
        end
    end
    
    assign q = reg_data;
    
endmodule

module Reg1 (
    input  logic        clk,      // Clock
    input  logic        reset,    // Active-low asynchronous reset
    input  logic        load,     // Load enable (write enable)
    input  logic  d,        // Data input
    output logic  q         // Data output
);
    
    logic  reg_data;
    
    // Asynchronous reset, synchronous load
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_data <= 1'd0;
        end
        else if (load) begin
            reg_data <= d;
        end
    end
    
    assign q = reg_data;
    
endmodule
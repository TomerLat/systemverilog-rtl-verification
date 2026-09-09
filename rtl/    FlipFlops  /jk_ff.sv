`timescale 1ns / 1ps

// Define a module named "top" with an interface "jk_if"
module jk_top(jk_if.dut jkif);
    
    // Always block triggered on the positive edge of the clock
    always_ff @(posedge jkif.clk) begin
    
        case ({jkif.j, jkif.k}) // Concatenation of J & K
            // 2'b00 --> Hold State
            2'b01 : jkif.q <= 1'b0; // Reset
            2'b10 : jkif.q <= 1'b1; // Set
            2'b11 : jkif.q <= ~jkif.q; // Toggle
        endcase
        
    end
endmodule

// Define an interface module for the DUT
interface jk_if;

    logic clk; // Clock Signal - Input
    logic k; // Reset Signal - Input
    logic j; // Set Signal - Input
    logic q; // Data Output
    
    // DUT modport
    modport dut(input clk, input k, input j, output q);
endinterface

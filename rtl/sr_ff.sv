`timescale 1ns / 1ps

// Define a module named "top" with an interface "sr_if"
module sr_top(sr_if.dut srif);
    
    // Always block triggered on the positive edge of the clock
    always_ff @(posedge srif.clk) begin
    
        case ({srif.set, srif.rst}) // Concatenation of Set & Reset
            // 2'b00 --> Hold State
            2'b01 : srif.q <= 1'b0; // Reset
            2'b10 : srif.q <= 1'b1; // Set
            2'b11 : srif.q <= 1'bx; // Invalid (Simulation Only)
        endcase
        
    end
endmodule

// Define an interface module for the DUT
interface sr_if;

    logic clk; // Clock Signal - Input
    logic rst; // Reset Signal - Input
    logic set; // Set Signal - Input
    logic q; // Data Output
    
    // DUT modport
    modport dut(input clk, input rst, input set, output q);
endinterface

`timescale 1ns / 1ps

//Define a module named "top" with an interface "tif_if"
module top(tif_if.dut tif);
    
    
    // Always block triggered on the positive edge of the clock
    always_ff @(posedge tif.clk) begin
        // Check if the reset signal is asserted, if reset is active then output is '0
        if(tif.rst == 1'b1)
            tif.q <= 1'b0;
        // If Toggle is active than output is the complement of the previous output
        else if (tif.t == 1'b1)
            tif.q <= ~tif.q;
        // Else the output keeps the same state
    end
endmodule


interface tif_if;
    logic clk; // Clock Signal
    logic rst; // Reset Signal
    logic t; // Toggle Input
    logic q; // Data Output
    
    // DUT modport
    modport dut(input clk, rst, t, output q);
    
endinterface

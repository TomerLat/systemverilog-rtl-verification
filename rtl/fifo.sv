`timescale 1ns / 1ps



module fifo_top(fifo_if.dut fif);
    
    // Pointers for Write and Read operations
    reg [3:0] wptr = 0, rptr = 0;
    
    // Counter for tracking the number of elements in FIFO
    reg [4:0] cnt = 0;
    
    // Memory array to stroe data
    reg [7:0] mem [15:0];
    
    always @(posedge fif.clk) begin
        if (fif.rst == 1'b1) begin
            // Reset the pointers and counter when Reset is asserted
            wptr <= 0;
            rptr <= 0;
            cnt <= 0;
        end
        else if (fif.wr && !fif.full) begin
            // Write data to the FIFO if it's not full yet
            mem[wptr] <= fif.data_in;
            wptr <= wptr + 1;
            cnt <= cnt + 1;
        end
        else if (fif.rd && !fif.empty) begin
            // Read data from FIFO if it's not empty yet
            fif.data_out <= mem[rptr];
            rptr <= rptr + 1;
            cnt <= cnt - 1;
        end
        
    end
    
    // Determine if FIFO is 'empty' or 'full'
    assign fif.empty = (cnt == 0) ? 1'b1 : 1'b0;
    assign fif.full = (cnt == 16) ? 1'b1 : 1'b0;
        
endmodule


////////////////////////////////////////


// Define an interface for FIFO
interface fifo_if;
    
    logic clk, rd, wr; // Clock, Read and Write Signals
    logic full, empty; // Flag of FIFO's status
    logic [7:0] data_in; // Data Input
    logic [7:0] data_out; // Data Output
    logic rst; // Reset signal
    
    // DUT modport
    modport dut (input clk, input rd,input wr,input rst, input data_in,
                output full, output empty, output data_out);
endinterface

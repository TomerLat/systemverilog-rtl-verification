`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module top(wb_if.dut vif);

    reg [7:0] mem[256]; // 256-size array to store 8-bit data
    reg [7:0] temp; // 8-bit data to store in array
    
    // FSM
    typedef enum bit [1:0] {idle = 0, check_mode = 1, write = 2, read = 3} state_type;
    state_type state, next_state;
    
    // Reset decoder
    always_ff @(posedge vif.clk) begin
        if(vif.rst) begin // Check reset
            state <= idle;
            for(int i = 0; i < 256; i++)
                mem[i] <= 8'h11;
        end
        else
            state <= next_state;
    end
    
    // Next state and output decoder
    always_comb begin
        case(state)
            
            // Idle state
            idle : begin
            vif.ack = 1'b0;
            vif.r_data = 8'h00;
            next_state = check_mode;                
           end
           
           // Check Mode state
           check_mode : begin
            if(vif.strb && vif.we)
                next_state = write;
            else if (vif.strb && !vif.we) begin
                next_state = read;
                temp = mem[vif.addr];
            end
            else
                next_state = check_mode;
           end
           
           // Write state
           write : begin
            mem[vif.addr] = vif.w_data;
            vif.ack = 1'b1;
            next_state = idle;
           end
           
           // Read state
           read : begin
            vif.r_data = temp;
            vif.ack = 1'b1;
            next_state = idle;
           end
           
           // Other state
           default : next_state = idle;
        endcase
    end
endmodule

//////////////////////////////////////////////////////////////////////////////////

interface wb_if;
    logic clk; // Clock signal
    logic we; // 1 - Write, 0- Signal - flag
    logic strb; // Transfer active flag
    logic rst; // Reset
    logic [7:0] addr; // 8-bit Address
    logic [7:0] w_data; // 8-bit Write Data
    logic [7:0] r_data; // 8-bit Read Data
    logic ack; // Slave done flag
    
    modport dut(input clk, we, strb, rst, addr, w_data, output r_data, ack);
endinterface

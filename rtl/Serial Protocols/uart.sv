`timescale 1ns / 1ps

////////////////////////////

// Transmitter
module uart_tx #(parameter clk_freq = 1_000_000, parameter baud_rate = 9_600) (uart_if.map_tx t);

    localparam clk_count = (clk_freq / baud_rate); // Number of clocks per UART bit
    
    integer count = 0; // Counter for internal clock generation
    integer count_s = 0; // Counter for transmitted data
    
    reg u_clk = 0; // Initialize internal clock signal
    
    enum bit {idle = 1'b0, transfer = 1'b1} state;
    
    // UART Clock Generation
    always @(posedge t.clk) begin
        if (count < (clk_count / 2))
            count <= count + 1;
        else begin
            count <= 0;
            u_clk <= ~u_clk;
        end
    end
    
    // Reset decoder
    
    reg [7:0] data_in;
    
    // State machine
    always @(posedge u_clk) begin
        if (t.rst) // Case reset
            state<= idle;
        else begin
            case(state)
                idle : begin // Case 'idle'
                    count_s <= 0;
                    t.tx <= 1'b1;
                    t.done_tx <= 1'b0;
                    
                    if (t.newd) begin
                        state <= transfer;
                        data_in <= t.data_in;
                        t.tx <= 1'b0; // tx changes from '1' to '0', indicates new data transfer
                    end
                    else
                        state <= idle;
                end
                // Case 'transfer'
                transfer: begin
                    // 8-bit data transfer
                    if (count_s <= 7) begin 
                        count_s <= count_s + 1;
                        t.tx <= data_in[count_s];  
                        state <= transfer;
                    end
                    else begin
                        count_s <= 0;
                        t.tx <= 1'b1; // tx changes to '1', indicates transfer finished
                        state <= idle;
                        t.done_tx <= 1'b1;
                    end
                end
                
                default : state <= idle;
            endcase
        end
    end
    
endmodule

/////////////////////////////

// Reciever
module uart_rx #(parameter clk_freq = 1_000_000, parameter baud_rate = 9_600) (uart_if.map_rx r);

    localparam clk_count = (clk_freq / baud_rate); // Number of clocks per UART bit
    
    integer count = 0; // Counter for internal clock generation
    integer count_s = 0; // Counter for recieved data
    
    reg u_clk = 0;
    
    enum bit [1:0] {idle = 2'b00, start = 2'b01} state;
    
    // UART Clock Generation
    always @(posedge r.clk) begin
        if (count < (clk_count / 2))
            count <= count + 1;
        else begin
            count <= 0;
            u_clk <= ~u_clk;
        end
    end
    
    always @(posedge u_clk) begin
        if (r.rst) begin
            state <= idle;
            count_s <= 0;
            
            r.data_out <= 8'h00;
            r.done_rx <= 1'b0;
        end
        else begin
            // State machine
            case(state)
                // Case 'idle'
                idle : begin
                    r.data_out <= 8'h00;
                    count_s <= 0;
                    r.done_rx <= 1'b0;
                    
                    if(r.rx == 1'b0)
                        state <= start;
                    else
                        state <= idle;
                end
                
                // Case 'start'
                start : begin
                    if (count_s <= 7) begin
                        count_s <= count_s + 1;
                        r.data_out <= {r.rx, r.data_out[7:1]};
                    end
                    else begin
                        count_s <= 0;
                        r.done_rx <= 1'b1;
                        state <= idle;
                    end
                end
                
                default : state <= idle;
            endcase
        end
    end
endmodule

////////////////////////////

// Design Main
module top #(parameter clk_freq = 1_000_000, parameter baud_rate = 9_600) (uart_if vif);

    uart_rx #(clk_freq, baud_rate) u_rx (vif.map_rx); // Connect Reciever to Interface
    uart_tx #(clk_freq, baud_rate) u_tx (vif.map_tx); // Connect Transmitter to Interface
    
    // assign vif.rx = vif.tx; // Connect Transmit-Recieve line
    assign vif.u_clk_tx = u_tx.u_clk;
    assign vif.u_clk_rx = u_rx.u_clk;
    
endmodule


////////////////////////////////////

// UART Interface
interface uart_if;
    logic clk; // Clock signal
    logic u_clk_tx; // Transmitrer clock signal
    logic u_clk_rx; // Reciever clock signal
    logic rst; // Reset signal
    logic rx; // Communication bit to recieve data
    logic tx; // Communication bit to transmit data
    logic [7:0] data_in; // 8-bit data input - Transmitter
    logic newd; // Flag to signal new data
    logic [7:0] data_out; // Data output- Reciever
    logic done_tx; // Event to trigger Transmitter done its work
    logic done_rx; // Event to trigger Reciever done its work
    
    modport map_tx(input clk, input rst, input newd, input data_in, output tx, output done_tx);
    modport map_rx(input clk, input rst, input rx, output done_rx, output data_out);
endinterface

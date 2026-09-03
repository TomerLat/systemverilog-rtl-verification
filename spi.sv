`timescale 1ns / 1ps

///////////////////////////////////

// SPI Master
module spi_master(spi_if.master mstr);

    // Create State Machine
    typedef enum bit [1:0] {idle = 2'b00, send = 2'b01} state_type;
    state_type state = idle;
    
    // Create counters to generate Serial Clock
    int countc = 0;
    int count = 0;
    
    // Generation of Serial Clock
    // Serial Clock signal is 20 times slower that Clock signal 
    always @(posedge mstr.clk) begin
        if(mstr.rst == 1'b1) begin
            countc <= 0;
            count <= 0;
            mstr.s_clk <= 1'b0;
        end
        else begin
            if (countc < 10)
                countc <= countc + 1;
            else begin
                countc <= 0;
                mstr.s_clk <= ~mstr.s_clk;
            end
                
        end
    end
    
    reg [11:0] temp; // 12-bit to store data
    
    always @(posedge mstr.s_clk) begin
        if (mstr.rst == 1'b1) begin
            mstr.cs <= 1'b1; // idle (active-low CS)
            mstr.mosi <= 1'b0;
        end
        else begin
            case (state)
                // 'idle' state
                idle: begin
                    // If new data signal is asserted then prepare to send data
                    if(mstr.newd == 1) begin
                        state <= send;
                        temp <= mstr.data_in;
                        mstr.cs <= 1'b0;
                    end
                    else begin
                        state <= idle;
                        temp <= 12'h000;
                    end
                end
                // 'send' state
                send: begin
                    // Send data information - 12-bit
                    if (count <= 11) begin
                        mstr.mosi <= temp[count]; // Sending LSB first
                        count <= count + 1; 
                    end
                    else begin
                        count <= 0;
                        state <= idle;
                        mstr.cs <= 1'b1;
                        mstr.mosi <= 1'b0;
                    end
                end
                
                default : state <= idle;
            endcase
        end
    end
endmodule

///////////////////////////////////

// SPI SLAVE
module spi_slave(spi_if.slave slv);
    
    // Create State Machine 
    typedef enum bit {detect_start = 1'b0, read_data = 1'b1} state_type;
    state_type state = detect_start;
    
    // 12-bit temoorary to store data input
    reg [11:0] temp = 12'h000;
    int count = 0;
    
    always @(posedge slv.s_clk) begin // Wait for Serial Clock's rising edge
        case (state)
            // 'detect_start' state
            detect_start: begin
                slv.done <= 1'b0;
                // Check if 'cs' is asserted
                if (slv.cs == 1'b0)
                    state <= read_data;
                else
                    state <= detect_start;
            end
            // 'read_data' state
            read_data : begin
                if (count <= 11) begin
                    count <= count + 1;
                    temp <= {slv.mosi, temp [11:1]};
                    
                end
                else begin
                    count <= 0;
                    slv.done <= 1'b1;
                    state <= detect_start;
                end
            end
        endcase
    end
    
    assign slv.data_out = temp;
endmodule

//////////////////////////////////////
module top(spi_if sif);

    
    
    spi_master m1 (sif.master);
    spi_slave s1 (sif.slave);

endmodule


/////////////////////////////////////

interface spi_if;
    logic clk; // Clock signal
    logic newd; // New Data enable signal
    logic rst; // Reset signal
    logic [11:0] data_in; // Data input
    
    logic s_clk; // Serial Clock signal
    logic cs; // Chip Select bit, active-low select: 1 = idle, 0 = transfer
    logic mosi; // Master Out Slave In signal
    
    logic [11:0] data_out; // Data output
    logic done;
    
    // Master module modport
    modport master(input clk, input newd, input rst, input data_in, output s_clk, output cs, output mosi);
    
    // Slave module modport
    modport slave(input s_clk, input cs, input mosi, output data_out, output done);    
endinterface

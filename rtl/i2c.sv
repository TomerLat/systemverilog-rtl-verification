
`timescale 1ns / 1ps
///////////////////////////
// Master
module I2C_master(i2c_if.master m);
    
    reg scl_t = 0, sda_t = 0; // internal Serial Clock, Serial Data
    
    parameter sys_freq = 40_000_000; // System's frequency 40 MHz
    parameter i2c_freq = 100_000; // Component's frequency 100 KHz
    
    parameter clk_count4 = (sys_freq / i2c_freq); // 400
    parameter clk_count1 = clk_count4 / 4; // 100
    
    integer count1 = 0; // Counter for clock1 generation
    reg i2c_clk = 0; // ?
    
    // 4-Phase counter
    reg [1:0] pulse = 0;
    always @(posedge m.clk) begin // Wait for 1 clock's rising edge
        if (m.rst) begin // Reset clock signal
            pulse <= 0;
            count1 <= 0;
        end
        else if (m.busy == 1'b0) begin // 'pulse' count start only after 'newd'
            pulse <= 0;
            count1 <= 0;
        end
        else if (count1 == clk_count1 - 1) begin // Check when count reach 100
            pulse <= 1;
            count1 <= count1 + 1;
        end
        else if (count1 == clk_count1 * 2 -1) begin // Check when count reach 200
            pulse <= 2;
            count1 <= count1 + 1;
        end
        else if (count1 == clk_count1 * 3 - 1) begin // Check when count reach 300
            pulse <= 3;
            count1 <= count1 + 1;
        end
        else if (count1 == clk_count1 * 4 - 1) begin // Check when count reach 400
            pulse <= 0;
            count1 <= 0;
        end
        else
            count1 <= count1 + 1;
    end
    
    // ?
    reg [3:0] bit_count = 0; //
    reg [7:0] data_addr = 0, data_tx = 0; // internal input address and transmitter dat
    reg r_ack = 0; // recieve ack flag
    reg [7:0] rx_data = 0; // internal recieve data
    reg sda_en = 0; // serial data enable
    
    
    // State Machine
    typedef enum logic [3:0] {idle = 0, start = 1, write_addr = 2, ack_1 = 3, write_data = 4, read_data = 5, stop = 6, ack_2 = 7, master_ack = 8} state_type;
    state_type state = idle;
    
    always @(posedge m.clk) begin // Wait for clock's rising edge
    if(m.rst) begin // Reset all inputs
        bit_count <= 0;
        data_addr <= 0;
        data_tx <= 0;
        scl_t <= 0;
        sda_t <= 1;
        state <= idle;
        m.busy <= 1'b0;
        m.ack_err <= 1'b0;
        m.done <= 1'b0;
    end
    else begin
        case(state)
            // Idle state
            idle: begin
                m.done <= 1'b0;
                if(m.newd == 1'b1) begin
                    data_addr <= {m.addr, m.op};
                    data_tx <= m.din;
                    m.busy <= 1'b1;
                    state <= start;
                    m.ack_err <= 1'b0;
                end
                else begin
                    data_addr <= 0;
                    data_tx <= 0;
                    m.busy <= 1'b0;
                    state <= idle;
                    m.ack_err <= 1'b0;
                end
            end
            // Start state
            start: begin
                sda_en <= 1'b1; // Send start to slace
                    // Pulse State-Machine cases
                    case(pulse)
                        0 : begin scl_t <= 1'b1; sda_t <= 1'b1; end
                        1 : begin scl_t <= 1'b1; sda_t <= 1'b1; end
                        2 : begin scl_t <= 1'b1; sda_t <= 1'b0; end
                        3 : begin scl_t <= 1'b1; sda_t <= 1'b0; end
                    endcase
                    
                    if(count1 == clk_count1 * 4 - 1) begin
                        state <= write_addr;
                        scl_t <= 1'b0;
                    end
                    else
                        state <= start;
            end
            
            // Write Address state
            write_addr: begin
                sda_en <= 1'b1; // Send addr to slace
                if(bit_count <= 7) begin
                    case(pulse)
                        0 : begin scl_t <= 1'b0; sda_t <= 1'b0; end
                        1 : begin scl_t <= 1'b0; sda_t <= data_addr[7 - bit_count]; end
                        2 : begin scl_t <= 1'b1; end
                        3 : begin scl_t <= 1'b1; end 
                    endcase
                    
                    if(count1 == clk_count1 * 4 - 1) begin
                        state <= write_addr;
                        scl_t <= 1'b0;
                        bit_count <= bit_count + 1;
                    end
                    else
                        state <= write_addr;
                end
                else begin
                    state <= ack_1;
                    bit_count <= 0;
                    sda_en <= 1'b0;
                end
            end
            
            // Ack_1
            ack_1 : begin
                sda_en <= 1'b0; // Recieve from slave
                case(pulse)
                    0 : begin scl_t <= 1'b0; sda_t <= 1'b0; end
                    1 : begin scl_t <= 1'b0; sda_t <= 1'b0; end
                    2 : begin scl_t <= 1'b1; sda_t <= 1'b0; r_ack <= m.sda; end // Recieve ACK from Slave
                    3 : begin scl_t <= 1'b1; end 
                endcase
                
                if(count1 == clk_count1 * 4 - 1) begin
                    if (r_ack == 1'b0 && data_addr[0] == 1'b0) begin
                        state <= write_data;
                        sda_t <= 1'b0;
                        sda_en <= 1'b1; // Write data to Slave
                        bit_count <= 0;
                    end
                    else if (r_ack == 1'b0 && data_addr[0] == 1'b1) begin
                        state <= read_data;
                        sda_t <= 1'b1;
                        sda_en <= 1'b0; // Read data from Slave
                        bit_count <= 0;
                    end
                    else begin
                        state <= stop;
                        sda_en <= 1'b1; // Send 'stop' to Slave
                        m.ack_err <= 1'b1;
                    end
                end
                else
                    state <= ack_1;
            end
            
            // Write Data state
            write_data: begin
                if(bit_count <= 7) begin
                    case(pulse)
                        0 : begin scl_t <= 1'b0; end
                        1: begin scl_t <= 1'b0; sda_en <= 1'b1; sda_t <= data_tx[7 - bit_count]; end
                        2 : begin scl_t <= 1'b1; end
                        3 : begin scl_t <= 1'b1; end
                    endcase
                    if (count1 == clk_count1 * 4 - 1) begin
                        state <= write_data;
                        scl_t <= 1'b0;
                        bit_count <= bit_count + 1;
                    end
                    else
                        state <= write_data;
                end
                else begin
                    state <= ack_2;
                    bit_count <= 0;
                    sda_en <= 1'b0; // Read from Slave
                end
            end
            
            // Read Data slave
            read_data : begin
                sda_en <= 1'b0; // Read from slave
                if (bit_count <= 7) begin
                    case(pulse)
                        0 : begin scl_t <= 1'b0; sda_t <= 1'b0; end
                        1 : begin scl_t <= 1'b0; sda_t <= 1'b0; end
                        2 : begin scl_t <= 1'b1; rx_data[7:0] <= (count1 == 200) ? {rx_data[6:0], m.sda} : rx_data; end
                        3 : begin scl_t <= 1'b1; end
                    endcase
                    
                    if (count1 == clk_count1 * 4 - 1) begin
                        state<= read_data;
                        scl_t <= 1'b0;
                        bit_count <= bit_count + 1;
                    end
                    else
                        state <= read_data;
                end
                else begin
                    state <= master_ack;
                    bit_count <= 0;
                    sda_en <= 1'b1; // Master will send ACK to Slave
                end
            end
            
            // Master ACK -> Send NACK
            master_ack : begin
                sda_en <= 1'b1;
                case(pulse)
                    0 : begin scl_t <= 1'b0; sda_t <= 1'b1; end
                    1 : begin scl_t <= 1'b0; sda_t <= 1'b1; end
                    2 : begin scl_t <= 1'b1; sda_t <= 1'b1; end
                    3 : begin scl_t <= 1'b1; sda_t <= 1'b1; end
                endcase
                
                if (count1 == clk_count1 * 4 - 1) begin
                    sda_t <= 1'b0;
                    state <= stop;
                    sda_en <= 1'b1; // Send Stop to slave
                end
                else
                    state <= master_ack;
            end
            
            // ACK 2 state
            ack_2 : begin
                sda_en <= 1'b0; // Recieve ACK from Slave
                case(pulse)
                    0 : begin scl_t <= 1'b0; sda_t <= 1'b0; end
                    1 : begin scl_t <= 1'b0; sda_t <= 1'b0; end
                    2 : begin scl_t <= 1'b1; sda_t <= 1'b0; r_ack <= m.sda; end
                    3 : begin scl_t <= 1'b1; end
                endcase
                
                if (count1 == clk_count1 * 4 - 1) begin
                    sda_t <= 1'b0;
                    sda_en <= 1'b1; // Send stop to Slave
                    if(r_ack == 1'b0) begin
                        state <= stop;
                        m.ack_err <= 1'b0;
                    end
                    else begin
                        state <= stop;
                        m.ack_err <= 1'b1;
                    end
                end
                else
                    state <= ack_2;
                
            end
            
            // Stop state
            stop : begin
                sda_en <= 1'b1; // Send stop to Slave
                case(pulse)
                    0 : begin scl_t <= 1'b1; sda_t <= 1'b0; end
                    1 : begin scl_t <= 1'b1; sda_t <= 1'b0; end
                    2 : begin scl_t <= 1'b1; sda_t <= 1'b1; end
                    3 : begin scl_t <= 1'b1; sda_t <= 1'b1; end
                    
                endcase
                
                if (count1 == clk_count1 * 4 - 1) begin
                    state <= idle;
                    scl_t <= 1'b0;
                    m.busy <= 1'b0;
                    sda_en <= 1'b1; // Send start to Slave
                    m.done <= 1'b1;
                    $display("[MST] done ack_err=%0d dout=%0d rx=%0d", m.ack_err, m.dout, rx_data);
                end
                else
                    state <= stop;
                
                m.dout <= rx_data;
            end
            
            // Others state
            default : state <= idle;
            
        endcase
    end
    end
    
    // en = 1 -> Write to Slave else Read
    // if sda_en == 1 then if sda_t == 0 pull line low, else release so that pull up make line high
    assign m.sda = (sda_en && !sda_t) ? 1'b0 : 1'bz;
    assign m.scl = scl_t; // Connect interface Serial Clock to Master's one
    
endmodule
///////////////////////////
// Slave
module I2C_slave(i2c_if.slave s);
    typedef enum logic [3:0] {idle = 0, read_addr = 1, send_ack1 = 2, send_data = 3, master_ack = 4, read_data = 5, send_ack2 = 6, wait_p = 7, detect_stop = 8} state_type;
    state_type state = idle;
    
    reg [7:0] mem [128]; // 128 array of 8-bit data
    reg [7:0] r_addr; // 8-bit
    reg [6:0] addr; // 7-bit address data
    reg r_mem = 0, w_mem = 0; 
    reg [7:0] din, dout; // 8-bit data input, data output
    reg sda_t, sda_en; // internal Serial Data, Serial Data enable
    reg [3:0] bit_cnt = 0; // 4-bit bit counter
    reg done = 1'b0; // Internal 'done' flag to signal when work completed
    reg ack_err = 1'b0; // Internal 'ack_err' flag to signal when ACK hasn't occured
    
    // Initialize mem
    always @(posedge s.clk) begin
        if(s.rst) begin
            for(int i = 0; i < 128; i++) begin
                mem[i] = i;
            end
            dout <= 8'h0;
        end
        else if (r_mem)
            dout <= mem[addr];
        else if (w_mem)
            mem[addr] <= din;
    end
    
    // pulse_gen logic
    parameter sys_freq = 40_000_000; // 40 MHz
    parameter i2c_freq = 100_000; // 100 KHz
    
    parameter clk_count4 = (sys_freq / i2c_freq);
    parameter clk_count1 = clk_count4 / 4;
    
    integer count1 = 0;
    reg i2c_clk = 0;
    
    // 4x Clock signal Generation
    reg [1:0] pulse = 0;
    reg busy = 0;
    always @(posedge s.clk) begin
        if (s.rst) begin
            pulse <= 0;
            count1 <= 0;
        end
        else if (busy == 1'b0) begin // 'pulse' count start only after 'newd'
            pulse <= 0;
            count1 <= 0;
        end
        else if (count1 == clk_count1 - 1) begin
            pulse <= 1;
            count1 <= count1 + 1;
        end
        else if (count1 == clk_count1 * 2 -1) begin
            pulse <= 2;
            count1 <= count1 + 1;
        end
        else if (count1 == clk_count1 * 3 - 1) begin
            pulse <= 3;
            count1 <= count1 + 1;
        end
        else if (count1 == clk_count1 * 4 - 1) begin
            pulse <= 0;
            count1 <= 0;
        end
        else
            count1 <= count1 + 1;
    end
    
    
    // ?
    reg scl_t;
    wire start;
    always @(posedge s.clk) begin
        scl_t <= s.scl;
    end
    
    assign start = ~s.scl & scl_t;
    
    reg r_ack;
    
    always @(posedge s.clk) begin
        if (s.rst) begin
            bit_cnt <= 0;
            state <= idle;
            r_addr <= 7'b0000000;
            sda_en <= 1'b0;
            sda_t <= 1'b0;
            // addr <= 0;
            r_mem <= 0;
            // din <= 8'h00;
            // ack_err <= 0;
            // done <= 1'b0;
            busy <= 1'b0;
        end
        else begin
            case(state)
                // Idle state
                idle : begin
                    if (s.scl == 1'b1 && s.sda == 1'b0) begin
                        busy <= 1'b1;
                        state <= wait_p;
                    end
                    else
                        state <= idle;
                end
                
                // Wait P state
                wait_p : begin
                    if(pulse == 2'b11 && count1 == 399)
                        state <= read_addr;
                    else
                        state <= wait_p;
                end
                
                // Read Address state
                read_addr: begin
                    sda_en <= 1'b0; // Read address to Slave
                    if (bit_cnt <= 7) begin
                        case(pulse)
                            0 : begin end
                            1 : begin end
                            2 : begin r_addr <= {r_addr[6:0], s.sda}; end
                            3 : begin end
                        endcase
                        if(count1 == clk_count1 * 4 - 1) begin
                            state <= read_addr;
                            bit_cnt <= bit_cnt + 1;
                        end
                        else
                            state <= read_addr;
                    end
                    else begin
                        state <= send_ack1;
                        bit_cnt <= 0;
                        sda_en <= 1'b1;
                        addr <= r_addr[7:1];
                    end
                end
                
                // Send ACK 1 state
                send_ack1 : begin
                    case(pulse)
                        0 : begin sda_t <= 1'b0; end
                        1 : begin end
                        2 : begin end
                        3 : begin end
                    endcase
                    
                    if (count1 == clk_count1 * 4 - 1) begin
                        if(r_addr[0] == 1'b1) begin // Read
                            state <= send_data;
                            r_mem <= 1'b1;
                        end
                        else begin
                            state <= read_data;
                            r_mem <= 1'b0;
                        end
                    end
                    else
                        state <= send_ack1;
                end
                
                // Read Data state
                read_data : begin
                    sda_en <= 1'b0; // Read address to Slave
                    if (bit_cnt <= 7) begin
                        case (pulse)
                            0 : begin end
                            1 : begin end
                            2 : begin din <= (count1 == clk_count1 * 2) ? {din[6:0], s.sda} : din; end
                            3 : begin end
                        endcase
                        
                        if (count1 == clk_count1 * 4 - 1) begin
                            state <= read_data;
                            bit_cnt <= bit_cnt + 1;
                        end
                        else
                            state <= read_data;
                    end
                    else begin
                        state = send_ack2;
                        bit_cnt <= 0;
                        sda_en <= 1'b1;
                        w_mem <= 1'b1;
                    end
                end
                
                // Send ACK 2 state
                send_ack2 : begin
                    case(pulse)
                        0 : begin sda_t <= 1'b0; end
                        1 : begin w_mem <= 1'b0; end
                        2 : begin end
                        3 : begin end
                    endcase
                    if (count1 == clk_count1 * 4 - 1) begin
                        state <= detect_stop;
                        sda_en <= 1'b0;
                    end
                    else
                        state <= send_ack2;
                end
                
                // Send Data state
                send_data : begin
                    sda_en <= 1'b1; // Read address to Slave
                    if (bit_cnt <= 7) begin
                        r_mem <= 1'b0;
                        case(pulse)
                            0 : begin end
                            1 : begin sda_t <= (count1 == clk_count1) ? dout[7 - bit_cnt] : sda_t; end
                            2 : begin end
                            3 : begin end
                        endcase
                        
                        if(count1 == clk_count1 * 4 - 1) begin
                            state <= send_data;
                            bit_cnt <= bit_cnt + 1;
                        end
                        else
                            state <= send_data;
                    end
                    else begin
                        state <= master_ack;
                        bit_cnt  <= 0;
                        sda_en <= 1'b0;
                    end
                end
                
                // Master ACK state
                master_ack : begin
                    case(pulse)
                        0 : begin end
                        1 : begin end
                        2 : begin r_ack <= (count1 == 200) ? s.sda : r_ack; end
                        3 : begin end
                    endcase
                    
                    if (count1 == clk_count1 * 4 - 1) begin
                        if (r_ack == 1'b1) begin // NACK
                            ack_err <= 1'b0;
                            state <= detect_stop;
                            sda_en <= 1'b0;
                        end
                        else begin
                            ack_err <= 1'b1;
                            state <= detect_stop;
                            sda_en <= 1'b0;
                        end
                    end
                    else
                        state <= master_ack;
                end
                
                // Detect Stop state
                detect_stop : begin
                    if(pulse == 2'b11 && count1 == 399) begin
                        state <= idle;
                        busy <= 1'b0;
                        done <= 1'b1;
                        $display("[SLV] r_addr=%0h addr=%0d dout=%0d din=%0d", r_addr, addr, dout, din);
                    end
                    else
                        state <= detect_stop;
                end
                
                // Others stae
                default : state <= idle;
                    
                
            endcase
        end
    end
    
    assign s.sda = (sda_en && !sda_t) ? 1'b0 : 1'bz;
endmodule
///////////////////////////
module top(i2c_if vif);
    I2C_master mstr (vif.master); // Connect Master to Interface
    I2C_slave slv (vif.slave); // Connect Slave to Interface
    
endmodule
///////////////////////////
interface i2c_if();
    logic clk; // Clock signal
    logic rst; // Reset signal
    logic newd; // Flag to signal new data transfer
    logic op; // Read/Write operation
    logic [7:0] din; // 8-bit Data Input
    logic [6:0] addr; // 7-bit Slave address?
    logic [7:0] dout; // 8-bit Data Output
    logic done; // Flag to signal data transfer is done
    logic busy; // Flag to signal when bus(sda, scl) should freeze
    logic ack_err; // Flag to signal when ACK didn't happen
    tri1 sda; // Serial Data
    logic scl; // Serial Clock
    
    // I2C Master and Slave modports
    modport master(input clk, rst, newd, addr, op, din, output scl, dout, busy, ack_err, done, inout sda);
    modport slave(input scl, clk, rst, inout sda);
endinterface


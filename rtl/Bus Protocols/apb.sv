`timescale 1ns / 1ps

////////////////////////////

module top(apb_if.dut vif);
    localparam [1:0] idle = 0, write = 1, read = 2;
    reg [7:0] mem[16]; // 16-size array of 8-bit data
    
    reg[1:0] state, n_state;
    
    bit addr_err, addv_err, data_err;
    
    // Reset decoder
    always @(posedge vif.p_clk, negedge vif.p_reset_n) begin
        if (vif.p_reset_n == 1'b0)
            state <= idle;
        else
            state <= n_state;
    end
    
    // Next state, output decoder
    always @(*) begin
        case(state)
        
            // Idle state
            idle : begin
                vif.p_r_data = 8'h00;
                vif.p_ready = 1'b0;
                
                if (vif.p_sel && vif.p_write)
                    n_state = write;
                else if (vif.p_sel && !vif.p_write)
                    n_state = read;
                else
                    n_state = idle;
            end
            
            // Write state
            write : begin
                if (vif.p_sel && vif.p_enable) begin
                    if(!addr_err && !addv_err && !data_err) begin
                        vif.p_ready = 1'b1;
                        mem[vif.p_addr] = vif.p_w_data;
                        n_state = idle;
                    end
                    else begin
                        vif.p_ready = 1'b1;
                        n_state = idle;
                    end
                end
            end
            
            // Read state
            read : begin
                if (vif.p_sel && vif.p_enable) begin
                    vif.p_ready = 1'b1;
                    vif.p_r_data = mem[vif.p_addr];
                    n_state = idle;
                end
                else begin
                    vif.p_ready = 1'b1;
                    vif.p_r_data = 8'h00;
                    n_state = idle;
                end
            end
            
            // Others state
            default : begin
                n_state = idle;
                vif.p_r_data = 8'h00;
                vif.p_ready = 1'b0;
            end
        endcase
    end
    
    // Check valid values of address
    reg av_t = 0;
    always @(*) begin
        if (vif.p_addr >= 0)
            av_t = 1'b0;
        else
            av_t = 1'b1;
    end
    
    // Check valid values of write data
    reg dv_t = 0;
    always @(*) begin
        if (vif.p_w_data >= 0)
            dv_t = 1'b0;
        else
            dv_t = 1'b1;
    end
    
    // Assigns
    assign addr_err = ((n_state == write || read) && (vif.p_addr > 15)) ? 1'b1 : 1'b0;
    assign addv_err = (n_state == write || read) ? av_t : 1'b0;
    assign data_err = (n_state == write || read) ? dv_t : 1'b0;
    
    assign p_slv_err = (vif.p_sel && vif.p_enable) ? (addv_err || addr_err || data_err) : 1'b0;

endmodule


////////////////////////////

interface apb_if;
    logic p_clk; // Clock signal
    logic p_reset_n; // Active-low reset
    logic [31:0] p_addr; // 32-bit Address
    logic p_sel;// Selects each slave
    logic p_enable; // Access phase is active
    logic [7:0] p_w_data; // 8-bit Write data
    logic p_write; // Operation select [1-Write, 0-Read]
    logic [7:0] p_r_data; // 8-bit Read data
    logic p_ready; // Slave ready(1-finish this cycle)
    logic p_slv_err; // Optional error
    
    modport dut (input p_clk, p_reset_n, p_addr, p_sel, p_enable, p_w_data, p_write, output p_r_data, p_ready, p_slv_err);
endinterface

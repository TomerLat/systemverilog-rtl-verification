`timescale 1ns / 1ps

/////////////////
module top(axi_if.dut vif);

    localparam idle = 0, send_w_addr_ack = 1, send_r_addr_ack = 2, send_w_data_ack = 3, update_mem = 4,
                send_wr_err = 5, send_wr_resp = 6, gen_data = 7, send_rd_err = 8, send_data = 9;
                
                reg [3:0] state = idle; // FSM
                reg [3:0] next_state = idle;
                reg [1:0] count = 0; // 2-bit counter
                reg [32:0] w_addr, r_addr, w_data, r_data; // 32-bit Write address, Read address, Write data, Read data
                reg [31:0] mem [128]; // 128-size to stor 32-bit of data
                
                always @(posedge vif.clk) begin
                    if (!vif.reset_n) begin
                        state <= idle;
                        for(int i = 0; i < 128; i++)
                            mem[i] <= 0;
                        vif.aw_ready <= 0;
                        vif.w_ready <= 0;
                        vif.b_valid <= 0;
                        vif.b_resp <= 0;
                        vif.ar_ready <= 0;
                        vif.r_valid <= 0;
                        vif.r_data <= 0;
                        vif.r_resp <= 0;
                        w_addr <= 0;
                        r_addr <= 0;
                        w_data <= 0;
                        r_data <= 0;
                    end
                    else begin
                        case(state)
                            // Idle case
                            idle : begin
                                vif.aw_ready <= 0;
                                vif.w_ready <= 0;
                                vif.b_valid <= 0;
                                vif.b_resp <= 0;
                                vif.ar_ready <= 0;
                                vif.r_valid <= 0;
                                vif.r_data <= 0;
                                vif.r_resp <= 0;
                                w_addr <= 0;
                                r_addr <= 0;
                                w_data <= 0;
                                r_data <= 0;
                                count <= 0;
                                
                                if (vif.aw_valid) begin
                                    state <= send_w_addr_ack;
                                    w_addr <= vif.aw_addr;
                                    vif.aw_ready <= 1'b1;
                                end
                                else if (vif.ar_valid) begin
                                    state <= send_r_addr_ack;
                                    r_addr <= vif.ar_addr;
                                    vif.ar_ready <= 1'b1;
                                end
                                else
                                    state <= idle;
                            end
                            
                            // Send Write Address ACK state
                            send_w_addr_ack : begin
                                vif.aw_ready <= 1'b0;
                                if(vif.w_valid) begin
                                    w_data <= vif.w_data;
                                    vif.w_ready <= 1'b1;
                                    state <= send_w_data_ack;
                                end
                                else
                                    state <= send_w_addr_ack;
                            end
                            
                            // Send Write Data ACK state
                            send_w_data_ack : begin
                                vif.w_ready <= 1'b0;
                                if (w_addr < 128) begin
                                    state <= update_mem;
                                    mem[w_addr] <= w_data;
                                end
                                else begin
                                    state <= send_wr_err;
                                    vif.b_resp <= 2'b1;; // Write error response
                                    vif.b_valid <= 1'b1;
                                end
                            end
                            
                            // Update Memory state
                            update_mem : begin
                                mem[w_addr] <= w_data;
                                state <= send_wr_resp;
                            end
                            
                            // Send Write Response state
                            send_wr_resp : begin
                                vif.b_resp <= 2'b00;
                                vif.b_valid <= 1'b1;
                                if(vif.b_ready)
                                    state <= idle;
                                else
                                    state <= send_wr_resp;
                            end
                            
                            // Send Write Error state
                            send_wr_err : begin
                                if(vif.b_ready)
                                    state <= idle;
                                else
                                    state <= send_wr_err;
                            end
                            
                            // Read Address ACK state
                            send_r_addr_ack : begin
                                vif.ar_ready = 1'b0;
                                if(r_addr < 128)
                                    state <= gen_data;
                                else begin
                                    vif.r_valid <= 1'b1;
                                    state <= send_rd_err;
                                    vif.r_data <= 0;
                                    vif.r_resp <= 2'b11;
                                end
                            end
                            
                            // Gen Data state
                            gen_data : begin
                                if(count < 2) begin
                                    r_data <= mem[r_addr];
                                    state <= gen_data;
                                    count <= count + 1;
                                end
                                else begin
                                    vif.r_valid <= 1'b1;
                                    vif.r_data <= r_data;
                                    vif.r_resp <= 2'b00;
                                    if(vif.r_ready)
                                        state <= idle;
                                    else
                                        state <= gen_data;
                                end
                            end
                            
                            // Send Read Error state
                            send_rd_err : begin
                                if(vif.r_ready)
                                    state <= idle;
                                else
                                    state <= send_rd_err;
                            end
                            
                            // Others state
                            default : state <= idle;
                        endcase
                    end
                end
endmodule

/////////////////

interface axi_if;
    logic clk, reset_n; // Clock signal, reset active-low
    logic aw_valid, aw_ready; // Write Address (Ready, Valid)
    logic w_valid, w_ready; // Write Data (Ready, Valid)
    logic b_valid, b_ready; // Write Response (Ready, Valid)
    logic ar_ready, ar_valid; // Read Address (Ready, Valid)
    logic r_ready, r_valid; // Read Data (Ready, Valid)
    logic [31:0] aw_addr, ar_addr, w_data, r_data; // 32-bit Write Adress, Read Adress, Write Data, Read Data
    logic [1:0] b_resp, r_resp; // 2-bit Write response, Read response

    modport dut (input clk, reset_n, aw_valid, aw_addr, w_valid, w_data, b_ready, ar_valid, ar_addr, r_ready, output aw_ready, w_ready, b_valid, b_resp, ar_ready, r_valid, r_data, r_resp);
endinterface

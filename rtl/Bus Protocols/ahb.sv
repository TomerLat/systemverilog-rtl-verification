`timescale 1ns / 1ps

`define NON_SEQ 2'd0
`define SEQ     2'd1
`define BUSY    2'd2
`define IDLE    2'd3

`define OKAY    2'b00
`define ERROR   2'b01
`define RETRY   2'b10
`define SPLIT   2'b11
////////////////////////////

module top(ahb_if.dut vif);
    
    reg [7:0] mem[256] = '{default : 12}; // 256-size of 8-bit stored data, initialize to d'12

    // Single 
    function bit [31:0] signle_tr (input bit [31:0] addr, input bit [2:0] h_size);
        unique case(h_size)
            
            3'b000 : begin
                mem[addr] = vif.h_w_data[7:0];    
            end
            
            3'b001 : begin
                mem[addr] = vif.h_w_data[7:0];
                mem[addr + 1] = vif.h_w_data[15:8];
            end
            
            3'b010 : begin
                mem[addr] = vif.h_w_data[7:0];
                mem[addr + 1] = vif.h_w_data[15:8]; 
                mem[addr + 2] = vif.h_w_data[23:16]; 
                mem[addr + 3] = vif.h_w_data[31:24];  
            end
        endcase
        
        return addr;
    endfunction
    
    // Unicr wr
    function bit[31:0] unincr_wr (input bit[31:0] addr, input bit[2:0] h_size);
        bit [31:0] r_addr;
        unique case(h_size)
            3'b000 : begin
                mem[addr] = vif.h_w_data[7:0];
                r_addr = addr + 1;    
            end
            
            3'b001 : begin
                mem[addr] = vif.h_w_data[7:0];
                mem[addr + 1] = vif.h_w_data[15:8];
                r_addr = addr + 2;
            end
            
            3'b010 : begin
                mem[addr] = vif.h_w_data[7:0];
                mem[addr + 1] = vif.h_w_data[15:8]; 
                mem[addr + 2] = vif.h_w_data[23:16]; 
                mem[addr + 3] = vif.h_w_data[31:24];
                r_addr = addr + 2;
            end
        
        endcase
        
        return r_addr;
    endfunction
    
    // Boundary
    function bit [7:0] boundary(input bit [2:0] h_burst, input [2:0] h_size);
        bit [7:0] temp;
        
        unique case(h_size)
            3'b000 : begin
                unique case (h_burst)
                    3'b010 : temp = 4 * 1;
                    3'b100 : temp = 8 * 1;
                    3'b110 : temp = 16 * 1;
                endcase
            end
            
            3'b001 : begin
                unique case (h_burst)
                    3'b010 : temp = 4 * 2;
                    3'b100 : temp = 8 * 2;
                    3'b110 : temp = 16 * 2;
                endcase
            end
            
            3'b010 : begin
                unique case (h_burst)
                    3'b010 : temp = 4 * 3;
                    3'b100 : temp = 8 * 3;
                    3'b110 : temp = 16 * 3;
                endcase
            end
        endcase
            
        return temp;
    
    endfunction
    
    // Wrap Write
    function bit[31:0] wrap_wr (input bit[31:0] addr, input bit[7:0] boundary, input [2:0] h_size);
        bit [31:0] addr1, addr2, addr3, addr4;
        
        unique case(h_size)
            3'b000 : begin
                mem[addr] = vif.h_w_data[7:0];
                if((addr + 1) % boundary == 0)
                    addr1 = (addr + 1) - boundary;
                else
                    addr1 = (addr + 1);
                return addr1;
            end
            
            3'b001 : begin
                mem[addr] = vif.h_w_data[7:0];
                if((addr + 1) % boundary == 0)
                    addr1 = (addr + 1) - boundary;
                else
                    addr1 = (addr + 1);
                    
                mem[addr1] = vif.h_w_data[15:8];
                if((addr1 + 1) % boundary == 0)
                    addr2 = (addr1 + 1) - boundary;
                else
                    addr2 = (addr1 + 1);
                    
                return addr2;
            end
            
            3'b010 : begin
                mem[addr] = vif.h_w_data[7:0];
                if((addr + 1) % boundary == 0)
                    addr1 = (addr + 1) - boundary;
                else
                    addr1 = (addr + 1);
                    
                mem[addr1] = vif.h_w_data[15:8];
                if((addr1 + 1) % boundary == 0)
                    addr2 = (addr1 + 1) - boundary;
                else
                    addr2 = (addr1 + 1);
                    
                    
                mem[addr2] = vif.h_w_data[23:16];
                if((addr2 + 1) % boundary == 0)
                    addr3 = (addr2 + 1) - boundary;
                else
                    addr3 = (addr2 + 1);  
                
                mem[addr3] = vif.h_w_data[31:24];
                if((addr3 + 1) % boundary == 0)
                    addr4 = (addr3 + 1) - boundary;
                else
                    addr4 = (addr3 + 1);
                    
                return addr4;
            end
        endcase
    endfunction
    
    // Incr Write
    function bit[31:0] incr_wr(input bit[31:0] addr, input bit[2:0] h_size);
        bit [31:0] r_addr;
        
        unique case(h_size)
            3'b000 : begin
                mem [addr] = vif.h_w_data[7:0];
                r_addr = addr + 1;
            end
            
            3'b001 : begin
                mem[addr] = vif.h_w_data;
                mem[addr + 1] = vif.h_w_data[15:8];
                r_addr = addr + 2;
            end
            
            3'b010 : begin
                mem[addr] = vif.h_w_data;
                mem[addr + 1] = vif.h_w_data[15:8];
                mem[addr + 2] = vif.h_w_data[23:16];
                mem[addr + 3] = vif.h_w_data[31:24];
                r_addr = addr + 4;
            end
        endcase
        
        return r_addr;
    endfunction
    
    // Single transfer read
    function bit[31:0] single_tr_rd(input bit[31:0] addr, input bit [2:0] h_size);
        unique case(h_size)
            3'b000 : begin
                vif.h_r_data[7:0] = mem[addr];
            end
        
            3'b001 : begin
                vif.h_r_data[7:0] = mem[addr];
                vif.h_r_data[15:8] = mem[addr + 1];
            end
        
            3'b010 : begin
                vif.h_r_data[7:0] = mem[addr];
                vif.h_r_data[15:8] = mem[addr + 1];
                vif.h_r_data[23:16] = mem[addr + 2];
                vif.h_r_data[31:24] = mem[addr + 3];
            end
        
        endcase
        
        return addr;
    endfunction
    
    // Read for unspec length
    function bit[31:0] unincr_rd(input bit [31:0] addr, input bit[2:0] h_size);
        bit [31:0] r_addr;
        unique case(h_size)
            3'b000 : begin
                vif.h_r_data[7:0] = mem[addr];
                r_addr = addr + 1;
            end
            
            3'b001 : begin
                vif.h_r_data[7:0] = mem[addr];
                vif.h_r_data[15:8] = mem[addr + 1];
                r_addr = addr + 2;
            end
            
            3'b010 : begin
                vif.h_r_data[7:0] = mem[addr];
                vif.h_r_data[15:8] = mem[addr + 1];
                vif.h_r_data[23:16] = mem[addr + 2];
                vif.h_r_data[31:24] = mem[addr + 3];
                r_addr = addr + 2;
            end
        endcase
        
        return r_addr;
    endfunction
    
    // Wrapping read
    function bit [31:0] wrap_rd (input bit[31:0] addr, input bit [7:0] boundary, input [2:0] h_size);
        
        bit [31:0] addr1, addr2, addr3, addr4;
        
        unique case (h_size)
            
            3'b000 : begin
             
             vif.h_r_data[7:0] = mem[addr];
             if((addr + 1) % boundary == 0)
                addr1 = (addr + 1) - boundary;
             else
                addr1 = (addr + 1); 
                
             return addr1;
            end
            
            3'b001 : begin
                
                vif.h_r_data[7:0] = mem[addr];
                if((addr + 1) % boundary == 0)
                    addr1 = (addr + 1) - boundary;
                else
                    addr1 = (addr + 1);

                vif.h_r_data[15:8] = mem[addr1];
                if((addr1 + 1) % boundary == 0)
                    addr2 = (addr1 + 1) - boundary;
                else
                    addr2 = (addr1 + 1);
                
                return addr2;
            end
            
            3'b010 : begin
                vif.h_r_data[7:0] = mem[addr];
                if((addr + 1) % boundary == 0)
                    addr1 = (addr + 1) - boundary;
                else
                    addr1 = (addr + 1);

                vif.h_r_data[15:8] = mem[addr1];
                if((addr1 + 1) % boundary == 0)
                    addr2 = (addr1 + 1) - boundary;
                else
                    addr2 = (addr1 + 1);
                
                vif.h_r_data[23:16] = mem[addr2];
                if((addr2 + 1) % boundary == 0)
                    addr3 = (addr2 + 1) - boundary;
                else
                    addr3 = (addr2 + 1);
                
                vif.h_r_data[31:24] = mem[addr3];
                if((addr3 + 1) % boundary == 0)
                    addr4 = (addr3 + 1) - boundary;
                else
                    addr4 = (addr3 + 1);
                
                return addr4;
            end
        endcase
        
    endfunction
    
    // Incr Read
    function bit[31:0] incr_rd(input bit [31:0] addr, input bit [2:0] h_size);
    
        bit [31:0] r_addr;
    
        unique case(h_size)
    
            3'b000: begin
                vif.h_r_data[7:0]  = mem[addr];
                r_addr        = addr + 1; 
            end
     
            3'b001: begin
                vif.h_r_data[7:0]  = mem[addr];
                vif.h_r_data[15:8] = mem[addr + 1];
                r_addr         = addr + 2;
            end
 
            3'b010: begin
                vif.h_r_data[7:0]   = mem[addr];
                vif.h_r_data[15:8]  = mem[addr + 1];
                vif.h_r_data[23:16] = mem[addr + 2];
                vif.h_r_data[31:24] = mem[addr + 3];
                r_addr         = addr + 4;
            end
        endcase
 
        return r_addr;
 
    endfunction


    // Create FSM
    typedef enum {idle = 0, check_mode = 1, write = 2, read = 3, addr_decode = 4} state_type;
    state_type state, next_state;

    // Reset check
    always_ff @(posedge vif.clk) begin
        if(!vif.h_reset_n)
            state <= idle;
        else
            state <= next_state;
    end
    
    //
    integer len_count = 0;
    reg first = 0;
    reg [31:0] ret_addr, next_addr;
    reg[7:0] w_boundary;
    
    // FSM
    always_comb begin
        
        case(state)
            // Idle state
            idle : begin
                next_state = check_mode;
                vif.h_ready = 1'b0;
                len_count = 0;
                first = 0;
                vif.h_resp = `OKAY;
            end
        
            // Check Mode state 
            check_mode : begin
                vif.h_ready = 1'b0;
                if(vif.h_reset_n && vif.h_sel && vif.h_write) begin
                    if(vif.h_addr < 256) 
                        next_state = addr_decode;  
                    else begin 
                        next_state = idle;
                        vif.h_resp = `ERROR;
                    end
                end
                else if (vif.h_reset_n && vif.h_sel && !vif.h_write) begin
                    if(vif.h_addr < 256)    
                        next_state = addr_decode;
                    else begin
                        next_state = idle;
                        vif.h_resp = `ERROR; 
                    end
                end
                else
                    next_state = idle;
                                                            
            end
  
            // Address Decode
            addr_decode: begin
                if(vif.h_trans == `NON_SEQ) begin
                    next_addr = vif.h_addr;
                    if(vif.h_write)
                        next_state = write;
                    else
                        next_state = read;          
                end 
                else if (vif.h_trans == `SEQ) begin
                    next_addr  = ret_addr;                           
                    if(vif.h_write)
                        next_state = write;
                    else
                        next_state = read;
                end
            end
  
            // Write state
            write: begin
                case(vif.h_burst)
  
                    // Single Write at h_addr
                    3'b000: begin  ////single transfer
                        ret_addr = single_tr_rd(next_addr, vif.h_size);
                        vif.h_ready     = 1'b1;
                        next_state = idle;
                        vif.h_resp = `OKAY;
                    end
                    // Increment for Unpecifies length            
                    3'b001: begin   ////incr mode
                        vif.h_ready = 1'b1;
                        ret_addr = unincr_wr(next_addr, vif.h_size);
                        vif.h_resp = `OKAY;         
                       
                        if(len_count < 32) begin
                            len_count = len_count + 1;
                            next_state = check_mode; 
                        end
                        else begin
                            len_count = 0;
                            next_state = idle;
                        end                               
                    end
 
                    // 4 beat wrapping
                    3'b010 : begin
                        vif.h_ready = 1'b1; 
                        w_boundary = boundary(vif.h_burst, vif.h_size);
                        ret_addr   = wrap_wr(next_addr, w_boundary, vif.h_size);
                        vif.h_resp = `OKAY;
                                       
                        if(len_count <= 2) begin // 0 1 2 3
                            len_count = len_count + 1;
                            next_state = check_mode;
                        end
                        else begin
                        next_state = idle;
                        len_count = 0;
                        end
                    end 
        
                    //4 beat incrementing
                    3'b011: begin    
                        vif.h_ready = 1'b1;
                        ret_addr = incr_wr(next_addr, vif.h_size);
                        vif.h_resp = `OKAY;
                                   
                        if(len_count <= 2) begin
                            len_count = len_count + 1;
                            next_state = check_mode;
                        end
                        else begin
                            next_state = idle;
                            len_count = 0;
                            first = 0; 
                        end       
                    end    
                               
                    //8 beat wrapping
                    3'b100 : begin                  
                        vif.h_ready = 1'b1; 
                        w_boundary = boundary(vif.h_burst, vif.h_size);
                        ret_addr = wrap_wr(next_addr, w_boundary, vif.h_size);
                        vif.h_resp = `OKAY;
                                           
                        if(len_count <= 6) begin
                            len_count = len_count + 1;
                            next_state = check_mode;
                        end
                        else begin
                            next_state = idle;
                            len_count = 0;
                        end
                    end
                                       
                    //8 beat Incrementing
                    3'b101 : begin
                        vif.h_ready = 1'b1;
                        ret_addr = incr_wr(next_addr, vif.h_size);
                        vif.h_resp = `OKAY;
                                   
                        if(len_count <= 6) begin
                            len_count = len_count + 1;
                            next_state = check_mode;
                        end
                        else begin
                            next_state = idle;
                            len_count = 0;
                        end
                    end  
 
                    //16 beat wrapping
                    3'b110 : begin     
                        vif.h_ready = 1'b1; 
                        w_boundary = boundary(vif.h_burst, vif.h_size);
                        ret_addr = wrap_wr(next_addr, w_boundary, vif.h_size);
                        vif.h_resp = `OKAY;
                               
                        if(len_count <= 14) begin
                            len_count = len_count + 1;
                            next_state = check_mode;
                        end
                        else begin
                            next_state = idle;
                            len_count = 0;
                        end
                    end
 
                    //16 beat incr
                    3'b111 : begin
                        vif.h_ready = 1'b1;
                        ret_addr = incr_wr(next_addr, vif.h_size);
                        vif.h_resp = `OKAY;
                                   
                        if(len_count <= 14) begin
                            len_count = len_count + 1;
                            next_state = check_mode;
                        end
                        else begin
                            next_state = idle;
                            len_count = 0;
                        end
                    end 
                endcase
            end // Write Case end

            // Read Case
            read : begin
            
                case(vif.h_burst)
  
                    //Single Write at HADDR
                    3'b000 : begin  ////single transfer
                        ret_addr = single_tr_rd(vif.h_addr,vif.h_size);
                        vif.h_ready     = 1'b1;
                        next_state = idle;
                        vif.h_resp = `OKAY;
                    end
            
                    // Increment for unspecified length                   
                    3'b001 : begin   ////incr mode
                        vif.h_ready = 1'b1;
                        ret_addr = unincr_rd(next_addr, vif.h_size);
                        vif.h_resp = `OKAY;
        
                        if(len_count < 32) begin
                            len_count = len_count + 1;
                            next_state = check_mode;
                        end
                        else begin
                            len_count = 0;  
                            next_state = idle;
                        end                            
                    end  
            
                    //4 beat wrapping
                    3'b010 : begin      
                        vif.h_ready = 1'b1; 
                        w_boundary = boundary(vif.h_burst, vif.h_size);
                        ret_addr = wrap_rd(next_addr, w_boundary, vif.h_size);
                        vif.h_resp = `OKAY;
                          
                        if(len_count <= 2) begin
                            len_count = len_count + 1;
                            next_state = check_mode;
                        end
                        else begin
                            next_state = idle;
                            len_count = 0;
                        end             
                    end 
        
                    //4 beat incrementing read
                    3'b011 : begin
                        vif.h_ready = 1'b1;
                        ret_addr = incr_rd(next_addr, vif.h_size);
                        vif.h_resp = `OKAY;
                                   
                        if(len_count <= 2) begin
                            len_count = len_count + 1;
                            next_state = check_mode;
                        end
                        else begin
                            next_state = idle;
                            len_count = 0;
                        end 
                    end    
                               
                    //8 beat wrapping
                    3'b100 : begin     
                        vif.h_ready = 1'b1; 
                        w_boundary = boundary(vif.h_burst, vif.h_size);
                        ret_addr = wrap_rd(next_addr, w_boundary, vif.h_size);
                        vif.h_resp = `OKAY;
                                           
                        if(len_count <= 6) begin
                            len_count = len_count + 1;
                            next_state = check_mode;
                        end
                        else begin
                            next_state = idle;
                            len_count = 0;
                        end                     
                    end
                                       
                    //8 beat Incrementing
                    3'b101 : begin
                        vif.h_ready = 1'b1;
                        ret_addr = incr_rd(next_addr, vif.h_size);
                        vif.h_resp = `OKAY;
                                   
                        if(len_count <= 6) begin
                            len_count = len_count + 1;
                            next_state = check_mode;
                        end
                        else begin
                            next_state = idle;
                            len_count = 0;
                        end    
                    end  
 
                    //16 beat wrapping
                    3'b110 : begin
                        vif.h_ready = 1'b1; 
                        w_boundary = boundary(vif.h_burst, vif.h_size);
                        ret_addr = wrap_rd(next_addr, w_boundary, vif.h_size);
                        vif.h_resp = `OKAY;
                               
                        if(len_count <= 14) begin
                            len_count = len_count + 1;
                            next_state = check_mode;
                        end
                        else begin
                            next_state = idle;
                            len_count = 0;
                        end
                    end
 
                    //16 beat incr
                    3'b111 : begin
                        vif.h_ready = 1'b1;
                        ret_addr = incr_rd(next_addr, vif.h_size);
                        vif.h_resp = `OKAY;
                                   
                        if(len_count <= 14) begin
                            len_count = len_count + 1;
                            next_state = check_mode;
                        end
                        else begin
                            next_state = idle;
                            len_count = 0;
                        end
                    end // 3'b111 case end
       
                endcase // case(vif.h_burst) end
        
            end // read case end
        
        endcase // 'state' FSM end
 
    end // always_comb end

endmodule

////////////////////////////

interface ahb_if;
    
    logic clk;
    logic [31:0] h_w_data, h_addr, h_r_data, next_addr;
    logic [2:0] h_size,h_burst;
    logic [1:0] h_trans, h_resp;
    logic h_reset_n, h_sel, h_write, h_ready;
    
    modport dut(input clk, h_w_data, h_addr, h_size, h_burst, h_reset_n, h_sel, h_write, h_trans, output h_resp, h_ready, h_r_data);
endinterface

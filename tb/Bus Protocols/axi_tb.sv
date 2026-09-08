`timescale 1ns / 1ps
//////////////////

// Transaction
class transaction;

    randc bit op; // Write - 1, Read - 0
    rand bit [31:0] aw_addr; // 32-bit Write Address
    rand bit [31:0] w_data; // 32-bit Write Data
    rand bit [31:0] ar_addr; // 32-bit Read Address
    bit [31:0] r_data; // 32-bit Read Data
    bit [1:0] w_resp; // 2-bit Write ACK response
    bit [1:0] r_resp; // 2-bit Read ACK response
    
    constraint valid_addr_range {aw_addr == 1; ar_addr == 1;} // Write, Read Address values range
    constraint valid_data_range {w_data < 12; r_data < 12;} // Write, Read Data values range
    
    // Create deep copy of transaction object
    function transaction copy();
        copy = new(); // Create a new transaction object
        copy.op = this.op; // Copy Operation bit [1-Write, 0-Read]
        copy.aw_addr = this.aw_addr; // Copy Write Address
        copy.w_data = this.w_data; // Copy Write Data
        copy.ar_addr = this.ar_addr; // Copy Read Address
        copy.r_data = this.r_data; // Copy Read Data
        copy.w_resp = this.w_resp; // Copy Write ACK response
        copy.r_resp = this.r_resp; // Copy Read ACK response
    endfunction
endclass

//////////////////

// Generator
class generator;

    transaction tr; // Transaction object
    mailbox #(transaction) mbx_gen_drv; // Mailbox for sending transaction to Driver
    event next_sco; // Trigger when Scoreboard finished work
    event done; // Trigger when Generator finished all stiuli requests
    int count = 0; // Counts all stimuli requests
    
    // Initialize Generator instance
    function new(mailbox #(transaction) mbx_gen_drv);
        this.mbx_gen_drv = mbx_gen_drv; // Initialize mailbox for communication with Driver
        tr = new(); // Create new transaction object
    endfunction 
    
    // Generator main
    task run();
        for(int i = 0; i < count; i++) begin
            assert(tr.randomize()) else $error("Randomization Failed!");
            // Display Genrator values
            $display("[GEN] : OP : %0b, WRITE ADDRESS : %0d, WRITE DATA : %0d, READ ADDRESS : %0d", tr.op, tr.aw_addr, tr.w_data, tr.ar_addr);
            mbx_gen_drv.put(tr.copy()); // Sends transaction copy to Driver
            @(next_sco); // Trigger when Scoreboard finished work
        end
        -> done; // Trigger when Generator finished work
    endtask
endclass

//////////////////

// Driver
class driver;
    virtual axi_if vif; // Virtual interface
    transaction tr; // Transaction object
    mailbox #(transaction) mbx_gen_drv; // Mailbox for communication with Generator
    mailbox #(transaction) mbx_drv_mon; // Mailbox for communication with Monitor
    
    // Initialize Driver instance
    function new(mailbox #(transaction) mbx_gen_drv, mailbox #(transaction) mbx_drv_mon);
        this.mbx_gen_drv = mbx_gen_drv; // Initialize mailbox for communication with Generator
        this.mbx_drv_mon = mbx_drv_mon; // Initialize mailbox for communication with Monitor
    endfunction
    
    // Reset Driver
    task reset();
        vif.reset_n <= 1'b0; // Reset active-lo
        vif.aw_valid <= 1'b0;
        vif. aw_addr <= 0;
        vif.w_valid <= 0;
        vif.w_data <= 0;
        vif.b_ready <= 0;
        vif.ar_valid <= 1'b0;
        vif.ar_addr <= 0;
    
        repeat(5) @(posedge vif.clk);
        vif.reset_n <= 1'b1; // Reset inactive-high
    
    $display("---------------[DRV] : RESET DONE----------------");
    endtask
    
    // Write Data
    task write_data(input transaction tr);
        // Display Driver values message
        $display("[DRV] : OP : %0b, WRITE ADDRESS : %0d, WRITE DATA : %0d", tr.op, tr.aw_addr, tr.w_data);
        mbx_drv_mon.put(tr.copy()); // Send transaction copy to Monitor
        vif.reset_n <= 1'b1;
        vif.aw_valid <= 1'b1;
        vif.ar_valid <= 1'b0; // Disable Read
        vif.ar_addr <= 0;
        vif.aw_addr <= tr.aw_addr;
        
        @(negedge vif.aw_ready);
        vif.aw_valid <= 1'b0;
        vif.aw_addr <= 0;
        vif.w_valid <= 1'b1;
        vif.w_data <= tr.w_data;
        
        @(negedge vif.w_ready);
        vif.w_valid <= 1'b0;
        vif.w_data <= 0;
        vif.b_ready <= 1'b1;
        vif.r_ready <= 1'b0;
        
        @(negedge vif.b_valid);
        vif.b_ready <= 1'b0;
        
    endtask
    
    // Read Data
    task read_data(input transaction tr);
        // Display Driver values message
        $display("[DRV] : OP : %0b, READ ADDRESS : %0d", tr.op, tr.ar_addr);
        mbx_drv_mon.put(tr.copy()); // Send transaction copy to Monitor
        vif.reset_n  <= 1'b1;
        vif.aw_valid <= 1'b0;
        vif.aw_addr  <= 0;
        vif.w_valid  <= 1'b0;
        vif.w_data   <= 0;
        vif.b_ready  <= 1'b0;
        vif.ar_valid <= 1'b1;  
        vif.ar_addr  <= tr.ar_addr;
        
        @(negedge vif.ar_ready);
        vif.ar_addr  <= 0;
        vif.ar_valid <= 1'b0;
        vif.r_ready  <= 1'b1;
        
        @(negedge vif.r_valid);
        vif.r_ready  <= 1'b0;
    endtask
    
    // Driver main
    
    task run();
        forever begin
            mbx_gen_drv.get(tr); // Get transaction from Generator through mailbox
            // Write or Read operation
            if(tr.op)
                write_data(tr);
            else
                read_data(tr);
        end
    endtask
endclass

//////////////////

// Monitor
class monitor;
    virtual axi_if vif; // Virtual interface
    transaction tr, tr_d; // Transaction objects
    mailbox #(transaction) mbx_drv_mon; // Mailbox for communication with Driver
    mailbox #(transaction) mbx_mon_sco; // Mailbox for communication with Monitor
    
    // Initialize Monitor instance
    function new(mailbox #(transaction) mbx_drv_mon, mailbox #(transaction) mbx_mon_sco);
        this.mbx_drv_mon = mbx_drv_mon; // Initialize mailbox for communication with Driver
        this.mbx_mon_sco = mbx_mon_sco; // Initialize mailbox for communication with Scoreboard
    endfunction
    
    // Monitor main
    task run();
        tr = new();
        forever begin
            @(posedge vif.clk);
            mbx_drv_mon.get(tr_d); // Get transaction from Driver through mailbox
            // Write Data
            if (tr_d.op) begin
                tr.op = tr_d.op;
                tr.aw_addr = tr_d.aw_addr;
                tr.w_data = tr_d.w_data;
                
                @(posedge vif. b_valid);
                tr.w_resp = vif.b_resp;
                
                @(negedge vif.b_valid);
                // Display Monitor values
                $display("[MON] : OP : %0b, WRITE ADDRESS : %0d, WRITE DATA : %0d, WRITE RESPONSE", tr.op, tr.aw_addr, tr.w_data, tr.w_resp);
                mbx_mon_sco.put(tr.copy()); // Send transaction copy to Scoreboard                
            end
            // Read Data
            else begin
                tr.op = tr_d.op;
                tr.ar_addr = tr_d.ar_addr;
                
                @(posedge vif. r_valid);
                tr.r_data = vif.r_data;
                tr.r_resp = vif.r_resp;
                
                @(negedge vif.r_valid);
                // Display Monitor values
                $display("[MON] : OP : %0b, WRITE ADDRESS : %0d, WRITE DATA : %0d, READ RESPONSE", tr.op, tr.ar_addr, tr.r_data, tr.r_resp);
                mbx_mon_sco.put(tr.copy()); // Send transaction copy to Scoreboard  
            end
        end
    endtask
endclass

//////////////////

// Scoreboard
class scoreboard;
    transaction tr, tr_d; // Transaction objects
    mailbox #(transaction) mbx_mon_sco;
    event next_sco; // Trigger when Scoreboard finished work
    
    bit [31:0] temp; // 32-bit to store data
    bit [31:0] data[128] = '{default:0}; // 128-size array to stor 32-bit data
    
    // Initialize Scoreboard instance
    function new(mailbox #(transaction) mbx_mon_sco);
        this.mbx_mon_sco = mbx_mon_sco; // Initialize mailbox for communication with Monitor
    endfunction
    
    // Scoreboard main
    task run();
        forever begin
        mbx_mon_sco.get(tr); // Get transaction from Monitor through mailbox
    
    
        // Write Data
        if(tr.op) begin
            $display("[SCO] : OP : %0b, WRITE ADDRESS : %0d, WRITE DATA : %0d, WRITE RESPONSE", tr.op, tr.aw_addr, tr.w_data, tr.w_resp);
            if(tr.w_resp == 3)
                $display("[SCO] : DEC ERROR");
            else begin
                data[tr.aw_addr] = tr.w_data;
                $display("[SCO] : DATA STORED ADDRESS : %0d, DATA : %0d", tr.aw_addr, tr.w_data);
            end
        end
    
        else begin
            $display("[SCO] : OP : %0b, READ ADDRESS : %0d, READ DATA : %0d, WRITE RESPONSE", tr.op, tr.ar_addr, tr.r_data, tr.r_resp);
            temp = data[tr.ar_addr];
            if(tr.r_resp == 3)
                $display("[SCO] : DEC ERROR");
            else if (!tr.r_resp &&(tr.r_data == temp))
                $display("[SCO] : DATA MATCHED");
            else 
                $display("[SCO] : DATA MISMATCHED");  
        end
        
        $display("---------------------------------");
        -> next_sco; // Trigger when Scoreboard finished work
        
        end
    endtask
endclass

//////////////////

// Environment
class environment;

    generator gen; // Generator object
    driver drv; // Driver object
    monitor mon; // Monitor object
    scoreboard sco; // Scoreboard object
    
    event next_sco; // Event for Generator-Scoreboard communication
    
    mailbox #(transaction) mbx_gen_drv; // Mailbox for Generator-Driver communication
    mailbox #(transaction) mbx_drv_mon; // Mailbox for Driver-Monitor communication
    mailbox #(transaction) mbx_mon_sco; // Mailbox for Monitor-Scoreboard communication
    
    virtual axi_if vif; // Virtual AXI interface
    
    // Initialize Environment instance
    function new(virtual axi_if vif);
        mbx_gen_drv = new(); // Initialize Generator-Driver mailbox
        mbx_drv_mon = new(); // Initialize Driver-Monitor mailbox
        mbx_mon_sco = new(); // Initialize Monitor-Scoreboard mailbox
        
        gen = new(mbx_gen_drv); // Initialize Generator
        drv = new(mbx_gen_drv, mbx_drv_mon); // Initialize Driver
        mon = new(mbx_drv_mon, mbx_mon_sco); // Initialize Monitor
        sco = new(mbx_mon_sco); // Initialize Scoreboard
        
        this.vif = vif; // Set the virtual interface of DUT
        drv.vif = this.vif; // Connect virtual interface to Driver
        mon.vif = this.vif; // Connect virtual interface to Monitor
              
        // Synchronize Monitor-Scoreboard events
        gen.next_sco = next_sco;
        sco.next_sco = next_sco;
 
    endfunction

    // Pre-Test
    task pre_test();
        drv.reset(); // Perform Driver reset
    endtask
    
    // Test
    task test();
        fork
            gen.run(); // Run Generator
            drv.run(); // Run Driver
            mon.run(); // Run Monitor
            sco.run(); // Run Scoreboard
        join_any
    endtask
    
    // Post-Test
    task post_test();
        wait(gen.done.triggered); // Wait for Generation to finish
        $finish();
    endtask
    
    // Environment main
    task run();
        pre_test();
        test();
        post_test();
    endtask

endclass

//////////////////
module tb();

    axi_if vif(); // Virtual interface instance
    top dut(vif); // DUT interface
    
    // Reset clock signal
    initial begin
        vif.clk <= 1'b0;
    end
    
    // Create 100 MHz clock signal
    always #5 vif.clk <= ~vif.clk;
    
    // Create Environment instance
    environment env;
    
    // Create, Set, Run the Environment instance
    initial begin
        env = new(vif);
        env.gen.count = 10;
        env.run();
    end 
    
    // Drop Simulation
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end
endmodule

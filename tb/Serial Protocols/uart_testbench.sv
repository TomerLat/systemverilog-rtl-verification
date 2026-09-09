`timescale 1ns / 1ps
//////////////////////////////////////
// Transaction
class transaction;
    typedef enum bit {write = 1'b0, read = 1'b1} oper_type; // Create state machine
    
    randc oper_type oper; // Randomize operator
    
    bit rx; // Data bit - Reciever
    
    rand bit [7:0] data_in; // 8-bit data input
    
    bit newd; // New data Flag
    bit tx; // Data bit - Transmitter
    
    bit [7:0] data_out; // 8-bit data output
    bit done_tx; // Flag of Transmitter finished work
    bit done_rx; // Flag of Reciever finished work
    
    // Create deep copy of transaction object
    function transaction copy();
        copy = new(); // Create a new transaction object
        copy.oper = this.oper; // Copy 'oper' input
        copy.rx = this.rx; // Copy Reciever input bit
        copy.data_in = this.data_in; // Copy 8-bit Data input
        copy.newd = this.newd; // Copy 'newd' flaf
        copy.tx = this.tx; // Copy Transmitter output bit
        copy.data_out = this.data_out; // Copy 8-bit Data ouput
        copy.done_tx = this.done_tx; // Copy flag of when Transmitter completed work
        copy.done_rx = this.done_rx; // Copy flag of when Reciever completed work
    endfunction
endclass
//////////////////////////////////////

// Generator
class generator;
    transaction tr; // Transaction object to create and send information
    mailbox #(transaction) mbx; // Mailbox for communication with Driver
    
    event done; // Event to trigger when Generator completed all stimuli requests
    int count = 0; // Number of requested stimuli transactions
    
    event drv_next; // Event to trigger when Driver is ready for next stimuli
    event sco_next; // Event to trigger when Scoreboard is ready for next stimuli
    
    // Initiliaze Generator instance
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx; // Initialize the mailbox for the Driver
        tr = new(); // Create a new transaction object
    endfunction
    
    // Generator main
    task run();
        repeat (count) begin
            assert(tr.randomize()) else $error("[GEN] : RANDOMIZATION FAILED!"); // Try to randomize transaction inputs
            mbx.put(tr.copy); // Sends a copy of transaction object to Driver through mailbox
            $display("[GEN] : OPER : %0d, DATA IN : %0d", tr.oper.name(), tr.data_in);
            @(drv_next); // Wait for Driver to accept transaction
            @(sco_next); // Wait for Scoreboard to accept transaction
            
        end
        
        -> done; // Trigger 'done' when all stimuli requests are satisified
    endtask
    
endclass

//////////////////////////////////////

// Driver
class driver;
    virtual uart_if vif; // Virtual Interface
    transaction tr; // Transaction object to send and get information
    mailbox #(transaction) mbx_gen_drv; // Mailbox to get transaction to Generator
    mailbox #(bit [7:0]) mbx_drv_sco; // Mailbox to send transaction to Scoreboard
    event drv_next; // Event to trigger driver next iteration
    bit [7:0] data_in; // 8-bit data input
    bit w = 0; // Random operation Read / Write
    bit [7:0] data_rx; // Data recieved during Read
    
    // Initialize Driver instance
    function new(mailbox #(transaction) mbx_gen_drv, mailbox #(bit [7:0]) mbx_drv_sco);
        this.mbx_gen_drv = mbx_gen_drv; // Initialize Generator-Driver mailbox
        this.mbx_drv_sco = mbx_drv_sco; // Initilaize Driver-Scoreboard mailbox
    endfunction
    
    // Reset Driver
    task reset();
        vif.rst<= 1'b1;
        vif.data_in <= 1'b0;
        vif.newd <= 1'b0;
        vif.rx <= 1'b1;
        
        repeat(5) @(posedge vif.u_clk_tx)
        vif.rst <= 1'b0;
        
        @(posedge vif.u_clk_tx); // Wait for internal clock's rising edge
        $display("[DRV] : RESET DONE");
        $display("-----------------------");
    endtask
    
    // Driver Main
    task run();
        forever begin
            mbx_gen_drv.get(tr); // Transaction from Generator to Driver
            if (tr.oper == 1'b0) begin // Data Write
                
                @(posedge vif.u_clk_tx); // Wait for 1 internal clock's rising edge
                vif.rst <= 1'b0;
                vif.newd <= 1'b1; // Start sending data
                vif.rx <= 1'b1;
                vif.data_in <= tr.data_in;
                
                @(posedge vif.u_clk_tx);
                vif.newd <= 1'b0;
                mbx_drv_sco.put(tr.data_in);
                $display("[DRV] : DATA SENT : %0d", tr.data_in);
                
                wait(vif.done_tx == 1'b1);
                -> drv_next;
            end
            else if (tr.oper == 1'b1) begin // Data Read
                
                @(posedge vif.u_clk_rx);
                vif.rst<= 1'b0;
                vif.rx <= 1'b0; // Start bit
                vif.newd <= 1'b0;
                
                @(posedge vif.u_clk_rx);
                
                for(int i = 0; i <= 7; i++) begin
                    data_rx[i] = $urandom;
                    vif.rx <= data_rx[i];
                    @(posedge vif.u_clk_rx); // Data bit for the next Baud period end
                end
                
                vif.rx <= 1'b1; // Stop (Idle)
                @(posedge vif.u_clk_rx);
                
                wait(vif.done_rx == 1'b1);
                mbx_drv_sco.put(data_rx);
                $display("[DRV] : DATA RECIEVED : %0d", data_rx);
                
                -> drv_next;
            end
        
        
        end
    endtask
endclass

////////////////////////////////////////

// Monitor
class monitor;
    transaction tr; // Transaction object
    mailbox #(bit [7:0]) mbx; // 8-bit mailbox to transfer transaction object
    bit [7:0] s_rx; // 8-bit Transmit data
    bit [7:0] r_rx; // 8-bit Recieve data
    
    virtual uart_if vif; // Virtual interface
    
    // Initialize Monitor instance
    function new(mailbox #(bit [7:0]) mbx);
        this.mbx = mbx; // Initialize Monitor-Scoreboard mailbox
    endfunction
    
    task run();
        forever begin
            @(posedge vif.u_clk_tx); // Wait for 1 internal clock's rising edge
            if((vif.newd == 1'b1) && (vif.rx == 1'b1)) begin
                @(posedge vif.u_clk_tx); // Start collecting tx data from next clock's rising edge
                // Read 8-bit data into Monitor
                for (int i = 0; i <= 7; i++) begin
                    @(posedge vif.u_clk_tx);
                    s_rx[i] = vif.tx;
                end
                
                $display("[MON] : DATA SEND on UART TX : %0d", s_rx);
                
                @(posedge vif.u_clk_tx); // Wait for 1 internal clock's rising edge
                mbx.put(s_rx); // Send data to Scoreboard through mailbox
            end
            
            else if ((vif.rx == 1'b0) && (vif.newd == 1'b0)) begin
                wait (vif.done_rx == 1'b1);
                r_rx = vif.data_out;
                $display("[MON] : DATA RECIEVED RX : %0d", r_rx);
                
                @(posedge vif.u_clk_tx);
                mbx.put(r_rx);
            end
        end
    endtask
endclass

///////////////////////////////////////////

// Scoreboard
class scoreboard;
    mailbox #(bit [7:0]) mbx_drv_sco, mbx_mon_sco; // 8-bit mailboxes Scoreboard gets from Driver, Monitor accordingly
    bit [7:0] drv_sco, mon_sco; // 8-bit data inputs to get mailboxed transaction from Driver, Monitor'
    event sco_next; // Event to trigger when Scoreboard finished comparing
    
    // Initialize Scoreboard instance
    function new(mailbox #(bit [7:0]) mbx_drv_sco, mailbox #(bit [7:0]) mbx_mon_sco);
        this.mbx_drv_sco = mbx_drv_sco; // Initialize Driver-Scoreboard mailbox
        this.mbx_mon_sco = mbx_mon_sco; // Initialize Monitor-Scoreboard mailbox
    endfunction
    
    // Scoreboard Main
    task run();
        forever begin
            mbx_drv_sco.get(drv_sco); // Get transaction data from Driver through mailbox
            mbx_mon_sco.get(mon_sco); // Get transaction data from Monitor through mailbox
            
            $display("[SCO] : DRV : %0d, MON : %0d", drv_sco, mon_sco);
            if (drv_sco == mon_sco)
                $display("DATA MATCHED");
            else
                $display("DATA MISMATCHED");
            $display("-----------------------------");
            -> sco_next; // Scoreboard finished comparing results
        end
    
    endtask
endclass

/////////////////////////////////////////////

// Environment
class environment;
    generator gen; // Generator object
    driver drv; // Driver object
    monitor mon; // Monitor object
    scoreboard sco; // Scoreboard object
    
    event next_gen_drv; // Event for Generator-Driver communication
    event next_gen_sco; // Event for Generator-Scoreboard communication
    
    mailbox #(transaction) mbx_gen_drv; // Mailbox for Generator-Driver communication
    mailbox #(bit [7:0]) mbx_drv_sco; // Mailbox for Driver-Scoreboard communication
    mailbox #(bit  [7:0]) mbx_mon_sco; // Mailbox for Monitor-Scoreboard communication
    
    virtual uart_if vif; // Virtual UART Interface
    
    // Initialize Environment instance  
    function new(virtual uart_if vif);
        mbx_gen_drv = new(); // Initialize Generator-Driver mailbox
        mbx_drv_sco = new(); // Initialize Driver-Scoreboard mailbox
        mbx_mon_sco = new(); // Initialize Monitor-Scoreboard mailbox
        
        gen = new(mbx_gen_drv); // Initialize Generator
        drv = new(mbx_gen_drv, mbx_drv_sco); // Initialize Driver
        mon = new(mbx_mon_sco); // Initialize Monitor
        sco = new(mbx_drv_sco, mbx_mon_sco); // Initialize Scoreboard
        
        this.vif = vif; // Set the virtual  interface of DUT
        drv.vif = this.vif; // Connect Virtual interface to Driver
        mon.vif = this.vif; // Connect Virtual interface to Monitor
        
        gen.sco_next = next_gen_sco; // Synchronize Generator-Scoreboard
        sco.sco_next = next_gen_sco; // Synchronize Scoreboard-Generator
        
        gen.drv_next = next_gen_drv; // Synchronize Generator-Driver
        drv.drv_next = next_gen_drv; // Synchronize Driver-Generator
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
        wait(gen.done.triggered); // Wait for Generator to finish
        $finish();
    endtask
    
    // Environment Main
    task run();
        pre_test();
        test();
        post_test();
    endtask
endclass

//////////////////////////////////////////
module tb();

uart_if vif(); // Virtual interface instance 
top dut(vif); // DUT interface

// Reset Clock signal
initial begin
    vif.clk <= 1'b0;
end

// Create 50 MHz clock signal
always #10 vif.clk <= ~vif.clk;

// Create Environment instance
environment env;

// Create, set and  run Environment instance
initial begin
    env = new(vif);
    env.gen.count = 5;
    env.run();
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
end


endmodule

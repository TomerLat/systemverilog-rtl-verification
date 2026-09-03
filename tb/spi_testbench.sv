`timescale 1ns / 1ps

/////////////////////////////////////

// Transaction Class
class transaction;
    bit newd; // Flag for new Transaction
    rand bit [11:0] data_in; // Randomize 12-bit data input
    bit [11:0] data_out; // 12-bit data output
    
    // Creates a deep copy of Trasnaction object
    function transaction copy();
        copy = new(); // Creates a new Transaction object
        copy.newd = this.newd; // Copy the newd flag
        copy.data_in = this.data_in; // Copy the data input
        copy.data_out = this.data_out; // Copy the data output
    endfunction
endclass

/////////////////////////////////////

// Generator Class
class generator;
    transaction tr; // Transaction object to generate and send information
    mailbox #(transaction) mbx; // Mailbox for communication with Driver
    event done; // Event to declare when all requested number of transactions are satisfied
    int count = 0; // Transactions count
    event sco_next; // Event to sychronize with Scoreboard
    
    // Initialize Generator instance
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx; // Initialize mailbox
        tr = new(); // Creates a new transaction
    endfunction
    
    // Generator main
    task run();
        repeat(count) begin
            assert(tr.randomize()) else $error("[GEN] : Randomization Failed!"); // Try to randomize Transaction object's signals
            mbx.put(tr.copy()); // Put a copy of Transaction object in Mailbox 
            $display("[GEN] : data_in : %0d", tr.data_in); // Display data input
            @(sco_next); // Wait for the scoreboard synchronization event
        end
        -> done; // Trigger 'done' when all transactions are completed
    endtask
endclass

/////////////////////////////////////

// Driver Class
class driver;
    virtual spi_if sif; // Virtual Interface
    transaction tr; // Transaction object
    mailbox #(transaction) mbx; // Mailbox for transaction from Generator
    mailbox #(bit [11:0]) mbx_drv_sco; // Mailbox for transaction to Monitor
    
    bit [11:0] data_in; // 12-bit Data Input
    
    // Initilaize Driver instance
    function new(mailbox #(transaction) mbx, mailbox #(bit [11:0]) mbx_drv_sco);
        this.mbx = mbx; // Initialize mailbox from Generator
        this.mbx_drv_sco = mbx_drv_sco; // Initialize mailbox to Monitor
    endfunction
    
    // Driver Reset
    task reset();
        sif.rst <= 1'b1; // Set Reset signal
        sif.newd <= 1'b0; // Clear new data flag
        sif.data_in <= 12'h000; // Clear Data input
        
        repeat(10) @(posedge sif.clk); // Wait for 10 clock's rising-edges
        sif.rst <= 1'b0; // Toggle Reset signal
        
        repeat(5) @(posedge sif.clk); // Wait for 5 clock's rising edges
        
        $display("[DRV] : REST DONE");
        $display("--------------------");
    endtask
    
    // Driver Main
    task run();
        forever begin
            mbx.get(tr); // Get a transaction object from Generator through mailbox
            sif.newd <= 1'b1; // Set new data flag
            sif.data_in <= tr.data_in; // Set data input
            mbx_drv_sco.put(tr.data_in); // Send data input to Monitor through mailbox
            
            @(posedge sif.s_clk); // Wait for Serial Clock rising edge
            sif.newd <= 1'b0; // Clear new data flag
            
            @(posedge sif.done); // Wait for 
            $display("[DRV] : DATA SENT TO DAC : %0d", tr.data_in);
            @(posedge sif.s_clk); // Wait for Serial Clock rising edge
        end
    endtask
     
endclass

/////////////////////////////////////////

// Monitor Class
class monitor;
    transaction tr; // Transaction object
    mailbox #(bit [11:0]) mbx_mon_sco; // Mailbox for data output to Scoreboard
    
    virtual spi_if sif; // Virtual interface
    
    // Initialize Monitor instance
    function new(mailbox #(bit [11:0]) mbx_mon_sco);
        this.mbx_mon_sco = mbx_mon_sco; // Initialize the mailbox
    endfunction
    
    // Monitor main
    task run();
        tr = new(); // Create a new transaction object
        forever begin
            @(posedge sif.s_clk); // Wait for Serial Clock rising edge
            @(posedge sif.done); // Wait for ...
            tr.data_out = sif.data_out; // Capture data output
            
            @(posedge sif.s_clk); // Wait for Serial Clock rising edge
            $display("[MON]: DATA SENT : %0d", tr.data_out);
            mbx_mon_sco.put(tr.data_out); // Send data output to Scoreboard through mailbox
        end
    endtask
endclass

//////////////////////////////////////////

// Scoreboard mailbox
class scoreboard;
    mailbox #(bit [11:0]) mbx_drv_sco, mbx_mon_sco; // Mailboxes sent from Driver and Monitor
    bit [11:0] drv_sco; // Data sent from Driver
    bit [11:0] mon_sco; // Data sent from Monitor
    event sco_next; // Event to synchronize with evirnoment
    
    // Initialize Scoreboard instance
    function new(mailbox #(bit[11:0]) mbx_drv_sco, mailbox #(bit [11:0]) mbx_mon_sco);
        this.mbx_drv_sco = mbx_drv_sco; // Initialize Driver-Scoreboard mailbox
        this.mbx_mon_sco = mbx_mon_sco; // Initialize Monitor-Scoreboard mailbox
    endfunction
    
    // Scoreboard main
    task run();
        forever begin
            mbx_drv_sco.get(drv_sco); // Recieve data from Driver through mailbox
            mbx_mon_sco.get(mon_sco); // Recieve data from Monitor through mailbox
            $display("[SCO] : DRV : %0d, MON : %0d", drv_sco, mon_sco);
            
            // Compare data outputs of Driver and Monitor
            if(drv_sco == mon_sco)
                $display("[SCO] : DATA MATCHED");
            else
                $display("[SCO] : DATA MISMATCHED");
            
            $display("-------------------------------");
            ->sco_next; // Synchronize with the environment
        
        end
    endtask
endclass

//////////////////////////////////////////

// Environment class
class environment;
    generator gen; // Generator object
    driver drv; // Driver object
    monitor mon; // Monitor object
    scoreboard sco; // Scoreboard object
    
    event next_gen_sco; // Event for Generator-Scoreboard communication
    
    mailbox #(transaction) mbx_gen_drv; // Mailbox for Generator-Driver communication
    mailbox #(bit [11:0]) mbx_drv_sco; // Mailbox for Driver-Scoreboard communication
    mailbox #(bit [11:0]) mbx_mon_sco; // Mailbox for Monitor-Scoreboard communication
    
    virtual spi_if sif; // Virtual interface
    
    // Initialize Environment instance
    function new(virtual spi_if sif);
        mbx_gen_drv = new(); // Initialize Generator-Driver mailbox
        mbx_drv_sco = new(); // Initialize Driver-Scoreboard mailbox
        mbx_mon_sco = new(); // Initialize Monitor-Scoreboard mailbox
    
        gen = new(mbx_gen_drv); // Intialize Generator
        drv = new(mbx_gen_drv, mbx_drv_sco); // Initialize Driver
        mon = new(mbx_mon_sco); // Initialize Monitor
        sco = new(mbx_drv_sco, mbx_mon_sco); // Initialize Scoreboard
        
        this.sif = sif; // Set the virtual interface for SUT
        drv.sif = this.sif; // Connect the virtual interface to Driver
        mon.sif = this.sif; // Connect the virtual interface to Monitor
        
        gen.sco_next  = next_gen_sco; // Synchronize Generator-Scoroeboard
        sco.sco_next = next_gen_sco; // Synchronize Scoreboard-Generator
        
    endfunction

    // Pre-Test
    task pre_test();
        drv.reset(); // Perform driver reset
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
    
    // Environment main
    task run();
        pre_test();
        test();
        post_test();
        
    endtask

endclass

////////////////////////////////////////////
module tb();
    spi_if sif(); // Virtual interface instance
    top dut(sif); // DUT instance
    
    // Reset Clock signal
    initial begin
        sif.clk <= 0;
    end
    
    // Create Environment instance
    environment env;
    
    // Create 50 MHz Clock signal
    always #10 sif.clk <= ~sif.clk;
    
    // Create, set and run Environment instance
    initial begin
        env = new(sif);
        env.gen.count = 5;
        env.run();
    end
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end

endmodule

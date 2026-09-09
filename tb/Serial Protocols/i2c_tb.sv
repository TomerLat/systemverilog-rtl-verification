`timescale 1ns / 1ps
///////////////////////////

// Transaction
class transaction;

    bit newd; // Flag to signal when there is new data
    rand bit op; // Select operation bit [ 0- Write, 1 - Read]
    rand bit [7:0] din; // 8-bit data input
    rand bit [6:0] addr; // 7-bit address input
    bit [7:0] dout; // 8-bit data output
    bit done; // Flag to signal 'done'
    bit busy; // Flag to signal when transfer wires are busy
    bit ack_err; // Flag to signal when ACK didn't happen

    // Define Address, Data Input's values and Operation's distribution
    constraint addr_c {addr > 1; addr < 5; din > 1; din < 10;}
    constraint rd_wr_c {op dist {1 :/ 50, 0:/ 50};}
    
    // Creates a deep copy of Transaction object
    function transaction copy();
        copy = new(); // Create a new transaction object
        copy.newd = this.newd; // Copy 'newd' flag
        copy.op = this.op; // Copy 'op' input
        copy.din = this.din; // Copy 8-bit data input
        copy.addr = this.addr; // Copy 7-bit address input
        copy.dout = this.dout; // Copy 8-bit data output
        copy.done = this.done; // Copy 'done' flag
        copy.busy = this.busy; // Copy 'busy' flag
        copy.ack_err = this.ack_err; // Copy 'ack_err' flag
    endfunction
endclass
///////////////////////////

// Generator
class generator;
    transaction tr; // Transaction object for communication with Driver
    mailbox #(transaction) mbx_gen_drv; // Mailbox object for communication with Driver
    event done; // Event to trigger when Generator completed all stimuli requests
    event drv_next; // Event to signal when Driver completed work
    event sco_next; // Event to signal when Scoreboard completed work
    
    int count = 0; // Number of requested stimuli transactions
    
    // Initialize Generator instance
    function new (mailbox #(transaction) mbx_gen_drv);
        this.mbx_gen_drv = mbx_gen_drv; // Initialize the mailbox for the Driver
        tr = new(); // Create a new transaction object
    endfunction
    
    task run();
        repeat(count) begin
            // Try to Randomize Transaction input values
            assert(tr.randomize()) else $error("Randomization Failed");
            // tr.addr = 7'h12;
            // tr.din = 8'hff;
            mbx_gen_drv.put(tr.copy()); // Sends Transaction's copy to Driver
            $display("[GEN] : OP : %0d, ADDRESS : %0d, DATA IN : %0d", tr.op, tr.addr, tr.din);
            @(drv_next); // Wait for Driver to accept transaction
            @(sco_next); // Wait for Scoreboard to accept transaction
        end
        -> done; // Trigger 'done' when all stimuli requests are satisfied
    endtask  
endclass
///////////////////////////

// Driver
class driver;
    virtual i2c_if vif; // Virtual interface
    transaction tr; // Transaction object to send and get information
    mailbox #(transaction) mbx_gen_drv; // Mailbox to get transaction from Generator
    event drv_next; // Event to trigger Driver's next iteration
    
    // Initialize Driver instance
    function new(mailbox #(transaction) mbx_gen_drv);
        this.mbx_gen_drv = mbx_gen_drv; // Initialize Generator-Driver mailbox
    endfunction
    
    // Reset Driver
    task reset();
        // Toggle 'rst' to high and all other inputs to low
        vif.rst <= 1'b1;
        vif.newd <= 1'b0;
        vif.op <= 1'b0;
        vif.din <= 0;
        vif.addr <= 0;
        
        repeat(10) @(posedge vif.clk); // Wait for 10 clock's rising edges
        vif.rst <= 1'b0; // Toggle 'rst' back to low
        $display("[DRV] : RESET DONE"); // Display reset message
        $display("-------------------");
    endtask
    
    // Write Operation
    task write();
        vif.rst <= 1'b0; // 'rst' to low
        vif.newd <= 1'b1; // Start sending data
         vif.op <= 1'b0; // 'op' to low (Write)
         vif.din <= tr.din; // Capture data input to DUT
         vif.addr <= tr.addr; // Capture address input to DUT
          
         repeat(5) @(posedge vif.clk); // Wait for 5 clock's rising edges
         vif.newd <= 1'b0; // Stop sending data
         
         @(posedge vif.done); // Wait for Generator to finish work
         $display("[DRV] : OP : WRITE, ADDR : %0d, DATA IN : %0d", tr.addr, tr.din); // Display output message
         vif.newd <= 1'b0; // Stop Sending data
    endtask
    
    // Read Operation
    task read();
        vif.rst <= 1'b0; // 'rst' to low
        vif.newd <= 1'b1; // start sending data
        vif.op <= 1'b1; // 'op' to high (Read)
        vif.din <= 0; // reset data input
        vif.addr <= tr.addr; // Capture address do DUT // 7'h12
        
        repeat(5) @(posedge vif.clk); // Wait 5 clock's rising edges
        vif.newd <= 1'b0; // Stop sending data
        
        @(posedge vif.done); // Wait for DUT to finish work
        $display("[DRV] : OP : RD, ADDRESS : %0d, DATA OUT : %0d", tr.addr, vif.dout); // Display output message
    endtask
    
    // Driver Main
    task run();
        tr = new(); // Create new transaction object
        forever begin
            mbx_gen_drv.get(tr); // Get transaction information from Generator
            if(tr.op == 1'b0) // Apply Write operation
                write();
            else
                read(); // Apply Read operation
            -> drv_next; // Signal Generator that work is done
        end
        
    endtask
endclass

///////////////////////////

// Monitor
class monitor;
    virtual i2c_if vif; // Virtual interface
    transaction tr; // Transaction object to send and get information
    mailbox #(transaction) mbx_mon_sco; // Mailbox to send transaction to Scoreboard
    
    // Initialize Monitor Instance
    function new(mailbox #(transaction) mbx_mon_sco);
        this.mbx_mon_sco = mbx_mon_sco; // Initialize Monitor-Scoreboard mailbox
    endfunction
    
    // Monitor Main
    task run();
        tr = new(); // Create a new transaction object
        forever begin
            // Capture DUT pins to Monitor
            // @(posedge vif.clk);
            @(posedge vif.done); // Wait for Generator to finish work
            tr.din = vif.din; // Capture data input from DUT
            tr.addr = vif.addr; // Capture address input from DUT
            tr.op = vif.op; // Capture 'op' from DUT
            tr.dout = vif.dout; // Capture data output from DUT
            
            repeat(5) @(posedge vif.clk); // Capture 5 clock's rising edges
            mbx_mon_sco.put(tr); // Send transaction information to Scoreboard through mailbox
            $display("[MON] : OP : %0d, ADDRESS : %0d, DATA IN : %0d, DATA OUT : %0d", tr.op, tr.addr, tr.din, tr.dout); // Display output message
        end
    endtask
endclass
///////////////////////////

// Scoreboard
class scoreboard;
    transaction tr; // Transaction object
    mailbox #(transaction) mbx_mon_sco; // Mailbox to get transaction's information from Monitor
    event sco_next; // Event to signal Generator when work completed
    bit [7:0] temp; // 8-bit to store data from Monitor
    bit [7:0] mem [128] = '{default : 0}; // 128-array of 8-bit data
    
    // Initialize Scoreboard Instance
    function new(mailbox #(transaction) mbx_mon_sco);
        this.mbx_mon_sco = mbx_mon_sco; // Initialize Monitor-Scoreboard mailbox
        for(int i = 0; i < 128; i++) // Set 'mem' array values
            mem[i] = i;
    endfunction
    
    // Scoreboard Main
    task run();
        forever begin
            mbx_mon_sco.get(tr); // Get transaction information form Monitor through maiilbox
            temp = mem[tr.addr]; // Store data into 'temp'
            if(tr.op == 1'b0) begin // Check if 'Write' operation
                mem[tr.addr] = tr.din; // Store data input into array
                $display("[SCO] : DATA STORED -> ADDRESS : %0d, DATA : %0d", tr.addr, tr.din); // Display output message
            end
            else begin
                if(tr.dout == temp) // || (tr.dout == tr.addr)
                    $display("[SCO] : DATA READ -> DATA MATCHED, exp : %0d, rec : %0d", temp, tr.dout); // Display output message
                else
                    $display("[SCO] : DATA READ -> DATA MISMATCHED, exp : %0d, rec : %0d", temp, tr.dout); // Display output message
                $display("-----------------------");
            end
            -> sco_next; // Signal Generator work is completed
        end
    endtask
    
endclass
///////////////////////////

// Environment
class environment;
    generator gen; // Generator object
    driver drv; // Driver object
    monitor mon; // Monitor object
    scoreboard sco; // Scoreboardobject
    
    mailbox #(transaction) mbx_gen_drv; // Mailbox for Generator-Driver communication
    mailbox #(transaction) mbx_mon_sco; // Mailbox for Monitor-Scoreboard communication
    
    event drv_next; // Event for Generator-Driver communication
    event sco_next; // Event for Generator-Scoreboard communication
    
    virtual i2c_if vif; // Virtual I2C Interface
    
    // Initialize Environment instance
    function new(virtual i2c_if vif);
        mbx_gen_drv = new();// Initialize Generator-Driver mailbox
        mbx_mon_sco = new(); // Initialize Monitor-Scoreboard mailbox
        
        gen = new(mbx_gen_drv); // Initialize Generator
        drv = new(mbx_gen_drv); // Initialize Driver
        mon = new(mbx_mon_sco); // Initialize Monitor
        sco = new(mbx_mon_sco); // Initialize Scoreboard
        
        this.vif = vif; // Set the virtual interface of DUT
        drv.vif = this.vif; // Connect virtual interface to Driver
        mon.vif = this.vif; // Connect virtual interface to Monitor
        
        gen.drv_next = this.drv_next; // Synchronize Generator-Driver
        drv.drv_next = this.drv_next; // Synchronize Driver-Generator
        
        gen.sco_next = this.sco_next; // Synchronize Generator-Scoreboard
        sco.sco_next = this.sco_next; // Synchronize Scoreboard-Generator
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
///////////////////////////

module tb();
    i2c_if vif(); // Virtual interface instance
    top dut(vif); // DUT interface
    
    // Reset clock signal
    initial begin
        vif.clk <= 1'b0;
    end
    
    // Generate 100 MHz clock signal
    always #12.5 vif.clk <= ~vif.clk;
    
    // Create Environment instance
    environment env;
    
    // Create, Set and Run Environment instance
    initial begin
        env = new(vif);
        env.gen.count = 5;
        env.run();
    end
    
    // Simulation files and variables
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end
endmodule

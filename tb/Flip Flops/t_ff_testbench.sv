`timescale 1ns / 1ps

class transaction;
    
    rand bit t; // Define a random input bit "t" (Toggle)
    bit q; // Define an output bit "q" (Q state)
    
    // Created a deep copy of the data transferred between classes
    function transaction copy();
        copy = new(); // Create a new transaction object
        copy.t = this.t; // Copy the input value
        copy.q = this.q; // Copy the output value
    endfunction
    
    // Display transaction information
    function void display(input string tag);
        $display("[%0s] : Toggle : %0b, Q : %0b", tag, t, q);
    endfunction
    
endclass

//////////////////////////////////////////////////////

class generator;

    transaction tr; // Define a transaction object
    mailbox #(transaction) mbx; // Create a mailbox to send data to Driver
    mailbox #(transaction) mbx_ref; // Create a mailbox to sent data to Scoreboard for comparison (Golden Data)
    event sco_next; // Event to sense the completion of scoreboard work
    event done; // Event to trigger when the requested number of stimulus is applied
    int count; // Stimulus count
    
    // Initializing a Generator instance
    function new(mailbox #(transaction) mbx, mailbox #(transaction) mbx_ref);
        this.mbx = mbx; // Initialize the mailbox for the driver
        this.mbx_ref = mbx_ref; // Initialize the mailbox for the scoreboard
        tr = new(); // Create a new transaction object
    endfunction
    
    // Generator class core
    task run();
        repeat(count) begin
            assert (tr.randomize()) else $error ("[GEN] : Randomization Failed!"); // Trt randomizing the Toggle input
            mbx.put(tr.copy); //  Put a copy of the transaction into the driver mailbox
            mbx_ref.put(tr.copy); // Put a copy of the transaction into the socreboard mailbox
            tr.display("GEN"); // Calls transaction class function to print the data
            @(sco_next); // Wait for the scoreboard's work completion
        end
        
        -> done; // Trigger "done" event when all stimulus are applied
    endtask
    
endclass


///////////////////////////////////////////////////////

class driver;

    transaction tr; // Define a transaction object
    mailbox #(transaction) mbx; // Create a mailbox to recieve data fron Generator
    virtual tif_if vif; // Virtual Interface for DUT
    
    // Initialize Driver instance
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx; // Initialize the mailbox for recieving data
    endfunction
    
    // Managing Reset activation
    task reset();
        vif.rst <= 1'b1; // Reset signal --> active
        repeat(5) @(posedge vif.clk); // Wait for 5 clock cycles
        vif.rst <= 1'b0; // Reset signal --> low
        @(posedge vif.clk); // Wait for one more clock cycle
        $display("[DRV] : RESET DONE"); // Display reset 
    endtask
    
    // Driver class core
    task run();
        forever begin
            mbx.get(tr); // Get a transaction from Generator
            vif.t <= tr.t; // Set DUT input from the transaction
            @(posedge vif.clk); // Wait for clock's rising edge
            tr.display("DRV"); // Printing dransaction data by calling Transaction function
            vif.t <= 1'b0; // Set DUT input to 0
            @(posedge vif.clk); // Wait for clock's rising edge
        end
    endtask
endclass


//////////////////////////////////////////////////////////

class monitor;

transaction tr; // Define a transaction object
    mailbox #(transaction) mbx; // Create a mailbox to send data to Scoreboard
    virtual tif_if vif; // Virtual Interface for DUT
    
    // Initialize Monitor instance
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx; // Initialize the mailbox for sending data to Scoreboard
    endfunction
    
    // Monitor class core
    task run();
        tr = new(); // Create a new transaction
        forever begin
            repeat (2) @(posedge vif.clk); // Wait for 2 clock's rising edges
            tr.q = vif.q; // Capture DUT output
            mbx.put(tr); // Send the captured data to Scoreboard
            tr.display("MON"); // Print transaction data 
        end
    endtask
endclass

///////////////////////////////////////////////////////////

class scoreboard;

    transaction tr; // Define a transaction object
    transaction tr_ref; // Define a refernce transaction object for reference
    mailbox #(transaction) mbx; // Create a mailbox to recieve data from Monitor 
    mailbox #(transaction) mbx_ref; // Create a mailbox to recieve reference data from Generator
    event sco_next; // Event to signal completion of scoreboard work
    bit expected_q = 0; // Starts from 0 because of the initial reset value
    
    // Initialize Scoreboard instance
    function new(mailbox #(transaction) mbx, mailbox #(transaction) mbx_ref);
        this.mbx = mbx; // Initialize the mailbox for recieving Monitor's data
        this.mbx_ref = mbx_ref; // Initialize the mailbox for recieving Generator's reference data 
    endfunction
    
    function void output_match(transaction tr,transaction tr_ref);
        if (tr_ref.t == 1'b1) // If Toggle input is active then output is the opposite of the previous output
            expected_q = ~expected_q;
        // Else the output stays the same
        
        
        // Compares actual Vs. expected
        if(tr.q == expected_q)
            $display("[SCO] : DATA MATCHED");
        else
            $display("[SCO] : DATA MISMATCHED");
        $display("--------------------------");
    endfunction
    
    // Scoreboard class core
    task run();
        forever begin
            mbx.get(tr); // Get a transaction from Driver
            mbx_ref.get(tr_ref); // Get a transaction from Generator
            tr.display("SCO"); // Display Driver's transaction data
            tr_ref.display("REF"); // Display Reference transaction data from Generator
            output_match(tr, tr_ref);
            
            -> sco_next; // Signal when Scoreboard completes its work
        end
    endtask
    
    
    
endclass

////////////////////////////////////////////////////////////


class environment;
    
    generator gen; // Generator instance
    driver drv; // Driver instance
    monitor mon; // Monitor instance
    scoreboard sco; // Scoreboard instance
    event next; // Event to communicate between Generator and Driver
    
    mailbox #(transaction) gen_drv_mbx; // Mailbox to communicate between Generator and Driver
    mailbox #(transaction) mon_sco_mbx; // Mailbox to communicate between Monitor and Scoreboard
    mailbox #(transaction) mbx_ref; // Mailbox to communicate between Generator between Scoreboard
    
    virtual tif_if vif; // Virtual interface for DUT
    
    function new(virtual tif_if vif);
        gen_drv_mbx = new(); // Create a mailbox for Generator-Driver communication
        mon_sco_mbx = new(); // Create a mailbox for Monitor- Scoreboard communication
        mbx_ref = new(); // Create a mailbox for Generator-Scoreboard reference data
        
        gen = new(gen_drv_mbx, mbx_ref); // Initialize the Generator
        drv = new(gen_drv_mbx); // Initilaize the Driver
        mon = new(mon_sco_mbx); // Initialize the Monitor
        sco = new(mon_sco_mbx, mbx_ref); // Initialize the  Scoreboard
        
        this.vif = vif; // Set the Virtual interface for DUT
        drv.vif = this.vif; // Connect the virtual interface to Driver
        mon.vif = this.vif; // Connect the virtual interface to Monitor
        
        gen.sco_next = next; // Set the communication between Generator and Scoreboard
        sco.sco_next = next; // Set the communication event between Scoreboard and Generator
        
    endfunction
    
    // Execute tasks/functions before test
    task pre_test();
        drv.reset(); // Perfrom Driver's reset
    endtask
    
    // Execute test
    task test();
        fork
            gen.run(); // Start Generator
            drv.run(); // Start Driver
            mon.run(); // Start Monitor
            sco.run(); // Start Scoreboard
        join_any
    endtask
    
    task post_test();
        wait(gen.done.triggered); // Wait for Generator to complete stimuli
        $finish(); // finish simulation
    endtask
    
    // Environment class core
    task run();
        pre_test(); // Run pre-test setup
        test(); // Run the test
        post_test(); // Run post-test cleanup
    endtask
    
endclass

////////////////////////////////////////////////////////////

module tb();
    tif_if vif(); // Create DUT interface
    
    top dut(vif.dut); // Create DUT instance
    
    
    initial begin
        vif.clk <= 0; // Initialize clock signal
        vif.t <= 0;
        vif.rst <= 1;
    end
    
    always #10 vif.clk <= ~vif.clk; // Create 50 MHz clock signal
    
    
    environment env; // Create environment instance
    
    initial begin
       env = new(vif); // Initialize Environment instance
       env.gen.count = 30; // Set Generator's stimulus count
       env.run(); // Run the Environment 
    end
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars; // Dump all variables
    end
endmodule

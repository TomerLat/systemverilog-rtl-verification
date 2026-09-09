`timescale 1ns / 1ps

///////////////////////////////////////////////

// Transaction Class
class transaction;
    
    rand bit set, rst; // Define random input bit for Set and Reset
    bit q; // Define an output bit Q
    
    // Creates a deep copy of the data transferred between classes
    function transaction copy();
        copy = new(); // Creates a new transaction object
        copy.set = this.set; // Copy the Set input value
        copy.rst = this.rst; // Copy the Reset input value
        copy.q = this.q; // Copy the Q data output value
    endfunction
    
    // Display transaction information
    function void display(input string tag);
        $display("[%0s] : SET : %0b, RESET : %0b, Q : %0b", tag, set, rst, q);
    endfunction
    
endclass

///////////////////////////////////////////////

// Generator Class
class generator;
    transaction tr; // Define a transaction object
    mailbox #(transaction) mbx; // Create a Mailbox to send data to Driver
    mailbox #(transaction) mbx_ref; // Create a mailbox to send data to Scoreboard for comparison
    event sco_next; // Event to sense when Scoreboard finished comparison work
    event done; // Event to trigger when the requested number of stimulus is applied
    int count; // Stimulus count
    
    function new(mailbox #(transaction) mbx, mailbox #(transaction) mbx_ref);
        this.mbx = mbx; // Initialize the mailbox for the Driver
        this.mbx_ref = mbx_ref; // Initialize the mailbox for the Scoreboard
        tr = new(); // Create a new transaction object
    endfunction
    
    // Generator main
    task run();
        repeat(count) begin
            assert(tr.randomize()) else $error("[GEN] : RANDOMIZATION FAILED!");
            mbx.put(tr.copy); // Send transaction information to Driver via its mailbox
            mbx_ref.put(tr.copy); // Send transaction information to Scoreboard via its mailbox
            tr.display("GEN"); // Display the data information in Generator
            @(sco_next); // Wait for the Scoreboard to finish comparing test
        end
        
        -> done; // Trigger "done" when all stimulus are applied
    endtask

endclass

//////////////////////////////////////////////////

// Driver Class
class driver;
    
    transaction tr; // Define a transaction object
    mailbox #(transaction) mbx; // Create a mailbox to recieve data from the Generator
    virtual sr_if vif; // Virtual interface for DUT
    
    // Initialize Driver instance
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx; // Initialize the mailbox for recieving information from Generator
    endfunction
    
    task run();
        forever begin
            mbx.get(tr); // Get a transaction information from Generator
            vif.set <= tr.set; // Get DUT Set input from transaction
            vif.rst <= tr.rst; // Get DUT Reset input from transaction 
            @(posedge vif.clk); // Wait for clock's rising edge
            
            tr.display("DRV"); // Display transaction information in Driver
            @(posedge vif.clk); // Wair for another rising edge so the Set and Reset become stable
            
            vif.set <= 1'b0; // Reset 'Set' signal
            vif.rst <= 1'b0; // Reset 'Reset' signal
            //@(posedge vif.clk); // Wait another rising edge so the system will be able to detect the changes          
        end
    endtask
    
endclass

//////////////////////////////////////////////////

// Monitor Class
class monitor;
    
    transaction tr; // Define a transaction object
    mailbox #(transaction) mbx; // Create a mailbox to send data to Scoreboard
    virtual sr_if vif; // Virtual Interface for DUT
    
    // Initialize Monitor instance
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx; // Initialize the mailbox for sending data to Scoreboard
    endfunction
    
    // Monitor main
    task run();
        tr = new(); // Create a new transaction
        forever begin
            
            
            // Wait 2 rising edge so the DUT can update according to Driver
            repeat(2) @(posedge vif.clk);
            
            tr.q = vif.q; // Capture DUT output
            tr.set = vif.set;
            tr.rst = vif.rst;
            mbx.put(tr); // Send the information captured from DUT to Scoreboard
            tr.display("MON"); // Display transaction information in Monitor
        end
    endtask
    
endclass
//////////////////////////////////////////////////

// Scoreboard class
class scoreboard;
    
    transaction tr; // Define a transaction object
    transaction tr_ref; // Define a transaction object for reference
    mailbox #(transaction) mbx; // Create mailbox to recieve transaction information from Monitor
    mailbox #(transaction) mbx_ref; // Create mailbox to recieve reference transaction information from Generator
    event sco_next; // Event to signal completion of Scoreboard work
    bit expected_q = 0; // Q output variable for comparison with the real output
    
    // Initialize Scoreboard Instance
    function new(mailbox #(transaction) mbx, mailbox #(transaction) mbx_ref);
    
        this.mbx = mbx; // Initialize mailbox for recieving information from Monitor
        this.mbx_ref = mbx_ref;     // Initialize mailbox for recieving information from Generator 
    endfunction
    
    // Compare Generator's and Monitor's transaction information
    function void output_compare(transaction tr, transaction tr_ref);
        case ({tr_ref.set, tr_ref.rst})
            2'b00 : expected_q = expected_q; // Hold State
            2'b01 : expected_q = 1'b0; // Reset State
            2'b10 : expected_q = 1'b1; // Set State
            2'b11 : expected_q = 1'bx; // Invalid State
        endcase
        
        if(tr.q == expected_q)
            $display("DATA MATCHED");
        else
            $display("DATA UNMATCHED");
    endfunction
    
    // Scoreboard main
    task run();
        forever begin
            mbx.get(tr); // Get transaction information from Monitor
            mbx_ref.get(tr_ref); // Get transaction information from Generator
            tr.display("SCO [MON]"); // Display Monitor's transaction information
            tr_ref.display("SCO [GEN]"); // Display Generator's transaction information
            output_compare(tr, tr_ref);
            -> sco_next; // Trigger the event when Scoreboard completes its work
            
        end
       
    endtask
    
endclass

///////////////////////////////////////////////////

// Environment class
class environment;

    generator gen; // Generator instance
    driver drv; // Driver instance
    monitor mon; // Monitor instance
    scoreboard sco; // Scoreboard instance
    event next; // Event communicate between Generator and Driver
    
    mailbox #(transaction) gen_drv_mbx; // Mailbox for Generator- Driver communication
    mailbox #(transaction) mon_sco_mbx; // Mailbox for Monitor- Scoreboard communication
    mailbox #(transaction) mbx_ref; // Mailbox for Generator- Scoreboard communication and comparison
    
    virtual sr_if vif; // Virtual interface for DUT
    
    // Initialize Environment instance
    function new(virtual sr_if vif);
        gen_drv_mbx = new(); // Create a mailbox for Generator-Driver communication
        mon_sco_mbx = new(); // Create a mailbox for Monitor-Scoreboard communication
        mbx_ref = new(); // Create a mailbox for Generator-Scoreboard reference information
        
        gen = new(gen_drv_mbx, mbx_ref); // Initialize the Generator
        drv = new(gen_drv_mbx); // Initialize the Driver
        mon = new(mon_sco_mbx); // Initialize the Monitor
        sco = new(mon_sco_mbx, mbx_ref); // Initialize the Scoreboard
        
        this.vif = vif; // Set the virtual interface for DUT
        drv.vif = this.vif; // Connect the virtual interface to Driver
        mon.vif = this.vif; // Connect the virtual interface to Monitor
        
        gen.sco_next = next; // Set the communication of Generator to Scoreboard
        sco.sco_next = next; // Set the communication of Scoreboard to Generator
    endfunction
    
    task test();
        fork
            gen.run(); // Start Generator
            drv.run(); // Start Driver
            mon.run(); // Start Monitor
            sco.run(); // Start Scoreboard     
        join_any
    endtask
    
    task post_test();
        wait(gen.done.triggered); // Wait for Generator to signal completion of stimuli
        $finish();
    endtask
    
    task run();
        test(); // Run the test
        post_test(); // Run the post-test cleanup
    endtask

endclass


/////////////////////////////////////////////////////

module sr_tb();

    sr_if vif(); // Create DUT interface
   
    sr_top dut(vif.dut); // Create DUT instance
   
    // Initialize DUT inputs
    initial begin
        vif.clk <= 1'b0;
        vif.set <= 1'b0;
        vif.rst <= 1'b0;
    
    end
    
    always #10 vif.clk <= ~vif.clk; // Create 50 MHz clock signal
    
    environment env; // Create Environment instance
    
    initial begin
        env = new(vif); // Initialize Environment instance
        env.gen.count = 30; // Set Generator's stimulus count
        env.run(); // Run the environment
    end
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars; // Dump all variables
    end
    
endmodule

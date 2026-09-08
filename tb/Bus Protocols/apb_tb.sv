`timescale 1ns / 1ps

////////////////////////////

// Transaction
class transaction;
    rand bit [31:0] p_addr; // Address
    rand bit [7:0] p_w_data; // Write Data
    rand bit p_sel; // Select a Slave (one p_sel for each slave)
    randc bit p_write; // Operation input (1-write, 0- read)
    bit [7:0] p_r_data; // Read Data (from slave)
    bit p_ready; // Slave ready (1-finish the cycle)
    bit p_slv_err; // Error from slave
    
    constraint addr_c {p_addr >= 0; p_addr <= 15;} // Address values contraint
    constraint data_c {p_w_data >= 0; p_w_data <= 255;} // Write Data values constraint
    
    // Display all values
    function void display(input string tag);
        $display("[%0s] : p_addr : %0d, p_w_data : %0d, p_write : %0b, p_r_data : %0d, p_slv_err : %0b @ :%0t", tag, p_addr, p_w_data, p_write, p_r_data, p_slv_err, $time);
    endfunction
    
    // Create deep copy of transaction object
    function transaction copy();
        copy = new(); // Create a new transaction object
        copy.p_addr = this.p_addr; // Copy address
        copy.p_w_data = this.p_w_data; // Copy write data
        copy.p_sel = this.p_sel; // Copy slave select
        copy.p_write = this.p_write; // Copy operation input
        copy.p_r_data = this.p_r_data; // Copy read data
        copy. p_ready = this.p_ready; // Copy slave enable
        copy.p_slv_err = this.p_slv_err; // Copy slave error flag
    endfunction
endclass

////////////////////////////

// Generator
class generator;
    transaction tr; // Transaction object to create and send information
    mailbox #(transaction) mbx_gen_drv; // Mailbox for communication with Driver
    int count = 0; // Number of requested stimuli transactions
    
    event next_drv; // Event to signal Generator when Driver finished work
    event next_sco; // Event to signal Generator when Scoreboard finished work
    event done; // Event to trigger when Generator finished work
    
    // Initialize Generator instance
    function new(mailbox #(transaction) mbx_gen_drv);
        this.mbx_gen_drv = mbx_gen_drv; // Initialize the mailbox for the Driver
        tr = new(); // Create a new transaction object
    endfunction
    
    task run();
        repeat(count) begin
            // Try to randomize transaction values
            assert(tr.randomize()) else $error("Randomization Failed!");
            mbx_gen_drv.put(tr.copy()); // Send transaction copy to Driver
            tr.display("GEN"); // Display message of transaction in Generator
            @(next_drv); // Trigger Generator-Driver event
            @(next_sco); // Trigger Generator-Scoreboard event
        end
        -> done; // Trigger when Generator finished work
    endtask
endclass

////////////////////////////

// Driver
class driver;
    virtual apb_if vif; // Virtual interface
    transaction tr; // Transaction object
    mailbox #(transaction) mbx_gen_drv; // Mailbox for communication with Generator
    event next_drv; // Event to trigger when Driver finished work
    
    // Initialize Driver instance
    function new(mailbox #(transaction) mbx_gen_drv);
        this.mbx_gen_drv = mbx_gen_drv; // Initialize the mailbox for Driver
    endfunction
    
    // Reset Driver
    task reset();
        vif.p_reset_n <= 1'b0; // Reset active-low
        vif.p_sel <= 1'b0;
        vif.p_enable <= 1'b0;
        vif.p_w_data <= 0;
        vif.p_addr <= 0;
        vif.p_write <= 1'b0;
        
        repeat(5) @(posedge vif.p_clk); // Wait 5 clock's rising edges
        vif.p_reset_n <= 1'b1; // Toggle reset to inactive-high
        $display("[DRV] : RESET DONE"); 
        $display("------------------------");
    endtask
    
    // Driver main
    task run();
        forever begin
            mbx_gen_drv.get(tr); // Get tranaction from Generator through mailbox
            
            @(posedge vif.p_clk); // Wait for 1 clock's rising edge
            if(tr.p_write) begin // Write operation
                vif.p_sel <= 1'b1;
                vif.p_enable <= 1'b0;
                vif.p_w_data <= tr.p_w_data; // DUT captures write data
                vif.p_addr <= tr.p_addr; // DUT captures data
                vif.p_write <= 1'b1;
                
                @(posedge vif.p_clk); // Wait for 1 clock's rising edge
                vif.p_enable <= 1'b1;
                
                @(posedge vif.p_clk); // Wait for 1 clock's rising edge
                vif.p_sel <= 1'b0;
                vif.p_enable <= 1'b0;
                vif.p_write <= 1'b0;
                tr.display("DRV"); // Display message of Driver values
                -> next_drv; // Trigger when Driver finished work
            end
            else if (!tr.p_write) begin // Read operation
                vif.p_sel <= 1'b1;
                vif.p_enable <= 1'b0;
                vif.p_w_data <= 0;
                vif.p_addr <= tr.p_addr; // DUT captures address
                vif.p_write <= 1'b0;
                
                @(posedge vif.p_clk); // Wait for 1 clock's rising edge 
                vif.p_enable <= 1'b1;
                
                @(posedge vif.p_clk); // Wait for 1 clock's rising edge
                vif.p_sel <= 1'b0;
                vif.p_enable <= 1'b0;
                vif.p_write <= 1'b0;
                tr.display("DRV"); // Display message of Driver values
                -> next_drv; // Trigger when Driver finished work
            end
        end
    endtask
endclass

////////////////////////////

// Monitor
class monitor;
    virtual apb_if vif; // Virtual interface
    mailbox #(transaction) mbx_mon_sco; // Mailbox for communication with Scoreboard
    transaction tr; // Transaction object
    
    // Initialize Monitor instance
    function new(mailbox #(transaction) mbx_mon_sco);
        this.mbx_mon_sco = mbx_mon_sco; // Initialize the mailbox for Monitor
    endfunction
    
    // Monitor main
    task run();
        tr = new(); // Create new transaction object
        forever begin
            @(posedge vif.p_clk); // Wait 1 clock's rising edge
            if (vif.p_ready) begin // Slave ready
                // Capture DUT values
                tr.p_w_data = vif.p_w_data;
                tr.p_addr = vif.p_addr;
                tr.p_write = vif.p_write;
                tr.p_r_data = vif.p_r_data;
                tr.p_slv_err = vif.p_slv_err;
                @(posedge vif.p_clk); // Wait 1 clock's rising edge
                tr.display("MON"); // Display message of Monitor values
                mbx_mon_sco.put(tr.copy()); // Send transaction copy to Scoreboard
            end
        end
    endtask
endclass

////////////////////////////

// Scoreboard
class scoreboard;
    transaction tr; // Transaction object
    mailbox #(transaction) mbx_mon_sco; // Mailbox for communication with Monitor
    event next_sco; // Trigger when Scoreboard finished work
    
    bit [7:0] p_w_data[16] = '{default : 0}; // 16-size array of 8-bit write data inputs
    bit [7:0] r_data; // 8-bit read data output
    int err = 0; // Errors counter
    
    // Initialize Scoreboard instance
    function new(mailbox #(transaction) mbx_mon_sco);
        this.mbx_mon_sco = mbx_mon_sco; // Initialize Monitor-Scoreboard  mailbox
    endfunction
    
    // Scoreboard ain
    task run();
        forever begin
            mbx_mon_sco.get(tr); // Get transaction from Monitor through mailbox
            if(tr.p_write && !tr.p_slv_err) begin // Write access
                p_w_data[tr.p_addr] = tr.p_w_data; // Write data into array
                $display("[SCO] : DATA STORED DATA : %0d, ADDRESS : %0d", tr.p_w_data, tr.p_addr); // Display Write data
            end
            else if (!tr.p_write && !tr.p_slv_err) begin // Read access
                r_data = p_w_data[tr.p_addr]; // Read data from array
                if(tr.p_r_data == r_data) // Compare Monitor and DUT read data results
                    $display("[SCO] : DATA MATCHED");
                else begin
                    err++; // Increase errors counter
                    $display("[SCO] : DATA MISMATCHED");
                end
            end
            else if (tr.p_slv_err)
                $display("[SCO] : SLAVE ERROR DETECTED");
            
            $display("-----------------------------------------");
            -> next_sco; // Trigger Scoreboard finished work
        end
    endtask
endclass

////////////////////////////

// Environment
class environment;

    generator gen; // Generator object
    driver drv; // Driver object
    monitor mon; // Monitor object
    scoreboard sco; // Scoreboard object
    
    event next_drv; // Event for Generator-Driver communication
    event next_sco; // Event for Generator-Scoreboard communication
    
    mailbox #(transaction) mbx_gen_drv; // Mailbox for Generator-Driver communication
    mailbox #(transaction) mbx_mon_sco; // Mailbox for Monitor-Driver communication
    
    virtual apb_if vif; // Virtual APB interface
    
    // Initialize Environment instance
    function new(virtual apb_if vif);
        mbx_gen_drv = new(); // Initialize Generator-Driver mailbox
        mbx_mon_sco = new(); // Initialize Monitor-Scoreboard mailbox
        
        gen = new(mbx_gen_drv); // Initialize Generator
        drv = new(mbx_gen_drv); // Initialize Driver
        mon = new(mbx_mon_sco); // Initialize Monitor
        sco = new(mbx_mon_sco); // Initialize Scoreboard
        
        this.vif = vif; // Set the virtual interface of DUT
        drv.vif = this.vif; // Connect virtual interface to Driver
        mon.vif = this.vif; // Connect virtual interface to Monitor
        
        // Synchronize Generator-Driver events
        gen.next_drv = next_drv;
        drv.next_drv = next_drv;
        
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
        $display("----Total number of mismatch : %0d -------", sco.err); // Display number of errors
        $finish();
    endtask
    
    // Environment main
    task run();
        pre_test();
        test();
        post_test();
    endtask

endclass

////////////////////////////

module tb();

    apb_if vif(); // Virtual interface instance
    top dut(vif); // DUT interface
    
    // Reset clock signal
    initial begin
        vif.p_clk <= 1'b0;
    end
    
    // Create 50 MHz clock signal
    always #10 vif.p_clk <= ~vif.p_clk;
    
    // Create Environment instance
    environment env;
    
    // Create, Set, Run the Environment instance
    initial begin
        env = new(vif);
        env.gen.count = 20;
        env.run();
    end 
    
    // Drop Simulation
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end
endmodule

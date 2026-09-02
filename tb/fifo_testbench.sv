`timescale 1ns / 1ps

////////////////////////////////////

// Transaction
class transaction;
    rand bit oper; // Randomize bit for operatior control (Write or Read)
    bit rd, wr; // Read and Write control bits
    bit [7:0] data_in; // 8-bit data input
    bit full, empty; // Flags of 'full' and 'empty' status
    bit [7:0] data_out; // 8-bit data output
    
    // Constraint to randomize 'oper' with 50% probability for each Write('1'), Read('0')
    constraint oper_ctrl {oper dist {1'b1 :/ 50, 1'b0 :/ 50};}
    
    // Creates deep copy of the Transaction object
    function transaction copy();
        copy = new(); // Creates a new transaction object
        copy.oper = this.oper; // Copy the Operation bit value
        copy.rd = this.rd; // Copy Read input value
        copy.wr = this.wr; // Copy Write input value
        copy.data_in = this.data_in; // Copy Data input value
        copy.full = this.full; // Copy 'full' status
        copy.empty = this.empty; // Copy 'empty' status
        copy.data_out = this.data_out; // Copy Data output value
    endfunction
endclass

///////////////////////////////////

// Generator
class generator;
    transaction tr; // Transaction object to generate and send information
    mailbox #(transaction) mbx; // Mailbox for communication
    int count = 0; // Number of transaction to generate
    int i = 0; // Iteration counter
    
    event next; // Event to signal when to send the next transaction
    event done; // Event to signal when all requested number of transaction has completed
    
    // Initialize Generator instance
    function new (mailbox #(transaction) mbx);
        this.mbx = mbx; // Initialize the mailbox for the Driver
        tr = new(); // Create a new transation object
    endfunction
    
    // Generator main
    task run();
        repeat (count) begin
            assert(tr.randomize()) else $error("Randomization Failed!"); // Try Randomizing transaction information
            i++; // Iterations count update
            mbx.put(tr.copy()); // Send transaction data to Driver with mailbox
            $display("[GEN] : Oper : %0d, Iteration : %0d", tr.oper, i); // Display the data information in Generator
            @(next); // Wait for Scoreboard to funish its comparing test 
        end
        -> done; // Trigger "done" when all stimulus are applied
    endtask

endclass

////////////////////////////////

// Driver
class driver;
    virtual fifo_if fif; // Virtual interface of DUT
    mailbox #(transaction) mbx; // Creates mailbox to recieve data from Generator
    transaction tr; // Defines a transaction
    
    // Initialize Driver instance
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx; // Initialize maibox to recieve information from Generator
    endfunction
    
    // Reset FIFO
    task reset();
        fif.rst <= 1'b1;
        fif.rd <= 1'b0;
        fif.wr <= 1'b0;
        fif.data_in <= 1'b0;
        
        repeat (5) @(posedge fif.clk);
        fif.rst <= 1'b0;
        
        $display("[DRV] : DUT Reset Done");
        $display("-------------------------");
    endtask
    
    // Write data to the FIFO
    task write();
        @(posedge fif.clk);
        fif.rst <= 1'b0;
        fif.rd <= 1'b0;
        fif.wr <= 1'b1;
        fif.data_in <= $urandom_range(1,10); // Randomizing input in range 1-10
        
        @(posedge fif.clk);
        fif.wr <= 1'b0;
        
        $display("[DRV] : DATA WRITE : %0d", fif.data_in);
        @(posedge fif.clk);
    endtask
    
    // Read data from FIFO
    task read();
        @(posedge fif.clk);
        fif.rst <= 1'b0;
        fif.wr <= 1'b0;
        fif.rd <= 1'b1;
        
        
        @(posedge fif.clk);
        fif.rd <= 1'b0;
        
        $display ("[DRV] DATA READ");
        @(posedge fif.clk);
    endtask
    
    // Apply random stimulus to FIFO
    task run();
        forever begin
            mbx.get(tr); // Recieves transaction information from Generator
            // Apply Write or Read operation based on input
            if (tr.oper == 1'b1)
                write();
            else
                read();
        end
    endtask
endclass

////////////////////////////////////

// Monitor
class monitor;
    
    virtual fifo_if fif; // Virtual interface of DUT
    mailbox #(transaction) mbx; // Mailbox for communication with Scoreboard
    transaction tr; // Transaction object for communication
    
    // Initialize Monitor instance
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx; // Initialize mailbox to send data to Scoreboard
    endfunction
    
    // Monitor main
    task run();
        tr = new();
        
        forever begin
            // Capture FIFO output 
            repeat (2) @(posedge fif.clk);
            tr.wr = fif.wr;
            tr.rd = fif.rd;
            tr.data_in = fif.data_in;
            tr.full = fif.full;
            tr.empty = fif.empty;
            
            @(posedge fif.clk);
            tr.data_out = fif.data_out;
            
            mbx.put(tr.copy());
            $display("[MON] : WRITE : %0d, READ : %0d, DATA IN : %0d, DATA OUT : %0d, FULL : %0d, EMPTY : %0d", tr.wr, tr.rd, tr.data_in, tr.data_out, tr.full, tr.empty);
            
        end
    endtask
endclass

/////////////////////////////////////

// Scoreboard
class scoreboard;
    mailbox #(transaction) mbx; // Mailbox for communication
    transaction tr; // Transacion for comminication with Monitor
    event next;
    bit [7:0] din[$]; // Queue to store written data
    bit [7:0] temp; // Temportary data storage
    int err = 0; // Error count
    
    function new(mailbox #(transaction) mbx);
        this.mbx = mbx;
    endfunction
    
    // Scoreboard main
    task run();
        forever begin
            mbx.get(tr); // Receieves transaction information from Monitor
            $display("[MON] : WRITE : %0d, READ : %0d, DATA IN : %0d, DATA OUT : %0d, FULL : %0d, EMPTY : %0d", tr.wr, tr.rd, tr.data_in, tr.data_out, tr.full, tr.empty);
            
            // Checks the Write operation
            if (tr.wr == 1'b1) begin
                if (tr.full == 1'b0) begin
                    din.push_front(tr.data_in);
                    $display("[SCO] : DATA STORED IN QUEUE : %0d", tr.data_in);
                end
                else begin
                    $display("[SCO] : FIFO is full");
                end
                $display("------------------------------");
            end
            
            // Checks the Read operation
            if (tr.rd == 1'b1) begin
                if(tr.empty == 1'b0) begin
                    temp = din.pop_back();
                    
                    if(tr.data_out == temp)
                        $display("[SCO] : DATA MATCH");
                    else begin
                        $error("[SCO] : DATA MISMATCH");
                        err++;
                    end
                end
                else begin
                    $display("[SCO] : FIFO IS EMPTY");
                end
                
                $display("-----------------------------");
            end
            
            -> next;
        end
    endtask
endclass

//////////////////////////////////////

// Environment
class environment;

    generator gen; // Generator instance
    driver drv; // Driver instance
    monitor mon; // Monitor instance
    scoreboard sco; // Scoreboard instance
    
    mailbox #(transaction) gen_drv_mbx; // Generator to Driver mailbox
    mailbox #(transaction) mon_sco_mbx; // Monitor to Scoreboard mailbox
    
    event next_gs; // Event to signal from Generator to Scoreboard
    virtual fifo_if fif; // Virtual interface of DUT
    
    function new(virtual fifo_if fif);
        gen_drv_mbx = new(); // Creates a mailbox for Generator-Driver communication
        mon_sco_mbx = new(); // Creates a mailbox for Monitor-Scoreboard communication
    
        gen = new(gen_drv_mbx); // Initialize the Generator
        drv = new(gen_drv_mbx); // Intialize the Driver
        mon = new(mon_sco_mbx); // Initialize the Monitor
        sco = new(mon_sco_mbx); // Initilize the Scoreboard
    
        this.fif = fif; // Set the virtual interfac for DUT
        drv.fif = this.fif; // Connect the virtual interface to Driver
        mon.fif = this.fif; // Connect the virtual interface to Monitor
    
        gen.next = next_gs; // Set the communication of Generator to Scoreboard
        sco.next = next_gs; // Set the communication of Scoreboard to Generator
    
    endfunction
    
    // Apply all pre run requisites
    task pre_test();
        drv.reset(); // Reset Driver instance
    endtask
    
    task test();
        fork
            gen.run(); // Start Generator
            drv.run(); // Start Driver
            mon.run(); // Start Monitor
            sco.run(); // Start Scoeboard
        join_any
    endtask
    
    task post_test();
        wait(gen.done.triggered); // Wait for Generator o signal completion of stimuli
        $display("--------------------------------------");
        $display("Error count : %0d", sco.err); // Display the count of Mismatched Data comparisons
        $display("----------------------------------------");
        $finish();
    endtask
    
    task run();
        pre_test(); // Run the Pre-Test
        test(); // Run the Test 
        post_test(); // Run the Post-Test cleanup
    endtask
    

endclass

/////////////////////////////////////////


// Testbench Main
module tb();
    fifo_if fif(); // Creates DUT interface
    fifo_top dut(fif.dut); // Creates DUT instance
    
    // Initialize DUT inputs
    initial begin
        fif.clk <= 1'b0;
    end
    
    always #10 fif.clk <= ~fif.clk; // Creates 50 MHz clock signal
    
    environment env; // Creates Environment instance
    
    initial begin
        env = new(fif); // Initialize Environment instance
        env.gen.count = 10; // Set Generator's stimulus count
        env.run(); // Run the Environment
    end
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end
endmodule

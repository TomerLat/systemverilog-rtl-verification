`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

// Transaction
class transaction;
    randc bit [1:0] op_mode; // Write = 0, Read = 1, Random = 2
    rand bit we;
    rand bit strb;
    rand bit [7:0] addr;
    rand bit [7:0] w_data;
    bit [7:0] r_data;
    bit ack;
    
    constraint opmode_c {op_mode >= 0; op_mode < 3;}
    constraint addr_c {addr == 5;}
    constraint wdata_c {w_data > 0; w_data <= 8;}
    
    // Create deep copy of transaction object
    function transaction copy();
        copy = new(); // Create new transaction object
        copy.op_mode = this.op_mode; // Copy operator select mode
        copy.we = this.we; // Copy 'we' flag
        copy.strb = this.strb; // Copy 'strb' flag
        copy.addr = this.addr; // Copy address
        copy.w_data = this.w_data; // Copy write data
        copy.r_data = this.r_data; // Copy read data
        copy.ack = this.ack; // Copy 'ack' flag
    endfunction
    
    function void display(input string tag);
        $display("[%0s] : MODE :%0d WE : %0b STRB : %0b ADDR : %0d WDATA : %0d RDATA : %0d", tag, op_mode, we, strb, addr, w_data, r_data);
    endfunction
endclass

//////////////////////////////////////////////////////////////////////////////////

// Generator
class generator;
    transaction tr; // Transaction object
    mailbox #(transaction) mbx_gen_drv; // Mailbox to communicate with Driver
    event next_drv; // Trigger when Driver finished work
    event next_sco; // Trigger when Scoreboard finished work
    event done; // Trigger when all stimuli requests completed
    int count = 0; // Number of stimuli requests
    
    // Initialize Generator instance
    function new(mailbox #(transaction) mbx_gen_drv);
        this.mbx_gen_drv = mbx_gen_drv; // Initialize mailbox for Generator-Driver communication
        tr = new(); // Create new transaction object
    endfunction
    
    task run();
        for(int i = 0; i < count; i++) begin
            // Try to randomize transaction
            assert(tr.randomize()) else $error("Randomization Failed!");
            $display("------------------------------");
            $display("GEN");
            mbx_gen_drv.put(tr.copy()); // Send transaction copy to Driver through mailbox
            @(next_drv); // Wait for Driver to finish work
            @(next_sco); // Wait for Scoreboard to finish work
        end
        -> done; // Trigger when Generator finished all stimuli requests
    endtask
endclass

//////////////////////////////////////////////////////////////////////////////////

// Driver
class driver;
    virtual wb_if vif; // Virtual interface
    transaction tr; // Transaction object
    mailbox #(transaction) mbx_gen_drv; // Mailbox for Generator-Driver communication
    event next_drv; // Trigger when Driver finish work
    
    // Initialize Driver instance
    function new(mailbox #(transaction) mbx_gen_drv);
        this.mbx_gen_drv = mbx_gen_drv; // Initialize mailbox for Generator-Driver communication
    endfunction
    
    // Reset Driver
    task reset();
        vif.rst   <= 1'b1;
        vif.we    <= 0;
        vif.addr  <= 0;
        vif.w_data <= 0;
        vif.strb  <= 0;
        repeat(10) @(posedge vif.clk);
        vif.rst <= 1'b0;
        repeat(5) @(posedge vif.clk);
        $display("[DRV] : RESET DONE");
    endtask
    
    // Write Data
    task write();
        @(posedge vif.clk);
        $display("[DRV] : DATA WRITE MODE");
        vif.rst   <= 1'b0;
        vif.we    <= 1'b1;
        vif.strb  <= 1'b1;
        vif.addr  <= tr.addr;
        vif.w_data <= tr.w_data;
        @(posedge vif.ack);
        @(posedge vif.clk);
        ->next_drv;
  endtask
  
    // Read Data
    task read();
        @(posedge vif.clk);
        $display("[DRV] : DATA READ MODE");
        vif.rst   <= 1'b0;
        vif.we    <= 1'b0;
        vif.strb  <= 1'b1;
        vif.addr  <= tr.addr;
        @(posedge vif.ack);
        @(posedge vif.clk);
        ->next_drv;
    endtask
   
    // Randomize Driver
    task random();
        @(posedge vif.clk);
        $display("[DRV] : RANDOM MODE");
        vif.rst   <= 1'b0;
        vif.we    <= tr.we;
        vif.strb  <= tr.strb;
        vif.addr  <= tr.addr;
        if(tr.we == 1'b1)
            vif.w_data <= tr.w_data;
        repeat(2)@(posedge vif.clk);
        ->next_drv;
    endtask
    
    // Driver Main
    task run();
        forever begin
            mbx_gen_drv.get(tr);
            if(tr.op_mode == 0) // Write 
                write();  
            else if (tr.op_mode == 1) // Read
                read();
            else if(tr.op_mode == 2) // Randomize
                random();
         end
    endtask
endclass

//////////////////////////////////////////////////////////////////////////////////

// Monitor
class monitor;
    virtual wb_if vif; // Virtual interface
    transaction tr; // Transaction object
    mailbox #(transaction) mbx_mon_sco; // Mailbox for Monitor-Scoreboard communication
    
    // Initialize Monitor instance
    function new( mailbox #(transaction) mbx_mon_sco );
        this.mbx_mon_sco = mbx_mon_sco; // Initialize mailbox for Monitor-Scoreboard communication
  endfunction
  
  // Monitor main
  task run();
    
    tr = new(); // Transaction object
    
    forever begin 
        wait( vif.rst == 1'b0); 
        repeat(5) @(posedge vif.clk);
        @(posedge vif.clk);
        if(vif.strb == 1'b0) begin
            tr.strb = vif.strb;
            repeat(2) @(vif.clk);
            $display("[MON] : STRB IS ZERO");
            mbx_mon_sco.put(tr.copy());  
        end
        else begin
            @(posedge vif.ack);
            tr.we = vif.we;
            tr.strb = vif.strb;
            tr.w_data = vif.w_data;
            tr.addr = vif.addr;
            tr.r_data = vif.r_data; 
            @(posedge vif.clk);
            $display("[MON] : STRB IS VALID");
            mbx_mon_sco.put(tr.copy());  
        end
      end 
  endtask
endclass

//////////////////////////////////////////////////////////////////////////////////

// Scoreboard
class scoreboard;

    transaction tr; // Transaction object
    mailbox #(transaction) mbx_mon_sco; // Mailbox for Monitor-Scoreboard communication
    event next_sco; // Trigger when Scoreboard finished work
    bit [7:0] data[256] = '{default : 0}; // 256-size array to store 8-bit data
    
    //Initialize Scoreboard instance
    function new( mailbox #(transaction) mbx_mon_sco );
        this.mbx_mon_sco = mbx_mon_sco; // Initialize mailbox for Monitor-Scoreboard communication
  endfunction
  
    // Scoreboard main
    task run();
        forever begin
            mbx_mon_sco.get(tr); // Get transaction from Monitor through mailbox
            if(tr.strb == 1'b0)
                $display("[SCO] : INVALID STROBE");
            else begin 
                if(tr.we == 1'b1) begin
                    data[tr.addr] = tr.w_data;
                    $display("[SCO] : DATA WRITE DATA : %0d ADDR : %0d", tr.w_data, tr.addr);
                end  
                else begin
                    if(tr.r_data == 8'h11)
                        $display("[SCO] : DATA MATCHED : DEFAULT VALUE READ");
                     else if (tr.r_data == data[tr.addr])
                        $display("[SCO] : DATA MATCHED DATA : %0d ADDR : %0d", tr.w_data, tr.addr);
                     else
                       $display("[SCO] : DATA MISMATCHED DATA : %0d ADDR : %0d", tr.w_data, tr.addr);
             end
        end
      $display("------------------------------------------");
     ->next_sco; 
   end
  endtask
endclass
//////////////////////////////////////////////////////////////////////////////////

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
    
    virtual wb_if vif; // Virtual Whishbone interface
    
    // Initialize Environment instance
    function new(virtual wb_if vif);
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
        $finish();
    endtask
    
    // Environment main
    task run();
        pre_test();
        test();
        post_test();
    endtask
endclass

//////////////////////////////////////////////////////////////////////////////////


module tb();

    wb_if vif(); // Virtual interface instance
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

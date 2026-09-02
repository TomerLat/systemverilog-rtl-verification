FIFO lab notes

Course FIFO: depth 16, 8-bit data, synchronous (one clock).
Design uses write/read pointers for RAM addresses and a 5-bit occupancy counter for empty / full.



1. DUT idea







Piece



Width



Role





mem[15:0]



8 bits per word



storage





wptr



4 bits



next write address (0..15, wraps)





rptr



4 bits



next read address





cnt



5 bits



number of stored words (0..16)

cnt must be 5 bits. A 4-bit counter cannot hold 16, so full would never go high.

Pointers address the RAM. They are not how this design computes empty/full. Empty/full come from cnt.

Write / read (clocked)

On posedge clk:





reset → wptr, rptr, cnt to 0



else if wr && !full → write mem[wptr], wptr++, cnt++



else if rd && !empty → data_out <= mem[rptr], rptr++, cnt--

if / else if means write and read cannot happen in the same cycle. That is acceptable for this course FIFO.

data_out is a register (assignment is inside the always @(posedge clk)). After a read, the new word is visible on the following sample window, not combinationally.

Empty / full (combinational)

These must sit outside the clocked always:

assign fif.empty = (cnt == 0);
assign fif.full  = (cnt == 16);

assign is a continuous driver. Putting assign inside always @(posedge clk) is the wrong form.

The ternary ? 1'b1 : 1'b0 is optional; the comparison already yields 1 bit.

Because cnt updates on the clock edge, a monitor that samples wr and empty in the same window as the write often still sees old flags (EMPTY=1 on the first write into an empty FIFO). That is expected.



2. Pointers vs counter (why both)





Pointers walk through mem. 4 bits wrap naturally from 15 → 0.



Counter tracks how many words are valid.

A pointer-only FIFO (no cnt) usually uses an extra bit on each pointer:





wr_ptr == rd_ptr → empty



same address bits, different wrap bits → full

This lab does not use that. It uses cnt == 0 / cnt == 16 instead.

Async FIFOs (two clocks) need Gray-coded pointers and synchronizers. This design is single-clock, so binary pointers + cnt are enough.



3. Interface

fifo_if carries clk, rst, wr, rd, data_in, data_out, full, empty.

DUT modport: inputs are control + data_in; outputs are full, empty, data_out.

Testbench classes talk to the DUT through a virtual fifo_if.



4. Testbench structure

generator  --mailbox-->  driver  -->  DUT (fifo_if)
monitor    --mailbox-->  scoreboard
generator  <--event next-->  scoreboard   (pacing only)

There is no generator → scoreboard data mailbox. The scoreboard builds expected data itself from monitored writes (a queue). That is different from the Flip-Flop lab, where the generator sent a reference transaction to the scoreboard.

Transaction





rand bit oper — 1 write, 0 read (50/50 constraint)



data_in is not rand in this lab



Driver creates write data with $urandom_range(1,10) and ignores tr.data_in

copy() clones every field into a new object. Needed because a mailbox stores a handle. Without a copy, the next randomize() or the next monitor sample overwrites the object the consumer still holds.

function transaction copy();
    copy = new();
    copy.oper     = this.oper;
    copy.rd       = this.rd;
    copy.wr       = this.wr;
    copy.data_in  = this.data_in;
    copy.full     = this.full;
    copy.empty    = this.empty;
    copy.data_out = this.data_out;
endfunction

Call it with parentheses: tr.copy().

Generator





tr = new() in new()



each loop: randomize(), mbx.put(tr.copy()), wait @(next)

Driver





reset(): rst high for 5 clocks, controls idle



write() / read(): 3-clock pulse (wr or rd high for one cycle, then low)



run(): get(tr) and branch on tr.oper

Monitor

copy() does not create the working object. You need both:

tr = new();                 // once, before forever
// ... sample wr, rd, data_in, full, empty, then data_out
mbx.put(tr.copy());         // snapshot for the scoreboard

If tr = new() is missing, tr is null and the first tr.wr = ... fails.

Sampling is aligned to the driver’s 3-clock tasks (repeat (2) @(posedge clk) then one more for data_out). Fragile if the driver timing changes.

Scoreboard





wr && !full → din.push_front(data_in)



rd && !empty → pop_back() and compare to data_out



push_front + pop_back is FIFO order



-> next unblocks the generator

data_in on a read transaction is leftover bus data (driver does not clear it). Ignore it on reads.



5. $display format

One format string, six values:

$display("[MON] : WRITE : %0d, READ : %0d, DATA IN : %0d, DATA OUT : %0d, FULL : %0d, EMPTY : %0d",
         tr.wr, tr.rd, tr.data_in, tr.data_out, tr.full, tr.empty);

A split string such as

$display("... DATA OUT : %0d", "FULL : %0d, EMPTY : %0d", tr.wr, ...);

makes the second string the first %0d argument → giant decimal in the WRITE column.

Scoreboard used the same print with a [MON] tag, so each transaction shows two identical “MON” lines. Harmless; only [SCO] is the check.



6. Example run (10 transactions)

Error count : 0







Iters



What



Scoreboard





1–2



read while empty



FIFO IS EMPTY





3–6



write 3, 8, 6, 6



stored





7–10



read



3, 8, 6, 6 — DATA MATCH

First write can still log EMPTY : 1 (pre-update cnt). Next write already has EMPTY : 0.



7. Vivado schematics

RTL schematic (use this to explain the code)

Drawn as operators:





RTL_ADD — wptr+1, rptr+1, cnt+1



RTL_SUB — cnt-1



RTL_MUX — hold vs update (if / else if)



RTL_REG_SYNC — wptr, rptr, cnt, data_out



RTL_RAM — mem



RTL_AND / RTL_INV — wr && !full, rd && !empty



RTL_ROM on empty/full — not a memory; Vivado’s name for the small LUT that implements cnt==0 / cnt==16

Synthesis schematic

Same circuit mapped to FPGA cells: LUT cloud, FF stacks, distributed RAM (blue primitives), IBUF/OBUF.
Bit-blasted and unreadable as a single sheet. Do not use the full synth view as the main figure.



8. Saving figures for GitHub

Do not rely on a screenshot or a full-chip synthesis PDF (often blurry, and GitHub will not preview PDF in the README).

Export from the active schematic window:

write_schematic -format svg -orientation landscape -scope all docs/fifo_rtl.svg

For synthesis, select a few nets (fif.empty, fif.full, or mem) → F4 / Schematic to open only that cone, then:

write_schematic -format svg -orientation landscape -scope visible docs/fifo_flags_synth.svg

Suggested files:

docs/
  notes.md
  fifo_rtl.svg              # main figure
  fifo_flags_synth.svg      # optional cone

README snippet:

## FIFO RTL schematic
![RTL](docs/fifo_rtl.svg)

Use SVG (or a zoomed PNG of a cone). Scope all for the RTL sheet, visible for a cropped cone.



9. Checklist before a re-run





[ ] assign empty/full outside the always



[ ] cnt is [4:0]



[ ] copy() on transaction



[ ] generator: mbx.put(tr.copy())



[ ] monitor: tr = new() once and mbx.put(tr.copy())



[ ] $display is a single format string



[ ] no extra gen→sco transaction mailbox unless the generator owns data_in

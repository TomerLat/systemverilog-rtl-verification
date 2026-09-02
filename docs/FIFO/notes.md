# Synchronous FIFO

## Behavior
```
| wr | rd | full | empty | Action              |
| -- | -- | ---- | ----- | ------------------- |
| 1  | x  | 0    | x     | Write mem[wptr]     |
| x  | 1  | x    | 0     | Read  mem[rptr]     |
| 1  | x  | 1    | x     | Hold (write ignored)|
| x  | 1  | x    | 1     | Hold (read ignored) |
```

Depth 16, data width 8. First word written is first word read.

## Implementation Notes
- Synchronous design using `always @(posedge fif.clk)`
- Interface + modport used for clean connection
- `wptr` / `rptr` [3:0] address the RAM; `cnt` [4:0] tracks occupancy (0..16)
- `empty` / `full` are continuous assigns from `cnt == 0` / `cnt == 16` (outside the `always`)
- Write and read are `if` / `else if`, so they do not happen in the same cycle

## Testbench
- Layered testbench (Generator → Driver → Monitor → Scoreboard)
- Self-checking Scoreboard with a queue as the reference model
- `transaction.copy()` used on Generator→Driver and Monitor→Scoreboard puts
- First write can still sample `empty = 1` (counter updates on the clock edge); DUT behavior is correct

## Files
- RTL: `rtl/fifo.sv`
- Testbench: `tb/fifo_testbench.sv`

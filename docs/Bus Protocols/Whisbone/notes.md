# Wishbone Slave (classic, simplified)

Wishbone is a simple public-domain on-chip bus.
This lab is one slave: a 256 x 8-bit register file.

No `cyc`, no `sel`, no `err` / `rty`. A transfer is valid when `strb && ack`.
Same idea as APB `PSEL`/`PENABLE`/`PREADY`, with fewer names.

## Signals

Master (Driver) drives `clk`, `rst`, `we`, `strb`, `addr`, `w_data`.
Slave (`top`) drives `r_data` and `ack`.

```
| Signal | Dir (slave) | Purpose                                      |
| ------ | ----------- | -------------------------------------------- |
| clk    | in          | Bus clock                                    |
| rst    | in          | Active-high reset. FSM -> idle, mem = 8'h11  |
| addr   | in          | 8-bit address (0..255)                       |
| we     | in          | 1 = write, 0 = read                          |
| strb   | in          | Strobe. 1 = this cycle is a real transfer    |
| w_data | in          | 8-bit write data                             |
| r_data | out         | 8-bit read data                              |
| ack    | out         | Slave done. Master samples when ack is 1     |
```

Handshake:

```
transfer completes when strb && ack
```

If `strb` is 0, the slave stays in `check_mode` and does not ACK.

## Behavior

```
| strb | we | What happens                            |
| ---- | -- | --------------------------------------- |
| 0    | x  | Idle / wait. ack = 0                    |
| 1    | 1  | Write: mem[addr] = w_data, then ack     |
| 1    | 0  | Read:  r_data = mem[addr], then ack     |
```

```
         request           ack
strb    ________/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\________
ack     ________________/¯¯¯¯¯¯¯¯\________
addr    --------<   stable       >--------
we      --------<   1 or 0       >--------
w_data  --------< write data     >--------   (write)
r_data  --------------------< rd >--------   (read)
```

This copy uses three clocks after reset-idle: `idle` → `check_mode` → `write`/`read` (ack) → `idle`.

## Implementation Notes

- One `wb_if`. DUT modport: master pins in, `r_data` / `ack` out.
- FSM: `idle`, `check_mode`, `write`, `read`.
  - `idle`: drop `ack` / `r_data`, go to `check_mode`.
  - `check_mode`: if `strb && we` → write; if `strb && !we` → latch `temp = mem[addr]`, go read; else stay.
  - `write`: `mem[addr] = w_data`, `ack = 1`, back to idle.
  - `read`: `r_data = temp`, `ack = 1`, back to idle.
- Sequential block:

```
if (rst) state <= idle;
else     state <= next_state;
```

  Without the `else`, reset is overwritten every clock.

- Init `mem[i] = 8'h11` **only on reset**. Do not refill memory in `idle`. Idle runs after every transfer, so a write would be erased and every read would look like “default 8'h11.”

## Testbench

- Layered TB: Generator → Driver → Monitor → Scoreboard.
- `op_mode`: 0 = write, 1 = read, 2 = random (`we` / `strb` as randomized).
- Driver constructor must be `this.mbx_gen_drv = mbx_gen_drv`. Assigning `this.mbx_gen_drv = this.mbx_gen_drv` leaves a null mailbox and crashes on `get`.
- `w_data` in the transaction must be `rand bit [7:0]`. `rand bit w_data` is 1-bit, so every write is `0` or `1`.
- This copy pins `addr == 5`.
- Monitor: `strb == 0` → “STRB IS ZERO” / scoreboard “INVALID STROBE”. `strb == 1` → wait `ack`, then sample.
- Scoreboard mirror `data[256]`.
  - Write: `data[addr] = w_data`.
  - Read: if `r_data == 8'h11` and nothing was stored yet → default match; else compare `r_data` to `data[addr]`.
  - Print `tr.r_data` on a read match, not `tr.w_data` (that field is leftover random data).

## Files

- RTL: `rtl/wishbone.sv` (or your design filename)
- Testbench: `tb/wishbone_testbench.sv`
- Notes: `docs/Wishbone/notes.md`

# APB Slave

APB (Advanced Peripheral Bus) is a simple parallel bus for slow peripherals.
This lab is one slave: a 16 x 8-bit register file.

Unlike UART / SPI / I2C, a transfer is a whole address + data word, not a bit stream.

## Signals

Master (testbench Driver) drives most pins. Slave (`top`) drives the last three.

```
| Signal     | Dir (slave) | Purpose                                              |
| ---------- | ----------- | ---------------------------------------------------- |
| p_clk      | in          | Bus clock. Everything is sampled on the rising edge  |
| p_reset_n  | in          | Active-low reset. FSM goes to idle                   |
| p_addr     | in          | Register address. This slave uses 0..15              |
| p_sel      | in          | Slave select. 1 = this slave is being talked to      |
| p_enable   | in          | Access phase. 1 = setup is done, transfer is live    |
| p_write    | in          | 1 = write, 0 = read                                  |
| p_w_data   | in          | 8-bit write data (ignored on a read)                 |
| p_r_data   | out         | 8-bit read data from mem[p_addr]                     |
| p_ready    | out         | 1 = slave finished this cycle (no extra wait)        |
| p_slv_err  | out         | 1 = bad address / data during an access              |
```

`p_sel` alone is the **setup** phase (address and control are valid).
`p_sel && p_enable` is the **access** phase (data moves).
A transfer is complete only when `p_sel && p_enable && p_ready`.

## Behavior

```
| p_sel | p_enable | p_write | What happens                         |
| ----- | -------- | ------- | ------------------------------------ |
| 0     | 0        | x       | Idle. p_ready = 0, p_r_data = 0      |
| 1     | 0        | 1       | Setup write. Latch addr + p_w_data   |
| 1     | 1        | 1       | Access write. Store mem[addr]        |
| 1     | 0        | 0       | Setup read. Latch addr               |
| 1     | 1        | 0       | Access read. Drive p_r_data          |
```

Minimum transfer is 2 clocks: setup, then access. Then back to idle.

```
         Setup          Access
p_sel   ________/¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\________
p_enable________________/¯¯¯¯¯¯¯¯\________
p_addr  --------<   stable       >--------
p_write --------<   1 or 0       >--------
p_w_data--------< write data     >--------   (writes)
p_r_data--------------------< rd >--------   (reads)
p_ready --------------------/¯¯¯¯\--------
```

## Implementation Notes

- One `apb_if`. DUT modport: inputs are master pins, outputs are `p_r_data`, `p_ready`, `p_slv_err`.
- `top` FSM: `idle`, `write`, `read`. Sequential block updates `state`. Combo block computes `n_state` and the outputs.
- Memory is `reg [7:0] mem[16]`. Write stores `p_w_data` at `mem[p_addr]`. Read drives `mem[p_addr]` onto `p_r_data`.
- `addr_err` if `p_addr > 15` during a transfer. `addv_err` / `data_err` flag “invalid” address / write data (`>= 0` check in this copy, so they stay 0 for unsigned vectors).
- Drive `vif.p_slv_err`, not a bare `p_slv_err`. A plain `assign p_slv_err = ...` is a different net and the interface pin stays undriven.

## Testbench

- Layered TB: Generator → Driver → Monitor → Scoreboard.
- Generator randomizes `p_addr` / `p_w_data` / `p_write`, `put`s a `copy()` to the Driver, then waits `next_drv` and `next_sco`.
- Constraints in this lab: `p_addr` 0..15, `p_w_data` 0..255. Error cases are not generated.
- Driver does the 2-cycle protocol: clock 1 raise `p_sel` with `p_enable = 0`, clock 2 raise `p_enable`, clock 3 drop both.
- Monitor samples when `p_ready` is high, then `put`s a `copy()` to the Scoreboard.
- Scoreboard keeps `bit [7:0] p_w_data[16]` as a mirror of `mem`.
  - Good write (`p_write && !p_slv_err`): store the byte.
  - Good read (`!p_write && !p_slv_err`): compare `p_r_data` to the mirror.
  - Do **not** store on `p_write && p_slv_err` — that skips real writes and later reads mismatch.

## Files

- RTL: `rtl/apb.sv` (or your design filename)
- Testbench: `tb/apb_testbench.sv`
- Notes: `docs/APB/notes.md`

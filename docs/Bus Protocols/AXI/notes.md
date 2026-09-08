# AXI Slave (simple / Lite-style)

AXI (Advanced eXtensible Interface) is a high-speed parallel bus.
This lab is one slave: a 128 x 32-bit register file.

Not full AXI4. No burst, no ID, no `WLAST` / `RLAST`, one beat per transfer.
Think: APB idea (one address, one data) with a `VALID`/`READY` handshake on each channel.

## Channels

Write path:

```
AW (address) -> W (data) -> B (response)
```

Read path:

```
AR (address) -> R (data + response)
```

Reads and writes use different pins, so they can run at the same time on a full AXI slave.
This FSM does **one** thing at a time: idle picks either `aw_valid` or `ar_valid`.

## Signals

Master (Driver) drives `*_valid`, addresses, `w_data`, `b_ready`, `r_ready`.
Slave (`top`) drives `*_ready`, `b_*`, `r_*`.

```
| Signal    | Dir (slave) | Channel | Purpose                                      |
| --------- | ----------- | ------- | -------------------------------------------- |
| clk       | in          | all     | Bus clock                                    |
| reset_n   | in          | all     | Active-low reset. FSM -> idle, mem cleared   |
| aw_valid  | in          | AW      | Master has a write address                   |
| aw_addr   | in          | AW      | Write address (this slave: 0..127 valid)     |
| aw_ready  | out         | AW      | Slave accepted the write address             |
| w_valid   | in          | W       | Master has write data                        |
| w_data    | in          | W       | 32-bit write data                            |
| w_ready   | out         | W       | Slave accepted the write data                |
| b_valid   | out         | B       | Slave has a write response                   |
| b_resp    | out         | B       | 2'b00 OKAY, non-zero = error                 |
| b_ready   | in          | B       | Master accepted the write response           |
| ar_valid  | in          | AR      | Master has a read address                    |
| ar_addr   | in          | AR      | Read address                                 |
| ar_ready  | out         | AR      | Slave accepted the read address              |
| r_valid   | out         | R       | Slave has read data                          |
| r_data    | out         | R       | 32-bit read data                             |
| r_resp    | out         | R       | 2'b00 OKAY, 2'b11 decode error in this lab   |
| r_ready   | in          | R       | Master accepted the read data                |
```

Handshake on every channel:

```
beat transfers when VALID && READY  (sampled on clk)
```

Do not change the payload while `VALID` is 1 and `READY` is still 0.

## Behavior

```
| Channel ready | What the slave just accepted     |
| ------------- | -------------------------------- |
| aw_ready      | Latched aw_addr                  |
| w_ready       | Latched w_data                   |
| b_valid       | Write done (or write error)      |
| ar_ready      | Latched ar_addr                  |
| r_valid       | Read data (or read error)        |
```

Write, in order:

1. Master raises `aw_valid` + `aw_addr`. Slave pulses `aw_ready`, stores `w_addr`.
2. Master raises `w_valid` + `w_data`. Slave pulses `w_ready`, stores `w_data`.
3. If `w_addr < 128`, slave writes `mem[w_addr]`, then `b_valid` + `b_resp = 00`.
4. If address is out of range, `b_valid` + error resp. No store.
5. Master raises `b_ready`. Slave returns to idle.

Read, in order:

1. Master raises `ar_valid` + `ar_addr`. Slave pulses `ar_ready`, stores `r_addr`.
2. If `r_addr < 128`, slave reads `mem[r_addr]` (this copy waits 2 clocks in `gen_data`).
3. Slave raises `r_valid` + `r_data` + `r_resp = 00`.
4. If address is out of range, `r_valid` + `r_data = 0` + `r_resp = 11`.
5. Master raises `r_ready`. Slave returns to idle.

## Implementation Notes

- One `axi_if`. DUT modport: master pins in, slave pins out.
- FSM states: `idle`, `send_w_addr_ack`, `send_w_data_ack`, `update_mem`, `send_wr_resp`, `send_wr_err`, `send_r_addr_ack`, `gen_data`, `send_rd_err`.
- Memory is `reg [31:0] mem[128]`. Reset clears it to 0.
- `idle` prefers a write if `aw_valid` is high (`if aw_valid ... else if ar_valid`).
- Address check is `addr < 128`. This lab’s constraint pins both addresses to `1`, so the error path is not hit unless you open the range.
- Use non-blocking `<=` on outputs inside the clocked `always`. A blocking `vif.ar_ready = 0` in `send_r_addr_ack` is inconsistent with the rest of the FSM.

## Testbench

- Layered TB: Generator → Driver → Monitor → Scoreboard.
- Three mailboxes: `gen→drv`, `drv→mon`, `mon→sco`. All three must be `new()` in `environment`. A missing `mbx_drv_mon = new()` is a null-handle crash on `put`.
- Generator `put`s a `copy()`, then waits `next_sco`.
- Driver `write_data`: pulse AW, then W, then wait B. `read_data`: pulse AR, then wait R.
- Monitor must wait **B** on a write (`b_valid`) and **R** on a read (`r_valid`). Waiting on `b_valid` during a read hangs the sim.
- Scoreboard `run` must be `forever`. One `get` and the task exits → Generator waits `next_sco` forever and `$finish` never runs.
- Scoreboard keeps `bit [31:0] data[128]`.
  - Good write (`b_resp` not error): `data[aw_addr] = w_data`.
  - Good read: compare `r_data` to `data[ar_addr]` (load `temp` from that slot first). Comparing to an unused `temp` (always 0) looks like a mismatch on every real read.

Constraints in this copy: `aw_addr == 1`, `ar_addr == 1`, `w_data < 12`.

## Files

- RTL: `rtl/axi.sv` (or your design filename)
- Testbench: `tb/axi_testbench.sv`
- Notes: `docs/AXI/notes.md`

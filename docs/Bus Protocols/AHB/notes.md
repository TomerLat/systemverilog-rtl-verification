# AHB-Lite Slave

AHB (Advanced High-performance Bus) is ARM’s mid-range AMBA bus.
This lab is one slave: a 256 x 8-bit memory, word/half/byte beats, all burst types.

Unlike APB / Wishbone, address and data are **pipelined**. The address of beat N is on the bus one clock before its data. The slave must latch the address and use that copy in the data phase.

This copy is AHB-Lite style: one master, no arbiter.

## Signals

Master (Driver) drives most pins. Slave (`top`) drives `h_r_data`, `h_ready`, `h_resp`.

```
| Signal    | Dir (slave) | Purpose                                          |
| --------- | ----------- | ------------------------------------------------ |
| clk       | in          | Bus clock                                        |
| h_reset_n | in          | Active-low reset                                 |
| h_sel     | in          | This slave is selected                           |
| h_addr    | in          | Address (address phase). Driver may hold start   |
| h_write   | in          | 1 = write, 0 = read                              |
| h_trans   | in          | Transfer type (see below)                        |
| h_size    | in          | Beat width: 000 byte, 001 half, 010 word         |
| h_burst   | in          | SINGLE / INCR / WRAP4 / INCR4 / ... / INCR16     |
| h_w_data  | in          | Write data (data phase)                          |
| h_r_data  | out         | Read data (data phase)                           |
| h_ready   | out         | 1 = this data phase finished                     |
| h_resp    | out         | 00 OKAY, 01 ERROR (addr >= 256 in this lab)      |
```

This file also uses `next_addr` / `ret_addr` as **lab helpers** (current beat address / address after this beat). They are not AMBA pins. The Monitor reads `next_addr` so the Scoreboard stores the right location. If the DUT does not drive `vif.next_addr`, peek it from the TB:

```
assign vif.next_addr = ahb_dut.next_addr;
```

Use the instance name from `top ahb_dut(vif);`. Do not also drive `vif.next_addr` from the DUT if that assign exists.

## HTRANS (this lab’s encoding)

```
| Define   | Value | Meaning                |
| -------- | ----- | ---------------------- |
| NON_SEQ  | 2'd0  | First beat of a burst  |
| SEQ      | 2'd1  | Following beat         |
| BUSY     | 2'd2  | Pause (not used here)  |
| IDLE     | 2'd3  | No transfer            |
```

Real AMBA is IDLE=00, BUSY=01, NONSEQ=10, SEQ=11. This lab is internally consistent: Driver first beat `2'b00`, later beats `2'b01`. Do not mix in the spec numbers unless you change both DUT and TB.

A beat is real when `h_sel && (h_trans is NON_SEQ or SEQ)` and the slave raises `h_ready`.

## Bursts (`h_burst`)

```
| h_burst | Name    | Beats |
| ------- | ------- | ----- |
| 000     | SINGLE  | 1     |
| 001     | INCR    | unspec (this copy caps at 32 / u_len) |
| 010     | WRAP4   | 4     |
| 011     | INCR4   | 4     |
| 100     | WRAP8   | 8     |
| 101     | INCR8   | 8     |
| 110     | WRAP16  | 16    |
| 111     | INCR16  | 16    |
```

INCR: address goes up by the beat size each time (byte +1, half +2, word +4).  
WRAP: same step, then fold back when `(addr + 1) % boundary == 0`.  
`boundary()` in this copy is `beats * 1/2/3` by `h_size`. For WRAP16 + word that is 48, so a start of 5 walks `5,9,…,45,1,5,…`.

This lab’s constraints often pin `h_burst == 6` (WRAP16) and `h_addr == 5`.

## FSM

States: `idle` → `check_mode` → `addr_decode` → `write` / `read` → back to `check_mode` for the next beat, or `idle` when the burst length is done.

- `idle`: drop `h_ready`, clear `len_count`.
- `check_mode`: need `h_reset_n && h_sel`. `h_addr >= 256` → `h_resp = ERROR`, idle. Else `addr_decode`.
- `addr_decode`: `NON_SEQ` latches `next_addr = h_addr`. `SEQ` takes `next_addr` from the previous `ret_addr`.
- `write` / `read`: pick a helper by `h_burst` (`single_tr`, `incr_wr`, `wrap_wr`, …), pulse `h_ready`, bump `len_count`.

Memory is `reg [7:0] mem[256]`, reset/init default `12` (`8'h0c`). A word write stores four bytes little-endian.

DUT port must be `module top(ahb_if.dut vif);` — not `apb_if`. TB is `ahb_if vif(); top ahb_dut(vif);`.

## Testbench

- Layered TB: Generator → Driver → Monitor → Scoreboard.
- Extra mailbox `mbx_gen_mon` carries `u_len` for unspecified INCR.
- Driver has one task per burst × write/read. First beat `h_trans = 00`, later beats `01`. Wait `posedge h_ready` each beat.
- Use the **same names** as `ahb_if` (`h_w_data`, `h_burst`, `h_trans`, `h_r_data`). `vif.hwdata` / `vif.hburst` / `tr.hrdata` will not compile.
- Events: `-> next_drv` (not `drvnext`). Scoreboard event must be the one connected in `environment` (`next_sco`).
- Monitor samples `vif.next_addr` as the beat address. If that pin stays 0, every write lands on `data[0]` and reads mismatch.
- Scoreboard mirror `data[256]` default 12. Write stores 4 bytes at `tr.h_addr`. Read packs those 4 bytes and compares to `h_r_data`. `32'h0c0c0c0c` is “never written.”
- Driver `$display` often prints data in the ADDR field (`ADDR : 9 DATA : 5` means data=9, start addr=5).
- `wrap16_rd` may still print `WRAP4 DATA READ`. Ignore the string; `h_burst` is what matters.

## Files

- RTL: `rtl/ahb.sv` (or your design filename)
- Testbench: `tb/ahb_testbench.sv`
- Notes: `docs/AHB/notes.md`

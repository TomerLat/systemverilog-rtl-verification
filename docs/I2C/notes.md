# I2C Master + Slave

## Behavior
```
| newd | op | What happens                                      |
| ---- | -- | ------------------------------------------------- |
| 1    | 0  | Master write: START, addr+W, ACK, data, ACK, STOP |
| 1    | 1  | Master read:  START, addr+R, ACK, data, NACK, STOP|
```

7-bit address + 1 R/W bit (`op`: 0 = write, 1 = read). Data is 8 bits, **MSB first**. ACK is SDA low. Master ends a 1-byte read with NACK (SDA high).

`scl` / `sda` are the bus. `newd`, `addr`, `op`, `din`, `dout`, `done` are the parallel “CPU” side of the **master only**.

## Wires
- `scl` — master output. Slave only samples it.
- `sda` — shared, open-drain. Drive `0` or release `Z`. `tri1 sda` in the interface is the pull-up (released line reads as `1`).
- Master: `assign m.sda = (sda_en && !sda_t) ? 1'b0 : 1'bz;`
- Slave: same rule. Do not drive `1`. Do not pull `0` whenever `sda_en` is set.

## Frame
```
START | A6..A0 R/W | ACK | D7..D0 | ACK/NACK | STOP
```
START: SDA falls while SCL is high.  
STOP:  SDA rises while SCL is high.  
Data bits change only while SCL is low.

## Implementation Notes
- One `i2c_if`. Master modport owns `newd/addr/op/din/dout/done/busy/ack_err/scl`. Slave modport is only `clk, rst, scl, sda`.
- Slave has a 128-byte `mem`, reset to `mem[i] = i`. Writes store a byte; reads send `mem[addr]`.
- Bit timing is a **4-phase counter** (`pulse` 0..3 over `clk_count4 = sys_freq/i2c_freq` system clocks). Typical use: pulse 0–1 SCL low (set SDA), pulse 2–3 SCL high (sample SDA).
- Master and slave each have their own `pulse` / `count1`. They do **not** start on the same `newd`. That is why a slave sample of `count1 == 200` often misses the address (`r_addr` stuck at `0`/`1`/`ff`).
- Sampling address on **rising `s.scl`** (using delayed `scl_t`) is more reliable than the slave’s own `count1`.
- `top` is just `I2C_master(vif.master)` + `I2C_slave(vif.slave)`. No extra assigns.

## Testbench
- Layered TB (Generator → Driver → Monitor → Scoreboard).
- Driver pulses `newd`, sets `op/addr/din`, waits `posedge vif.done`.
- Scoreboard keeps a copy of `mem`. Writes update the model; reads compare `vif.dout` to `mem[addr]`.
- `transaction.copy()` must fill the new object.
- Only the **master** should drive `done` / `dout`. If the slave also drives them, `dout` becomes `z`.
- SCO “MATCHED 0 vs 0” with `DATA OUT : z` is not a real pass.

## Known gaps in this lab copy
- Slave address capture vs master bit times is still fragile if you sample on the slave `pulse` counter.
- First transfer may never print `[SLV]` (`detect_stop` not reached).
- Writes can show `ack_err=1` while the TB still logs “DATA STORED” from parallel pins, not from SDA.

## Files
- RTL: `rtl/i2c.sv` (or your design filename)
- Testbench: `tb/i2c_testbench.sv`

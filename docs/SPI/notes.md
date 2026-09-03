# SPI Master + Slave

## Behavior
```
| cs | newd | What happens                          |
| -- | ---- | ------------------------------------- |
| 1  | x    | Idle — slave does not sample          |
| 0  | 1    | Master starts a 12-bit send on MOSI   |
| 0  | 0    | Bits shift on each rising s_clk       |
```

One direction only: master → slave on `mosi` (LSB first). No MISO in this design.

`cs` is active-low select (`1` = idle, `0` = transfer). It is not write vs read.

## Implementation Notes
- One `spi_if`; two modports: `master` and `slave`
- `top` takes `spi_if sif` and connects `sif.master` / `sif.slave`
- `clk` = fast system clock. `s_clk` = SPI bit clock (toggled every 10 `clk` cycles, ~20× slower)
- Slave FSM runs on `s_clk`, not `clk` — an off-chip slave would never see `clk`
- Master states used: `idle`, `send`. Slave states: `detect_start`, `read_data`
- When `cs` goes low, slave shifts `{mosi, temp[11:1]}` for 12 `s_clk` edges, then pulses `done`

## Testbench
- Layered TB (Generator → Driver → Monitor → Scoreboard)
- Driver puts expected `data_in` on `mbx_drv_sco`; monitor puts observed `data_out` on `mbx_mon_sco`
- Scoreboard `get`s both, compares, then `-> sco_next` so the generator sends the next word
- `transaction.copy()` on generator `put`
- TB drives `sif.*` (not `dut.m1.s_clk`)

## Files
- RTL: `rtl/spi.sv` (or your design filename)
- Testbench: `tb/spi_testbench.sv`

# SystemVerilog RTL + Verification

This repository contains my personal projects while learning **SystemVerilog** for digital design and verification.

I focus on writing clean RTL together with structured testbenches (Generator, Driver, Monitor, Scoreboard).

---

## Done

For each finished design you will find:

* RTL code
* Layered testbench
* Waveforms
* Notes / schematic (when available)

### Flip-Flops

* **T Flip-Flop**
* **SR Flip-Flop** 
* **JK Flip-Flop** 

### FIFO

Synchronous FIFO, depth 16, 8-bit data. Write/read pointers address the RAM; a 5-bit occupancy counter generates `empty` / `full`.

---

## Next

### Serial protocols

* UART
* SPI
* I2C

### Bus protocols

* APB
* AHB
* AXI
* ACE
* Wishbone

---

## Repository Structure
| Path | Contents |
|---|---|
| `rtl/` | Design files (`.sv`) |
| `tb/` | Testbench files |
| `docs/` | Waveforms, schematics, notes |
| `README.md` | This file |

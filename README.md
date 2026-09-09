# SystemVerilog RTL + Verification

This repository contains my personal projects while learning **SystemVerilog** for digital design and verification.

I focus on writing clean RTL together with structured testbenches (Generator, Driver, Monitor, Scoreboard).

The list below is complete for now. I may add more designs later.

---

## Done

For each finished design you will find:

* RTL code
* Layered testbench
* Waveforms
* Notes / schematic (when available)

### Flip-Flops

* **T Flip-Flop** — [rtl/FlipFlops](rtl/FlipFlops) · [tb/Flip Flops](tb/Flip%20Flops) · [docs/t_ff](docs/t_ff)
* **SR Flip-Flop** — [rtl/FlipFlops](rtl/FlipFlops) · [tb/Flip Flops](tb/Flip%20Flops) · [docs/sr_ff](docs/sr_ff)
* **JK Flip-Flop** — [rtl/FlipFlops](rtl/FlipFlops) · [tb/Flip Flops](tb/Flip%20Flops) · [docs/jk_ff](docs/jk_ff)

Group folder: [docs/Flip Flops](docs/Flip%20Flops)

### FIFO

Synchronous FIFO, depth 16, 8-bit data. Write/read pointers address the RAM; a 5-bit occupancy counter generates `empty` / `full`.

[rtl/FlipFlops](rtl/FlipFlops) · [tb/Flip Flops](tb/Flip%20Flops) · [docs/FIFO](docs/FIFO)

### Serial protocols

* **SPI** — [rtl/Serial Protocols](rtl/Serial%20Protocols) · [tb/Serial Protocols](tb/Serial%20Protocols) · [docs/SPI](docs/SPI)
* **UART** — [rtl/Serial Protocols](rtl/Serial%20Protocols) · [tb/Serial Protocols](tb/Serial%20Protocols) · [docs/UART](docs/UART)
* **I2C** — [rtl/Serial Protocols](rtl/Serial%20Protocols) · [tb/Serial Protocols](tb/Serial%20Protocols) · [docs/I2C](docs/I2C)

### Bus protocols

* **APB** — [rtl/Bus Protocols](rtl/Bus%20Protocols) · [tb/Bus Protocols](tb/Bus%20Protocols) · [docs/Bus Protocols/APB](docs/Bus%20Protocols/APB)
* **AXI** — [rtl/Bus Protocols](rtl/Bus%20Protocols) · [tb/Bus Protocols](tb/Bus%20Protocols) · [docs/Bus Protocols/AXI](docs/Bus%20Protocols/AXI)
* **AHB** — [rtl/Bus Protocols](rtl/Bus%20Protocols) · [tb/Bus Protocols](tb/Bus%20Protocols) · [docs/Bus Protocols/AHB](docs/Bus%20Protocols/AHB)
* **Wishbone** — [rtl/Bus Protocols](rtl/Bus%20Protocols) · [tb/Bus Protocols](tb/Bus%20Protocols) · [docs/Bus Protocols/Whisbone](docs/Bus%20Protocols/Whisbone)

---

## Repository structure

```
├── rtl/
│   ├── FlipFlops/           # T, SR, JK, FIFO
│   ├── Serial Protocols/    # SPI, UART, I2C
│   └── Bus Protocols/       # APB, AXI, AHB, Wishbone
├── tb/
│   ├── Flip Flops/          # T, SR, JK, FIFO
│   ├── Serial Protocols/    # SPI, UART, I2C
│   └── Bus Protocols/       # APB, AXI, AHB, Wishbone
├── docs/
│   ├── Flip Flops/, t_ff/, sr_ff/, jk_ff/, FIFO/
│   ├── SPI/, UART/, I2C/
│   └── Bus Protocols/       # APB, AXI, AHB, Whisbone
└── README.md
```

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

* **T Flip-Flop** — [rtl/FlipFlops](rtl/FlipFlops) · [tb/FlipFlops](tb/FlipFlops)
* **SR Flip-Flop** — [rtl/FlipFlops](rtl/FlipFlops) · [tb/FlipFlops](tb/FlipFlops) · [docs/SR_FF](docs/SR_FF)
* **JK Flip-Flop** — [rtl/FlipFlops](rtl/FlipFlops) · [tb/FlipFlops](tb/FlipFlops) · [docs/JK_FF](docs/JK_FF)

### FIFO

Synchronous FIFO, depth 16, 8-bit data. Write/read pointers address the RAM; a 5-bit occupancy counter generates `empty` / `full`.

[rtl/FlipFlops](rtl/FlipFlops) · [tb/FlipFlops](tb/FlipFlops) · [docs/FIFO](docs/FIFO)

### Serial protocols

* **SPI** — [rtl/Serial Protocols](rtl/Serial%20Protocols) · [tb/Serial Protocols](tb/Serial%20Protocols) · [docs/SPI](docs/SPI)
* **UART** — [rtl/Serial Protocols](rtl/Serial%20Protocols) · [tb/Serial Protocols](tb/Serial%20Protocols) · [docs/UART](docs/UART)
* **I2C** — [rtl/Serial Protocols](rtl/Serial%20Protocols) · [tb/Serial Protocols](tb/Serial%20Protocols) · [docs/I2C](docs/I2C)

### Bus protocols

* **APB** — [rtl/Bus Protocols](rtl/Bus%20Protocols) · [tb/Bus Protocols](tb/Bus%20Protocols) · [docs/APB](docs/APB)
* **AXI** — [rtl/Bus Protocols](rtl/Bus%20Protocols) · [tb/Bus Protocols](tb/Bus%20Protocols) · [docs/AXI](docs/AXI)
* **AHB** — [rtl/Bus Protocols](rtl/Bus%20Protocols) · [tb/Bus Protocols](tb/Bus%20Protocols) · [docs/AHB](docs/AHB)
* **Wishbone** — [rtl/Bus Protocols](rtl/Bus%20Protocols) · [tb/Bus Protocols](tb/Bus%20Protocols) · [docs/Wishbone](docs/Wishbone)

---

## Repository structure

```
├── rtl/
│   ├── FlipFlops/           # T, SR, JK, FIFO
│   ├── Serial Protocols/    # SPI, UART, I2C
│   └── Bus Protocols/       # APB, AXI, AHB, Wishbone
├── tb/
│   ├── FlipFlops/           # T, SR, JK, FIFO
│   ├── Serial Protocols/    # SPI, UART, I2C
│   └── Bus Protocols/       # APB, AXI, AHB, Wishbone
├── docs/
│   ├── JK_FF/, SR_FF/, FIFO/
│   ├── SPI/, UART/, I2C/
│   └── APB/, AXI/, AHB/, Wishbone/
└── README.md
```

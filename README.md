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

* **T Flip-Flop** — [rtl/Flip Flops](rtl/Flip%20Flops) · [tb/Flip Flops](tb/Flip%20Flops)
* **SR Flip-Flop** — [rtl/Flip Flops](rtl/Flip%20Flops) · [tb/Flip Flops](tb/Flip%20Flops)
* **JK Flip-Flop** — [rtl/Flip Flops](rtl/Flip%20Flops) · [tb/Flip Flops](tb/Flip%20Flops)

### FIFO

Synchronous FIFO, depth 16, 8-bit data. Write/read pointers address the RAM; a 5-bit occupancy counter generates `empty` / `full`.

Notes: [docs/notes.md](docs/notes.md)

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
│   ├── Flip Flops/          # T, SR, JK
│   ├── Serial Protocols/    # SPI, UART, I2C
│   └── Bus Protocols/       # APB, AXI, AHB, Wishbone
├── tb/
│   ├── Flip Flops/
│   ├── Serial Protocols/
│   └── Bus Protocols/
├── docs/                    # notes, waveforms, schematics
│   ├── SPI/, UART/, I2C/
│   ├── APB/, AXI/, AHB/, Wishbone/
│   └── notes.md             # FIFO
└── README.md
```

FIFO RTL / TB sit with the serial or top-level files if they were not moved into one of the three folders.

---

Same TB pattern on every lab: Generator → Driver → Monitor → Scoreboard, with `transaction.copy()` on mailbox `put`.

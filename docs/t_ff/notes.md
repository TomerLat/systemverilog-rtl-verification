# T Flip-Flop

## Behavior
- `t = 0` → Hold previous value of Q
- `t = 1` → Toggle Q (`Q = ~Q`)
- Synchronous reset: when `rst = 1`, Q is forced to 0

## Implementation Notes
- Designed with SystemVerilog using `always_ff`
- Uses an interface with modport for clean connection
- Synchronous reset

## Testbench
- Layered testbench architecture:
  - Generator
  - Driver
  - Monitor
  - Scoreboard
- Includes a simple reference model in the Scoreboard
- Self-checking (compares actual vs expected Q)

## Files
- RTL: `rtl/t_ff.sv`
- Testbench: `tb/t_ff_testbench.sv`

# SR Flip-Flop

## Behavior
- `set=1, rst=0` → Q = 1 (Set)
- `set=0, rst=1` → Q = 0 (Reset)
- `set=0, rst=0` → Hold previous value
- `set=1, rst=1` → Invalid (Q = x in simulation)

## Notes
- Synchronous design using `always_ff`
- Invalid state is only for simulation (`1'bx`)
- Testbench uses layered approach (Generator + Driver + Monitor + Scoreboard)

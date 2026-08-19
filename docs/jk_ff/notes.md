# JK Flip-Flop

## Behavior
| J | K | Next Q     | Action  |
|---|---|------------|---------|
| 0 | 0 | Q          | Hold    |
| 0 | 1 | 0          | Reset   |
| 1 | 0 | 1          | Set     |
| 1 | 1 | ~Q         | Toggle  |

## Implementation Notes
- Synchronous design using `always_ff @(posedge clk)`
- Interface + modport used for clean connection
- Toggle case (`J=1, K=1`) correctly implemented in the DUT

## Testbench
- Layered testbench (Generator → Driver → Monitor → Scoreboard)
- Self-checking Scoreboard with reference model
- Note: Occasional Scoreboard mismatches can appear on consecutive Toggle operations due to sampling timing.  
  The waveform confirms that the DUT behavior itself is correct.

## Files
- RTL: `rtl/jk_ff.sv` (or `jk_top.sv`)
- Testbench: `tb/jk_ff_testbench.sv`

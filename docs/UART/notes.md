# UART TX + RX

## Behavior
```
| newd | rx   | What happens                                |
| ---- | ---- | ------------------------------------------- |
| 1    | x    | TX leaves idle, drives start bit 0 on tx    |
| 0    | x    | TX shifts data_in[0]..[7] then stop bit 1   |
| x    | 1    | RX idle (line high)                         |
| x    | 0    | RX sees start, then shifts 8 bits into data_out |
```

8-bit data, LSB first, 1 start bit (0), 1 stop bit (1). No parity.

TX and RX are two separate blocks inside `top`. `tx` is always an output. `rx` is always an input. They are not inouts.

This lab originally had `assign vif.rx = vif.tx` (loopback) inside `top`. That shorts the two pins so RX hears TX. It fights a testbench that also drives `rx` on a "read". Loopback was commented out so write tests drive TX only and read tests bit-bang `rx`.

## Frame
```
idle (1) | start (0) | d0 d1 d2 d3 d4 d5 d6 d7 | stop (1) | idle (1)
```

One bit per `u_clk` period. `u_clk` is a divided copy of `clk`:
`clk_count = clk_freq / baud_rate` (1_000_000 / 9600). Toggle every `clk_count/2` system clocks.

TX and RX each make their own `u_clk`. They are not a shared baud tick and RX does not sample mid-bit.

## Implementation Notes
- One `uart_if`; two modports: `map_tx` and `map_rx`
- `top` instantiates `uart_tx` / `uart_rx` and exports `u_clk_tx` / `u_clk_rx` from the internals (debug hook)
- TX states: `idle`, `transfer`. On `newd` it latches `data_in`, drops `tx` (start), then `t.tx <= data_in[count_s]` while `count_s` is 0..7, then stop and `done_tx`
- RX states: `idle`, `start`. Falling `rx` moves idle → start. Then 8 times `data_out <= {rx, data_out[7:1]}`, then `done_rx`
- `data_in` is a parallel load (all 8 bits at once). `data_out` is a shift register, so the waveform walks through intermediate values until `done_rx`
- `done_tx` / `done_rx` are 1-cycle (1 baud) pulses
- On reset, init `u_clk = 0` and set RX `state` / `count_s`. TX should also force `tx = 1` on reset or the wave starts as X

## Testbench
- Layered TB (Generator → Driver → Monitor → Scoreboard)
- `oper`: `write` = load TX (`data_in` + `newd`), scoreboard compares that byte to bits sampled on `tx`
- `oper`: `read` = Driver drives start + 8 random bits + stop on `rx`, scoreboard compares `data_rx` to `data_out`
- GEN `data_in` is unused on a read unless the Driver bit-bangs that byte onto `rx`
- `transaction.copy()` must fill the *new* object (`copy.oper = this.oper`), not `this`
- Driver DUT pins use `<=`. Local `data_rx[i]` uses `=`
- Read timing that matches this RX: drive start, wait one `u_clk_rx`, then for each bit `vif.rx <= data_rx[i]` *before* `@(posedge u_clk_rx)`
- Monitor guesses write vs read from `newd` / `rx` (it does not get `oper`)
- Generator waits `drv_next` then `sco_next` so frames do not overlap
- Do not drive `rx` from both `assign vif.rx = vif.tx` and the Driver in the same test

## Files
- RTL: `rtl/uart.sv` (or your design filename)
- Testbench: `tb/uart_testbench.sv`

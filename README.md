# shrike-edge

MCU-FPGA edge link for Vicharak Shrike, Shrike-lite, and Shrike-fi.

Timing cores. Not a seeker.

This repo is the **link**. Same ForgeFPGA bitstream on every board variant.
The host pin map changes. That is the whole point of having this tree next
to [shrike-edgekit](https://github.com/Geneticscrol/shrike-edgekit):

| Repo | Job |
|---|---|
| `shrike-edgekit` | kit + protocol + RP-first bring-up |
| `shrike-edge` | portable host + first-class Shrike-fi (ESP32-S3, 4-bit on-PCB link) |

FPGA fabric does not care which MCU is soldered next to it. The published
interconnect does.

## Boards

| Board | MCU | On-PCB link | IRQ / TRIG |
|---|---|---|---|
| Shrike-lite | RP2040 | 6-bit (4 SPI + GPIO17/18) | on-PCB |
| Shrike | RP2350 | 6-bit | on-PCB |
| Shrike-fi | ESP32-S3 | 4-bit (config SPI only) | use headers |

PWR + EN are reserved on every variant. After bitstream load the config
SPI pins become the Link-6 register bus (SPI Mode 0, 16-bit frames).

Pin table: `docs/PINS.md`. Frames and registers: `docs/PROTOCOL.md`
(same map as edgekit, ID `0xE6`).

## Layout

```
rtl/                     SLG47910 Verilog + IO planner
firmware/micropython/    Link6(board="rp"|"fi")
firmware/c/link6.h       pin maps for both MCUs
tests/                   pin + protocol locks
sim/                     Icarus benches
```

## Host

```python
from link6 import Link6

bus = Link6(board="rp")   # or board="fi"
assert bus.ping()         # ID == 0xE6
bus.write(0x05, 0x1D)
bus.set_pwm(1000, 0.25)
```

On Shrike-fi, `IRQ`/`TRIG` are optional constructor pins. The 4-wire bus
works without them. Sampler arm then goes through `SMP_CTRL`.

## Tests

```
python -m unittest discover -s tests -v
make test
```

## License

MIT. Pin numbers restated from Vicharak's published interconnect.

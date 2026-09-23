# Pin map — Shrike / Shrike-lite / Shrike-fi

Source: https://vicharak-in.github.io/shrike/shrike_pinouts.html

3.3 V only.

## Reserved

| Role | FPGA | RP2040 / RP2350 | ESP32-S3 |
|---|---|---|---|
| PWR | PWR | GPIO 12 | GPIO 8 |
| EN  | EN  | GPIO 13 | GPIO 9 |

## Register bus (after bitstream)

| Signal | FPGA | RP2040 / RP2350 | ESP32-S3 | Config-time name |
|---|---|---|---|---|
| SCK  | 3 | GPIO 2  | GPIO 12 | SPI_SCLK |
| CS_N | 4 | GPIO 1  | GPIO 10 | SPI_SS |
| MOSI | 5 | GPIO 3  | GPIO 11 | SPI_SI |
| MISO | 6 | GPIO 0  | GPIO 13 | SPI_SO |

## Sideband (6-bit boards only, on-PCB)

| Signal | FPGA | RP2040 / RP2350 |
|---|---|---|
| IRQ  | 18 | GPIO 14 |
| TRIG | 17 | GPIO 15 |

Shrike-fi has no on-PCB pair for these. Pass header GPIOs into Link6 or
arm the sampler over the register bus.

## LEDs (active high)

| LED | RP | ESP32-S3 | FPGA |
|---|---|---|---|
| MCU | GPIO 4 | GPIO 21 | - |
| FPGA | - | - | GPIO 16 |

## User pads on the FPGA top

PWM GPIO14, UART 8/9, sampler 10, LED 16.
OSC_CLK / OSC_EN for clk / clk_en.

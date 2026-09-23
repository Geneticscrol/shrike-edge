# Link protocol (shared with shrike-edgekit)

SPI Mode 0, MSB first, 16 clocks per access while CS_N is low.

```
{ W[15], ADDR[14:8], DATA[7:0] }
```

W=1 write, W=0 read. ID at 0x00 is `0xE6`. VER `0x10`. CAPS `0x07`.

| Addr | Name | Notes |
|---|---|---|
| 0x03 | STATUS | bit0 rx_rdy, 1 tx_busy, 2 overrun, 3 smp_rdy, 4 smp_armed |
| 0x04 | IRQ_MASK | default 0x09 |
| 0x05 | CTRL | bit0 core, 1 led, 2 pwm, 3 uart, 4 smp |
| 0x10-13 | PWM period/duty | 16-bit LE, fabric clocks |
| 0x20-23 | UART div / TX / RX | default div 434 = 115200 @ 50 MHz |
| 0x30-34 | sampler | ARM at 0x30 bit0; period HI clears ready |

On 4-bit boards there is no IRQ pin. Poll STATUS.

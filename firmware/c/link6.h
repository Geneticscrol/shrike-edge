#ifndef SHRIKE_EDGE_LINK6_H
#define SHRIKE_EDGE_LINK6_H

#include <stdint.h>

/* Shrike / Shrike-lite (RP2040 / RP2350) */
#define LINK6_RP_PWR  12
#define LINK6_RP_EN   13
#define LINK6_RP_SCK  2
#define LINK6_RP_CS   1
#define LINK6_RP_MOSI 3
#define LINK6_RP_MISO 0
#define LINK6_RP_IRQ  14
#define LINK6_RP_TRIG 15
#define LINK6_RP_LED  4

/* Shrike-fi (ESP32-S3). No on-PCB IRQ/TRIG. */
#define LINK6_FI_PWR  8
#define LINK6_FI_EN   9
#define LINK6_FI_SCK  12
#define LINK6_FI_CS   10
#define LINK6_FI_MOSI 11
#define LINK6_FI_MISO 13
#define LINK6_FI_LED  21

#define LINK6_REG_ID     0x00
#define LINK6_REG_VER    0x01
#define LINK6_REG_CAPS   0x02
#define LINK6_REG_STATUS 0x03
#define LINK6_REG_CTRL   0x05
#define LINK6_ID_MAGIC   0xE6
#define LINK6_SYS_HZ     50000000u

static inline uint16_t link6_frame_write(uint8_t addr, uint8_t data)
{
    return (uint16_t)((1u << 15) | ((addr & 0x7Fu) << 8) | data);
}

static inline uint16_t link6_frame_read(uint8_t addr)
{
    return (uint16_t)((addr & 0x7Fu) << 8);
}

#endif

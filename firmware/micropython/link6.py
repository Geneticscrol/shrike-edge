"""Portable Link-6 host. board='rp' or board='fi'."""
from machine import Pin
import time

BOARDS = {
    "rp": {
        "pwr": 12, "en": 13,
        "sck": 2, "cs": 1, "mosi": 3, "miso": 0,
        "irq": 14, "trig": 15, "led": 4,
    },
    "fi": {
        "pwr": 8, "en": 9,
        "sck": 12, "cs": 10, "mosi": 11, "miso": 13,
        "irq": None, "trig": None, "led": 21,
    },
}

REG_ID = 0x00
REG_VER = 0x01
REG_CAPS = 0x02
REG_STATUS = 0x03
REG_CTRL = 0x05
REG_PWM_PERIOD_LO = 0x10
REG_UART_DIV_LO = 0x20
REG_UART_TX = 0x22
REG_UART_RX = 0x23
REG_SMP_CTRL = 0x30
REG_SMP_WIDTH_LO = 0x31
REG_SMP_PERIOD_LO = 0x33

ID_MAGIC = 0xE6
SYS_HZ = 50_000_000


class Link6:
    def __init__(self, board="rp", irq=None, trig=None, half_period_us=5):
        if board not in BOARDS:
            raise ValueError("board must be 'rp' or 'fi'")
        p = dict(BOARDS[board])
        if irq is not None:
            p["irq"] = irq
        if trig is not None:
            p["trig"] = trig
        self.half = half_period_us
        self.board = board
        self.pwr = Pin(p["pwr"], Pin.OUT, value=1)
        self.en = Pin(p["en"], Pin.OUT, value=1)
        self.sck = Pin(p["sck"], Pin.OUT, value=0)
        self.cs = Pin(p["cs"], Pin.OUT, value=1)
        self.mosi = Pin(p["mosi"], Pin.OUT, value=0)
        self.miso = Pin(p["miso"], Pin.IN)
        self.irq = Pin(p["irq"], Pin.IN) if p["irq"] is not None else None
        self.trig = Pin(p["trig"], Pin.OUT, value=0) if p["trig"] is not None else None
        self.led = Pin(p["led"], Pin.OUT, value=0)

    def _tick(self):
        time.sleep_us(self.half)

    def xfer16(self, word):
        result = 0
        self.cs.value(0)
        self._tick()
        for i in range(15, -1, -1):
            self.mosi.value((word >> i) & 1)
            self._tick()
            self.sck.value(1)
            self._tick()
            result = (result << 1) | self.miso.value()
            self.sck.value(0)
        self._tick()
        self.cs.value(1)
        self._tick()
        return result

    def write(self, addr, data):
        self.xfer16((1 << 15) | ((addr & 0x7F) << 8) | (data & 0xFF))

    def read(self, addr):
        return self.xfer16((addr & 0x7F) << 8) & 0xFF

    def ping(self, tries=20):
        for _ in range(tries):
            if self.read(REG_ID) == ID_MAGIC:
                return True
            time.sleep_ms(10)
        return False

    def write16(self, lo, value):
        self.write(lo, value & 0xFF)
        self.write(lo + 1, (value >> 8) & 0xFF)

    def read16(self, lo):
        return self.read(lo) | (self.read(lo + 1) << 8)

    def set_pwm(self, freq_hz, duty_frac):
        period = max(1, int(SYS_HZ / freq_hz))
        if period > 0xFFFF:
            raise ValueError("freq too low")
        self.write16(REG_PWM_PERIOD_LO, period)
        self.write16(REG_PWM_PERIOD_LO + 2, int(period * duty_frac) & 0xFFFF)

    def set_baud(self, baud):
        self.write16(REG_UART_DIV_LO, max(1, int(SYS_HZ / baud)))

    def uart_write(self, byte):
        self.write(REG_UART_TX, byte & 0xFF)

    def uart_read(self):
        return self.read(REG_UART_RX)

    def arm_sampler(self):
        if self.trig is not None:
            self.trig.value(1)
            time.sleep_us(20)
            self.trig.value(0)
        else:
            self.write(REG_SMP_CTRL, 0x01)

    def irq_level(self):
        return self.irq.value() if self.irq is not None else None

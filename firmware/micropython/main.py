"""Bring-up. Set BOARD to 'rp' or 'fi'."""
from link6 import Link6, REG_CTRL, REG_STATUS, REG_VER, REG_CAPS

BOARD = "rp"


def main():
    bus = Link6(board=BOARD)
    if not bus.ping():
        print("no FPGA ID on board=%s" % BOARD)
        return
    print("id=E6 ver=%02x caps=%02x board=%s" % (
        bus.read(REG_VER), bus.read(REG_CAPS), BOARD))
    bus.write(REG_CTRL, 0x1D)
    bus.set_pwm(1000, 0.25)
    bus.set_baud(115200)
    print("status=%02x irq=%s" % (bus.read(REG_STATUS), bus.irq_level()))


if __name__ == "__main__":
    main()

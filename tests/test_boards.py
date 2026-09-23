import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HDR = (ROOT / "firmware" / "c" / "link6.h").read_text()
PY = (ROOT / "firmware" / "micropython" / "link6.py").read_text()


def cpp(name):
    m = re.search(rf"#define\s+{name}\s+(\S+)", HDR)
    assert m, name
    return m.group(1).rstrip("u")


class BoardPinTests(unittest.TestCase):
    def test_rp_matches_vicharak(self):
        self.assertEqual(cpp("LINK6_RP_PWR"), "12")
        self.assertEqual(cpp("LINK6_RP_EN"), "13")
        self.assertEqual(cpp("LINK6_RP_SCK"), "2")
        self.assertEqual(cpp("LINK6_RP_CS"), "1")
        self.assertEqual(cpp("LINK6_RP_MOSI"), "3")
        self.assertEqual(cpp("LINK6_RP_MISO"), "0")
        self.assertEqual(cpp("LINK6_RP_IRQ"), "14")
        self.assertEqual(cpp("LINK6_RP_TRIG"), "15")

    def test_fi_matches_vicharak(self):
        self.assertEqual(cpp("LINK6_FI_PWR"), "8")
        self.assertEqual(cpp("LINK6_FI_EN"), "9")
        self.assertEqual(cpp("LINK6_FI_SCK"), "12")
        self.assertEqual(cpp("LINK6_FI_CS"), "10")
        self.assertEqual(cpp("LINK6_FI_MOSI"), "11")
        self.assertEqual(cpp("LINK6_FI_MISO"), "13")

    def test_python_has_both_boards(self):
        self.assertIn('"rp"', PY)
        self.assertIn('"fi"', PY)

    def test_id(self):
        self.assertEqual(cpp("LINK6_ID_MAGIC"), "0xE6")

    def test_frames(self):
        w = (1 << 15) | (0x05 << 8) | 0x1D
        self.assertEqual(w >> 15, 1)
        self.assertEqual((w >> 8) & 0x7F, 0x05)


if __name__ == "__main__":
    unittest.main()

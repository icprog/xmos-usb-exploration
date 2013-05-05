#!/usr/bin/python

import usb
import time

XMOS_TEST_VID = 0x59e3
XMOS_TEST_PID = 0xf000

dev = usb.core.find(idVendor=XMOS_TEST_VID, idProduct=XMOS_TEST_PID)
from pylab import *
for div in arange(0, 2**16):
	div = int(div)
	low = div & 0xFFFF
	high = (div >> 16) & 0xFFFF
	dev.ctrl_transfer(0x40|0x80, 0x02, high, low, 0)
	time.sleep(1)
print map(hex, dev.ctrl_transfer(0x40|0x80, 0x01, 0, 0, 2))

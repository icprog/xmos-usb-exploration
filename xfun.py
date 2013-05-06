#!/usr/bin/python
from __future__ import division
import usb

XMOS_TEST_VID = 0x59e3
XMOS_TEST_PID = 0xf000

dev = usb.core.find(idVendor=XMOS_TEST_VID, idProduct=XMOS_TEST_PID)

def setFrequency(freq):
	if freq != 0:
		period = 1/freq
		tensOfNanoSeconds = period/1e-08
		div = int(tensOfNanoSeconds/2)
	else:
		div = 2**31
	low = div & 0xFFFF
	high = (div >> 16) & 0xFFFF
	dev.ctrl_transfer(0x40|0x80, 0x02, low, high, 0)

if __name__ == "__main__":
	setFrequency(57e3)

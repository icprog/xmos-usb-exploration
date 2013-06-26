#!/usr/bin/python

import usb
import time

XMOS_TEST_VID = 0x59e3
XMOS_TEST_PID = 0xf000
XMOS_TEST_EP_IN = 0x81
XMOS_TEST_EP_OUT = 0x01

dev = usb.core.find(idVendor=XMOS_TEST_VID, idProduct=XMOS_TEST_PID)
size = 2**10
for i in range(256):
	s = time.time()
	dev.write(XMOS_TEST_EP_OUT, [i]*size)
	l = time.time()
	map(hex, dev.read(XMOS_TEST_EP_IN, size, 0, 1000))
	print l-s

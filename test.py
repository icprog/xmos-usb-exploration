#!/usr/bin/python

import usb
import time

XMOS_TEST_VID = 0x9999
XMOS_TEST_PID = 0xffff
XMOS_TEST_EP_IN = 0x81
XMOS_TEST_EP_OUT = 0x01

dev = usb.core.find(idVendor=XMOS_TEST_VID, idProduct=XMOS_TEST_PID)

for i in range(32):
	dev.write(XMOS_TEST_EP_OUT, [i]*i)
	print map(hex, dev.read(XMOS_TEST_EP_IN, i+1, 0, 1000))

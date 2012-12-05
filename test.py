#!/usr/bin/python

import usb

XMOS_TEST_VID = 0x20b1
XMOS_TEST_PID = 0x0101
XMOS_TEST_EP_IN = 0x81
XMOS_TEST_EP_OUT = 0x01

dev = usb.core.find(idVendor=XMOS_TEST_VID, idProduct=XMOS_TEST_PID)
while True:
	print map(hex, dev.read(XMOS_TEST_EP_IN, 4, 0, 1000))

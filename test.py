#!/usr/bin/python

import usb

XMOS_TEST_VID = 0x9999
XMOS_TEST_PID = 0xffff
XMOS_TEST_EP_IN = 0x81
XMOS_TEST_EP_OUT = 0x01

dev = usb.core.find(idVendor=XMOS_TEST_VID, idProduct=XMOS_TEST_PID)

print dev.ctrl_transfer(0xC0, 0x01, 0, 0, 64)

i = 0

while True:
	i = (i+1) % 0xFF
	dev.write(XMOS_TEST_EP_OUT, [i])
	print map(hex, dev.read(XMOS_TEST_EP_IN, 1, 0, 1000))

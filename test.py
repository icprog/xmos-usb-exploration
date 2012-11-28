#!/usr/bin/python

import usb
import itertools 

XMOS_XTAG2_VID = 0x20b1
XMOS_XTAG2_PID = 0x0101
XMOS_XTAG2_EP_IN = 0x81
XMOS_XTAG2_EP_OUT = 0x01

dev = usb.core.find(idVendor=XMOS_XTAG2_VID, idProduct=XMOS_XTAG2_PID)
while True:
	print dev.read(XMOS_XTAG2_EP_IN, 4, 0, 1000)

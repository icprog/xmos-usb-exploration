TARGET = XTAG2

APP_NAME = app_example_usb

XCC_FLAGS = -Wall -O2 -report -fsubword-select -DUSB_CORE=0

USED_MODULES = module_usb_shared module_xud

XMOS_MAKE_PATH ?= ../..
include $(XMOS_MAKE_PATH)/xcommon/module_xcommon/build/Makefile.common

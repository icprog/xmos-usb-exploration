/**
 * Module:  app_l1_usb_hid
 * Version: 1v5
 * Build:   85182b6a76f9342326aad3e7c15c1d1a3111f60e
 * File:	main.xc
 *
 * The copyrights, all other intellectual and industrial 
 * property rights are retained by XMOS and/or its licensors. 
 * Terms and conditions covering the use of this code can
 * be found in the Xmos End User License Agreement.
 *
 * Copyright XMOS Ltd 2010
 *
 * In the case where this code is a modification of existing code
 * under a separate license, the separate license terms are shown
 * below. The modifications to the code are still covered by the 
 * copyright notice above.
 *
 **/								   
#include <xs1.h>
#include <platform.h>
#include <print.h>

#include "xud.h"
#include "usb.h"

#define XUD_EP_COUNT_OUT 1
#define XUD_EP_COUNT_IN	1

#define USB_RST_PORT	XS1_PORT_1I


/* USB Port declarations */
on stdcore[0]: out port p_usb_rst = USB_RST_PORT;
on stdcore[0]: clock	clk	   = XS1_CLKBLK_3;

void Endpoint0( chanend c_ep0_out, chanend c_ep0_in, chanend userChannel);

void frequencyDrive(chanend getCounter, out port H, out port L) {
	unsigned int t;
	unsigned int counter;
	timer tmr;
	// 50 kilohertz
	counter = 1000;
	tmr :> t;
	while (1) {
		select {
			case getCounter :> counter : break;
			default: break;
		}
		t += counter;
		tmr when timerafter(t) :> void;
		H <: 0;
		L <: 1;
		t += counter;
		tmr when timerafter(t) :> void;
		L <: 0;
		H <: 1;
	}
}	
		
			
out port ho = XS1_PORT_1A;
out port lo = XS1_PORT_1C;

XUD_EpType epTypeTableOut[XUD_EP_COUNT_OUT] = {XUD_EPTYPE_CTL};
XUD_EpType epTypeTableIn[XUD_EP_COUNT_IN] =   {XUD_EPTYPE_CTL};

int main() 
{
	chan c_ep_out[1], c_ep_in[1];
	chan counter;
	par 
	{
		
		on stdcore[0]: XUD_Manager( c_ep_out, XUD_EP_COUNT_OUT, c_ep_in, XUD_EP_COUNT_IN,
								null, epTypeTableOut, epTypeTableIn,
								p_usb_rst, clk, -1, XUD_SPEED_HS, null); 
		
		on stdcore[0]:
		{
			set_thread_fast_mode_on();
			Endpoint0( c_ep_out[0], c_ep_in[0], counter);
		}

		on stdcore[0]:
		{
			frequencyDrive(counter, ho, lo);
		}
			
	}

	return 0;
}

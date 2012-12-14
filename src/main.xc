/**
 * Module:  app_l1_usb_hid
 * Version: 1v5
 * Build:   85182b6a76f9342326aad3e7c15c1d1a3111f60e
 * File:    main.xc
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

#define XUD_EP_COUNT_OUT   2
#define XUD_EP_COUNT_IN    2

#define USB_RST_PORT    XS1_PORT_1I


/* Endpoint type tables */
XUD_EpType epTypeTableOut[XUD_EP_COUNT_OUT] = {XUD_EPTYPE_CTL, XUD_EPTYPE_BUL};
XUD_EpType epTypeTableIn[XUD_EP_COUNT_IN] =   {XUD_EPTYPE_CTL, XUD_EPTYPE_BUL};

/* USB Port declarations */
on stdcore[USB_CORE]: out port p_usb_rst = USB_RST_PORT;
on stdcore[USB_CORE]: clock    clk       = XS1_CLKBLK_3;

void Endpoint0( chanend c_ep0_out, chanend c_ep0_in);

char reportBufferIN[] = {0};
char reportBufferOUT[] = {0};

void testIN(chanend chan_ep1_in, chanend in2out) 
{
    XUD_ep c_ep1_in = XUD_Init_Ep(chan_ep1_in);
   
    while(1) 
    {
        in2out :> reportBufferIN[0];

        if (XUD_SetBuffer(c_ep1_in, reportBufferIN, 1) < 0)
        {
            XUD_ResetEndpoint(c_ep1_in, null);
        }
	}
}

void testOUT(chanend chan_ep1_out, chanend in2out)
{
	XUD_ep c_ep1_out = XUD_Init_Ep(chan_ep1_out);
	int len;
	while(1) {
		len = XUD_GetBuffer(c_ep1_out, reportBufferOUT);
		if (len < 0) {
			XUD_ResetEndpoint(c_ep1_out, null);
    	}
		else {
			in2out <: reportBufferOUT[0];
		}
    }
   return;
}

/*
 * The main function fires off three processes: the XUD manager, Endpoint 0, and 'test'. An array of
 * channels is used for both in and out endpoints, endpoint zero requires both, 'test' is just an
 * IN endpoint.
 */

int main() 
{
    chan c_ep_out[2], c_ep_in[2];
	chan in2out;
    par 
    {
        
        on stdcore[USB_CORE]: XUD_Manager( c_ep_out, XUD_EP_COUNT_OUT, c_ep_in, XUD_EP_COUNT_IN,
                                null, epTypeTableOut, epTypeTableIn,
                                p_usb_rst, clk, -1, XUD_SPEED_HS, null); 
        
        on stdcore[USB_CORE]:
        {
            set_thread_fast_mode_on();
            Endpoint0( c_ep_out[0], c_ep_in[0]);
        }
       
        on stdcore[USB_CORE]:
        {
            set_thread_fast_mode_on();
            testIN(c_ep_in[1], in2out);
		}
        on stdcore[USB_CORE]:
        {
            set_thread_fast_mode_on();
            testOUT(c_ep_out[1], in2out);
			
        }
    }

    return 0;
}

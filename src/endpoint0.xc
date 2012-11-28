/**
 * Module:  app_l1_usb_hid
 * Version: 1v3
 * Build:   d24ac9fea5c6296216c47a7a5f7ca171537dd233
 * File:    endpoint0.xc
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
/*
 * @file endpoint0.xc
 * @brief Implements endpoint zero for an HID device.
 * @author Ross Owen, XMOS Semiconductor
 * @version 0.1
 */

#include <xs1.h>
#include <print.h>
#include "xud.h"
#include "usb.h"
#include "DescriptorRequests.h"

// This devices Device Descriptor:
static unsigned char hiSpdDesc[] = { 
  0x12,                /* 0  bLength */
  0x01,                /* 1  bdescriptorType */ 
  0x00,                /* 2  bcdUSB */ 
  0x02,                /* 3  bcdUSB */ 
  0xFF,                /* 4  bDeviceClass */ 
  0x00,                /* 5  bDeviceSubClass */ 
  0x00,                /* 6  bDeviceProtocol */ 
  0x40,                /* 7  bMaxPacketSize */ 
  0xb1,                /* 8  idVendor */ 
  0x20,                /* 9  idVendor */ 
  0x01,                /* 10 idProduct */ 
  0x01,                /* 11 idProduct */ 
  0x10,                /* 12 bcdDevice */
  0x00,                /* 13 bcdDevice */
  0x01,                /* 14 iManufacturer */
  0x02,                /* 15 iProduct */
  0x00,                /* 16 iSerialNumber */
  0x01                 /* 17 bNumConfigurations */
};

unsigned char fullSpdDesc[] =
{ 
    0x0a,              /* 0  bLength */
    DEVICE_QUALIFIER,  /* 1  bDescriptorType */ 
    0x00,              /* 2  bcdUSB */
    0x02,              /* 3  bcdUSB */ 
    0xFF,              /* 4  bDeviceClass */ 
    0x00,              /* 5  bDeviceSubClass */ 
    0x00,              /* 6  bDeviceProtocol */ 
    0x40,              /* 7  bMaxPacketSize */ 
    0x01,              /* 8  bNumConfigurations */ 
    0x00               /* 9  bReserved  */ 
};


static unsigned char hiSpdConfDesc[] = {  
  0x09,                /* 0  bLength */ 
  0x02,                /* 1  bDescriptortype */ 
  0x22, 0x00,          /* 2  wTotalLength */ 
  0x01,                /* 4  bNumInterfaces */ 
  0x01,                /* 5  bConfigurationValue */
  0x04,                /* 6  iConfiguration */
  0x80,                /* 7  bmAttributes */ 
  0xC8,                /* 8  bMaxPower */
  
  0x09,                /* 0  bLength */
  0x04,                /* 1  bDescriptorType */ 
  0x00,                /* 2  bInterfacecNumber */
  0x00,                /* 3  bAlternateSetting */
  0x01,                /* 4: bNumEndpoints */
  0xFF,                /* 5: bInterfaceClass */ 
  0x00,                /* 6: bInterfaceSubClass */ 
  0x00,                /* 7: bInterfaceProtocol*/ 
  0x00,                /* 8  iInterface */ 
  
  0x09,                /* 0  bLength */ 
  0x00,                /* 1  bDescriptorType (HID) */ 
  0x00,                /* 2  bcdHID */ 
  0x00,                /* 3  bcdHID */ 
  0x00,                /* 4  bCountryCode */ 
  0x01,                /* 5  bNumDescriptors */ 
  0x22,                /* 6  bDescriptorType[0] (Report) */ 
  0x48,                /* 7  wDescriptorLength */ 
  0x00,                /* 8  wDescriptorLength */ 
  
  0x07,                /* 0  bLength */ 
  0x05,                /* 1  bDescriptorType */ 
  0x81,                /* 2  bEndpointAddress */ 
  0x03,                /* 3  bmAttributes */ 
  0x40,                /* 4  wMaxPacketSize */ 
  0x00,                /* 5  wMaxPacketSize */ 
  0x01                 /* 6  bInterval */ 
}; 


unsigned char fullSpdConfDesc[] =
{
    0x09,              /* 0  bLength */
    OTHER_SPEED_CONFIGURATION,      /* 1  bDescriptorType */
    0x12,              /* 2  wTotalLength */
    0x00,              /* 3  wTotalLength */
    0x01,              /* 4  bNumInterface: Number of interfaces*/
    0x00,              /* 5  bConfigurationValue */
    0x00,              /* 6  iConfiguration */
    0x80,              /* 7  bmAttributes */
    0xC8,              /* 8  bMaxPower */

    0x09,              /* 0 bLength */
    0x04,              /* 1 bDescriptorType */
    0x00,              /* 2 bInterfaceNumber */
    0x00,              /* 3 bAlternateSetting */
    0x00,              /* 4 bNumEndpoints */
    0xFF,              /* 5 bInterfaceClass */
    0x00,              /* 6 bInterfaceSubclass */
    0x00,              /* 7 bInterfaceProtocol */
    0x00,              /* 8 iInterface */

};


static unsigned char stringDescriptors[][40] = {
	"\009\004",                    // Language string
  	"XMOS",				           // iManufacturer 
 	"Example Mouse" 			   // iProduct
 	"" 			                   // unUsed
 	"Config"   			           // iConfiguration
};

extern int min(int a, int b);

void Endpoint0( chanend chan_ep0_out, chanend chan_ep0_in)
{
    unsigned char buffer[1024];
    SetupPacket sp;
    unsigned int current_config = 0;
    
    XUD_ep c_ep0_out = XUD_Init_Ep(chan_ep0_out);
    XUD_ep c_ep0_in  = XUD_Init_Ep(chan_ep0_in);
    
    while(1)
    {
        /* Do standard enumeration requests */ 
        int retVal = 0;

        retVal = DescriptorRequests(c_ep0_out, c_ep0_in, hiSpdDesc, sizeof(hiSpdDesc), 
            hiSpdConfDesc, sizeof(hiSpdConfDesc), fullSpdDesc, sizeof(fullSpdDesc), 
            fullSpdConfDesc, sizeof(fullSpdConfDesc), stringDescriptors, sp);
        
        if (retVal)
        {
            /* Request not covered by XUD_DoEnumReqs() so decode ourselves */
            switch(sp.bmRequestType.Type)
            {
                case BM_REQTYPE_TYPE_STANDARD:
                    switch(sp.bmRequestType.Recipient)
                    {
                        case BM_REQTYPE_RECIP_INTER:
                    
                            switch(sp.bRequest)
                            {
                                /* Set Interface */
                                case SET_INTERFACE:
                        
                                    /* TODO: Set the interface */
                        
                                    /* No data stage for this request, just do data stage */
                                    XUD_DoSetRequestStatus(c_ep0_in, 0);
                                    break;
                        
                                case GET_INTERFACE:
                                    buffer[0] = 0;
                                    XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer,1, sp.wLength );
                                    break;
                        
                                case GET_STATUS:
                                    buffer[0] = 0;
                                    buffer[1] = 0;
                                    XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer, 2, sp.wLength);
                                    break; 
             
                                case GET_DESCRIPTOR:
                                    buffer[0] = 0;
                                    buffer[1] = 0;
                                    XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer, 2, sp.wLength);
                                    break;
                        
                            }       
                            break;
                    
                /* Recipient: Device */
                case BM_REQTYPE_RECIP_DEV:
                    
                    /* Standard Device requests (8) */
                    switch( sp.bRequest )
                    {      
                        /* TODO We could check direction to be double safe */
                        /* Standard request: SetConfiguration */
                        case SET_CONFIGURATION:
                        
                            /* Set the config */
                            current_config = sp.wValue;
                        
                            /* No data stage for this request, just do status stage */
                            XUD_DoSetRequestStatus(c_ep0_in,  0);
                            break;
                        
                        case GET_CONFIGURATION:
                            buffer[0] = (char)current_config;
                            XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer, 1, sp.wLength);
                            break; 
                        
                        case GET_STATUS:
                            buffer[0] = 0;
                            buffer[1] = 0;
                            if (hiSpdConfDesc[7] & 0x40)
                                buffer[0] = 0x1;
                            XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer, 2, sp.wLength);
                            break; 
                    
                        case SET_ADDRESS:
                            /* Status stage: Send a zero length packet */
                            retVal = XUD_SetBuffer_ResetPid(c_ep0_in,  buffer, 0, PIDn_DATA1);

                            /* We should wait until ACK is received for status stage before changing address */
                            {
                                timer t;
                                unsigned time;
                                t :> time;
                                t when timerafter(time+50000) :> void;
                            }

                            /* Set device address in XUD */
                            XUD_SetDevAddr(sp.wValue);
                            break;
                        
                        default:
                            //XUD_Error("Unknown device request");
                            break;
                        
                    }  
                    break;
                    
                default: 
                    /* Got a request to a recipient we didn't recognise... */ 
                    //XUD_Error("Unknown Recipient"); 
                    break;
                }
                break;
            
            default:
                /* Error */ 
                break;
    
            }
            
        } /* if XUD_DoEnumReqs() */


        if (retVal == -1) 
        {
            XUD_ResetEndpoint(c_ep0_out, c_ep0_in);
        } 


    }
}

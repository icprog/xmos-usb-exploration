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

int HandleVendorRequest(XUD_ep c_ep0_out, XUD_ep c_ep0_in, unsigned char buffer[], SetupPacket& sp, chanend userChannel){
  switch(sp.bRequest){
    case 0x01:
      buffer[0] = 0xAA;
      buffer[1] = 0x55;
      return XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer, 2, sp.wLength );

    default:
      break;
  }
  return 1;
}

static unsigned char stringDescriptors[][40] = {
  "\x09\x04",            // Language string
  "Nonolith Labs",                 // iManufacturer 
  "Example"              // iProduct
};

extern unsigned char DeviceDescriptor[100];
extern unsigned  len_DeviceDescriptor;

extern unsigned char ConfigurationDescriptor[100];
extern unsigned  len_ConfigurationDescriptor;

extern unsigned char DeviceDescriptorFS[100];
extern unsigned  len_DeviceDescriptorFS;

extern unsigned char ConfigurationDescriptorFS[100];
extern unsigned  len_ConfigurationDescriptorFS;


#pragma unsafe arrays
void Endpoint0( chanend chan_ep0_out, chanend chan_ep0_in, chanend userChannel){
    unsigned char buffer[1024];
    SetupPacket sp;
    unsigned int current_config = 0;
    
    XUD_ep c_ep0_out = XUD_Init_Ep(chan_ep0_out);
    XUD_ep c_ep0_in  = XUD_Init_Ep(chan_ep0_in);
    
    while(1){
        /* Do standard enumeration requests */ 
        int retVal = 0; // 0 if handled, 1 if not handled, -1 on error

        retVal = DescriptorRequests(c_ep0_out, c_ep0_in,
            DeviceDescriptor,          len_DeviceDescriptor, 
            ConfigurationDescriptor,   len_ConfigurationDescriptor,
            DeviceDescriptorFS,        len_DeviceDescriptorFS, 
            ConfigurationDescriptorFS, len_ConfigurationDescriptorFS,
            stringDescriptors, sp);
        
        if (retVal){
          /* Request not covered by XUD_DoEnumReqs() so decode ourselves */
          switch(sp.bmRequestType.Type){
            case BM_REQTYPE_TYPE_STANDARD:
              switch(sp.bmRequestType.Recipient){
                case BM_REQTYPE_RECIP_INTER:
                  switch(sp.bRequest){
                    /* Set Interface */
                    case SET_INTERFACE:

                        /* TODO: Set the interface */

                        /* No data stage for this request, just do data stage */
                      retVal = XUD_DoSetRequestStatus(c_ep0_in, 0);
                      break;

                    case GET_INTERFACE:
                      buffer[0] = 0;
                      retVal = XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer,1, sp.wLength );
                      break;

                    case GET_STATUS:
                      buffer[0] = 0;
                      buffer[1] = 0;
                      retVal = XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer, 2, sp.wLength);
                      break; 

                    case GET_DESCRIPTOR:
                      buffer[0] = 0;
                      buffer[1] = 0;
                      retVal = XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer, 2, sp.wLength);
                      break;
                  }     
                  break;

                /* Recipient: Device */
                case BM_REQTYPE_RECIP_DEV:
                  /* Standard Device requests (8) */
                  switch( sp.bRequest ){      
                    /* TODO We could check direction to be double safe */
                    /* Standard request: SetConfiguration */
                    case SET_CONFIGURATION:

                      /* Set the config */
                      current_config = sp.wValue;

                      /* No data stage for this request, just do status stage */
                      retVal = XUD_DoSetRequestStatus(c_ep0_in,  0);
                      break;

                    case GET_CONFIGURATION:
                      buffer[0] = (char)current_config;
                      retVal = XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer, 1, sp.wLength);
                      break; 

                    case GET_STATUS:
                      buffer[0] = 0;
                      buffer[1] = 0;
                      if (ConfigurationDescriptor[7] & 0x40)
                        buffer[0] = 0x1;
                      retVal = XUD_DoGetRequest(c_ep0_out, c_ep0_in, buffer, 2, sp.wLength);
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
                      break;
                  }  
                  break;

                default: 
                  break;
              }
              break;

            case BM_REQTYPE_TYPE_VENDOR:
              retVal = HandleVendorRequest(c_ep0_out, c_ep0_in, buffer, sp, userChannel);
              break;

            default:
              break;
          }
        }

        if (retVal == 1){
          XUD_SetStall_Out(0);
          XUD_SetStall_In(0);
        }else if (retVal == -1) {
          XUD_ResetEndpoint(c_ep0_out, c_ep0_in);
        } 
    }
}

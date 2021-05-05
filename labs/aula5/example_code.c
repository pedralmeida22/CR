/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h" // "light" printf
#include "sleep.h"		// contains Microblaze specific sleep related APIs
#include "xgpio_l.h"	// identifiers and driver functions (or macros) that can be used to access the device (XGpio_WriteReg, XGpio_ReadReg,...)

#include "stdbool.h" ///C99

// 7-segment decoder
//converts a 4-bit number [0..15] to 7-segments, dp is a dot point
unsigned char Hex2Seg(unsigned int value, bool dp)
{
	static const char Hex2SegLUT[] = {0x40, 0x79 /*, TODO: COMPLETE THIS CODE*/};
	return dp ? Hex2SegLUT[value] : (0x80 | Hex2SegLUT[value]);
}

// Rising edge detection
bool DetectRisingEdge(unsigned int oldValue, unsigned int newValue, unsigned char bitIndex)
{
	unsigned int mask = 1 << bitIndex;

	return ((~oldValue & mask) & (newValue & mask)) == mask;
}

int main()
{
    init_platform();

    print("Hello World\n\r");

//	Tri-state configuration
//	Inputs
    // 	  XGpio_WriteReg
    //    Write a value to a GPIO register. A 32 bit write is performed. If the
    //    GPIO core is implemented in a smaller width, only the least significant data
    //    is written.
	//    @param	BaseAddress is the base address of the GPIO device.
	//    @param	RegOffset is the register offset from the base to write to.
	//    @param	Data is the data written to the register.
    XGpio_WriteReg(XPAR_AXI_GPIO_SWITCHES_BASEADDR, XGPIO_TRI_OFFSET,  0xFFFFFFFF);
    XGpio_WriteReg(XPAR_AXI_GPIO_BUTTONS_BASEADDR,  XGPIO_TRI_OFFSET,  0xFFFFFFFF);

//	Outputs
    XGpio_WriteReg(XPAR_AXI_GPIO_LEDS_BASEADDR,     XGPIO_TRI_OFFSET,  0xFFFF0000);
    XGpio_WriteReg(XPAR_AXI_GPIO_DISPLAYS_BASEADDR,  XGPIO_TRI_OFFSET,  0xFFFFFF00);
    XGpio_WriteReg(XPAR_AXI_GPIO_DISPLAYS_BASEADDR,  XGPIO_TRI2_OFFSET, 0xFFFFFF00);


//  Test 1: Output fixed patterns
    XGpio_WriteReg(XPAR_AXI_GPIO_LEDS_BASEADDR,    XGPIO_DATA_OFFSET, 0x5555);
    XGpio_WriteReg(XPAR_AXI_GPIO_DISPLAYS_BASEADDR, XGPIO_DATA_OFFSET, 0xF0);
    XGpio_WriteReg(XPAR_AXI_GPIO_DISPLAYS_BASEADDR, XGPIO_DATA2_OFFSET, 0x00);

////  Test 2: Switches -> LEDs loopback
//    unsigned int switchesVal;
//    while(1)
//    {
////		XGpio_ReadReg
////		Read a value from a GPIO register. A 32 bit read is performed. If the
////		GPIO core is implemented in a smaller width, only the least
////		significant data is read from the register. The most significant data
////		will be read as 0.
////		@param	BaseAddress is the base address of the GPIO device.
////		@param	RegOffset is the register offset from the base to read from.
////		@return	Data read from the register
//    	switchesVal = XGpio_ReadReg(XPAR_AXI_GPIO_SWITCHES_BASEADDR, XGPIO_DATA_OFFSET);
//    	XGpio_WriteReg(XPAR_AXI_GPIO_LEDS_BASEADDR, XGPIO_DATA_OFFSET, switchesVal);
//    }

///  Test 3: Displays refresh demo
//    while(1)
//    {
//    	XGpio_WriteReg(XPAR_AXI_GPIO_DISPLAYS_BASEADDR, XGPIO_DATA_OFFSET,  0xFE);
//    	XGpio_WriteReg(XPAR_AXI_GPIO_DISPLAYS_BASEADDR, XGPIO_DATA2_OFFSET, Hex2Seg(0, false));
//
//    	usleep(1000000); //delay in usec
//
//    	XGpio_WriteReg(XPAR_AXI_GPIO_DISPLAYS_BASEADDR, XGPIO_DATA_OFFSET,  0xFD);
//    	XGpio_WriteReg(XPAR_AXI_GPIO_DISPLAYS_BASEADDR, XGPIO_DATA2_OFFSET, Hex2Seg(1, true));
//
//    	usleep(1000000); //delay in usec
//
//    	//TODO: try showing other than 1 and 0 values on the displays
//    }

////  Test 4: Buttons readback demo
//    unsigned int newValue;
//    while(1)
//    {
//    	newValue = XGpio_ReadReg(XPAR_AXI_GPIO_BUTTONS_BASEADDR, XGPIO_DATA_OFFSET);
////    	The purpose of this routine is to output data the same as the standard printf function
////		without the overhead most run-time libraries involve. Usually the printf brings in many
////		kilobytes of code and that is unacceptable in most embedded systems.
//    	xil_printf("\r\n%02x", newValue);
//    }

////  Test 5:	Buttons rising-edge detection
//    unsigned int oldValue = 0xFF;
//    unsigned int newValue;
//
//	while(1)
//	{
//		newValue = XGpio_ReadReg(XPAR_AXI_GPIO_BUTTONS_BASEADDR, XGPIO_DATA_OFFSET);
//		print("\r\n");
//		for (int i = 4; i >= 0; i--)
//		{
//			if (DetectRisingEdge(oldValue, newValue, i))
//			{
//				print("|");
//			}
//			else
//			{
//				print(".");
//			}
//		}
//
//		oldValue = newValue;
//		usleep(100000); //delay in usec
//	}

    cleanup_platform();
    return 0;
}

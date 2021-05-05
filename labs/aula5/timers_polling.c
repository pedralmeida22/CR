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
#include "xil_printf.h"
#include "sleep.h"
#include "xgpio_l.h"
#include "xtmrctr_l.h"
#include "stdbool.h"

// 7 segment decoder
unsigned char Hex2Seg(unsigned int value, bool dp) //converts a 4-bit number [0..15] to 7-segments
{
	static const char Hex2SegLUT[] = {0x40, 0x79, 0x24, 0x30, 0x19, 0x12, 0x02, 0x78,
									  0x00, 0x10, 0x08, 0x03, 0x46, 0x21, 0x06, 0x0E};
	return dp ? Hex2SegLUT[value] : (0x80 | Hex2SegLUT[value]);
}

void RefreshDisplays(unsigned char digitEnables, const unsigned int digitValues[8], unsigned char decPtEnables) //all enables come in positive logic, this function is invoked at 800Hz frequency
{
	static unsigned int digitRefreshIdx = 0; // static variable - is preserved across calls

	// Insert your code here...
	///*** STEP 1
	unsigned int an = 0x01;
	an = an << digitRefreshIdx; 	// select the right display to refresh (rotatively)
	an = an & digitEnables;			// check if the selected display is enabled
	bool dp = an & decPtEnables;	// check if the selected dot is enabled
	XGpio_WriteReg(XPAR_AXI_GPIO_DISPLAYS_BASEADDR, XGPIO_DATA_OFFSET, ~an); //an
	XGpio_WriteReg(XPAR_AXI_GPIO_DISPLAYS_BASEADDR, XGPIO_DATA2_OFFSET, Hex2Seg(digitValues[digitRefreshIdx], dp)); //seg
	///***

	digitRefreshIdx++;
	digitRefreshIdx &= 0x07; // AND bitwise
}

int main()
{
    init_platform();

    print("Hello World\n\r");

    //Demo 1: Timer event detection using polling
 	// Disable timer
 	XTmrCtr_SetControlStatusReg(XPAR_AXI_TIMER_0_BASEADDR, 0, 0x0); //set the Control Status Register of the timer 0 counter to the specified value

	// Set timer load value
    XTmrCtr_SetLoadReg(XPAR_AXI_TIMER_0_BASEADDR, 0, 500000000); // set the Load Register of the timer 0 counter to the specified value
    XTmrCtr_SetControlStatusReg(XPAR_AXI_TIMER_0_BASEADDR, 0, XTC_CSR_LOAD_MASK); //load the timer 0 using the load value provided earlier in the Load Register

	// Enable timer, down counting with auto reload
    XTmrCtr_SetControlStatusReg(XPAR_AXI_TIMER_0_BASEADDR, 0, XTC_CSR_ENABLE_TMR_MASK | XTC_CSR_AUTO_RELOAD_MASK | XTC_CSR_DOWN_COUNT_MASK);
    // XTC_CSR_ENABLE_TMR_MASK - Enables only the specific timer
    // XTC_CSR_AUTO_RELOAD_MASK - In compare mode, configures the timer counter to reload  from the Load Register. The default  mode causes the timer counter to hold when the compare value is hit.
    // XTC_CSR_DOWN_COUNT_MASK - Configures the timer counter to count down from start value, the default is to count up

  	while (1)
  	{
		// Detection using polling of timer event
  		unsigned int tmrCtrlStatReg = XTmrCtr_GetControlStatusReg(XPAR_AXI_TIMER_0_BASEADDR, 0); //get the Control Status Register of the timer 0 counter

  		if (tmrCtrlStatReg & XTC_CSR_INT_OCCURED_MASK) // if bit is set, an interrupt has occurred
  		{
  			// Print current count register
  			xil_printf("\r\n%09d", XTmrCtr_GetTimerCounterReg(XPAR_AXI_TIMER_0_BASEADDR, 0)); // get the Timer Counter Register of the timer 0 counter

  			print("*****\n");

			XTmrCtr_SetControlStatusReg(XPAR_AXI_TIMER_0_BASEADDR, 0, tmrCtrlStatReg | XTC_CSR_INT_OCCURED_MASK); //if set (interrupt) and '1' is written to this bit position, bit is cleared
		}
   	}

//    // Demo 2: 7-segment displays control
//    // Disable hardware timer
//	XTmrCtr_SetControlStatusReg(XPAR_AXI_TIMER_0_BASEADDR, 0, 0x00000000);
//	// Set hardware timer load value
//	XTmrCtr_SetLoadReg(XPAR_AXI_TIMER_0_BASEADDR, 0, 125000); // Counter will wrap around every 1.25 ms
//	XTmrCtr_SetControlStatusReg(XPAR_AXI_TIMER_0_BASEADDR, 0, XTC_CSR_LOAD_MASK);
//	// Enable hardware timer, down counting with auto reload
//	XTmrCtr_SetControlStatusReg(XPAR_AXI_TIMER_0_BASEADDR, 0, XTC_CSR_ENABLE_TMR_MASK  |
//															  XTC_CSR_AUTO_RELOAD_MASK |
//															  XTC_CSR_DOWN_COUNT_MASK);
//	xil_printf("\n\rHardware timer configured.");
//
//	xil_printf("\n\rSystem running.\n\r");
//
//	unsigned char digitEnables   = 0x3C;
//	unsigned int  digitValues[8] = {0, 0, 9, 5, 9, 5, 0, 0};
//	unsigned char decPtEnables   = 0x00;
//
//	// Timer event software counter
//	unsigned hwTmrEventCount = 0;
//	while (1)
//	{
//		unsigned int tmrCtrlStatReg = XTmrCtr_GetControlStatusReg(XPAR_AXI_TIMER_0_BASEADDR, 0);
//
//		if (tmrCtrlStatReg & XTC_CSR_INT_OCCURED_MASK)
//		{
//			// Clear hardware timer event (interrupt request flag)
//			XTmrCtr_SetControlStatusReg(XPAR_AXI_TIMER_0_BASEADDR, 0,
//										tmrCtrlStatReg | XTC_CSR_INT_OCCURED_MASK);
//			hwTmrEventCount++;
//
//			// Put here operations that must be performed at 800Hz rate
//			// Refresh displays
//			RefreshDisplays(digitEnables, digitValues, decPtEnables);
//			if (hwTmrEventCount == 400) // 2Hz
//			{
//				// Put here operations that must be performed at 2Hz rate
//				// Count down timer normal operation
//				decPtEnables ^= 0x10;
//				// Reset hwTmrEventCount every second
//				hwTmrEventCount = 0;
//			}
//		}
//	}

    cleanup_platform();
    return 0;
}



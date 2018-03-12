//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: board_gpio.c
//
// Authors: Shengye Wang - shengye@eng.ucsd.edu
//------------------------------------------------------------

#include "xparameters.h"
#include "xgpio.h"
#include "stdio.h"
#include "xstatus.h"
#include "board_gpio.h"

#define OUTPUT_CHANNEL 1
#define OUTPUT_CHANNEL_2 2

static u32 output_buf;
static u32 output_buf_2;

XGpio gpio_inst;

int gpio_init()
{
    int status;
    status = XGpio_Initialize(&gpio_inst, XPAR_AXI_GPIO_0_DEVICE_ID);
    if (status != XST_SUCCESS) return XST_FAILURE;
    XGpio_SetDataDirection(&gpio_inst, OUTPUT_CHANNEL, 0x00000000);
	XGpio_SetDataDirection(&gpio_inst, OUTPUT_CHANNEL_2, 0x00000000);
    // hypothesis: will read from buffer output pin, if 3-state buffer disabled, can not read back, take down
	output_buf = 0x00000000;
    output_buf_2 = 0xFFFFFFFF;
    XGpio_DiscreteWrite(&gpio_inst, OUTPUT_CHANNEL, output_buf);
	XGpio_DiscreteWrite(&gpio_inst, OUTPUT_CHANNEL_2, output_buf_2);
    return XST_SUCCESS;
}

u32 gpio_is_override()
{
    if (read_pin(GPIO_OVERRIDE_N)) return 0;
    if (!read_pin(GPIO_OVERRIDE_P)) return 0;
    return 1;
}

void gpio_set_override()
{
	//output_buf = 0x00000000;
    output_buf_2 = 0xFFFFFFFF;
    //XGpio_DiscreteWrite(&gpio_inst, OUTPUT_CHANNEL, output_buf);
	XGpio_DiscreteWrite(&gpio_inst, OUTPUT_CHANNEL_2, output_buf_2);
    change_pin(GPIO_OVERRIDE_P, 1);
    change_pin(GPIO_OVERRIDE_N, 0);
}

void gpio_clear_override()
{
    //output_buf = 0x00000000;
    output_buf_2 = 0xFFFFFFFF;
    //XGpio_DiscreteWrite(&gpio_inst, OUTPUT_CHANNEL, output_buf);
	XGpio_DiscreteWrite(&gpio_inst, OUTPUT_CHANNEL_2, output_buf_2);
}

/*
u32 read_switches()
{
    return XGpio_DiscreteRead(&gpio_inst, SWITCH_CHANNEL);
}

u32 read_switch(u32 id)
{
    return read_switches() & (1 << id);
}
*/

u32 read_pin(u32 id)
{
    return output_buf_2 & (1 << id);
}

int change_pin(u32 id, u32 val)
{
    output_buf_2 &= ~(1 << id);
    output_buf_2 |= (val ? (1 << id) : 0);
    XGpio_DiscreteWrite(&gpio_inst, OUTPUT_CHANNEL_2, output_buf_2);
    return gpio_is_override() ? XST_SUCCESS : XST_FAILURE;
}

int pll_prog_pll(u8 sel, u8 *arr, u8 len){
	u8 i;
	output_buf = 0x30000000;
	output_buf |= sel << 24;
	XGpio_DiscreteWrite(&gpio_inst, OUTPUT_CHANNEL, output_buf);
	for (i=0; i<(len>>1); i++) {
		output_buf = 0x20000000;
		output_buf |= sel << 24;
		output_buf |= (i+1) << 16;
		output_buf |= (((u32)(arr[i<<1])<<8));
		output_buf |= ((u32)(arr[(i<<1)+1]));
		XGpio_DiscreteWrite(&gpio_inst, OUTPUT_CHANNEL, output_buf);
	}
	output_buf = 0x00000000;
	XGpio_DiscreteWrite(&gpio_inst, OUTPUT_CHANNEL, output_buf);
	return XST_SUCCESS;
}

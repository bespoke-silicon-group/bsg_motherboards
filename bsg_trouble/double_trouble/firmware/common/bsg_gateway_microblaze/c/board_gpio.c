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
#define SWITCH_CHANNEL 2

static u32 output_buf;

XGpio gpio_inst;

int gpio_init()
{
    int status;
    status = XGpio_Initialize(&gpio_inst, XPAR_AXI_GPIO_0_DEVICE_ID);
    if (status != XST_SUCCESS) return XST_FAILURE;
    XGpio_SetDataDirection(&gpio_inst, SWITCH_CHANNEL, 0xFFFFFFFF);
    XGpio_SetDataDirection(&gpio_inst, OUTPUT_CHANNEL, 0x00000000);
    // hypothesis: will read from buffer output pin, if 3-state buffer disabled, can not read back, take down
    output_buf = 0xFFFFFFFF;
    XGpio_DiscreteWrite(&gpio_inst, OUTPUT_CHANNEL, output_buf);
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
    output_buf = 0xFFFFFFFF;
    XGpio_DiscreteWrite(&gpio_inst, OUTPUT_CHANNEL, output_buf);
    change_pin(GPIO_OVERRIDE_P, 1);
    change_pin(GPIO_OVERRIDE_N, 0);
}

void gpio_clear_override()
{
    output_buf = 0xFFFFFFFF;
    XGpio_DiscreteWrite(&gpio_inst, OUTPUT_CHANNEL, output_buf);
}

u32 read_switches()
{
    return XGpio_DiscreteRead(&gpio_inst, SWITCH_CHANNEL);
}

u32 read_switch(u32 id)
{
    return read_switches() & (1 << id);
}

u32 read_pin(u32 id)
{
    return output_buf & (1 << id);
}

int change_pin(u32 id, u32 val)
{
    output_buf &= ~(1 << id);
    output_buf |= (val ? (1 << id) : 0);
    XGpio_DiscreteWrite(&gpio_inst, OUTPUT_CHANNEL, output_buf);
    return gpio_is_override() ? XST_SUCCESS : XST_FAILURE;
}


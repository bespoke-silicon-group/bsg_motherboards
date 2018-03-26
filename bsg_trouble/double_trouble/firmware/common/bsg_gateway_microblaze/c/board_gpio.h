//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: board_gpio.h
//
// Authors: Shengye Wang - shengye@eng.ucsd.edu
//------------------------------------------------------------

#ifndef BOARD_GPIO_H  /* prevent circular inclusions */
#define BOARD_GPIO_H  /* by using protection macros */

#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"

#define GPIO_OVERRIDE_P 11
#define GPIO_OVERRIDE_N 10
#define GPIO_ASIC_CORE_EN 9
#define GPIO_ASIC_IO_EN 8
#define GPIO_CUR_MON_ADDR1 7
#define GPIO_CUR_MON_ADDR0 6
#define GPIO_DIG_POT_ADDR1 5
#define GPIO_DIG_POT_ADDR0 4
#define GPIO_DIG_POT_NRST 3
#define GPIO_DIG_POT_INDEP 2
#define GPIO_FPGA_LED1 1
#define GPIO_FPGA_LED0 0

int gpio_init();

u32 gpio_is_override();
void gpio_set_override();
void gpio_clear_override();

u32 read_switch(u32 id);
u32 read_switches();

int change_pin(u32 id, u32 val);
u32 read_pin(u32 id);

#endif


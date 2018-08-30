//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: uart_console.h
//
// Authors: Shengye Wang - shengye@eng.ucsd.edu
//------------------------------------------------------------

#ifndef UART_CONSOLE_H      /* prevent circular inclusions */
#define UART_CONSOLE_H      /* by using protection macros */

#include "board_info.h"

#define CMD_VER 0x00
#define CMD_DESC '~'

#define CMD_POWER_MASTER_OFF 0x10
#define CMD_POWER_SET_ALLOW 0x11
#define CMD_PROG_DIG_POT 0x12
#define CMD_PROG_DIG_POT_VOLTAGE_NOW 0x13

#define CMD_POWER_CORE_ON 0x20
#define CMD_POWER_CORE_OFF 0x21
#define CMD_POWER_CORE_SET 0x22
#define CMD_POWER_CORE_READ 0x23

#define CMD_POWER_IO_ON 0x30
#define CMD_POWER_IO_OFF 0x31
#define CMD_POWER_IO_SET 0x32
#define CMD_POWER_IO_READ 0x33

#define CMD_POWER_PLL_ON 0x34
#define CMD_POWER_PLL_OFF 0x35
#define CMD_POWER_PLL_SET 0x36
#define CMD_POWER_PLL_READ 0x37

#define CMD_MEASURE_IOCORE 0x40
#define CMD_MEASURE_MISC 0x41

#define CMD_PLL_SET_CONTROL 0x50
#define CMD_PLL_SET_IO_OSC 0x51
#define CMD_PLL_SET_IO_DIV 0x52
#define CMD_PLL_SET_IO_ISDIV 0x53
#define CMD_PLL_SET_CORE_OSC 0x54
#define CMD_PLL_SET_CORE_DIV 0x55
#define CMD_PLL_SET_CORE_ISDIV 0x56

#define CMD_NOP 0xAA

int check_console();

#endif



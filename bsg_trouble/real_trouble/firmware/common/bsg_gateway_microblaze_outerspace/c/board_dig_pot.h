//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: board_dig_pot.h
//
// Authors: Shengye Wang - shengye@eng.ucsd.edu
//------------------------------------------------------------

#ifndef BOARD_DIG_POT_H  /* prevent circular inclusions */
#define BOARD_DIG_POT_H  /* by using protection macros */

#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"

#define IIC_DIG_POT_SLAVE_ADDRESS 0x20
#define IIC_DIG_POT_PLL_SLAVE_ADDRESS 0x20

// Feedback for core connect to W1, feedback for IO connect to W2
#define CORE_DEFAULT_RES 0x1F // 1.1V
#define IO_DEFAULT_RES 0x44 // 1.8V
#define PLL_DEFAULT_RES 0x1F // 1.1V

// Maximum Value
#define CORE_MAX_RES 0x2E // 1.4V
#define IO_MAX_RES 0x66 // 2.5V
#define PLL_MAX_RES 0x2E // 1.4V

int dig_pot_init();
int dig_pot_prog_eeprom_default();
int dig_pot_prog_eeprom_voltage_now();
int dig_pot_allow_update();
int dig_pot_disallow_update();
int dig_pot_update_core(u8 val);
int dig_pot_report_core(u8* rtn);
int dig_pot_update_io(u8 val);
int dig_pot_report_io(u8* rtn);
int dig_pot_update_pll(u8 val);
int dig_pot_report_pll(u8* rtn);

#endif

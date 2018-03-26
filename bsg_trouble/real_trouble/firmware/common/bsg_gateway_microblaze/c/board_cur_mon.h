//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: board_cur_mon.h
//
// Authors: Shengye Wang - shengye@eng.ucsd.edu
//------------------------------------------------------------

#ifndef BOARD_CUR_MON_H  /* prevent circular inclusions */
#define BOARD_CUR_MON_H  /* by using protection macros */

#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"

#define IIC_CUR_MON_SLAVE_ADDRESS 0x4F

extern u8 cur_mon_misc[4]; // Misc info
extern u8 cur_mon_cur[4]; // Current info

int cur_mon_init();
int cur_mon_update_cur();
int cur_mon_update_misc();

#endif

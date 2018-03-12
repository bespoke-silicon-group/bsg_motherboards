//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: board_uart.h
//
// Authors: Shengye Wang - shengye@eng.ucsd.edu
//------------------------------------------------------------

#ifndef BOARD_UART_H  /* prevent circular inclusions */
#define BOARD_UART_H  /* by using protection macros */

#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"

int uart_init();
int uart_send(const u8* buffer, int len);
int uart_recv(u8* buffer, int len);

#endif


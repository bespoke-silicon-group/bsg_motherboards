//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: main.c
//
// Authors: Shengye Wang - shengye@eng.ucsd.edu
//------------------------------------------------------------

#include <stdio.h>
#include "xparameters.h"
#include "xil_cache.h"
#include "xbasic_types.h"
#include "board_cur_mon.h"
#include "board_dig_pot.h"
#include "board_gpio.h"
#include "board_uart.h"
#include "uart_console.h"

#define printf xil_printf

int main()
{

    int status;
    Xil_ICacheEnable();
    Xil_DCacheEnable();

    print("--- UCSD Double Trouble Debug Information ---\n\r");

    print("Initializing GPIO... ");
    status = gpio_init();
    print(status == XST_SUCCESS ? "SUCCEED\n\r" : "FAILED\n\r");

    print("Initializing Digital Potentiometer... ");
    status = dig_pot_init();
    print(status == XST_SUCCESS ? "SUCCEED\n\r" : "FAILED\n\r");

    print("Initializing Current Monitor... ");
    status = cur_mon_init();
    print(status == XST_SUCCESS ? "SUCCEED\n\r" : "FAILED\n\r");

    print("Initializing UART Interface... ");
    status = uart_init();
    print(status == XST_SUCCESS ? "SUCCEED\n\r" : "FAILED\n\r");
/*
    print("Programming Digital Potentiometer... ");
    status = dig_pot_prog_eeprom_default();
    print(status == XST_SUCCESS ? "SUCCEED\n\r" : "FAILED\n\r");
*/
    while (1) {
        check_console();
    }

    Xil_DCacheDisable();
    Xil_ICacheDisable();

    return 0;
}


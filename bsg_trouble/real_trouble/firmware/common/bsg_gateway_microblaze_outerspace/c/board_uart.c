//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: board_uart.c
//
// Authors: Shengye Wang - shengye@eng.ucsd.edu
//------------------------------------------------------------

#include "xparameters.h"
#include "xstatus.h"
#include "xuartlite.h"

#define UARTLITE_DEVICE_ID  XPAR_UARTLITE_0_DEVICE_ID

XUartLite uart_inst;        /* Instance of the UartLite Device */

int uart_init()
{
    int status;
    // Initialize the UartLite driver so that it is ready to use.
    status = XUartLite_Initialize(&uart_inst, XPAR_AXI_UARTLITE_0_DEVICE_ID);
    if (status != XST_SUCCESS) { return XST_FAILURE; }
    // Perform a self-test to ensure that the hardware was built correctly.
    status = XUartLite_SelfTest(&uart_inst);
    if (status != XST_SUCCESS) { return XST_FAILURE; }
    return XST_SUCCESS;
}

int uart_send(u8* buffer, int len)
{
    int send_count;
    send_count = XUartLite_Send(&uart_inst, buffer, len);
    if (send_count != len) { return XST_FAILURE; }
    while (XUartLite_IsSending(&uart_inst));
    return XST_SUCCESS;
}

int uart_recv(u8* buffer, int len)
{
    int received_count = 0;
    while (1) {
        received_count += XUartLite_Recv(&uart_inst, buffer + received_count, len - received_count);
        if (received_count == len) {
            break;
        }
    }
    return XST_SUCCESS;
}


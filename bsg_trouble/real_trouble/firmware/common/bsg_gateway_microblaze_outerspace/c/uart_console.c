//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: uart_console.c
//
// Authors: Shengye Wang - shengye@eng.ucsd.edu
//------------------------------------------------------------

#include "board_uart.h"
#include "board_dig_pot.h"
#include "board_cur_mon.h"
#include "board_gpio.h"
#include "board_info.h"
#include "uart_console.h"

#define printf xil_printf

int check_console()
{
    u8 cmd;
    u8 parameter;
    u8 p_array[256];
    int status;
    status = XST_FAILURE;
    uart_recv(&cmd, 1);
    switch (cmd) {
        case CMD_VER:
            uart_send(&response_follow_flag, 1);
            uart_send(&board_ver, 1);
            status = XST_SUCCESS;
            break;
        case CMD_DESC:
            uart_send(&response_follow_flag, 1);
            uart_send((u8*)&board_desc[0], 8);
            uart_send((u8*)&board_desc[8], 8);
            uart_send((u8*)&board_desc[16], 8);
            uart_send((u8*)&board_desc[24], 8);
            status = XST_SUCCESS;
            break;
        case CMD_POWER_MASTER_OFF:
		    status = change_pin(GPIO_ASIC_PLL_EN, 0);
            status = change_pin(GPIO_ASIC_CORE_EN, 0);
            status = (change_pin(GPIO_ASIC_IO_EN, 0) == XST_SUCCESS) ? status : XST_FAILURE;
            break;
        case CMD_POWER_SET_ALLOW:
            uart_recv(&parameter, 1);
            if (parameter == ALLOW_MATCH) {
                 gpio_set_override();
                 dig_pot_allow_update();
            } else {
                 gpio_clear_override();
                 dig_pot_disallow_update();
            }
            status = XST_SUCCESS;
            break;
        case CMD_PROG_DIG_POT:
            status = dig_pot_prog_eeprom_default();
            break;
		case CMD_PROG_DIG_POT_VOLTAGE_NOW:
            status = dig_pot_prog_eeprom_voltage_now();
            break;
        case CMD_POWER_CORE_ON:
            status = change_pin(GPIO_ASIC_CORE_EN, 1);
            break;
        case CMD_POWER_CORE_OFF:
            status = change_pin(GPIO_ASIC_CORE_EN, 0);
            break;
        case CMD_POWER_IO_ON:
            status = change_pin(GPIO_ASIC_IO_EN, 1);
            break;
        case CMD_POWER_IO_OFF:
            status = change_pin(GPIO_ASIC_IO_EN, 0);
            break;
		case CMD_POWER_PLL_ON:
            status = change_pin(GPIO_ASIC_PLL_EN, 1);
            break;
        case CMD_POWER_PLL_OFF:
            status = change_pin(GPIO_ASIC_PLL_EN, 0);
            break;
        case CMD_POWER_CORE_SET:
            uart_recv(&parameter, 1);
            status = dig_pot_update_core(parameter);
            break;
        case CMD_POWER_IO_SET:
            uart_recv(&parameter, 1);
            status = dig_pot_update_io(parameter);
            break;
        case CMD_POWER_PLL_SET:
            uart_recv(&parameter, 1);
            status = dig_pot_update_pll(parameter);
            break;
        case CMD_POWER_CORE_READ:
            status = dig_pot_report_core(&parameter);
            if (status == XST_SUCCESS) {
                 uart_send(&response_follow_flag, 1);
                 uart_send(&parameter, 1);
            }
            break;
        case CMD_POWER_IO_READ:
            status = dig_pot_report_io(&parameter);
            if (status == XST_SUCCESS) {
                 uart_send(&response_follow_flag, 1);
                 uart_send(&parameter, 1);
            }
            break;
        case CMD_POWER_PLL_READ:
            status = dig_pot_report_pll(&parameter);
            if (status == XST_SUCCESS) {
                 uart_send(&response_follow_flag, 1);
                 uart_send(&parameter, 1);
            }
            break;
        case CMD_MEASURE_IOCORE:
            status = cur_mon_update_cur();
            if (status == XST_SUCCESS) {
                uart_send(&response_follow_flag, 1);
                uart_send(cur_mon_cur, sizeof(cur_mon_cur));
            }
            break;
        case CMD_MEASURE_MISC:
            status = cur_mon_update_misc();
            if (status == XST_SUCCESS) {
                uart_send(&response_follow_flag, 1);
                uart_send(cur_mon_misc, sizeof(cur_mon_misc));
            }
            break;
		case CMD_PROG_TAG:
			uart_recv(p_array, 3);
			status = prog_tag(p_array[0], p_array[1], p_array[2]);
			break;
		case CMD_RESET_TAG:
			status = reset_tag();
			break;
        case CMD_NOP:
            status = XST_SUCCESS;
            break;
        default:
            status = XST_FAILURE;
            break;
    }
    parameter = (status == XST_SUCCESS) ? '#' : '!';
    uart_send(&parameter, 1);
    return XST_SUCCESS;
}


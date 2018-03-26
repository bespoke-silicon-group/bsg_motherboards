#!/usr/bin/env python
# -*- coding: utf-8 -*-

from console_util import *

def pll_set_control():
    ser.write([cmd_map['CMD_PLL_SET_CONTROL']])
    return check_cmd_return()

def pll_set_io_osc(value):
    cmd = bytearray([cmd_map['CMD_PLL_SET_IO_OSC'], value])
    ser.write(cmd)
    return check_cmd_return()

def pll_set_io_div(value):
    cmd = bytearray([cmd_map['CMD_PLL_SET_IO_DIV'], value])
    ser.write(cmd)
    return check_cmd_return()
	
def pll_set_io_isDiv(value):
    cmd = bytearray([cmd_map['CMD_PLL_SET_IO_ISDIV'], value])
    ser.write(cmd)
    return check_cmd_return()

def pll_set_core_osc(value):
    cmd = bytearray([cmd_map['CMD_PLL_SET_CORE_OSC'], value])
    ser.write(cmd)
    return check_cmd_return()

def pll_set_core_div(value):
    cmd = bytearray([cmd_map['CMD_PLL_SET_CORE_DIV'], value])
    ser.write(cmd)
    return check_cmd_return()
	
def pll_set_core_isDiv(value):
    cmd = bytearray([cmd_map['CMD_PLL_SET_CORE_ISDIV'], value])
    ser.write(cmd)
    return check_cmd_return()

def pll_restore():
    pll_set_io_osc(int(27))
    pll_set_io_div(int(0))
    pll_set_io_isDiv(int(1))
    pll_set_core_osc(int(13))
    pll_set_core_div(int(0))
    pll_set_core_isDiv(int(0))
    pll_set_control()
    return

prompt_pll = '''
-------------------- Trouble Master --------------------
1. Set control of PLL
2. Set PLL IO OSC payload
3. Set PLL IO DS payload
4. Choose PLL IO DS mode
5. Set PLL CORE OSC payload
6. Set PLL CORE DS payload
7. Choose PLL CORE DS mode
8. Restore factory settings
0. Return
-------------------- Trouble Master --------------------
'''

def console_set_pll():
    while (True):
        print prompt_pll
        try:
            cmd = raw_input('Please make a selection: ')
            cmd = int(cmd)
            if (cmd == 1):
                pll_set_control()
            elif (cmd == 2):
                parameter = raw_input('Please input io OSC payload (0-31): ')
                pll_set_io_osc(int(parameter))
            elif (cmd == 3):
                parameter = raw_input('Please input io DS payload (0-255): ')
                pll_set_io_div(int(parameter))
            elif (cmd == 4):
                parameter = raw_input('Please choose io mode (0 = OSC mode, 1 = DS mode): ')
                pll_set_io_isDiv(int(parameter))
            elif (cmd == 5):
                parameter = raw_input('Please input core OSC payload (0-31): ')
                pll_set_core_osc(int(parameter))
            elif (cmd == 6):
                parameter = raw_input('Please input core DS payload (0-255): ')
                pll_set_core_div(int(parameter))
            elif (cmd == 7):
                parameter = raw_input('Please choose core mode (0 = OSC mode, 1 = DS mode): ')
                pll_set_core_isDiv(int(parameter))
            elif (cmd == 8):
                pll_restore()
            elif (cmd == 0):
                return;
        except:
            raise


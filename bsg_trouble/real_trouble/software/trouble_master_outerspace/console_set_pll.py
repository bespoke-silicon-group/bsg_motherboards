#!/usr/bin/env python
# -*- coding: utf-8 -*-

from console_util import *

def pll_set_osc(select, value):
    cmd = bytearray([cmd_map['CMD_PROG_TAG'], select, value, 0x00])
    ser.write(cmd)
    check_cmd_return()
    cmd = bytearray([cmd_map['CMD_PROG_TAG'], select, 0x01, 0x02])
    ser.write(cmd)
    check_cmd_return()
    cmd = bytearray([cmd_map['CMD_PROG_TAG'], select, 0x00, 0x02])
    ser.write(cmd)
    return check_cmd_return()

def pll_set_ds(select, value):
    cmd = bytearray([cmd_map['CMD_PROG_TAG'], select, value, 0x01])
    ser.write(cmd)
    return check_cmd_return()

def pll_set_all_osc(value):
    for i in range(6):
        response = pll_set_osc(i, value)
    return response
	
def pll_set_all_ds(value):
    for i in range(6):
        response = pll_set_ds(i, value)
    return response
    
def pll_reset_tag():
    cmd = bytearray([cmd_map['CMD_RESET_TAG']])
    ser.write(cmd)
    return check_cmd_return()


prompt_pll = '''
-------------------- Trouble Master --------------------
1. Set CORE OSC
2. Set CORE DS
3. Set IO OSC
4. Set IO DS
5. Set DFI2X OSC
6. Set DFI2X DS
7. Set DRLP OSC
8. Set DRLP DS
9. Set FSB OSC
10. Set FSB DS
11. Set OP OSC
12. Set OP DS
13. Set ALL OSC
14. Set ALL DS
15. Reset TAG
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
                parameter = raw_input('Please input CORE OSC payload (0-31): ')
                pll_set_osc(0, int(parameter))
            elif (cmd == 2):
                parameter = raw_input('Please input CORE DS payload (0-255): ')
                pll_set_ds(0, int(parameter))
            elif (cmd == 3):
                parameter = raw_input('Please input IO OSC payload (0-31): ')
                pll_set_osc(1, int(parameter))
            elif (cmd == 4):
                parameter = raw_input('Please input IO DS payload (0-255): ')
                pll_set_ds(1, int(parameter))
            elif (cmd == 5):
                parameter = raw_input('Please input DFI2X OSC payload (0-31): ')
                pll_set_osc(2, int(parameter))
            elif (cmd == 6):
                parameter = raw_input('Please input DFI2X DS payload (0-255): ')
                pll_set_ds(2, int(parameter))
            elif (cmd == 7):
                parameter = raw_input('Please input DRLP OSC payload (0-31): ')
                pll_set_osc(3, int(parameter))
            elif (cmd == 8):
                parameter = raw_input('Please input DRLP DS payload (0-255): ')
                pll_set_ds(3, int(parameter))
            elif (cmd == 9):
                parameter = raw_input('Please input FSB OSC payload (0-31): ')
                pll_set_osc(4, int(parameter))
            elif (cmd == 10):
                parameter = raw_input('Please input FSB DS payload (0-255): ')
                pll_set_ds(4, int(parameter))
            elif (cmd == 11):
                parameter = raw_input('Please input OP OSC payload (0-31): ')
                pll_set_osc(5, int(parameter))
            elif (cmd == 12):
                parameter = raw_input('Please input OP DS payload (0-255): ')
                pll_set_ds(5, int(parameter))
            elif (cmd == 13):
                parameter = raw_input('Please input ALL OSC payload (0-31): ')
                pll_set_all_osc(int(parameter))
            elif (cmd == 14):
                parameter = raw_input('Please input ALL DS payload (0-255): ')
                pll_set_all_ds(int(parameter))
            elif (cmd == 15):
                pll_reset_tag()
            elif (cmd == 0):
                return;
        except:
            raise


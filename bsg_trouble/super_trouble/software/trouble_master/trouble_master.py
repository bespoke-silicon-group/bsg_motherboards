#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014-2015 UCSD Bespoken Systems Group
# All rights reserved
# Created by Shengye Wang <shengye@ucsd.edu>

from console_util import *
from console_board import console_board
from console_dig_pot import console_voltage_power
from console_cur_mon import console_report_current
from console_set_pll import console_set_pll

prompt_main = '''
-------------------- Trouble Master --------------------
1. Board Version
2. Set Voltage and Power
3. Measure Current
4. Reset Communication
5. Miscellaneous
6. ASIC Emulator Master OFF
7. Program Digital Potential Meter EEPROM
8. Program Digital Potential Meter EEPROM With Current Voltage
9. Set PLL frequency
0. Exit
-------------------- Trouble Master --------------------
'''

misc_info = '''
-------------------- Bespoken Silicon Group --------------------
--------------------  Trouble Master V1.00  --------------------
'''

while (True):
    print prompt_main
    try:
        cmd = raw_input('Please make a selection: ')
        try:
            cmd = int(cmd)
        except:
            print "Unknown command."
            continue
        if (cmd == 1):
            console_board()
        elif (cmd == 2):
            console_voltage_power()
        elif (cmd == 3):
            console_report_current()
        elif (cmd == 4):
            ser.read(256)
            ser.write([cmd_map['CMD_NOP']])
            check_cmd_return()
        elif (cmd == 5):
            print misc_info
        elif (cmd == 6):
            ser.write([cmd_map['CMD_POWER_MASTER_OFF']])
            check_cmd_return()
        elif (cmd == 7):
            ser.write([cmd_map['CMD_PROG_DIG_POT']])
            check_cmd_return()
        elif (cmd == 8):
            ser.write([cmd_map['CMD_PROG_DIG_POT_VOLTAGE_NOW']])
            check_cmd_return()
        elif (cmd == 9):
            console_set_pll()
        elif (cmd == 0):
            exit(0)
    except:
        raise


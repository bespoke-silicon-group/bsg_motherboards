#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014-2015 UCSD Bespoken Systems Group
# All rights reserved
# Created by Shengye Wang <shengye@ucsd.edu>

import serial
ser = serial.Serial('COM9', 115200, timeout=1)

cmd_map = { 'CMD_VER':0x00,
            'CMD_DESC':'~',
            'CMD_POWER_MASTER_OFF':0x10,
            'CMD_POWER_SET_ALLOW':0x11,
            'CMD_PROG_DIG_POT':0x12,
            'CMD_PROG_DIG_POT_VOLTAGE_NOW':0x13,
            'CMD_POWER_CORE_ON':0x20,
            'CMD_POWER_CORE_OFF':0x21,
            'CMD_POWER_CORE_SET':0x22,
            'CMD_POWER_CORE_READ':0x23,
            'CMD_POWER_IO_ON':0x30,
            'CMD_POWER_IO_OFF':0x31,
            'CMD_POWER_IO_SET':0x32,
            'CMD_POWER_IO_READ':0x33,
            'CMD_POWER_PLL_ON':0x34,
            'CMD_POWER_PLL_OFF':0x35,
            'CMD_POWER_PLL_SET':0x36,
            'CMD_POWER_PLL_READ':0x37,
            'CMD_MEASURE_IOCORE':0x40,
            'CMD_MEASURE_MISC':0x41,
            'CMD_PROG_TAG':0x50,
            'CMD_RESET_TAG':0x51,
            'CMD_NOP':0xAA }

SUCCESS_FLAG = '#';
RESPONSE_FLAG = '/';
FAILURE_FLAG = '!';

CMD_RTN_FAIL = 0
CMD_RTN_OK = 1
CMD_RTN_RESPONSE = 2

def check_cmd_return(verbose = True):
    rtn = ser.read()
    if (rtn == SUCCESS_FLAG):
        if (verbose):
            print '[   OK   ]'
        return CMD_RTN_OK
    elif (rtn == RESPONSE_FLAG):
        return CMD_RTN_RESPONSE
    else:
        if (verbose):
            print '[ Failed ]'
        return CMD_RTN_FAIL

def str_to_int(inp_str):
    rtn = []
    for s in inp_str:
        rtn.append(ord(s))
    return rtn


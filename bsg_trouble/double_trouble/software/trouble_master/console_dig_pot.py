#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014-2015 UCSD Bespoken Systems Group
# All rights reserved
# Created by Shengye Wang <shengye@ucsd.edu>

from console_util import *

def set_allow_token(token):
    cmd = bytearray([cmd_map['CMD_POWER_SET_ALLOW'], int(token)])
    ser.write(cmd)
    return check_cmd_return()

def calc_pot_res(voltage):
    res = int((float(voltage) / 0.5 * 1 - 1) / 10 * 256)
    return res

def clac_pot_voltage(res):
    voltage = (res / 256.0 * 10 + 1) * (0.5 / 1)
    return voltage

def set_core_voltage(voltage):
    cmd = bytearray([cmd_map['CMD_POWER_CORE_SET'], calc_pot_res(voltage)])
    ser.write(cmd)
    return check_cmd_return()

def power_on_core():
    ser.write([cmd_map['CMD_POWER_CORE_ON']]);
    return check_cmd_return()

def power_off_core():
    ser.write([cmd_map['CMD_POWER_CORE_OFF']]);
    return check_cmd_return()

def check_core_voltage():
    ser.write([cmd_map['CMD_POWER_CORE_READ']]);
    if check_cmd_return() == CMD_RTN_RESPONSE:
        res = ord(ser.read())
        voltage = clac_pot_voltage(res)
        print 'The core voltage is set to %.4fV.' % voltage
    return check_cmd_return()

def set_io_voltage(voltage):
    cmd = bytearray([cmd_map['CMD_POWER_IO_SET'], calc_pot_res(voltage)])
    ser.write(cmd)
    return check_cmd_return()

def power_on_io():
    ser.write([cmd_map['CMD_POWER_IO_ON']]);
    return check_cmd_return()

def power_off_io():
    ser.write([cmd_map['CMD_POWER_IO_OFF']]);
    return check_cmd_return()

def check_io_voltage():
    ser.write([cmd_map['CMD_POWER_IO_READ']]);
    if check_cmd_return() == CMD_RTN_RESPONSE:
        res = ord(ser.read())
        voltage = clac_pot_voltage(res)
        print 'The IO voltage is set to %.4fV.' % voltage
    return check_cmd_return()

prompt_voltage_and_power = '''
-------------------- Trouble Master --------------------
1. Set Allow Token
2. Set Core Voltage
3. Read Core Voltage Setting
4. Power On Core Supply
5. Power Off Core Supply
6. Set IO Voltage
7. Read IO Voltage Setting
8. Power On IO Supply
9. Power Off IO Supply
0. Return
-------------------- Trouble Master --------------------
'''

def console_voltage_power():
    while (True):
        print prompt_voltage_and_power
        try:
            cmd = raw_input('Please make a selection: ')
            cmd = int(cmd)
            if (cmd == 1):
                parameter = raw_input('Please input allow token [45 = Allow, Other = Disallow]: ')
                set_allow_token(int(parameter))
            elif (cmd == 2):
                parameter = raw_input('Please input core voltage: ')
                set_core_voltage(float(parameter))
            elif (cmd == 3):
                check_core_voltage()
            elif (cmd == 4):
                power_on_core()
            elif (cmd == 5):
                power_off_core()
            elif (cmd == 6):
                parameter = raw_input('Please input IO voltage: ')
                set_io_voltage(float(parameter))
            elif (cmd == 7):
                check_io_voltage()
            elif (cmd == 8):
                power_on_io()
            elif (cmd == 9):
                power_off_io()
            elif (cmd == 0):
                return;
        except:
            raise


#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014-2015 UCSD Bespoken Systems Group
# All rights reserved
# Created by Shengye Wang <shengye@ucsd.edu>

from console_util import *

def convert_temperature(report_val):
    report_val = int(report_val)
    report_val = report_val & ((1 << 12) - 1)
    return float(report_val / 16.0)

def convert_single_end_voltage(report_val):
    report_val = int(report_val)
    if ((1 << 14) & report_val):
        report_val &= ((1 << 14) - 1)
        report_val ^= ((1 << 14) - 1)
        report_val += 1
    else:
        report_val &= ((1 << 14) - 1)
    return report_val * 0.00030518

def convert_differential_voltage(report_val):
    report_val = int(report_val)
    if ((1 << 14) & report_val):
        report_val &= ((1 << 14) - 1)
        report_val ^= ((1 << 14) - 1)
        report_val += 1
    else:
        report_val &= ((1 << 14) - 1)
    return report_val * 0.00001942

def report_current():
    ser.write([cmd_map['CMD_MEASURE_IOCORE']]);
    if check_cmd_return() == CMD_RTN_RESPONSE:
        raw_data = ser.read(4)
        raw_data = str_to_int(raw_data)
        #core_current = convert_differential_voltage((raw_data[0] << 8) | raw_data[1]) / 0.060 * 1000
        #print 'Current is %.4fmA.' % (core_current)
        core_voltage = ((raw_data[1]<<8) | raw_data[0]) * 2**-9 * 1000
        print 'Core voltage is %.2fmV.' % (core_voltage)
        expo_sign = raw_data[3]>>7
        if expo_sign == 1:
            core_current = (((raw_data[3]&0x07)<<8) | raw_data[2]) * 2**-(0x20-(raw_data[3]>>3))
        else:
            core_current = (((raw_data[3]&0x07)<<8) | raw_data[2]) * 2**(raw_data[3]>>3)
        print 'Core current is %.2fA.' % (core_current)
    check_cmd_return()

def set_voltage(param):
    value = int((param - 0.35) * 1000 / 1.953 + 179)
    b0 = value % 0x100
    b1 = value / 0x100
    cmd = bytearray([cmd_map['CMD_MEASURE_MISC'], b0, b1])
    ser.write(cmd);
    check_cmd_return()

prompt_voltage_and_power = '''
-------------------- Trouble Master --------------------
1. Report Current
2. Set TPS546C23 voltage
0. Return
-------------------- Trouble Master --------------------
'''

def console_report_current():
    while (True):
        print prompt_voltage_and_power
        try:
            cmd = raw_input('Please make a selection: ')
            cmd = int(cmd)
            if (cmd == 1):
                report_current()
            elif (cmd == 2):
                parameter = raw_input('Please input TPS546C23 voltage: ')
                set_voltage(float(parameter))
            elif (cmd == 0):
                return;
        except:
            raise



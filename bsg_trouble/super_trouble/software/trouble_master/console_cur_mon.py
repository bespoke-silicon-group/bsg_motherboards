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
        core_current = convert_differential_voltage((raw_data[0] << 8) | raw_data[1]) / 0.060 * 1000
        io_current = convert_differential_voltage((raw_data[2] << 8) | raw_data[3]) / 0.060 * 1000
        print 'Core current is %.4fmA, IO current is %.4fmA.' % (core_current, io_current)
	check_cmd_return()

def report_misc():
    ser.write([cmd_map['CMD_MEASURE_MISC']]);
    if check_cmd_return() == CMD_RTN_RESPONSE:
        raw_data = ser.read(4)
        raw_data = str_to_int(raw_data)
        sensor_temp = convert_temperature((raw_data[0] << 8) | raw_data[1])
        sensor_vcc = convert_single_end_voltage((raw_data[2] << 8) | raw_data[3]) + 2.5
        print 'Board power supply is %.4fV, IO current is %.4f Celsius.' % (sensor_vcc, sensor_temp)
	check_cmd_return()

prompt_voltage_and_power = '''
-------------------- Trouble Master --------------------
1. Report Current
2. Report Sensor Vcc and Temperature
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
                report_misc()
            elif (cmd == 0):
                return;
        except:
            raise



#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright (C) 2014-2015 UCSD Bespoken Systems Group
# All rights reserved
# Created by Shengye Wang <shengye@ucsd.edu>

from console_util import *

def board_ver():
    ser.write([cmd_map['CMD_VER']]);
    if (check_cmd_return(verbose = False) == CMD_RTN_RESPONSE):
        ver = ser.read()
        print 'Board version: %d' % ord(ver)
    else:
        print 'Error while querying board version.'
    return check_cmd_return(ser)

def board_desc():
    ser.write([cmd_map['CMD_DESC']]);
    if (check_cmd_return(verbose = False) == CMD_RTN_RESPONSE):
        rtn = ser.read(32)
        print '%s' % str(rtn)
    else:
        print 'Error while querying board description.'
    return check_cmd_return(ser)

def console_board():
    board_ver()
    board_desc()

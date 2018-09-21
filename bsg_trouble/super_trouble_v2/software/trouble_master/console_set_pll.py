#!/usr/bin/env python
# -*- coding: utf-8 -*-

from console_util import *

def pll_prog_pll(myFile, cmd):

    array = [0x00] * 256
    length = 0
    all_zero = set("0_")
    for line in myFile.readlines() :
        line = line.strip()
        if ((len(line)!=0) and (line[0] != "#")):
            if (not (set(line) <= all_zero)):
                digits_only = filter(lambda m:m.isdigit(), str(line))
                if (digits_only[0:4] == "0011"):
                    break
                array[length] = int(digits_only[12:20], 2)
                array[length+1] = int(digits_only[20:28], 2)
                length = length + 2

    byte_array = [0x00] * length
    for i in range(0, length):
        byte_array[i] = array[i]

    ser.write([cmd])
    ser.write([length])
    ser.write(byte_array)
    return check_cmd_return()


def pll_prog_pll_1():
    myFile = open("bsg_gateway_trace_pll_1.in","r")
    pll_prog_pll(myFile, cmd_map['CMD_PROG_PLL_1'])

def pll_prog_pll_2():
    myFile = open("bsg_gateway_trace_pll_2.in","r")
    pll_prog_pll(myFile, cmd_map['CMD_PROG_PLL_2'])

def pll_prog_pll_3():
    myFile = open("bsg_gateway_trace_pll_3.in","r")
    pll_prog_pll(myFile, cmd_map['CMD_PROG_PLL_3'])
    
def pll_prog_pll_shmoo(i):
    myFile = open("shmoo/"+str(i)+".in","r")
    pll_prog_pll(myFile, cmd_map['CMD_PROG_PLL_3'])    

def pll_run_tests():
    i = 1
    while (i < 56):
        parameter = raw_input('Proceed to test '+str(i)+' (default) or jump to test ')
        if (parameter == ''):
            string = str(i)
            i = i + 1
        else:
            string = parameter
            i = int(parameter) + 1
        myFile = open('trace/trace_test_'+string+'.in','r')
        pll_prog_pll(myFile, cmd_map['CMD_PROG_PLL_3'])


prompt_pll = '''
-------------------- Trouble Master --------------------
1. Program PLL 1
2. Program PLL 2
3. Program PLL 3
4. Run PLL Tests
-------------------------------------------------
49-54, 57-62, 65-66, 73-82: manycore shmoo plot
-------------------------------------------------
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
                pll_prog_pll_1()
            if (cmd == 2):
                pll_prog_pll_2()
            if (cmd == 3):
                pll_prog_pll_3()
            if (cmd == 4):
                pll_run_tests()
            if (cmd >= 49 and cmd <= 82):
                pll_prog_pll_shmoo(cmd)
            elif (cmd == 0):
                return;
        except:
            raise


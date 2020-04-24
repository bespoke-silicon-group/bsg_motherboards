
# import pySerial
import serial
import time

# open serial port
ser = serial.Serial('/dev/ttyUSB0', 115200, timeout=1)

def write_bsg_tag_trace(en, id, rstn, len, data):
    word = 0
    word = word | ((data & ((1<<10)-1)) << 0 )
    word = word | ((len  & ((1<<4 )-1)) << 10)
    word = word | ((rstn & ((1<<1 )-1)) << 14)
    word = word | ((id   & ((1<<6 )-1)) << 15)
    word = word | ((en   & ((1<<3 )-1)) << 21)
    cmd=bytearray([0x34, (word>>0)&0xFF, (word>>8)&0xFF, (word>>16)&0xFF])
    ser.write(cmd)

def clk_gen_async_reset():
    write_bsg_tag_trace(6, 0, 1, 1, 0)
    write_bsg_tag_trace(6, 0, 1, 1, 1)
    write_bsg_tag_trace(6, 0, 1, 1, 0)

def clk_gen_sel_output_clk(osc_id, payload):
    write_bsg_tag_trace(6, osc_id+10, 1, 2, payload)

def osc_trigger(osc_id, payload):
    write_bsg_tag_trace(6, osc_id+4, 1, 1, payload)

def osc_set_raw_speed(osc_id, payload):
    write_bsg_tag_trace(6, osc_id+1, 1, 5, payload)
    osc_trigger(osc_id, 1)
    osc_trigger(osc_id, 0)

def ds_reset(osc_id, init_value):
    write_bsg_tag_trace(6, osc_id+7, 1, 7, (init_value<<1)|(0x1))
    write_bsg_tag_trace(6, osc_id+7, 1, 7, (init_value<<1)|(0x0))

def ds_set_value(osc_id, set_value):
    write_bsg_tag_trace(6, osc_id+7, 1, 7, (set_value<<1))

def clk_gen_init():
    clk_gen_async_reset()
    for i in range(3):
        osc_trigger(i, 0)
        osc_set_raw_speed(i, 31)
        ds_reset(i, 19)
        clk_gen_sel_output_clk(i, 1)

def osc_sweep(osc_id):
    for i in range(32):
        osc_set_raw_speed(osc_id, i)
        print("Current osc speed: %d", i, end='')
        input("")



def tps546c23_calc_current(raw_data):
    expo_sign = raw_data[1]>>7
    if expo_sign == 1:
        core_current = (((raw_data[1]&0x07)<<8) | raw_data[0]) * 2**-(0x20-(raw_data[1]>>3))
    else:
        core_current = (((raw_data[1]&0x07)<<8) | raw_data[0]) * 2**(raw_data[1]>>3)
    return core_current

def tps546c23_calc_voltage(raw_data):
    core_voltage = ((raw_data[1]<<8) | raw_data[0]) * 2**-9 * 1000
    return core_voltage



clk_gen_init()
ds_set_value(0, 1)
ds_set_value(1, 19)
ds_set_value(2, 3)

#osc_sweep(2)

time.sleep(1)
cmd=bytearray([0x61, 0x21, 0x5a, 0x8c, 0x21, 0x5b, 0x02])
ser.write(cmd)
rtn = ser.read(5)
print("Core current is %.4fA" % tps546c23_calc_current(bytearray([rtn[3], rtn[4]])))
cmd=bytearray([0x61, 0x21, 0x5a, 0x8b, 0x21, 0x5b, 0x02])
ser.write(cmd)
rtn = ser.read(5)
print("Core voltage is %.2fmV" % tps546c23_calc_voltage(bytearray([rtn[3], rtn[4]])))



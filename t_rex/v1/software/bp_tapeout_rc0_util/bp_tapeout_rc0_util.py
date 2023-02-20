
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




def chip_reset():
    ### STEP 1: INITIALIZE EVERYTHING
    # Reset both ASIC and GW Prev Link IO Control
    #SEND  en   id=13 d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(7, 13, 1, 3, 6)
    # Reset both ASIC and GW Prev Link CORE Control
    #SEND  en   id=14 d l=2   {up_link_reset, down_link_reset}
    write_bsg_tag_trace(7, 14, 1, 2, 3)
    # Reset both ASIC and GW Prev CT CORE Control
    #SEND  en   id=15 d l=2   {reset, fifo_reset}
    write_bsg_tag_trace(7, 15, 1, 2, 3)
    # Reset both ASIC and GW Next Link IO Control
    #SEND  en   id=16 d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(7, 16, 1, 3, 6)
    # Reset both ASIC and GW Next Link CORE Control
    #SEND  en   id=17 d l=2   {up_link_reset, down_link_reset}
    write_bsg_tag_trace(7, 17, 1, 2, 3)
    # Reset both ASIC and GW Next CT CORE Control
    #SEND  en   id=18 d l=2   {reset, fifo_reset}
    write_bsg_tag_trace(7, 18, 1, 2, 3)
    # Reset ASIC network_a, set cord to 0
    #SEND  en   id=21 d l=5   {reset, cord}
    write_bsg_tag_trace(2, 21, 1, 5, 16)
    write_bsg_tag_trace(4, 21, 1, 5, 16)
    # Reset GW network_a, set cord to 8
    #SEND  en   id=21 d l=5   {reset, cord}
    write_bsg_tag_trace(1, 21, 1, 5, 24)
    #SEND  en   id=25 d l=5   {reset, cord}
    write_bsg_tag_trace(1, 25, 1, 5, 24)
    # Reset ASIC network_b, set cord to i
    #SEND  en   id=22 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 22, 1, 10, 512)
    write_bsg_tag_trace(4, 22, 1, 10, 512)
    #SEND  en   id=23 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 23, 1, 10, 513)
    write_bsg_tag_trace(4, 23, 1, 10, 513)
    #SEND  en   id=24 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 24, 1, 10, 514)
    write_bsg_tag_trace(4, 24, 1, 10, 514)
    #SEND  en   id=25 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 25, 1, 10, 515)
    write_bsg_tag_trace(4, 25, 1, 10, 515)
    #SEND  en   id=26 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 26, 1, 10, 516)
    write_bsg_tag_trace(4, 26, 1, 10, 516)
    #SEND  en   id=27 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 27, 1, 10, 517)
    write_bsg_tag_trace(4, 27, 1, 10, 517)
    #SEND  en   id=28 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 28, 1, 10, 518)
    write_bsg_tag_trace(4, 28, 1, 10, 518)
    #SEND  en   id=29 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 29, 1, 10, 519)
    write_bsg_tag_trace(4, 29, 1, 10, 519)
    #SEND  en   id=30 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 30, 1, 10, 520)
    write_bsg_tag_trace(4, 30, 1, 10, 520)
    #SEND  en   id=31 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 31, 1, 10, 521)
    write_bsg_tag_trace(4, 31, 1, 10, 521)
    #SEND  en   id=32 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 32, 1, 10, 522)
    write_bsg_tag_trace(4, 32, 1, 10, 522)
    #SEND  en   id=33 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 33, 1, 10, 523)
    write_bsg_tag_trace(4, 33, 1, 10, 523)
    # Reset GW network_b, set cord to 32
    #SEND  en   id=22 d l=10   {reset, cord}
    write_bsg_tag_trace(1, 22, 1, 10, 544)
    #SEND  en   id=26 d l=10   {reset, cord}
    write_bsg_tag_trace(1, 26, 1, 10, 544)
    # Reset ASIC Manycore, set dest cord to 8
    #SEND  en   id=19 d l=5   {reset, cord}
    write_bsg_tag_trace(2, 19, 1, 5, 24)
    write_bsg_tag_trace(4, 19, 1, 5, 24)
    # Reset GW Manycore, set dest cord to 0
    #SEND  en   id=19 d l=5   {reset, cord}
    write_bsg_tag_trace(1, 19, 1, 5, 16)
    #SEND  en   id=23 d l=5   {reset, cord}
    write_bsg_tag_trace(1, 23, 1, 5, 16)
    # Reset ASIC Vcache, set dest cord to 32
    #SEND  en   id=20 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 20, 1, 10, 544)
    write_bsg_tag_trace(4, 20, 1, 10, 544)
    # Reset GW Vcache, set dest cord to 0
    #SEND  en   id=20 d l=10   {reset, cord}
    write_bsg_tag_trace(1, 20, 1, 10, 512)
    #SEND  en   id=24 d l=10   {reset, cord}
    write_bsg_tag_trace(1, 24, 1, 10, 512)
    ### STEP 2: Perform async token resets
    # Async token reset for IC1 GW Prev IO Link
    #SEND  en   id=13 d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(3, 13, 1, 3, 7)
    write_bsg_tag_trace(3, 13, 1, 3, 6)
    # Async token reset for IC0 IC1 Next IO Link
    #SEND  en   id=16 d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(6, 16, 1, 3, 7)
    write_bsg_tag_trace(6, 16, 1, 3, 6)
    ### STEP 3: De-assert Upstream IO Links reset
    # De-assert upstream reset for IC0 IC1 Prev IO Link
    #SEND  en   id=13 d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(1, 13, 1, 3, 2)
    # De-assert upstream reset for GW IC0 Next IO Link
    #SEND  en   id=16 d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(2, 16, 1, 3, 2)
    ### STEP 4: De-assert Downstream IO Links reset
    # De-assert downstream reset for IC0 IC1 Prev IO Link
    #SEND  en   id=13 d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(1, 13, 1, 3, 0)
    # De-assert downstream reset for GW IC0 Next IO Link
    #SEND  en   id=16 d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(2, 16, 1, 3, 0)
    ### STEP 5/6: De-assert Upstream/Downstream CORE Links reset
    # De-assert upstream/downstream reset for IC0 IC1 Prev CORE Link
    #SEND  en   id=14 d l=2   {up_link_reset, down_link_reset}
    write_bsg_tag_trace(1, 14, 1, 2, 0)
    # De-assert upstream/downstream reset for GW IC0 Next CORE Link
    #SEND  en   id=17 d l=2   {up_link_reset, down_link_reset}
    write_bsg_tag_trace(2, 17, 1, 2, 0)
    ### STEP 7: De-assert CT reset and fifo reset
    # De-assert reset and fifo_reset for IC0 IC1 Prev CT CORE Control
    #SEND  en   id=15 d l=2   {reset, fifo_reset}
    write_bsg_tag_trace(1, 15, 1, 2, 0)
    # De-assert reset and fifo_reset for GW IC0 Next CT CORE Control
    #SEND  en   id=18 d l=2   {reset, fifo_reset}
    write_bsg_tag_trace(2, 18, 1, 2, 0)
    ### STEP 8: De-assert Router reset
    # De-assert reset for ASIC network_a
    #SEND  en   id=21 d l=5   {reset, cord}
    write_bsg_tag_trace(2, 21, 1, 5, 0)
    write_bsg_tag_trace(4, 21, 1, 5, 0)
    # De-assert reset for GW network_a
    #SEND  en   id=21 d l=5   {reset, cord}
    write_bsg_tag_trace(1, 21, 1, 5, 8)
    #SEND  en   id=25 d l=5   {reset, cord}
    write_bsg_tag_trace(1, 25, 1, 5, 8)
    # De-assert reset for ASIC network_b
    #SEND  en   id=22 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 22, 1, 10, 0)
    write_bsg_tag_trace(4, 22, 1, 10, 0)
    #SEND  en   id=23 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 23, 1, 10, 1)
    write_bsg_tag_trace(4, 23, 1, 10, 1)
    #SEND  en   id=24 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 24, 1, 10, 2)
    write_bsg_tag_trace(4, 24, 1, 10, 2)
    #SEND  en   id=25 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 25, 1, 10, 3)
    write_bsg_tag_trace(4, 25, 1, 10, 3)
    #SEND  en   id=26 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 26, 1, 10, 4)
    write_bsg_tag_trace(4, 26, 1, 10, 4)
    #SEND  en   id=27 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 27, 1, 10, 5)
    write_bsg_tag_trace(4, 27, 1, 10, 5)
    #SEND  en   id=28 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 28, 1, 10, 6)
    write_bsg_tag_trace(4, 28, 1, 10, 6)
    #SEND  en   id=29 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 29, 1, 10, 7)
    write_bsg_tag_trace(4, 29, 1, 10, 7)
    #SEND  en   id=30 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 30, 1, 10, 8)
    write_bsg_tag_trace(4, 30, 1, 10, 8)
    #SEND  en   id=31 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 31, 1, 10, 9)
    write_bsg_tag_trace(4, 31, 1, 10, 9)
    #SEND  en   id=32 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 32, 1, 10, 10)
    write_bsg_tag_trace(4, 32, 1, 10, 10)
    #SEND  en   id=33 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 33, 1, 10, 11)
    write_bsg_tag_trace(4, 33, 1, 10, 11)
    # De-assert reset for GW network_b
    #SEND  en   id=22 d l=10   {reset, cord}
    write_bsg_tag_trace(1, 22, 1, 10, 32)
    #SEND  en   id=26 d l=10   {reset, cord}
    write_bsg_tag_trace(1, 26, 1, 10, 32)
    ### STEP 9: De-assert Manycore reset
    # De-assert reset for ASIC Manycore
    #SEND  en   id=19 d l=5   {reset, cord}
    write_bsg_tag_trace(2, 19, 1, 5, 8)
    write_bsg_tag_trace(4, 19, 1, 5, 8)
    # De-assert reset for GW Manycore
    #SEND  en   id=19 d l=5   {reset, cord}
    write_bsg_tag_trace(1, 19, 1, 5, 0)
    #SEND  en   id=23 d l=5   {reset, cord}
    write_bsg_tag_trace(1, 23, 1, 5, 0)
    # De-assert reset for ASIC Vcache
    #SEND  en   id=20 d l=10   {reset, cord}
    write_bsg_tag_trace(2, 20, 1, 10, 32)
    write_bsg_tag_trace(4, 20, 1, 10, 32)
    # De-assert reset for GW Vcache
    #SEND  en   id=20 d l=10   {reset, cord}
    write_bsg_tag_trace(1, 20, 1, 10, 0)
    #SEND  en   id=24 d l=10   {reset, cord}
    write_bsg_tag_trace(1, 24, 1, 10, 0)


def write_gpio(gpio_id, value):
    data = (gpio_id & 0x7F) | ((value & 0x01) << 7)
    cmd=bytearray([0x15, (data & 0xFF)])
    ser.write(cmd)


clk_gen_init()

osc_set_raw_speed(0, 8)
ds_set_value(0, 0)
osc_set_raw_speed(1, 16)
ds_set_value(1, 1)
osc_set_raw_speed(2, 29)
ds_set_value(2, 2)

write_gpio(12, 0)
write_gpio(11, 1)

chip_reset()

#osc_sweep(2)

time.sleep(0.5)
cmd=bytearray([0x61, 0x21, 0x5a, 0x8c, 0x21, 0x5b, 0x02])
ser.write(cmd)
rtn = ser.read(5)
print("Core current is %.4fA" % tps546c23_calc_current(bytearray([rtn[3], rtn[4]])))
cmd=bytearray([0x61, 0x21, 0x5a, 0x8b, 0x21, 0x5b, 0x02])
ser.write(cmd)
rtn = ser.read(5)
print("Core voltage is %.2fmV" % tps546c23_calc_voltage(bytearray([rtn[3], rtn[4]])))



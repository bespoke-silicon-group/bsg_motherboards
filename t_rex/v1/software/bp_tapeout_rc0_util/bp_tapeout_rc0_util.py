
# import pySerial
import serial
import time

# open serial port
ser = serial.Serial('/dev/ttyUSB0', 115200, timeout=1)

def write_bsg_tag_trace(en, id, rstn, len, data):
    word = 0
    word = word | ((data & ((1<<9 )-1)) << 0 )
    word = word | ((len  & ((1<<4 )-1)) << 9 )
    word = word | ((rstn & ((1<<1 )-1)) << 13)
    word = word | ((id   & ((1<<6 )-1)) << 14)
    word = word | ((en   & ((1<<2 )-1)) << 20)
    cmd=bytearray([0x34, (word>>0)&0xFF, (word>>8)&0xFF, (word>>16)&0xFF])
    ser.write(cmd)

def clk_gen_async_reset():
    write_bsg_tag_trace(1, 0, 1, 1, 0)
    write_bsg_tag_trace(1, 0, 1, 1, 1)
    write_bsg_tag_trace(1, 0, 1, 1, 0)

def clk_gen_sel_output_clk(osc_id, payload):
    write_bsg_tag_trace(1, osc_id+10, 1, 2, payload)

def osc_trigger(osc_id, payload):
    write_bsg_tag_trace(1, osc_id+4, 1, 1, payload)

def osc_set_raw_speed(osc_id, payload):
    write_bsg_tag_trace(1, osc_id+1, 1, 5, payload)
    osc_trigger(osc_id, 1)
    osc_trigger(osc_id, 0)

def ds_reset(osc_id, init_value):
    write_bsg_tag_trace(1, osc_id+7, 1, 7, (init_value<<1)|(0x1))
    write_bsg_tag_trace(1, osc_id+7, 1, 7, (init_value<<1)|(0x0))

def ds_set_value(osc_id, set_value):
    write_bsg_tag_trace(1, osc_id+7, 1, 7, (set_value<<1))

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
    #SEND  en   id=13  d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(3, 13, 1, 3, 6)
    
    # Reset both ASIC and GW Prev Link CORE Control
    #SEND  en   id=14  d l=2   {up_link_reset, down_link_reset}
    write_bsg_tag_trace(3, 14, 1, 2, 3)
    
    # Reset both ASIC and GW Prev CT CORE Control
    #SEND  en   id=15  d l=2   {reset, fifo_reset}
    write_bsg_tag_trace(3, 15, 1, 2, 3)
    
    # Reset both ASIC and GW Next Link IO Control
    #SEND  en   id=16  d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(3, 16, 1, 3, 6)
    
    # Reset both ASIC and GW Next Link CORE Control
    #SEND  en   id=17  d l=2   {up_link_reset, down_link_reset}
    write_bsg_tag_trace(3, 17, 1, 2, 3)
    
    # Reset both ASIC and GW Next CT CORE Control
    #SEND  en   id=18  d l=2   {reset, fifo_reset}
    write_bsg_tag_trace(3, 18, 1, 2, 3)
    
    # Reset ASIC Routers and set cord to i
    #SEND  en   id=19  d l=9   {reset, cord=1}
    write_bsg_tag_trace(1, 19, 1, 9, 257)
    #SEND  en   id=20  d l=9   {reset, cord=2}
    write_bsg_tag_trace(1, 20, 1, 9, 258)
    #SEND  en   id=21  d l=9   {reset, cord=3}
    write_bsg_tag_trace(1, 21, 1, 9, 259)
    #SEND  en   id=22  d l=9   {reset, cord=4}
    write_bsg_tag_trace(1, 22, 1, 9, 260)
    #SEND  en   id=23  d l=9   {reset, cord=5}
    write_bsg_tag_trace(1, 23, 1, 9, 261)
    
    # Reset GW Router Control and set cord to 0
    #SEND  en   id=19  d l=9   {reset, cord=0}
    write_bsg_tag_trace(2, 19, 1, 9, 256)
    
    # Reset GW BlackParrot CFG and set dest cord to 3 (CLINT)
    #SEND  en   id=36  d l=9   {reset, cord=9}
    write_bsg_tag_trace(2, 36, 1, 9, 259)
    
    # Reset ASIC BackParrot Control and set dest cord to 0 (DRAM)
    #SEND  en   id=37 d l=9   {reset, cord=0}
    write_bsg_tag_trace(1, 37, 1, 9, 256)
    
    # Reset GW BlackParrot Control and set dest cord to 0 (DRAM)
    #SEND  en   id=37 d l=9   {reset, cord=0}
    write_bsg_tag_trace(2, 37, 1, 9, 256)
    
    ### STEP 2: Perform async token resets
    
    # Async token reset for ASIC Prev IO Link
    #SEND  en   id=13  d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(1, 13, 1, 3, 7)
    write_bsg_tag_trace(1, 13, 1, 3, 6)
    
    # Assert async token reset for GW Next IO Link
    #SEND  en   id=16  d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(2, 16, 1, 3, 7)
    write_bsg_tag_trace(2, 16, 1, 3, 6)
    
    ### STEP 3: De-assert Upstream IO Links reset
    
    # De-assert upstream reset for ASIC Prev IO Link
    #SEND  en   id=13  d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(1, 13, 1, 3, 2)
    
    # De-assert upstream reset for GW Next IO Link
    #SEND  en   id=16  d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(2, 16, 1, 3, 2)
    
    ### STEP 4: De-assert Downstream IO Links reset
    
    # De-assert downstream reset for ASIC Prev IO Link
    #SEND  en   id=13  d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(1, 13, 1, 3, 0)
    
    # De-assert downstream reset for GW Next IO Link
    #SEND  en   id=16  d l=3   {up_link_reset, down_link_reset, async_token_reset}
    write_bsg_tag_trace(2, 16, 1, 3, 0)
    
    ### STEP 5/6: De-assert Upstream/Downstream CORE Links reset
    
    # De-assert upstream/downstream reset for ASIC Prev CORE Link
    #SEND  en   id=14  d l=2   {up_link_reset, down_link_reset}
    write_bsg_tag_trace(1, 14, 1, 2, 0)
    
    # De-assert upstream/downstream reset for GW Next CORE Link
    #SEND  en   id=17  d l=2   {up_link_reset, down_link_reset}
    write_bsg_tag_trace(2, 17, 1, 2, 0)
    
    ### STEP 7: De-assert CT reset and fifo reset
    
    # De-assert reset and fifo_reset for ASIC Prev CT CORE Control
    #SEND  en   id=15  d l=2   {reset, fifo_reset}
    write_bsg_tag_trace(1, 15, 1, 2, 0)
    
    # De-assert reset and fifo_reset for GW Next CT CORE Control
    #SEND  en   id=18  d l=2   {reset, fifo_reset}
    write_bsg_tag_trace(2, 18, 1, 2, 0)
    
    ### STEP 8: De-assert Router reset
    
    # Deassert reset ASIC Routers and set cord to i
    #SEND  en   id=19  d l=9   {reset, cord=1}
    write_bsg_tag_trace(1, 19, 1, 9, 1)
    #SEND  en   id=20  d l=9   {reset, cord=2}
    write_bsg_tag_trace(1, 20, 1, 9, 2)
    #SEND  en   id=21  d l=9   {reset, cord=3}
    write_bsg_tag_trace(1, 21, 1, 9, 3)
    #SEND  en   id=22  d l=9   {reset, cord=4}
    write_bsg_tag_trace(1, 22, 1, 9, 4)
    #SEND  en   id=23  d l=9   {reset, cord=5}
    write_bsg_tag_trace(1, 23, 1, 9, 5)
    write_bsg_tag_trace(1, 30, 1, 9, 12)
    
    # Deassert reset GW Router Control and set cord to 0
    #SEND  en   id=19  d l=9   {reset, cord=0}
    write_bsg_tag_trace(2, 19, 1, 9, 0)
    
    # Deassert reset GW BlackParrot CFG and set dest cord to 3 (CLINT)
    #SEND  en   id=36  d l=9   {reset, cord=9}
    write_bsg_tag_trace(2, 36, 1, 9, 3)
    
    # Deassert reset ASIC BackParrot Control and set dest cord to 0 (DRAM)
    #SEND  en   id=37 d l=9   {reset, cord=0}
    write_bsg_tag_trace(1, 37, 1, 9, 0)
    
    # Deassert reset GW BlackParrot Control and set dest cord to 0 (DRAM)
    #SEND  en   id=37 d l=9   {reset, cord=0}
    write_bsg_tag_trace(2, 37, 1, 9, 0)


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



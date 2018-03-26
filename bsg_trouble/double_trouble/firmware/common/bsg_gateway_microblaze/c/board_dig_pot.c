//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: board_dig_pot.c
//
// Authors: Shengye Wang - shengye@eng.ucsd.edu
//------------------------------------------------------------

#include "xparameters.h"
#include "xiic.h"
#include "board_dig_pot.h"
#include "xil_exception.h"
#include "board_info.h"

// IIC Utilities

#define IIC_BASE_ADDRESS    XPAR_AXI_IIC_DIG_POT_BASEADDR

static int write_to_digpot(u8* write_buffer, u16 byte_count)
{
    u16 sent_count;
    u32 status_reg;

    // wait IIC to be idle
    while (((status_reg = XIic_ReadReg(IIC_BASE_ADDRESS, XIIC_SR_REG_OFFSET)) &
        (XIIC_SR_RX_FIFO_EMPTY_MASK | XIIC_SR_TX_FIFO_EMPTY_MASK | XIIC_SR_BUS_BUSY_MASK))
        != (XIIC_SR_RX_FIFO_EMPTY_MASK | XIIC_SR_TX_FIFO_EMPTY_MASK));

    // start sending
    sent_count = 0;
    while (sent_count == 0) {
        status_reg = XIic_ReadReg(IIC_BASE_ADDRESS, XIIC_SR_REG_OFFSET);
        if (!(status_reg & XIIC_SR_BUS_BUSY_MASK)) {
            sent_count = XIic_DynSend(IIC_BASE_ADDRESS, IIC_DIG_POT_SLAVE_ADDRESS, write_buffer, byte_count, XIIC_STOP);
        }
    }

    return XST_SUCCESS;
}

static int read_from_digpot(u8 command, u8 parameter, u8* read_buffer, u16 byte_count)
{
    u16 sent_count;
    u16 recv_count;
    u32 status_reg;

    // prepare data to send
    u8 send_buffer[2];
    send_buffer[0] = command;
    send_buffer[1] = parameter;

    // wait IIC to be idle
    while (((status_reg = XIic_ReadReg(IIC_BASE_ADDRESS, XIIC_SR_REG_OFFSET)) &
        (XIIC_SR_RX_FIFO_EMPTY_MASK | XIIC_SR_TX_FIFO_EMPTY_MASK | XIIC_SR_BUS_BUSY_MASK))
        != (XIIC_SR_RX_FIFO_EMPTY_MASK | XIIC_SR_TX_FIFO_EMPTY_MASK));

    // write command
    sent_count = 0;
    while (sent_count == 0) {
        status_reg = XIic_ReadReg(IIC_BASE_ADDRESS, XIIC_SR_REG_OFFSET);
        if (!(status_reg & XIIC_SR_BUS_BUSY_MASK)) {
            sent_count = XIic_DynSend(IIC_BASE_ADDRESS, IIC_DIG_POT_SLAVE_ADDRESS, send_buffer, 2, XIIC_REPEATED_START);
        }
    }
    if (sent_count != 2) return XST_FAILURE;

    // start receiving
    recv_count = XIic_DynRecv(IIC_BASE_ADDRESS, IIC_DIG_POT_SLAVE_ADDRESS, read_buffer, byte_count);

    return (recv_count == byte_count) ? XST_SUCCESS : XST_FAILURE;
}

u8 write_buffer[2];

// Initialization
int dig_pot_init()
{
    int status;
    u32 status_reg;
    status = XIic_DynInit(IIC_BASE_ADDRESS);
    if (status != XST_SUCCESS) return XST_FAILURE;
    while (((status_reg = XIic_ReadReg(IIC_BASE_ADDRESS, XIIC_SR_REG_OFFSET)) &
        (XIIC_SR_RX_FIFO_EMPTY_MASK | XIIC_SR_TX_FIFO_EMPTY_MASK | XIIC_SR_BUS_BUSY_MASK))
        != (XIIC_SR_RX_FIFO_EMPTY_MASK | XIIC_SR_TX_FIFO_EMPTY_MASK));

    // Write control register, addr = 0xD0, val = no burst, linear gain, eeprom program disabled, RDAC protected
    write_buffer[0] = 0xD0;
    write_buffer[1] = 0x04;
    status = write_to_digpot(write_buffer, 2);
    if (status != XST_SUCCESS) return XST_FAILURE;

    return XST_SUCCESS;
}

// Program EEPROM
int dig_pot_prog_eeprom_default()
{
    u8 write_buffer[2];
    int status;

    // Write control register, addr = 0xD0, val = no burst, linear gain, eeprom program ENABLED, RDAC NO protect
    write_buffer[0] = 0xD0;
    write_buffer[1] = 0x07;
    status = write_to_digpot(write_buffer, sizeof(write_buffer));
    if (status != XST_SUCCESS) return XST_FAILURE;

    // Program eeprom for CORE
    write_buffer[0] = 0x80;
    write_buffer[1] = CORE_DEFAULT_RES;
    status = write_to_digpot(write_buffer, sizeof(write_buffer));
    if (status != XST_SUCCESS) return XST_FAILURE;

    // Program eeprom for IO
    write_buffer[0] = 0x82;
    write_buffer[1] = IO_DEFAULT_RES;
    status = write_to_digpot(write_buffer, sizeof(write_buffer));
    if (status != XST_SUCCESS) return XST_FAILURE;

    // Software reset
    write_buffer[0] = 0xB0;
    write_buffer[1] = 0x00;
    status = write_to_digpot(write_buffer, sizeof(write_buffer));
    if (status != XST_SUCCESS) return XST_FAILURE;

    // Write control register, addr = 0xD0, val = no burst, linear gain, eeprom program disabled, RDAC no protected
    write_buffer[0] = 0xD0;
    write_buffer[1] = 0x04;
    status = write_to_digpot(write_buffer, sizeof(write_buffer));
    if (status != XST_SUCCESS) return XST_FAILURE;

    return XST_SUCCESS;
}

int dig_pot_prog_eeprom_voltage_now()
{
    u8 write_buffer[2];
    int status;
	
	u8 IO_voltage_now;
	u8 CO_voltage_now;
	
	// Read current IO voltage
	status = dig_pot_report_io(&IO_voltage_now);
	if (status != XST_SUCCESS) return XST_FAILURE;
	
	// Real current CO voltage
	status = dig_pot_report_core(&CO_voltage_now);
	if (status != XST_SUCCESS) return XST_FAILURE;
	
    // Write control register, addr = 0xD0, val = no burst, linear gain, eeprom program ENABLED, RDAC NO protect
    write_buffer[0] = 0xD0;
    write_buffer[1] = 0x07;
    status = write_to_digpot(write_buffer, sizeof(write_buffer));
    if (status != XST_SUCCESS) return XST_FAILURE;

    // Program eeprom for CORE
    write_buffer[0] = 0x80;
    write_buffer[1] = CO_voltage_now;
    status = write_to_digpot(write_buffer, sizeof(write_buffer));
    if (status != XST_SUCCESS) return XST_FAILURE;

    // Program eeprom for IO
    write_buffer[0] = 0x82;
    write_buffer[1] = IO_voltage_now;
    status = write_to_digpot(write_buffer, sizeof(write_buffer));
    if (status != XST_SUCCESS) return XST_FAILURE;

    // Software reset
    write_buffer[0] = 0xB0;
    write_buffer[1] = 0x00;
    status = write_to_digpot(write_buffer, sizeof(write_buffer));
    if (status != XST_SUCCESS) return XST_FAILURE;

    // Write control register, addr = 0xD0, val = no burst, linear gain, eeprom program disabled, RDAC no protected
    write_buffer[0] = 0xD0;
    write_buffer[1] = 0x04;
    status = write_to_digpot(write_buffer, sizeof(write_buffer));
    if (status != XST_SUCCESS) return XST_FAILURE;

    return XST_SUCCESS;
}

int dig_pot_allow_update()
{
    // Write control register, addr = 0xD0, val = no burst, linear gain, eeprom program disabled, RDAC NO protect
    write_buffer[0] = 0xD0;
    write_buffer[1] = 0x05;
    return write_to_digpot(write_buffer, sizeof(write_buffer));
}

int dig_pot_disallow_update()
{
    // Write control register, addr = 0xD0, val = no burst, linear gain, eeprom program disabled, RDAC protect
    write_buffer[0] = 0xD0;
    write_buffer[1] = 0x04;
    return write_to_digpot(write_buffer, sizeof(write_buffer));
}

int dig_pot_update_core(u8 val)
{
    int status;
    u8 read_back_val;
    if (val > CORE_MAX_RES) return XST_FAILURE;
    write_buffer[0] = 0x10;
    write_buffer[1] = val;
    status = write_to_digpot(write_buffer, 2);
    if (status != XST_SUCCESS) return XST_FAILURE;
    status = dig_pot_report_core(&read_back_val);
    if (status != XST_SUCCESS) return XST_FAILURE;
    if (read_back_val != val) return XST_FAILURE;
    return XST_SUCCESS;
}

int dig_pot_report_core(u8* rtn)
{
    int status;
    status = read_from_digpot(0x30, 0x03, rtn, 1);
    if (status != XST_SUCCESS) return XST_FAILURE;
    return XST_SUCCESS;
}

int dig_pot_update_io(u8 val)
{
    int status;
    u8 read_back_val;
    if (val > IO_MAX_RES) return XST_FAILURE;
    write_buffer[0] = 0x11;
    write_buffer[1] = val;
    status = write_to_digpot(write_buffer, 2);
    if (status != XST_SUCCESS) return XST_FAILURE;
    status = dig_pot_report_io(&read_back_val);
    if (status != XST_SUCCESS) return XST_FAILURE;
    if (read_back_val != val) return XST_FAILURE;
    return XST_SUCCESS;
}

int dig_pot_report_io(u8* rtn)
{
    int status;
    status = read_from_digpot(0x31, 0x03, rtn, 1);
    if (status != XST_SUCCESS) return XST_FAILURE;
    return XST_SUCCESS;
}


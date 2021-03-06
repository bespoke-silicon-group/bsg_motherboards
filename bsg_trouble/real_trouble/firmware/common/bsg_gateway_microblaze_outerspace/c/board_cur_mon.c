//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: board_cur_mon.c
//
// Authors: Shengye Wang - shengye@eng.ucsd.edu
//------------------------------------------------------------

#include "xparameters.h"
#include "xiic.h"
#include "board_cur_mon.h"
#include "xil_exception.h"

u8 cur_mon_misc[4];
u8 cur_mon_cur[4];

// IIC Utilities
#define IIC_BASE_ADDRESS    XPAR_AXI_IIC_CUR_MON_BASEADDR

static int write_to_curmon(u8* write_buffer, u16 byte_count)
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
            sent_count = XIic_DynSend(IIC_BASE_ADDRESS, IIC_CUR_MON_SLAVE_ADDRESS, write_buffer, byte_count, XIIC_STOP);
        }
    }

    return (sent_count == byte_count) ? XST_SUCCESS : XST_FAILURE;
}

static int read_from_curmon(u8 reg_addr, u8* read_buffer, u16 byte_count)
{
    u16 sent_count;
    u16 recv_count;
    u32 status_reg;

    // wait IIC to be idle
    while (((status_reg = XIic_ReadReg(IIC_BASE_ADDRESS, XIIC_SR_REG_OFFSET)) &
        (XIIC_SR_RX_FIFO_EMPTY_MASK | XIIC_SR_TX_FIFO_EMPTY_MASK | XIIC_SR_BUS_BUSY_MASK))
        != (XIIC_SR_RX_FIFO_EMPTY_MASK | XIIC_SR_TX_FIFO_EMPTY_MASK));

    // write command
    sent_count = 0;
    while (sent_count == 0) {
        status_reg = XIic_ReadReg(IIC_BASE_ADDRESS, XIIC_SR_REG_OFFSET);
        if (!(status_reg & XIIC_SR_BUS_BUSY_MASK)) {
            sent_count = XIic_DynSend(IIC_BASE_ADDRESS, IIC_CUR_MON_SLAVE_ADDRESS, &reg_addr, 1, XIIC_REPEATED_START);
        }
    }
    if (sent_count != 1) return XST_FAILURE;

    // start receiving
    recv_count = XIic_DynRecv(IIC_BASE_ADDRESS, IIC_CUR_MON_SLAVE_ADDRESS, read_buffer, byte_count);

    return (recv_count == byte_count) ? XST_SUCCESS : XST_FAILURE;
}

u8 write_buffer[2];

// Initialization
int cur_mon_init()
{
    int status;
    u32 status_reg;
    status = XIic_DynInit(IIC_BASE_ADDRESS);
    if (status != XST_SUCCESS) return XST_FAILURE;
    while (((status_reg = XIic_ReadReg(IIC_BASE_ADDRESS, XIIC_SR_REG_OFFSET)) &
        (XIIC_SR_RX_FIFO_EMPTY_MASK | XIIC_SR_TX_FIFO_EMPTY_MASK | XIIC_SR_BUS_BUSY_MASK))
        != (XIIC_SR_RX_FIFO_EMPTY_MASK | XIIC_SR_TX_FIFO_EMPTY_MASK));

    // Write control register, addr = 0x01, val = Celsius, Repeated, Measure All, Differencial
    write_buffer[0] = 0x01;
    write_buffer[1] = 0x1E;
    status = write_to_curmon(write_buffer, 2);
    if (status != XST_SUCCESS) return XST_FAILURE;

    // Write trigger register, addr = 0x02, val = 0xFF (any)
    write_buffer[0] = 0x02;
    write_buffer[1] = 0xFF;
    status = write_to_curmon(write_buffer, 2);
    if (status != XST_SUCCESS) return XST_FAILURE;

    return XST_SUCCESS;
}

// Read the status register
static int cur_mon_read_status(u8* buf)
{
    return read_from_curmon(0x00, buf, 1);
}

// Update current array, these data will be decoded in the PC-end
int cur_mon_update_cur()
{
    u8 cur_state;
    int status;
    status = cur_mon_read_status(&cur_state);
    if (status != XST_SUCCESS) return XST_FAILURE;
    if (cur_state & (1 << 2)) { // V1 - V2 ready
        status = read_from_curmon(0x06, &cur_mon_cur[0], 2);
        if (status != XST_SUCCESS) return XST_FAILURE;
    }
    if (cur_state & (1 << 4)) { // V3 - V4 ready
        status = read_from_curmon(0x0A, &cur_mon_cur[2], 2);
        if (status != XST_SUCCESS) return XST_FAILURE;
    }
    return XST_SUCCESS;
}

// Update internal temp and Vcc, these data will be decoded in the PC-end
int cur_mon_update_misc()
{
    u8 cur_state;
    int status;
    status = cur_mon_read_status(&cur_state);
    if (status != XST_SUCCESS) return XST_FAILURE;
    if (cur_state & (1 << 1)) { // Internal Temperature
        status = read_from_curmon(0x04, &cur_mon_misc[0], 2);
        if (status != XST_SUCCESS) return XST_FAILURE;
    }
    if (cur_state & (1 << 6)) { // Sensor Vcc
        status = read_from_curmon(0x0E, &cur_mon_misc[2], 2);
        if (status != XST_SUCCESS) return XST_FAILURE;
    }
    return XST_SUCCESS;
}


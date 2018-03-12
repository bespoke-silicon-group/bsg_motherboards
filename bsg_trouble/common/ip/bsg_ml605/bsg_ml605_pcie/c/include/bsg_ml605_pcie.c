//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_pcie.c
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//          Qiaoshi Zheng - q5zheng@eng.ucsd.edu
//------------------------------------------------------------

#include "bsg_ml605_pcie.h"

bsg_ml605_pcie_device::bsg_ml605_pcie_device() {

    open_device();

    in_list = new vector<list<unsigned int> >(channel_number);

    verify_iom(in_list != NULL, (stderr, "Error allocating in_list\n"));

    current_channel = 0;

    initiate_connection();

}

bsg_ml605_pcie_device::~bsg_ml605_pcie_device() {

    delete in_list;
    delete l2f_fifo_status_vec;

    munmap(base_addr, 0x00001000);

    close(fd);

}

void bsg_ml605_pcie_device::handle_pci_io(int channel) {

    int packet_number = *(channel_array[channel].get_f2l_fifo_status);

    for (int i = 0; i < packet_number; i++) {
        (*in_list)[channel].push_back((*(channel_array[channel].read_fifo_data)));
    }

}

int bsg_ml605_pcie_device::write_packet_async_if_available(int channel, unsigned int data) {

    if ((*l2f_fifo_status_vec)[channel] > 0) {

        write_packet_async(channel, data);

        return 1;
    }
    else {

        (*l2f_fifo_status_vec)[channel] = *(channel_array[channel].get_l2f_fifo_status);

        if ((*l2f_fifo_status_vec)[channel] > 0) {

            write_packet_async(channel, data);

            return 1;
        }

        return 0;
    }

}

void bsg_ml605_pcie_device::write_packet_async(int channel, unsigned int data) {

    verify_iom(channel < channel_number, (stderr, "Error writing to invalid channel %d\n", channel));

    *(channel_array[channel].write_fifo_data) = data;

}


int bsg_ml605_pcie_device::read_packet_async(int channel, unsigned int &data) {

    if ((*in_list)[channel].empty()) {

        handle_pci_io(channel);

        if (!(*in_list)[channel].empty()) {
            data = (*in_list)[channel].front();
            (*in_list)[channel].pop_front();

            return 1;
        }

        return 0;
    }
    else {

        data = (*in_list)[channel].front();
        (*in_list)[channel].pop_front();

        return 1;
    }

}

void bsg_ml605_pcie_device::read_packet_blocking(int channel, unsigned int &data) {

    while (1) {
        if(!read_packet_async(channel, data))
            check_after_sleep(1);
        else
            break;
    }

}

int bsg_ml605_pcie_device::peek_packet_async(int channel, unsigned int &data) {

    if ((*in_list)[channel].empty()) {

        handle_pci_io(channel);

        if (!(*in_list)[channel].empty()) {
            data = (*in_list)[channel].front();
            return 1;
        }

        return 0;
    }
    else {

        data = (*in_list)[channel].front();

        return 1;
    }

}

void bsg_ml605_pcie_device::open_device() {

    const char *device_path = "/dev/bsg_ml605_pcie";

    struct stat buffer;

    if (stat(device_path, &buffer)) {

        printf("ERROR: device not found in /dev/bsg_ml605_pcie. Did you load the kernel module?\n");
        exit(EXIT_FAILURE);

    }

    if (access(device_path, R_OK)) {

        printf("ERROR: wrong read permission in /dev/bsg_ml605_pcie. Did you chmod 666 /dev/bsg_ml605_pcie?\n");
        exit(EXIT_FAILURE);

    }

    if (access(device_path, W_OK)) {

        printf("ERROR: wrong write permission in /dev/bsg_ml605_pcie. Did you chmod 666 /dev/bsg_ml605_pcie?\n");
        exit(EXIT_FAILURE);

    }

    fd = open(device_path, O_RDWR);

    base_addr = mmap(0, 0x00001000, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

    // channel, reset, test and status register are defined in bsg_ml605_pio_ep.v
    channel_register = (unsigned int *) ((long int)base_addr + CHANNEL_REGISTER_ADDR);
    reset_register = (unsigned int *) ((long int)base_addr + RESET_REGISTER_ADDR);
    test_register = (unsigned int *) ((long int)base_addr + TEST_REGISTER_ADDR);
    status_register = (unsigned int *) ((long int)base_addr + STATUS_REGISTER_ADDR);

    // send reset packet
    *reset_register = 0xffffffff;
    printf("BSG ML605 PCIE RESET\n");

    // sleep after reset
    sleep(1);

    // get the channel number from the hardware
    channel_number = *channel_register;

    printf("BSG ML605 PCIE CHANNELS: 0x%08x\n\n", channel_number);

    // set up channels

    channel_array = (channel_t *) malloc (channel_number * sizeof(channel_t));

    int i = 0;

    for (i = 0; i < channel_number; i++) {
        channel_array[i].get_l2f_fifo_status = (unsigned int *) ((long int)base_addr + 0x4 * i);
        channel_array[i].write_fifo_data = (unsigned int *) ((long int)base_addr + 0x40 + 0x4 * i);
        channel_array[i].get_f2l_fifo_status = (unsigned int *) ((long int)base_addr + 0xc0 + 0x4 * i);
        channel_array[i].read_fifo_data = (unsigned int *) ((long int)base_addr + 0x80 + 0x4 * i);
    }

    // get l2f status for all channels

    l2f_fifo_status_vec = new vector<int> (channel_number);

    for (i = 0; i < channel_number; i++) {

        (*l2f_fifo_status_vec)[i] = *(channel_array[i].get_l2f_fifo_status);

        printf("CHANNEL[%d] L2F FIFO STATUS REGISTER[0x1FD]: 0x%08x\n", i, (*l2f_fifo_status_vec)[i]);
    }

}


void bsg_ml605_pcie_device::initiate_connection() {

    if (*test_register != 0xfffffff0) {
        printf("\nERROR: WRONG TEST REGISTER DEFAULT VALUE\n");
    }

    *test_register = 0xf0ffff5c;

    if (*test_register != 0xf0ffff5c) {
        printf("\nERROR: NOT ABLE TO WRITE/READ FROM TEST REGISTER\n");
    }

    printf("\nBSG ML605 PCIE READY\n");
}


int bsg_ml605_pcie_device::check_after_sleep(int usec) {

    return 1;

}

unsigned int bsg_ml605_pcie_device::get_status_register_value() {

    status_register = (unsigned int *) ((long int)base_addr + STATUS_REGISTER_ADDR);

    return *status_register;

}

//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_pcie.h
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//          Qiaoshi Zheng - q5zheng@eng.ucsd.edu
//------------------------------------------------------------

#ifndef __BSG_ML605_PCIE_H
#define __BSG_ML605_PCIE_H

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>
#include <iomanip>
#include <list>
#include <vector>
#include <unistd.h>
#include <dlfcn.h>
#include <errno.h>

// channel, reset, test and status register are defined in bsg_ml605_pio_ep.v

#define CHANNEL_REGISTER_ADDR 0x7fc
#define RESET_REGISTER_ADDR 0x7f8
#define TEST_REGISTER_ADDR 0x7f4
#define STATUS_REGISTER_ADDR 0x7f0

using namespace std;

#define verify_iom(x,y) do { if (x) ; else {fprintf y; fprintf(stderr," [failed (" #x")] [%s : %d]\n",__FILE__,__LINE__); abort(); }} while (0)

struct channel_t {
    unsigned int * get_l2f_fifo_status;
    unsigned int * write_fifo_data;
    unsigned int * get_f2l_fifo_status;
    unsigned int * read_fifo_data;
};

class bsg_ml605_pcie_device {

private:

    void * base_addr;
    unsigned int * channel_register;
    unsigned int * reset_register;
    unsigned int * test_register;
    unsigned int * status_register;
    int channel_number;
    int fd;  // file descriptor

    // pointer to channels
    channel_t * channel_array;

    vector<list<unsigned int> > * in_list;

    vector<int> * l2f_fifo_status_vec;
    int current_channel;

    void open_device();
    void initiate_connection();

public:

    bsg_ml605_pcie_device();

    ~bsg_ml605_pcie_device();

    void handle_pci_io(int channel);

    int read_packet_async(int channel, unsigned int  &data);

    void read_packet_blocking(int channel, unsigned int &data);

    int peek_packet_async(int channel, unsigned int  &data);

    void write_packet_async(int channel, unsigned int data);

    int write_packet_async_if_available(int channel, unsigned int data);

    int check_after_sleep(int usec);

    unsigned int get_status_register_value();
};

#endif

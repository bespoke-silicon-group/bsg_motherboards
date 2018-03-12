//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_pcie.h
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//          Qiaoshi Zheng - q5zheng@eng.ucsd.edu
//------------------------------------------------------------

#ifndef BSG_ML605_PCIE_H
#define BSG_ML605_PCIE_H

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/pci.h>
#include <linux/init.h>
#include <linux/interrupt.h>

#include <linux/proc_fs.h>
#include <linux/blkdev.h>
#include <linux/dma-mapping.h>
#include <linux/interrupt.h>
#include <linux/hdreg.h>
#include <linux/cdev.h>
#include <linux/mm.h>
#include <linux/file.h>

#define BSG_ML605_PCIE_DEVICE_MFG 0x10ee
#define BSG_ML605_PCIE_DEVICE_ID 0x0008
#define BSG_ML605_PCIE_CHANNEL_NUMBER 0x7fc
#define BSG_ML605_PCIE_RESET 0x7f8
#define BSG_ML605_PCIE_TEST_REGISTER 0x7f4

#define BSG_MODE_DEBUG

#define BSG_INFO(format,...) printk(KERN_ERR "[%s] " format "\n", bsg_ml605_pcie_driver_name, ## __VA_ARGS__ )

#ifdef BSG_MODE_DEBUG
    #define BSG_DEBUG(format, ...) printk(KERN_ERR "[%s debug] " format "\n", bsg_ml605_pcie_driver_name, ## __VA_ARGS__ )
#else
    #define BSG_DEBUG(format, ...) ;
#endif

//For newer kernels,
#ifndef __devinit
    #define __devinit
#endif
#ifndef __devexit
    #define __devexit
#endif
//3.7+
#ifndef VM_RESERVED
    #define VM_RESERVED (VM_DONTEXPAND | VM_DONTDUMP)
#endif
//End newer kernel defines

struct bsg_ml605_pcie_device
{
    struct cdev chardev;
    dev_t chardevnum;
    struct class* chardev_class;
    //Driver Info
    int id;
    uint8_t driver_version;
    uint16_t driver_svnrevision;
    uint32_t driver_buildtimestamp;
    // Device Version and Capabilities Registers
    uint8_t dev_version;
    uint8_t dev_slotcount;
    uint16_t dev_svnrevision;
    uint32_t dev_buildtimestamp;
    uint32_t dev_capabilities;
    uint16_t dev_channelcount;
    uint16_t dev_tagcount;
    // PCI
    struct pci_dev *pcidev;
    struct device *dev;
    struct request_queue *queue;
    // PCI Memory Ranges
    unsigned long long memoryBase;
    unsigned long long memoryLength;
    // Virtual Memory Ranges
    void* mmapedBase;
    unsigned long mmapedLength;
    // Channel
    uint32_t channel_number;
};

extern char* bsg_ml605_pcie_driver_name;

// bsg_ml605_pcie_module
int __devinit bsg_ml605_pcie_alloc(struct pci_dev*);
int __devexit bsg_ml605_pcie_free(struct pci_dev*);
int bsg_ml605_pcie_probe(struct pci_dev*, const struct pci_device_id*);
void bsg_ml605_pcie_remove(struct pci_dev*);
int bsg_ml605_pcie_driver_init(void);
int bsg_ml605_pcie_setup(struct bsg_ml605_pcie_device*);
void bsg_ml605_pcie_teardown(struct bsg_ml605_pcie_device*);

// bsg_ml605_pcie_char
int bsg_ml605_pcie_char_setup(struct bsg_ml605_pcie_device*);
void bsg_ml605_pcie_char_teardown(struct bsg_ml605_pcie_device*);
int bsg_ml605_pcie_char_open(struct inode*, struct file*);
int bsg_ml605_pcie_char_release(struct inode*, struct file*);
int bsg_ml605_pcie_char_mmap(struct file*, struct vm_area_struct*);

// bsg_ml605_pcie_hw
int  bsg_ml605_pcie_hw_setup(struct bsg_ml605_pcie_device*);
void bsg_ml605_pcie_hw_teardown(struct bsg_ml605_pcie_device*);
void bsg_ml605_pcie_hw_get_channel_number(struct bsg_ml605_pcie_device*);
void bsg_ml605_pcie_hw_set_reset(struct bsg_ml605_pcie_device*);
void bsg_ml605_pcie_hw_set_test_register(struct bsg_ml605_pcie_device*, uint32_t);
uint32_t bsg_ml605_pcie_hw_get_test_register(struct bsg_ml605_pcie_device*);
uint32_t bsg_ml605_pcie_hw_get_l2f_status_register(struct bsg_ml605_pcie_device*, uint8_t);
void bsg_ml605_pcie_hw_write_fifo_data(struct bsg_ml605_pcie_device*, uint8_t, uint32_t);
uint32_t bsg_ml605_pcie_hw_get_f2l_status_register(struct bsg_ml605_pcie_device*, uint8_t);
uint32_t bsg_ml605_pcie_hw_read_fifo_data(struct bsg_ml605_pcie_device*, uint8_t);

#endif

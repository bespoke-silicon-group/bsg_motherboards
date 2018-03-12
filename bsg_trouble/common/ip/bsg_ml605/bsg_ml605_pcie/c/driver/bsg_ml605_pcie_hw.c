//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_pcie_hw.h
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//          Qiaoshi Zheng - q5zheng@eng.ucsd.edu
//------------------------------------------------------------

#include "bsg_ml605_pcie.h"

int bsg_ml605_pcie_hw_setup(struct bsg_ml605_pcie_device *BSG_ML605_PCIE_DEV)
{
    struct pci_dev *dev = BSG_ML605_PCIE_DEV->pcidev;
    int result;
    u16 status16;
    u16 size16;
    u16 maxread;
    u16 maxpayload;

    pci_read_config_word(dev,PCI_COMMAND,&status16);
    status16 |= 0x0001;
    pci_write_config_word(dev,PCI_COMMAND,status16);

    // Cache line size = 64
    pci_write_config_byte(dev, 0x0C, 16);
    pci_write_config_dword(dev, 0x30, 0xfab00000);

    pci_read_config_word(dev, 0x68, &size16);
    maxread = (size16 >> 12) & 0x7;
    maxpayload = (size16 >> 5) & 0x7;

    BSG_INFO("Reg: 0x%.4x, MaxPayload: %d, MaxRead: %d", size16, 128 << maxpayload, 128 << maxread);

    if ((result = pci_enable_device(dev)) != 0) {
        BSG_DEBUG("pci_enable_device returned %d", result);
        return result;
    }

    // Enable bus mastering (DMA)
    pci_set_master(dev);

    BSG_ML605_PCIE_DEV->memoryBase = pci_resource_start(dev, 0);
    BSG_ML605_PCIE_DEV->memoryLength = pci_resource_len(dev, 0);

    BSG_DEBUG("I/O Address: 0x%16llx + 0x%llx", BSG_ML605_PCIE_DEV->memoryBase,BSG_ML605_PCIE_DEV->memoryLength);

    if (dev->irq)
        BSG_DEBUG("Using IRQ %d", dev->irq);

    // Map BAR0 into memory so we can access the device registers
    BSG_ML605_PCIE_DEV->mmapedBase = ioremap_nocache(BSG_ML605_PCIE_DEV->memoryBase, BSG_ML605_PCIE_DEV->memoryLength);
    BSG_ML605_PCIE_DEV->mmapedLength = BSG_ML605_PCIE_DEV->memoryLength;

    BSG_DEBUG("Mapped Region: 0x%16llx + 0x%lx",(unsigned long long int)BSG_ML605_PCIE_DEV->mmapedBase, BSG_ML605_PCIE_DEV->mmapedLength);

    if (!BSG_ML605_PCIE_DEV->mmapedBase) {
        free_irq(dev->irq, BSG_ML605_PCIE_DEV);

        return -EIO;
    }

    // reset
    bsg_ml605_pcie_hw_set_reset(BSG_ML605_PCIE_DEV);
    bsg_ml605_pcie_hw_get_channel_number(BSG_ML605_PCIE_DEV);

    BSG_DEBUG("Read the channel number from the hardware. Channel_number=0x%08x", BSG_ML605_PCIE_DEV->channel_number);

    return 0;
}

void bsg_ml605_pcie_hw_teardown(struct bsg_ml605_pcie_device *BSG_ML605_PCIE_DEV)
{
    if (BSG_ML605_PCIE_DEV->pcidev->irq) {
        free_irq( BSG_ML605_PCIE_DEV->pcidev->irq, BSG_ML605_PCIE_DEV);
    }

    if (BSG_ML605_PCIE_DEV->mmapedBase) {
        iounmap(BSG_ML605_PCIE_DEV->mmapedBase);
        BSG_ML605_PCIE_DEV->mmapedBase = 0;
    }
}

// Read 32-bits channel_number from hardware register
void bsg_ml605_pcie_hw_get_channel_number(struct bsg_ml605_pcie_device *BSG_ML605_PCIE_DEV)
{
      BSG_ML605_PCIE_DEV->channel_number = ioread32(BSG_ML605_PCIE_DEV->mmapedBase + BSG_ML605_PCIE_CHANNEL_NUMBER);
}

// Write 0xFFFFFFFF to host reset hardware register
void bsg_ml605_pcie_hw_set_reset(struct bsg_ml605_pcie_device *BSG_ML605_PCIE_DEV)
{
    iowrite32(0xffffffff, BSG_ML605_PCIE_DEV->mmapedBase + BSG_ML605_PCIE_RESET);
}

void bsg_ml605_pcie_hw_set_test_register(struct bsg_ml605_pcie_device* BSG_ML605_PCIE_DEV, uint32_t data)
{
    BSG_DEBUG("Set the test Register to 0x%08x", data);

    iowrite32(data, BSG_ML605_PCIE_DEV->mmapedBase + BSG_ML605_PCIE_TEST_REGISTER);
}

uint32_t bsg_ml605_pcie_hw_get_test_register(struct bsg_ml605_pcie_device* BSG_ML605_PCIE_DEV)
{
    uint32_t test_reg;

    test_reg = ioread32(BSG_ML605_PCIE_DEV->mmapedBase + BSG_ML605_PCIE_TEST_REGISTER);

    BSG_DEBUG("Get from the test Register 0x%08x", test_reg);

    return test_reg;
}

// Linux to FPGA status register
// Read 32-bits channel linux to FPGA status register
// args:
//   1. pointer of bsg_ml605_pcie_device struct
//   2. channel_number
uint32_t bsg_ml605_pcie_hw_get_l2f_status_register(struct bsg_ml605_pcie_device* BSG_ML605_PCIE_DEV, uint8_t channel)
{
    uint32_t l2f_reg;

    if(channel >= 16) {
      BSG_DEBUG("Wrong channel number");
    }

    l2f_reg = ioread32(BSG_ML605_PCIE_DEV->mmapedBase + 0x4 * channel);

    BSG_DEBUG("The receive fifo status register on FPGA is 0x%08x", l2f_reg);

    return l2f_reg;
}

// Linux to FPGA FIFO:
// Write 32-bits data to channel linux to FPGA FIFO
// args:
//   1. pointer of bsg_ml605_pcie_device struct
//   2. channel number
//   3. data to FPGA
void bsg_ml605_pcie_hw_write_fifo_data(struct bsg_ml605_pcie_device* BSG_ML605_PCIE_DEV, uint8_t channel, uint32_t data)
{
    iowrite32(data, BSG_ML605_PCIE_DEV->mmapedBase + 0x40 +  0x4 * channel);
}

// FPGA to Linux status register:
// Read 32-bits channel FPGA to Linux status register
// args:
//   1. pointer of bsg_ml605_pcie_device struct
//   2. channel number
uint32_t bsg_ml605_pcie_hw_get_f2l_status_register(struct bsg_ml605_pcie_device* BSG_ML605_PCIE_DEV, uint8_t channel)
{
    uint32_t f2l_status_reg;

    f2l_status_reg = ioread32(BSG_ML605_PCIE_DEV->mmapedBase + 0xc0 + 0x4 * channel);

    BSG_DEBUG("The transfer fifo status register on FPGA is 0x%08x", f2l_status_reg);

    return f2l_status_reg;
}

// FPGA to Linux FIFO:
// Read 32-bits data from channel FPGA to Linux FIFO
uint32_t bsg_ml605_pcie_hw_read_fifo_data(struct bsg_ml605_pcie_device* BSG_ML605_PCIE_DEV, uint8_t channel)
{
    uint32_t f2l_data;

    f2l_data = ioread32(BSG_ML605_PCIE_DEV->mmapedBase + 0x80 + 0x4 * channel);

    BSG_DEBUG("The Linux box receive data is 0x%08x", f2l_data);

    return f2l_data;
}

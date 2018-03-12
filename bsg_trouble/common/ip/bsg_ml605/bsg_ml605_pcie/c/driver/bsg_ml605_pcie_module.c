//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_pcie_module.h
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//          Qiaoshi Zheng - q5zheng@eng.ucsd.edu
//------------------------------------------------------------

#include "bsg_ml605_pcie.h"

char * bsg_ml605_pcie_driver_name;

static pci_ers_result_t bsg_ml605_pcie_error_result(struct pci_dev *dev, enum pci_channel_state error)
{
    BSG_DEBUG("BSG ERROR ML605 PCIE BUS");
    return PCI_ERS_RESULT_NONE;
}

struct pci_device_id bsg_ml605_pcie_ids[] = {
    { PCI_DEVICE(BSG_ML605_PCIE_DEVICE_MFG, BSG_ML605_PCIE_DEVICE_ID), },
    { 0, }
};

struct pci_error_handlers bsg_ml605_pcie_error_handler = {
    .error_detected = bsg_ml605_pcie_error_result,
};

struct pci_driver bsg_ml605_pcie_driver = {
    .name = "bsg_ml605_pcie",
    .id_table = bsg_ml605_pcie_ids,
    .probe = bsg_ml605_pcie_probe,
    .remove = bsg_ml605_pcie_remove,
    .err_handler = &bsg_ml605_pcie_error_handler,
};

//--------------------------------------------------------------
//                      KERNEL MODULE INFO
//--------------------------------------------------------------
MODULE_DEVICE_TABLE(pci, bsg_ml605_pcie_ids);
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Bespoke Systems Group UCSD");
//--------------------------------------------------------------

//---------------------------------
// KERNEL-INIT FUNCTION STARTS HERE
//---------------------------------

static int __init bsg_ml605_pcie_init(void)
{
    int ret;

    bsg_ml605_pcie_driver_name = bsg_ml605_pcie_driver.name;
    ret = pci_register_driver(&bsg_ml605_pcie_driver);
    if (ret == 0) {
        BSG_INFO("BSG ML605 PCIE DRIVER REGISTERED");
        BSG_INFO("BSG ML605 PCIE ID: %.4x:%.4x", bsg_ml605_pcie_ids[0].vendor, bsg_ml605_pcie_ids[0].device);
    } else {
        BSG_INFO("BSG ERROR DRIVER REGISTRATION: %d", ret);
        return ret;
    }

    return 0;
}

//-------------------------------
// KERNEL-INIT FUNCTION ENDS HERE
//-------------------------------

//---------------------------------
// KERNEL-EXIT FUNCTION STARTS HERE
//---------------------------------

static void __exit bsg_ml605_pcie_exit(void)
{
    pci_unregister_driver(&bsg_ml605_pcie_driver);
    BSG_INFO("BSG ML605 PCIE MODULE UNLOADED");
}

//-------------------------------
// KERNEL-EXIT FUNCTION ENDS HERE
//-------------------------------

//--------------------------------
// KERNEL MACROS FOR INIT AND EXIT
//--------------------------------
module_init(bsg_ml605_pcie_init);
module_exit(bsg_ml605_pcie_exit);
//--------------------------------

//-------------------------------
// PCI-PROBE FUNCTION STARTS HERE
//-------------------------------

// Called when a new pci device is found that matches the device ID and
// manufacturer ID we specified. This is responsible for getting the device
// to a usable state and registering any entries in /dev.

int __devinit bsg_ml605_pcie_probe(struct pci_dev *dev, const struct pci_device_id *id)
{
    return  bsg_ml605_pcie_alloc(dev);
}

int bsg_ml605_pcie_alloc(struct pci_dev *pcidev)
{
    struct bsg_ml605_pcie_device *BSG_ML605_PCIE_DEV;
    int rc;

    BSG_INFO("BSG INITIALIZING DEVICE DATA STRUCTURES");

    // Allocate space for driver state data structure
    BSG_ML605_PCIE_DEV = kzalloc(sizeof(struct bsg_ml605_pcie_device), GFP_KERNEL);
    if (!BSG_ML605_PCIE_DEV) {
        rc = -ENOMEM;

        BSG_DEBUG("BSG ERROR BBD_ALLOC IN ERROR STATE: rc=%d", rc);

        return rc;
    }

    // Store some basic device information
    BSG_ML605_PCIE_DEV->pcidev = pcidev;
    BSG_ML605_PCIE_DEV->dev = &pcidev->dev;

    // Store pointer to driver state in device
    dev_set_drvdata(BSG_ML605_PCIE_DEV->dev, BSG_ML605_PCIE_DEV);

    // Call bbd_setup routine
    rc = bsg_ml605_pcie_setup(BSG_ML605_PCIE_DEV);
    if (rc != 0) {
        BSG_DEBUG("ERROR BBD_SETUP CALLED FROM BBD_ALLOC");

        kfree(BSG_ML605_PCIE_DEV);

        return rc;
    }

    return 0;
}

int bsg_ml605_pcie_setup(struct bsg_ml605_pcie_device *BSG_ML605_PCIE_DEV)
{
    BSG_ML605_PCIE_DEV->driver_version = 1;

    // initialize hardware
    if (bsg_ml605_pcie_hw_setup(BSG_ML605_PCIE_DEV))
        return -EIO;

    // initialize char
    bsg_ml605_pcie_char_setup(BSG_ML605_PCIE_DEV);

    BSG_DEBUG("BSG ML605 PCIE READY TO USE");

    return 0;
}

//-----------------------------
// PCI-PROBE FUNCTION ENDS HERE
//-----------------------------

//--------------------------------
// PCI-REMOVE FUNCTION STARTS HERE
//--------------------------------

// Called on device removal/module unload
void __devexit bsg_ml605_pcie_remove(struct pci_dev *dev)
{
    bsg_ml605_pcie_free(dev);
}

int bsg_ml605_pcie_free(struct pci_dev *pcidev)
{
    struct bsg_ml605_pcie_device *BSG_ML605_PCIE_DEV = dev_get_drvdata(&pcidev->dev);

    if (BSG_ML605_PCIE_DEV) {
        bsg_ml605_pcie_teardown(BSG_ML605_PCIE_DEV);
        dev_set_drvdata(&pcidev->dev, NULL);
        kfree(BSG_ML605_PCIE_DEV);
    }

    return 0;
}

void bsg_ml605_pcie_teardown(struct bsg_ml605_pcie_device *BSG_ML605_PCIE_DEV)
{
    bsg_ml605_pcie_char_teardown(BSG_ML605_PCIE_DEV);
    bsg_ml605_pcie_hw_teardown(BSG_ML605_PCIE_DEV);
}

//------------------------------
// PCI-REMOVE FUNCTION ENDS HERE
//------------------------------

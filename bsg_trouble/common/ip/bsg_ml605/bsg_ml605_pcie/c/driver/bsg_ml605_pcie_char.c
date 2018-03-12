//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: bsg_ml605_pcie_char.c
//
// Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
//          Qiaoshi Zheng - q5zheng@eng.ucsd.edu
//------------------------------------------------------------

#include "bsg_ml605_pcie.h"

struct file_operations bsg_ml605_pcie_char_fops = {
    .open = bsg_ml605_pcie_char_open,
    .release = bsg_ml605_pcie_char_release,
    .mmap = bsg_ml605_pcie_char_mmap,
};

int bsg_ml605_pcie_char_setup(struct bsg_ml605_pcie_device* BSG_ML605_PCIE_DEV)
{
    if(alloc_chrdev_region(&BSG_ML605_PCIE_DEV->chardevnum,0,1,"bsg_ml605_pcie")) {

        BSG_DEBUG("Failed to register character device major,minor number");

        return 1;
    }

    cdev_init(&BSG_ML605_PCIE_DEV->chardev, &bsg_ml605_pcie_char_fops);
    BSG_ML605_PCIE_DEV->chardev.owner = THIS_MODULE;
    cdev_add(&BSG_ML605_PCIE_DEV->chardev, BSG_ML605_PCIE_DEV->chardevnum, 1);

    BSG_DEBUG("Added Char Device %d, %d", MAJOR(BSG_ML605_PCIE_DEV->chardevnum), MINOR(BSG_ML605_PCIE_DEV->chardevnum));
    BSG_DEBUG("Before class_create");

    BSG_ML605_PCIE_DEV->chardev_class = class_create(THIS_MODULE, "bsg_ml605_pcie");

    BSG_DEBUG("After class_create");

    device_create(BSG_ML605_PCIE_DEV->chardev_class, NULL, BSG_ML605_PCIE_DEV->chardevnum, NULL, "bsg_ml605_pcie");

    BSG_DEBUG("After device_create");

    return 0;
}

void bsg_ml605_pcie_char_teardown(struct bsg_ml605_pcie_device* BSG_ML605_PCIE_DEV)
{
    device_destroy(BSG_ML605_PCIE_DEV->chardev_class, BSG_ML605_PCIE_DEV->chardevnum);
    class_destroy(BSG_ML605_PCIE_DEV->chardev_class);
    unregister_chrdev_region(BSG_ML605_PCIE_DEV->chardevnum, 1);
    cdev_del(&BSG_ML605_PCIE_DEV->chardev);
}

int bsg_ml605_pcie_char_open(struct inode* inode, struct file* filp)
{
    struct bsg_ml605_pcie_device* BSG_ML605_PCIE_DEV;
    BSG_ML605_PCIE_DEV = container_of(inode->i_cdev, struct bsg_ml605_pcie_device, chardev);

    filp->f_mode &= ~(FMODE_LSEEK | FMODE_PREAD | FMODE_PWRITE);
    filp->private_data = BSG_ML605_PCIE_DEV;

    return 0;
}

int bsg_ml605_pcie_char_release(struct inode* inode, struct file* filp)
{
    return 0;
}

int bsg_ml605_pcie_char_mmap(struct file* filp, struct vm_area_struct *UserVMA)
{
    struct bsg_ml605_pcie_device *BSG_ML605_PCIE_DEV = filp->private_data;
    long len;
    int  ret;

    len = 4096;
    if (UserVMA == NULL) {
        // Couldn't lookup vma
        return 1;
    }

    // If we make it here, we at least have a VMA from the user
    // We should check its size and see if there's enough space f
    // or us to map the registers and buffers
    if (UserVMA->vm_end - UserVMA->vm_start < len) {
        // Mapped region not big enough
        return 2;
    }

    UserVMA->vm_flags |= VM_RESERVED;
    UserVMA->vm_flags |= VM_IO;

    if((ret=remap_pfn_range(
    UserVMA,            // User vm area
    UserVMA->vm_start,  // User address start
    ((unsigned long)(BSG_ML605_PCIE_DEV->memoryBase + UserVMA->vm_pgoff) >> PAGE_SHIFT), // Physical address
    4096,               // Length
    UserVMA->vm_page_prot))) {
        BSG_DEBUG("#Qiaoshi#  Something wrong when call remap_pfn_range");
        return 3;
    }

    return 0;
}

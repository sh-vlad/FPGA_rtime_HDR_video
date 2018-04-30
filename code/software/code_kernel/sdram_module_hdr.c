#include <linux/module.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/slab.h>
#include <linux/fs.h> 
#include <linux/platform_device.h>
#include <linux/miscdevice.h> 
#include <linux/of_irq.h>
#include <linux/phy.h>
#include <asm/uaccess.h>
#include <linux/ioport.h>
#include <asm/io.h>
#include <linux/slab.h> 
#include <linux/pagemap.h>
#include <linux/vmalloc.h>
#include <linux/delay.h>

struct ioregion {
	char* name;
	unsigned long address;
	unsigned long size;
	void __iomem* base;
};
static struct {
	void __iomem *addr_buf_1;
	void __iomem *addr_buf_2;
} regs;
static int ioregion_request(struct ioregion* region_p) {
	/* reserve our memory region */
	if (NULL == request_mem_region(region_p->address, region_p->size,
				       region_p->name))
		return (-EBUSY);
	/* ioremap our memory region */
	region_p->base = ioremap_nocache(region_p->address, region_p->size);
	if (NULL == region_p->base) {
		release_mem_region(region_p->address, region_p->size);
		return (-ENOMEM);
	}
	return (0);
}
static void ioregion_release(struct ioregion* region_p) {
	iounmap(region_p->base);
	region_p->base = NULL;
	release_mem_region(region_p->address, region_p->size);

	return;
}
static struct ioregion regions_tab[] = {
	{"HDR", 0xC0000000UL, 32UL, NULL},
	{NULL, 0x0UL, 0UL, NULL}
};

#define init_regs()					         \
do {							         \
	regs.addr_buf_1 = (u8 *)regions_tab[0U].base + 0U;     \
	regs.addr_buf_2 = (u8 *)regions_tab[0U].base + 4U;     \
} while (0)
#define write_to_fpga(arg1, arg2)				 \
do {							         \
	writel((arg1), regs.addr_buf_1);			 \
	writel((arg2), regs.addr_buf_2);		  	 \
} while (0)

unsigned int addr_buf_write_1;
unsigned int addr_buf_write_2;
static unsigned int * b0_ptr1 = NULL;
static unsigned int * b0_ptr2 = NULL;
static dma_addr_t handle1;
static dma_addr_t handle2;
struct ioregion* region_p;

static int framebuffer_init(void)
{
	int retval;
	for (region_p = regions_tab; NULL != region_p->name; ++region_p) {
		retval = ioregion_request(region_p);
	}
	printk("The module is successfully added to kernel!\n");
	// allocation of two buffers 
	b0_ptr1 = dma_alloc_coherent( NULL, 4194304, &handle1, GFP_KERNEL | GFP_DMA ); // 4 MB
	b0_ptr2 = dma_alloc_coherent( NULL, 4194304, &handle2, GFP_KERNEL | GFP_DMA ); // 4 MB 
	printk("allocation of two buffers \n");
	// Address byte to address word
	addr_buf_write_1 = handle1 >> 3;
	addr_buf_write_2 = handle2 >> 3;
	printk("hps_addr_1 = %X\n", handle1);
	printk("hps_addr_2 = %X\n", handle2);
	printk("fpga_addr_write_1 = %X\n", addr_buf_write_1);
	printk("fpga_addr_write_2 = %X\n", addr_buf_write_2);
	init_regs();
	write_to_fpga(addr_buf_write_1, addr_buf_write_2);
	return 0;
}

static void framebuffer_exit(void)
{	
	printk("exit\n");
	if( b0_ptr1 )
        	dma_free_coherent(NULL, 4194304, b0_ptr1, handle1 );
	if( b0_ptr2 )
        	dma_free_coherent(NULL, 4194304, b0_ptr2, handle2 );
	for (region_p = regions_tab; NULL != region_p->name; ++region_p)
		if (NULL != region_p->base)
			ioregion_release(region_p);
}

module_init(framebuffer_init);
module_exit(framebuffer_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Andrey Papushin  andrey.papushin@gmail.com");
MODULE_DESCRIPTION("allocation of two buffers for hdr image");
MODULE_VERSION("1.0");

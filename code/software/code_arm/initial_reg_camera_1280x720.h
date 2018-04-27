#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <memory.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>
#include <fcntl.h>

#define PORT 3333
#define MEM_SPAN 0x40000000
#define BASE_ADDR_H2F_BRIDGE 0xC0000000



uint32_t reverse_byte(uint32_t value_in);
void initial_reg_camera_1280x720(int *hps2fpga);
void write_i2c(int *hps2fpga, uint16_t addr, uint8_t data);
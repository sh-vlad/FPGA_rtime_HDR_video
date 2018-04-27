#include "initial_reg_camera_1280x720.h"
void write_i2c(int *hps2fpga, uint16_t addr, uint8_t data)
{
	*(hps2fpga  + addr) = data;
}

uint32_t reverse_byte(uint32_t value_in)
{
	uint32_t byte0 = (value_in >> 24)         ;
	uint32_t byte1 = (value_in >> 16)  & 0xff;
	uint32_t byte2 = (value_in >> 8 )  & 0xff;
	uint32_t byte3 = value_in        & 0xff;
	return (byte3<<23) |(byte2<<16) | (byte1<<8)  | byte0;
	
}

void initial_reg_camera_1280x720(int *hps2fpga)
{
	write_i2c(hps2fpga, 0x3103,  0x11      );
	write_i2c(hps2fpga, 0x3008,  0x82      );
	write_i2c(hps2fpga, 0x3008,  0x42      );
	write_i2c(hps2fpga, 0x3103,  0x03      );
	write_i2c(hps2fpga, 0x3017,  0xff      );
	write_i2c(hps2fpga, 0x3018,  0xff      );
	write_i2c(hps2fpga, 0x3034,  0x18      );
	write_i2c(hps2fpga, 0x3035,  0x21      );
	write_i2c(hps2fpga, 0x3036,  0x46      );
	write_i2c(hps2fpga, 0x3037,  0x13      );
	write_i2c(hps2fpga, 0x3108,  0x01      );
	write_i2c(hps2fpga, 0x3630,  0x36      );
	write_i2c(hps2fpga, 0x3631,  0x0e      );
	write_i2c(hps2fpga, 0x3632,  0xe2      );
	write_i2c(hps2fpga, 0x3633,  0x12      );
	write_i2c(hps2fpga, 0x3621,  0xe0      );
	write_i2c(hps2fpga, 0x3704,  0xa0      );
	write_i2c(hps2fpga, 0x3703,  0x5a      );
	write_i2c(hps2fpga, 0x3715,  0x78      );
	write_i2c(hps2fpga, 0x3717,  0x01      );
	write_i2c(hps2fpga, 0x370b,  0x60      );
	write_i2c(hps2fpga, 0x3705,  0x1a      );
	write_i2c(hps2fpga, 0x3905,  0x02      );
	write_i2c(hps2fpga, 0x3906,  0x10      );
	write_i2c(hps2fpga, 0x3901,  0x0a      );
	write_i2c(hps2fpga, 0x3731,  0x12      );
	write_i2c(hps2fpga, 0x3600,  0x08      );
	write_i2c(hps2fpga, 0x3601,  0x33      );
	write_i2c(hps2fpga, 0x302d,  0x60      );
	write_i2c(hps2fpga, 0x3620,  0x52      );
	write_i2c(hps2fpga, 0x371b,  0x20      );
	write_i2c(hps2fpga, 0x471c,  0x50      );
	write_i2c(hps2fpga, 0x3a13,  0x43      );
	write_i2c(hps2fpga, 0x3a18,  0x00      );
	write_i2c(hps2fpga, 0x3a19,  0xf8      );
	write_i2c(hps2fpga, 0x3635,  0x13      );
	write_i2c(hps2fpga, 0x3636,  0x03      );
	write_i2c(hps2fpga, 0x3634,  0x40      );
	write_i2c(hps2fpga, 0x3622,  0x01      );
	write_i2c(hps2fpga, 0x3c01,  0x34      );
	write_i2c(hps2fpga, 0x3c04,  0x28      );
	write_i2c(hps2fpga, 0x3c05,  0x98      );
	write_i2c(hps2fpga, 0x3c06,  0x00      );
	write_i2c(hps2fpga, 0x3c07,  0x08      );
	write_i2c(hps2fpga, 0x3c08,  0x00      );
	write_i2c(hps2fpga, 0x3c09,  0x1c      );
	write_i2c(hps2fpga, 0x3c0a,  0x9c      );
	write_i2c(hps2fpga, 0x3c0b,  0x40      );
	write_i2c(hps2fpga, 0x3820,  0x41      );
	write_i2c(hps2fpga, 0x3821,  0x07      );
	write_i2c(hps2fpga, 0x3814,  0x31      );
	write_i2c(hps2fpga, 0x3815,  0x31      );
	write_i2c(hps2fpga, 0x3800,  0x00      );
	write_i2c(hps2fpga, 0x3801,  0x00      );
	write_i2c(hps2fpga, 0x3802,  0x00      );
	write_i2c(hps2fpga, 0x3803,  0x04      );
	write_i2c(hps2fpga, 0x3804,  0x0a      );
	write_i2c(hps2fpga, 0x3805,  0x3f      );
	write_i2c(hps2fpga, 0x3806,  0x07      );
	write_i2c(hps2fpga, 0x3807,  0x9b      );
	write_i2c(hps2fpga, 0x3808,  0x03      );
	write_i2c(hps2fpga, 0x3809,  0x20      );
	write_i2c(hps2fpga, 0x380a,  0x02      );
	write_i2c(hps2fpga, 0x380b,  0x58      );
	write_i2c(hps2fpga, 0x380c,  0x07      );
	write_i2c(hps2fpga, 0x380d,  0x68      );
	write_i2c(hps2fpga, 0x380e,  0x03      );
	write_i2c(hps2fpga, 0x380f,  0xd8      );
	write_i2c(hps2fpga, 0x3810,  0x00      );
	write_i2c(hps2fpga, 0x3811,  0x10      );
	write_i2c(hps2fpga, 0x3812,  0x00      );
	write_i2c(hps2fpga, 0x3813,  0x06      );
	write_i2c(hps2fpga, 0x3618,  0x00      );
	write_i2c(hps2fpga, 0x3612,  0x29      );
	write_i2c(hps2fpga, 0x3708,  0x64      );
	write_i2c(hps2fpga, 0x3709,  0x52      );
	write_i2c(hps2fpga, 0x370c,  0x03      );
	write_i2c(hps2fpga, 0x3a02,  0x03      );
	write_i2c(hps2fpga, 0x3a03,  0xd8      );
	write_i2c(hps2fpga, 0x3a08,  0x01      );
	write_i2c(hps2fpga, 0x3a09,  0x27      );
	write_i2c(hps2fpga, 0x3a0a,  0x00      );
	write_i2c(hps2fpga, 0x3a0b,  0xf6      );
	write_i2c(hps2fpga, 0x3a0e,  0x03      );
	write_i2c(hps2fpga, 0x3a0d,  0x04      );
	write_i2c(hps2fpga, 0x3a14,  0x03      );
	write_i2c(hps2fpga, 0x3a15,  0xd8      );
	write_i2c(hps2fpga, 0x4001,  0x02      );
	write_i2c(hps2fpga, 0x4004,  0x02      );
	write_i2c(hps2fpga, 0x3000,  0x00      );
	write_i2c(hps2fpga, 0x3002,  0x1c      );
	write_i2c(hps2fpga, 0x3004,  0xff      );
	write_i2c(hps2fpga, 0x3006,  0xc3      );
	write_i2c(hps2fpga, 0x300e,  0x58      );
	write_i2c(hps2fpga, 0x302e,  0x00      );
	write_i2c(hps2fpga, 0x4740,  0x21      );
	write_i2c(hps2fpga, 0x4300,  0xf8      );
	write_i2c(hps2fpga, 0x501f,  0x03      );
	write_i2c(hps2fpga, 0x4713,  0x03      );
	write_i2c(hps2fpga, 0x4407,  0x04      );
	write_i2c(hps2fpga, 0x440e,  0x00      );
	write_i2c(hps2fpga, 0x460b,  0x35      );
	write_i2c(hps2fpga, 0x460c,  0x20      );
	write_i2c(hps2fpga, 0x4837,  0x22      );
	write_i2c(hps2fpga, 0x3824,  0x02      );
	write_i2c(hps2fpga, 0x5000,  0xa7      );
	write_i2c(hps2fpga, 0x5001,  0xa3      );
	write_i2c(hps2fpga, 0x5180,  0xff      );
	write_i2c(hps2fpga, 0x5181,  0xf2      );
	write_i2c(hps2fpga, 0x5182,  0x00      );
	write_i2c(hps2fpga, 0x5183,  0x14      );
	write_i2c(hps2fpga, 0x5184,  0x25      );
	write_i2c(hps2fpga, 0x5185,  0x24      );
	write_i2c(hps2fpga, 0x5186,  0x09      );
	write_i2c(hps2fpga, 0x5187,  0x09      );
	write_i2c(hps2fpga, 0x5188,  0x09      );
	write_i2c(hps2fpga, 0x5189,  0x75      );
	write_i2c(hps2fpga, 0x518a,  0x54      );
	write_i2c(hps2fpga, 0x518b,  0xe0      );
	write_i2c(hps2fpga, 0x518c,  0xb2      );
	write_i2c(hps2fpga, 0x518d,  0x42      );
	write_i2c(hps2fpga, 0x518e,  0x3d      );
	write_i2c(hps2fpga, 0x518f,  0x56      );
	write_i2c(hps2fpga, 0x5190,  0x46      );
	write_i2c(hps2fpga, 0x5191,  0xf8      );
	write_i2c(hps2fpga, 0x5192,  0x04      );
	write_i2c(hps2fpga, 0x5193,  0x70      );
	write_i2c(hps2fpga, 0x5194,  0xf0      );
	write_i2c(hps2fpga, 0x5195,  0xf0      );
	write_i2c(hps2fpga, 0x5196,  0x03      );
	write_i2c(hps2fpga, 0x5197,  0x01      );
	write_i2c(hps2fpga, 0x5198,  0x04      );
	write_i2c(hps2fpga, 0x5199,  0x12      );
	write_i2c(hps2fpga, 0x519a,  0x04      );
	write_i2c(hps2fpga, 0x519b,  0x00      );
	write_i2c(hps2fpga, 0x519c,  0x06      );
	write_i2c(hps2fpga, 0x519d,  0x82      );
	write_i2c(hps2fpga, 0x519e,  0x38      );
	write_i2c(hps2fpga, 0x5381,  0x1e      );
	write_i2c(hps2fpga, 0x5382,  0x5b      );
	write_i2c(hps2fpga, 0x5383,  0x08      );
	write_i2c(hps2fpga, 0x5384,  0x0a      );
	write_i2c(hps2fpga, 0x5385,  0x7e      );
	write_i2c(hps2fpga, 0x5386,  0x88      );
	write_i2c(hps2fpga, 0x5387,  0x7c      );
	write_i2c(hps2fpga, 0x5388,  0x6c      );
	write_i2c(hps2fpga, 0x5389,  0x10      );
	write_i2c(hps2fpga, 0x538a,  0x01      );
	write_i2c(hps2fpga, 0x538b,  0x98      );
	write_i2c(hps2fpga, 0x5300,  0x08      );
	write_i2c(hps2fpga, 0x5301,  0x30      );
	write_i2c(hps2fpga, 0x5302,  0x10      );
	write_i2c(hps2fpga, 0x5303,  0x00      );
	write_i2c(hps2fpga, 0x5304,  0x08      );
	write_i2c(hps2fpga, 0x5305,  0x30      );
	write_i2c(hps2fpga, 0x5306,  0x08      );
	write_i2c(hps2fpga, 0x5307,  0x16      );
	write_i2c(hps2fpga, 0x5309,  0x08      );
	write_i2c(hps2fpga, 0x530a,  0x30      );
	write_i2c(hps2fpga, 0x530b,  0x04      );
	write_i2c(hps2fpga, 0x530c,  0x06      );
	write_i2c(hps2fpga, 0x5480,  0x01      );
	write_i2c(hps2fpga, 0x5481,  0x08      );
	write_i2c(hps2fpga, 0x5482,  0x14      );
	write_i2c(hps2fpga, 0x5483,  0x28      );
	write_i2c(hps2fpga, 0x5484,  0x51      );
	write_i2c(hps2fpga, 0x5485,  0x65      );
	write_i2c(hps2fpga, 0x5486,  0x71      );
	write_i2c(hps2fpga, 0x5487,  0x7d      );
	write_i2c(hps2fpga, 0x5488,  0x87      );
	write_i2c(hps2fpga, 0x5489,  0x91      );
	write_i2c(hps2fpga, 0x548a,  0x9a      );
	write_i2c(hps2fpga, 0x548b,  0xaa      );
	write_i2c(hps2fpga, 0x548c,  0xb8      );
	write_i2c(hps2fpga, 0x548d,  0xcd      );
	write_i2c(hps2fpga, 0x548e,  0xdd      );
	write_i2c(hps2fpga, 0x548f,  0xea      );
	write_i2c(hps2fpga, 0x5490,  0x1d      );
	write_i2c(hps2fpga, 0x5580,  0x02      );
	write_i2c(hps2fpga, 0x5583,  0x40      );
	write_i2c(hps2fpga, 0x5584,  0x10      );
	write_i2c(hps2fpga, 0x5589,  0x10      );
	write_i2c(hps2fpga, 0x558a,  0x00      );
	write_i2c(hps2fpga, 0x558b,  0xf8      );
	write_i2c(hps2fpga, 0x5800,  0x23      );
	write_i2c(hps2fpga, 0x5801,  0x14      );
	write_i2c(hps2fpga, 0x5802,  0x0f      );
	write_i2c(hps2fpga, 0x5803,  0x0f      );
	write_i2c(hps2fpga, 0x5804,  0x12      );
	write_i2c(hps2fpga, 0x5805,  0x26      );
	write_i2c(hps2fpga, 0x5806,  0x0c      );
	write_i2c(hps2fpga, 0x5807,  0x08      );
	write_i2c(hps2fpga, 0x5808,  0x05      );
	write_i2c(hps2fpga, 0x5809,  0x05      );
	write_i2c(hps2fpga, 0x580a,  0x08      );
	write_i2c(hps2fpga, 0x580b,  0x0d      );
	write_i2c(hps2fpga, 0x580c,  0x08      );
	write_i2c(hps2fpga, 0x580d,  0x03      );
	write_i2c(hps2fpga, 0x580e,  0x00      );
	write_i2c(hps2fpga, 0x580f,  0x00      );
	write_i2c(hps2fpga, 0x5810,  0x03      );
	write_i2c(hps2fpga, 0x5811,  0x09      );
	write_i2c(hps2fpga, 0x5812,  0x07      );
	write_i2c(hps2fpga, 0x5813,  0x03      );
	write_i2c(hps2fpga, 0x5814,  0x00      );
	write_i2c(hps2fpga, 0x5815,  0x01      );
	write_i2c(hps2fpga, 0x5816,  0x03      );
	write_i2c(hps2fpga, 0x5817,  0x08      );
	write_i2c(hps2fpga, 0x5818,  0x0d      );
	write_i2c(hps2fpga, 0x5819,  0x08      );
	write_i2c(hps2fpga, 0x581a,  0x05      );
	write_i2c(hps2fpga, 0x581b,  0x06      );
	write_i2c(hps2fpga, 0x581c,  0x08      );
	write_i2c(hps2fpga, 0x581d,  0x0e      );
	write_i2c(hps2fpga, 0x581e,  0x29      );
	write_i2c(hps2fpga, 0x581f,  0x17      );
	write_i2c(hps2fpga, 0x5820,  0x11      );
	write_i2c(hps2fpga, 0x5821,  0x11      );
	write_i2c(hps2fpga, 0x5822,  0x15      );
	write_i2c(hps2fpga, 0x5823,  0x28      );
	write_i2c(hps2fpga, 0x5824,  0x46      );
	write_i2c(hps2fpga, 0x5825,  0x26      );
	write_i2c(hps2fpga, 0x5826,  0x08      );
	write_i2c(hps2fpga, 0x5827,  0x26      );
	write_i2c(hps2fpga, 0x5828,  0x64      );
	write_i2c(hps2fpga, 0x5829,  0x26      );
	write_i2c(hps2fpga, 0x582a,  0x24      );
	write_i2c(hps2fpga, 0x582b,  0x22      );
	write_i2c(hps2fpga, 0x582c,  0x24      );
	write_i2c(hps2fpga, 0x582d,  0x24      );
	write_i2c(hps2fpga, 0x582e,  0x06      );
	write_i2c(hps2fpga, 0x582f,  0x22      );
	write_i2c(hps2fpga, 0x5830,  0x40      );
	write_i2c(hps2fpga, 0x5831,  0x42      );
	write_i2c(hps2fpga, 0x5832,  0x24      );
	write_i2c(hps2fpga, 0x5833,  0x26      );
	write_i2c(hps2fpga, 0x5834,  0x24      );
	write_i2c(hps2fpga, 0x5835,  0x22      );
	write_i2c(hps2fpga, 0x5836,  0x22      );
	write_i2c(hps2fpga, 0x5837,  0x26      );
	write_i2c(hps2fpga, 0x5838,  0x44      );
	write_i2c(hps2fpga, 0x5839,  0x24      );
	write_i2c(hps2fpga, 0x583a,  0x26      );
	write_i2c(hps2fpga, 0x583b,  0x28      );
	write_i2c(hps2fpga, 0x583c,  0x42      );
	write_i2c(hps2fpga, 0x583d,  0xce      );
	write_i2c(hps2fpga, 0x5025,  0x00      );
	write_i2c(hps2fpga, 0x3a0f,  0x30      );
	write_i2c(hps2fpga, 0x3a10,  0x28      );
	write_i2c(hps2fpga, 0x3a1b,  0x30      );
	write_i2c(hps2fpga, 0x3a1e,  0x26      );
	write_i2c(hps2fpga, 0x3a11,  0x60      );
	write_i2c(hps2fpga, 0x3a1f,  0x14      );
	write_i2c(hps2fpga, 0x3503,  0x00      );
	write_i2c(hps2fpga, 0x3c07,  0x07      );
	write_i2c(hps2fpga, 0x3803,  0xfa      );
	write_i2c(hps2fpga, 0x3806,  0x06      );
	write_i2c(hps2fpga, 0x3807,  0xa9      );
	write_i2c(hps2fpga, 0x3808,  0x05      );
	write_i2c(hps2fpga, 0x3809,  0x00      );
	sleep (2);
	write_i2c(hps2fpga, 0x380a,  0x02      );
	write_i2c(hps2fpga, 0x380b,  0xd0      );
	write_i2c(hps2fpga, 0x380c,  0x07      );
	write_i2c(hps2fpga, 0x380d,  0x64      );
	write_i2c(hps2fpga, 0x380e,  0x02      );
	write_i2c(hps2fpga, 0x380f,  0xe4      );
	write_i2c(hps2fpga, 0x3813,  0x04      );
	write_i2c(hps2fpga, 0x3a02,  0x02      );
	write_i2c(hps2fpga, 0x3a03,  0xe4      );
	write_i2c(hps2fpga, 0x3a08,  0x01      );
	write_i2c(hps2fpga, 0x3a09,  0xbc      );
	write_i2c(hps2fpga, 0x3a0a,  0x01      );
	write_i2c(hps2fpga, 0x3a0b,  0x72      );
	write_i2c(hps2fpga, 0x3a0e,  0x01      );
	write_i2c(hps2fpga, 0x3a0d,  0x02      );
	write_i2c(hps2fpga, 0x3a14,  0x02      );
	write_i2c(hps2fpga, 0x3a15,  0xe4      );
	write_i2c(hps2fpga, 0x3002,  0x00      );
	write_i2c(hps2fpga, 0x4713,  0x02      );
	write_i2c(hps2fpga, 0x4837,  0x16      );
	write_i2c(hps2fpga, 0x3824,  0x04      );
	write_i2c(hps2fpga, 0x5001,  0x83      );
	write_i2c(hps2fpga, 0x3035,  0x21      );
	write_i2c(hps2fpga, 0x3036,  0x46      );
	write_i2c(hps2fpga, 0x4837,  0x22      );
	write_i2c(hps2fpga, 0x5001,  0xa3      );
	write_i2c(hps2fpga, 0xffff,  0x01      );
	write_i2c(hps2fpga, 0x3008,  0x02      );
	printf( "end n" );
}
#include "initial_reg_camera_1280x720.h"
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <iostream>
#include <netinet/in.h>
#include <netdb.h>
#include <sys/socket.h>
#include <thread>
#include <sys/types.h>
#include <ctime>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <memory.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#define H 200
#define W 256
#define ADDR_BUF_3 0x3F900000
unsigned char new_hist_r[H][W];
unsigned char new_hist_g[H][W];
unsigned char new_hist_b[H][W];
unsigned int mas_freq[W];
struct map 
{
	unsigned int max_freq;
	unsigned char index;
};
void hist();
void user();
void initial_gamma_mem(unsigned char *lw_hps2fpga, double a);
void poll_status_register(int *mem_freq);
void build_hist(struct map new_max);
void build_hist2(struct map new_max);
struct map read_freq(int *mem_freq);
void initial_reg_camera();
void write_hist(int *mem_hist_write );

enum color { R_comp, G_comp, B_comp, Y_comp  };
color select_comp = Y_comp;
int main(int argc, char *argv[]) 
{
	if(argc > 1)
	{
		if(strcmp("hist",argv[1]) ==0 )
		{
			std::thread t1(hist);
			t1.join();
		}
		else if(strcmp("server", argv[1]) == 0 )
		{
			std::thread t2(user);
			t2.join();
		}
		else if(strcmp("work", argv[1]) == 0 )
		{
			std::thread t1(hist);
			std::thread t2(user);
			t1.join();
			t2.join();
		}
	}
	else 
	{
		initial_reg_camera();
		std::thread t1(hist);
		std::thread t2(user);
		t1.join();
		t2.join();
	
	}
		
	return 0;
}

struct map read_freq(int *mem_freq)
{
	struct map new_max;
	unsigned int tmp;
	int i;
	new_max.max_freq = 0;
	new_max.index = 0;
	for(i=0; i<W; i++)
	{	
		tmp = *(mem_freq  + i );
		mas_freq[i] = tmp;
		if(tmp > new_max.max_freq )
		{
			new_max.max_freq = tmp;
			new_max.index    = i;
		}
	}
//	printf("max = %u,  index = %u \n", new_max.max_freq,);
	return new_max;
}


void build_hist(struct map new_max)
{
	int i,j;
	unsigned int y_i;
	unsigned char new_R;
	unsigned char new_G;
	unsigned char new_B;
	switch(select_comp)
	{
		case R_comp: new_R = 255; new_G =   0; new_B =   0; break;
		case G_comp: new_R =   0; new_G = 255; new_B =   0; break;
		case B_comp: new_R =   0; new_G =   0; new_B = 255; break;
		case Y_comp: new_R = 247; new_G = 148; new_B =  60; break;
		default    : new_R = 247; new_G = 148; new_B =  60; break;
	}
	float s =  (float)200/new_max.max_freq;
	
	if(new_max.index == 255)
	{
		for(i=0; i<W-4; i++)
		{
			y_i = floor ((float)mas_freq[i] *s) ;
			j=0;
			if(y_i>0)
			{
				while (j < y_i)
				{
					new_hist_r[H-1-j][i] = new_R;
					new_hist_g[H-1-j][i] = new_G;
					new_hist_b[H-1-j][i] = new_B;
					j++;
				}
			}
		}
		for(i=W-4; i < W; i++)
		{
			j=0;
			while (j < H)
			{
					new_hist_r[H-1-j][i] = new_R;
					new_hist_g[H-1-j][i] = new_G;
					new_hist_b[H-1-j][i] = new_B;
					j++;
			}
		}
	}
	else if(new_max.index == 0)
	{
		for(i=0; i < 4; i++)
		{
			j=0;
			while (j < H)
			{
					new_hist_r[H-1-j][i] = new_R;
					new_hist_g[H-1-j][i] = new_G;
					new_hist_b[H-1-j][i] = new_B;
					j++;
			}
		}
		
		for(i=4; i<W; i++)
		{
			y_i = floor ((float)mas_freq[i] *s) ;
			j=0;
			if(y_i>0)
			{
				while (j < y_i)
				{
					new_hist_r[H-1-j][i] = new_R;
					new_hist_g[H-1-j][i] = new_G;
					new_hist_b[H-1-j][i] = new_B;
					j++;
				}
			}
		}
	}
	else
	{
		for(i=0; i<W; i++)
		{
			y_i = floor ((float)mas_freq[i] *s) ;
			j=0;
			if(y_i>0)
			{
				while (j < y_i)
				{
					new_hist_r[H-1-j][i] = new_R;
					new_hist_g[H-1-j][i] = new_G;
					new_hist_b[H-1-j][i] = new_B;
					j++;
				}
			}
		}
		
	}
}
void build_hist2(struct map new_max)
{
	int i,j,t;
	unsigned int y_i;
	unsigned int y_mas[26];
	unsigned char new_R;
	unsigned char new_G;
	unsigned char new_B;
	unsigned char tmp;
	switch(select_comp)
	{
		case R_comp: new_R = 255; new_G =   0; new_B =   0; break;
		case G_comp: new_R =   0; new_G = 255; new_B =   0; break;
		case B_comp: new_R =   0; new_G =   0; new_B = 255; break;
		case Y_comp: new_R = 247; new_G = 148; new_B =  60; break;
		default    : new_R = 247; new_G = 148; new_B =  60; break;
	}
	float s =  (float)200/new_max.max_freq;
	

    
	for(i=0; i<W/10; i++)
	{
		y_i=0;
		for( t=0;t<10;t++)
			y_i += floor ((float)mas_freq[i*10+t] *s) ;
		y_i = (float)y_i/10. ;
		j=0;
		if(y_i>0)
		{	
				while (j < y_i)
				{
					for( t=0;t<10;t++)
					{
						tmp = i*10+t;
						new_hist_r[H-1-j][tmp] = new_R;
						new_hist_g[H-1-j][tmp] = new_G;
						new_hist_b[H-1-j][tmp] = new_B;
					}
					j++;
				}
		
		}
	}
		
}


void write_hist(int *mem_hist_write)
{
	int i,j; 
	int l;
	unsigned int tmp =0;
	unsigned int byte0;
	unsigned int byte1;
	unsigned int byte2;
	for(i=0; i<H; i++)
	{
		for(j=0; j<W; j++)
		{
			byte0 = new_hist_r[i][j];
			byte1 = new_hist_g[i][j];
			byte2 = new_hist_b[i][j];
			tmp = (byte2 << 16 ) | (byte1 << 8 ) | byte0;
			l = W*i +j;
			*(mem_hist_write  + l   ) = tmp;
		}
	}
	for(i=0; i<H; i++)
		for(j=0; j<W; j++)
		{
			new_hist_r[i][j] = 255;
			new_hist_g[i][j] = 255;		
			new_hist_b[i][j] = 255;		
		}
}
void poll_status_register(int *mem_freq)
{
	int status_hist = 0;
	int i=0;
	while( status_hist ==0)
	{
		i++;
		status_hist = *(mem_freq  + 256);	
	}
	*(mem_freq  + 256) = 0;		
}

void initial_gamma_mem(unsigned char *lw_hps2fpga, double a)
{
	float n;
	unsigned char data;
	n =(float)(255./pow(255.,a));
    for(int i=0;i<256;i++)
    {
        data =(unsigned char) n*(pow((double)i, a));
		*(lw_hps2fpga  + i) = data;
		*(lw_hps2fpga  + 256 + i) = data;
    }
}
void hist()
{
	int fd;
	int *mem_hist_write;
	int *mem_freq_read;
	struct map new_max;
	//unsigned int max_freq;
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		//return( 1 );
	} 
	mem_hist_write  = ( int * ) mmap( NULL, 0x64000, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, ADDR_BUF_3  );
	mem_freq_read   =(int *) mmap( NULL, 0x404, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, ADDR_BUF_3 + 0x64000);
	while(1)
	{
	//==== 1. Poll of the status register in ddr buffer =====//
		poll_status_register( mem_freq_read );
		//==== 2.          =====//
		new_max = read_freq( mem_freq_read );
		//==== 3.  =====//
		build_hist(new_max);
		//==== 4.  =====//
		write_hist(mem_hist_write );
	}
	
	
	if( munmap( mem_hist_write, 0x64000 ) != 0 ||  munmap( mem_freq_read, 0x404 ) != 0) 
	{
		printf( "ERROR: munmap() failed...\n" );
		close( fd );
		//return( 1 );
	}

	
}

void initial_reg_camera()
{
	int fd;
	int *hps2fpga2;
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		//return( 1 );
	} 
	hps2fpga2 = (int *)mmap( NULL, MEM_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, BASE_ADDR_H2F_BRIDGE );
	initial_reg_camera_1280x720(hps2fpga2);
	if( munmap( hps2fpga2, MEM_SPAN ) != 0 ) 
	{
		printf( "ERROR: munmap() failed...\n" );
		close( fd );
	}
}

void user()
{
	int fd;
	int *hps2fpga;
	unsigned char *lw_hps2fpga;
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		//return( 1 );
	} 
	hps2fpga = (int *)mmap( NULL, MEM_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, BASE_ADDR_H2F_BRIDGE );
	lw_hps2fpga = (unsigned char *)mmap( NULL, 0x200, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, 0xFF200000 );
	initial_gamma_mem(lw_hps2fpga, 0.6);
	struct hostent *server;
	int server_socket, client_socket;
	int answer_len, count =0;
	struct sockaddr_in sin, client;
	server_socket = socket (AF_INET, SOCK_DGRAM, 0);
	if(server_socket==-1)
	{
		printf("Error\n");
		exit(1);
	}
	int n;
	int i;
	int size;
	int bridge;
	uint32_t buff[1024];
	sin.sin_family      = AF_INET;
	sin.sin_addr.s_addr =  INADDR_ANY;// sin_addr - структура, содержащая IP-адрес
	sin.sin_port        = htons(PORT);

	bind(server_socket, (struct sockaddr *) &sin, sizeof(sin) );
	printf("Server started \n");
	int f;
	unsigned short addr;
	unsigned char data;
	unsigned int tmp;
	uint16_t num_camera;
	socklen_t  clilen;
	while(1) {
        clilen = sizeof(client);
		int bsize=recvfrom(server_socket, buff, 4096, 0,(struct sockaddr *) &client_socket, &clilen);
		size   = reverse_byte(buff[0]);
		bridge = reverse_byte(buff[1]);
		if(bridge == 1)
			for(i=0;i<size-1;i++)
			{	
				tmp = reverse_byte(buff[i+2]);
				addr = tmp & 0xffff ;
				data = tmp >> 16;
				*(hps2fpga  + addr) = data;
				if(addr == 17)
				{
					switch(data)
					{
						case  1: select_comp = R_comp;  break;
						case  2: select_comp = G_comp;  break;
						case  4: select_comp = B_comp;  break;
						case  8: select_comp = Y_comp;  break;
						default: select_comp = Y_comp;  break;
					}
				}
			}
		else
			for(i=0;i<size-1;i++)
			{	
				tmp = reverse_byte(buff[i+2]);
				addr = tmp & 0xffff ;
				data = tmp >> 16;
				*(lw_hps2fpga  + addr) = data;
			}
    }
	if( munmap( hps2fpga, MEM_SPAN ) != 0  || munmap( lw_hps2fpga, 0x200 ) != 0) 
	{
		printf( "ERROR: munmap() failed...\n" );
		close( fd );
	}
	close(server_socket);
	
}











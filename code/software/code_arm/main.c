#include "initial_reg_camera_1280x720.h"


int main()
{
	int fd;
	int *hps2fpga;
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( 1 );
	} 
	hps2fpga = mmap( NULL, MEM_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, BASE_ADDR_H2F_BRIDGE );
	initial_reg_camera_1280x720(hps2fpga);
	
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
	uint32_t buff[1024];
	sin.sin_family      = AF_INET;
	sin.sin_addr.s_addr =  INADDR_ANY;// sin_addr - структура, содержащая IP-адрес
	sin.sin_port        = htons(PORT);

	bind(server_socket, (struct sockaddr *) &sin, sizeof(sin) );
	printf("Server started \n");
	int f;
	uint16_t addr;
	uint8_t data;
	uint32_t tmp;
	//uint16_t data;
	uint16_t num_camera;
	int clilen;
	while(1) {
        clilen = sizeof(client);
		int bsize=recvfrom(server_socket, buff, 4096, 0,(struct sockaddr *) &client_socket, &clilen);
		size  = reverse_byte(buff[0]);
		for(i=0;i<size;i++)
		{	
			tmp = reverse_byte(buff[i+1]);
			addr = tmp & 0xffff ;
			data = tmp >> 16;
			*(hps2fpga  + addr) = data;
		}
    }
	if( munmap( hps2fpga, MEM_SPAN ) != 0 ) 
	{
		printf( "ERROR: munmap() failed...\n" );
		close( fd );
		return( 1 );
	}
	close(server_socket);
	return 0;
}

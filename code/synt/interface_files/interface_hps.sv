//////////////////////////////////////////////////////
//Name File     : interface_hps                //
//Author        : Andrey Papushin                   //
//Email         : andrey.papushin@gmail.com         //
//Standart      : IEEE 1800—2009(SystemVerilog-2009)//
//Start design  : 23.04.2018                        //
//Last revision : 23.04.2018                        //
//////////////////////////////////////////////////////
interface sdram_ifc #(parameter WIDTH_ADDR=1,  WIDTH_DATA=1, WIDTH_BE=1);
	logic [WIDTH_ADDR-1:0]  address           ;
	logic [7:0]             burstcount        ;
	logic                   waitrequest       ;
	logic [WIDTH_DATA-1:0]  readdata          ;
	logic                   readdatavalid     ;
	logic                   read              ;
	logic [WIDTH_DATA-1:0]  writedata         ;
	logic [WIDTH_BE  -1:0]  byteenable        ;
	logic                   write             ;
	modport sdram_bidirect_slave_port
	(
		input   address      ,       
		input   burstcount   ,    
		output  waitrequest  ,   
		output  readdata     ,      
		output  readdatavalid, 
		input   read         ,          
		input   writedata    ,     
		input   byteenable   ,    
		input   write
	);
	modport sdram_bidirect_master_port
	(
		output   address      ,       
		output   burstcount   ,    
		input    waitrequest  ,   
		input    readdata     ,      
		input    readdatavalid, 
		output   read         ,          
		output   writedata    ,     
		output   byteenable   ,    
		output   write
	);
	
	modport sdram_write_slave_port
	(
		input   address      ,       
		input   burstcount   ,    
		output  waitrequest  ,          
		input   writedata    ,     
		input   byteenable   ,    
		input   write
	);
	
	modport sdram_write_master_port
	(
		output   address      ,       
		output   burstcount   ,    
		input    waitrequest  ,   
		output   writedata    ,     
		output   byteenable   ,    
		output   write
	);
	
	modport sdram_read_slave_port
	(
		input   address      ,       
		input   burstcount   ,    
		output  waitrequest  ,          
		input   read         ,          
		output   readdata     ,   
		output   readdatavalid 
		
	);
	
	modport sdram_read_master_port
	(
		output   address      ,       
		output   burstcount   ,    
		input  waitrequest  ,          
		output   read         ,          
		input   readdata     ,   
		input   readdatavalid 
	);
endinterface
       
interface avl_ifc #(parameter WIDTH_ADDR=1,  WIDTH_DATA=1, WIDTH_BE=1);

	logic [WIDTH_ADDR-1:0]  address   ;
	logic [WIDTH_DATA-1:0]  readdata  ;
	logic [WIDTH_DATA-1:0]  writedata ;
	logic [WIDTH_BE  -1:0]  byteenable;
	logic                   chipselect;
	logic                   clken     ;
	logic                   write     ;
                           
	modport mem_slave_port
	(
		input  address   ,    
		input  chipselect, 
		input  clken     ,      
		input  write     ,      
		output readdata  ,   
		input  writedata ,  
		input  byteenable       
	);   
	
	modport mem_master_port
	(
		output  clken     ,
		output  address   ,    
		output  chipselect,     
		output  write     ,      
		input   readdata  ,   
		output  writedata ,  
		output  byteenable       
	);   
	modport avl_slave_port
	(
		input  address   ,    
		input  chipselect,      
		input  write     ,      
		output readdata ,   
		input  writedata ,  
		input  byteenable       
	);   
	modport avl_write_slave_port
	(
		input  address   ,    
		input  chipselect,      
		input  write     ,      
		input  writedata ,  
		input  byteenable       
	);   
	
	
	modport avl_master_port
	(
		output  address   ,    
		output  chipselect,     
		output  write     ,      
		input   readdata  ,   
		output  writedata ,  
		output  byteenable       
	);   
endinterface	

interface ddr3_ifc;
	
	wire [14:0] a       ;        
	wire [2:0]  ba      ;        
	wire        ck      ;        
	wire        ck_n    ;        
	wire        cke     ;        
	wire        cs_n    ;        
	wire        ras_n   ;        
	wire        cas_n   ;        
	wire        we_n    ;        
	wire        reset_n ;   
	wire [31:0] dq      ;        
	wire [3:0]  dqs     ;        
	wire [3:0]  dqs_n   ;        
	wire        odt     ;        
	wire [3:0]  dm      ;        
    wire        rzqin   ;        
                              
	modport ddr3_port
	(
		output  a,      
        output  ba,     
        output  ck,     
        output  ck_n,   
        output  cke,    
        output  cs_n,   
        output  ras_n,  
        output  cas_n,  
        output  we_n,   
        output  reset_n,
        inout   dq,     
        inout   dqs,    
        inout   dqs_n,  
        output  odt,    
        output  dm,     
        input   rzqin 	
	);  
endinterface
interface hps_ifc;
	wire   emac1_inst_TX_CLK; 
	wire   emac1_inst_TXD0  ;
	wire   emac1_inst_TXD1  ;
	wire   emac1_inst_TXD2  ;
	wire   emac1_inst_TXD3  ;
	wire   emac1_inst_RXD0  ;
	wire   emac1_inst_MDIO  ;
	wire   emac1_inst_MDC   ;
	wire   emac1_inst_RX_CTL;
	wire   emac1_inst_TX_CTL;
	wire   emac1_inst_RX_CLK;
	wire   emac1_inst_RXD1  ;
	wire   emac1_inst_RXD2  ;
	wire   emac1_inst_RXD3  ;
	wire   sdio_inst_CMD    ;
	wire   sdio_inst_D0     ;
	wire   sdio_inst_D1     ;
	wire   sdio_inst_CLK    ;
	wire   sdio_inst_D2     ;
	wire   sdio_inst_D3     ;
	wire   usb1_inst_D0     ;
	wire   usb1_inst_D1     ;
	wire   usb1_inst_D2     ;
	wire   usb1_inst_D3     ;
	wire   usb1_inst_D4     ;
	wire   usb1_inst_D5     ;
	wire   usb1_inst_D6     ;
	wire   usb1_inst_D7     ;
	wire   usb1_inst_CLK    ;
	wire   usb1_inst_STP    ;
	wire   usb1_inst_DIR    ;
	wire   usb1_inst_NXT    ;
	wire   spim1_inst_CLK   ;
	wire   spim1_inst_MOSI  ;
	wire   spim1_inst_MISO  ;
	wire   spim1_inst_SS0   ;
	wire   uart0_inst_RX    ;
	wire   uart0_inst_TX    ;
	wire   i2c0_inst_SDA    ;
	wire   i2c0_inst_SCL    ;
	wire   i2c1_inst_SDA    ;
	wire   i2c1_inst_SCL    ;
                 
	modport hps_io_port
	(
		output	emac1_inst_TX_CLK  ,
		output	emac1_inst_TXD0    ,
		output	emac1_inst_TXD1    ,
		output	emac1_inst_TXD2    ,
		output	emac1_inst_TXD3    ,
		input 	emac1_inst_RXD0    ,
		inout 	emac1_inst_MDIO    ,
		output	emac1_inst_MDC     ,
		input 	emac1_inst_RX_CTL  ,
		output	emac1_inst_TX_CTL  ,
		input 	emac1_inst_RX_CLK  ,
		input 	emac1_inst_RXD1    ,
		input 	emac1_inst_RXD2    ,
		input 	emac1_inst_RXD3    ,	
		inout 	sdio_inst_CMD      ,
		inout 	sdio_inst_D0       ,
		inout 	sdio_inst_D1       ,
		output	sdio_inst_CLK      ,
		inout 	sdio_inst_D2       ,
		inout 	sdio_inst_D3       ,
		inout 	usb1_inst_D0       ,
		inout 	usb1_inst_D1       ,
		inout 	usb1_inst_D2       ,
		inout 	usb1_inst_D3       ,
		inout 	usb1_inst_D4       ,
		inout 	usb1_inst_D5       ,
		inout 	usb1_inst_D6       ,   
		inout 	usb1_inst_D7       ,   
		input 	usb1_inst_CLK      ,   
		output	usb1_inst_STP      ,   
		input 	usb1_inst_DIR      ,   
		input 	usb1_inst_NXT      ,   
		output	spim1_inst_CLK     ,   
		output	spim1_inst_MOSI    ,   
		input 	spim1_inst_MISO    ,   
		output	spim1_inst_SS0     ,   
		input 	uart0_inst_RX      ,   
		output	uart0_inst_TX      ,   
		inout 	i2c0_inst_SDA      ,   
		inout 	i2c0_inst_SCL      ,   
		inout 	i2c1_inst_SDA      ,   
		inout 	i2c1_inst_SCL      			
	);  
	
endinterface  

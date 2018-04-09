
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
//=========8===========//       
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

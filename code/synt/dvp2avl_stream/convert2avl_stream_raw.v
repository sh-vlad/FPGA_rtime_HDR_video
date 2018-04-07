//////////////////////////////////////////////////////
//Name File     : convert2avl_stream_raw            //
//Author        : Andrey Papushin                   //
//Email         : andrey.papushin@gmail.com         //
//Standart      : IEEE 1800—2009(SystemVerilog-2009)//
//Start design  : 27.02.2018                        //
//Last revision : 06.03.2018                        //
//////////////////////////////////////////////////////
module convert2avl_stream_raw
(
	input wire             pclk   	       ,
	input wire             clk_sys	       ,
	input wire             reset_n	       ,
	input wire             VSYNC  	       ,
	input wire             HREF   	       ,
	input wire [7:0]       D1     	       ,
	input wire [7:0]       D2     	       ,	                               
	output logic [7:0]     RAW_1           ,
	output logic [7:0]     RAW_2           ,
	output logic           valid_RAW_1     ,                                       
	output logic           valid_RAW_2     ,                                       
	output logic           SOF    	       ,
	output logic           EOF    	       ,
	output logic           start_frame     ,
	output logic [63:0]    data_ddr        ,
    output logic           valid_data_ddr
	
);
reg [9:0] reg_RAW_1;
reg [9:0] reg_RAW_2;

reg sh_VSYNC;
reg sh_HREF;		
always @(posedge pclk or negedge reset_n)
	if (~reset_n )
		sh_VSYNC <=1'b0;
	else 
		sh_VSYNC <=VSYNC;
always @(posedge pclk or negedge reset_n)
	if (~reset_n )
		sh_HREF <=1'b0;
	else 
		sh_HREF <=HREF;
		
wire p_VSYNC = VSYNC & ! sh_VSYNC;		
wire n_VSYNC = !VSYNC & sh_VSYNC;		
wire p_HREF  = HREF & ! sh_HREF;
reg [1:0] counter_comp;

wire valid_Y;
reg valid_Cb;
wire valid_Cr;
reg [11:0] count_data_dvp;
wire last_data = ( count_data_dvp == 12'd1279 );
reg sh_last_data;
always @(posedge pclk or negedge reset_n)
	if (~reset_n )
		reg_RAW_1 <='0;
	else if(p_HREF)
		reg_RAW_1 <= {2'b01, D1};
	else if(last_data)
		reg_RAW_1 <= {2'b10, D1};
	else 
		reg_RAW_1 <= {2'b00, D1};

always @(posedge pclk or negedge reset_n)
	if (~reset_n )
		reg_RAW_2 <='0;
	else if(p_HREF)
		reg_RAW_2 <= {2'b01, D2};
	else if(last_data)
		reg_RAW_2 <= {2'b10, D2};
	else 
		reg_RAW_2 <= {2'b00, D2};		
		
	
		
always @(posedge pclk or negedge reset_n)
	if (~reset_n )
		sh_last_data <='0;
	else 
		sh_last_data <= last_data;	
	

always @(posedge pclk, negedge reset_n)
	if(!reset_n)
		count_data_dvp <='0;
	else if(p_HREF)
		count_data_dvp <='d1;
	else if(sh_last_data)
		count_data_dvp <='0;
	else if(HREF)
		count_data_dvp <= count_data_dvp + 1;		

	
reg[17:0] data_fifo1_in;
reg[17:0] data_fifo2_in;


wire          empty1;		
wire          empty2;		
wire          rdreq1 =  !empty1;		
wire          rdreq2 =  !empty2;		
wire [17:0]   data_fifo_out1;	
wire [17:0]   data_fifo_out2;	

reg [2:0] sh_reg;
always @(posedge clk_sys, negedge reset_n)
	if(!reset_n)
		sh_reg <='0;
	else 
		sh_reg <={sh_reg[1:0],rdreq1};
fifo_dvp  fifo_dvp_image1 
(
	.wrclk   (pclk            ),
	.rdclk   (clk_sys         ),
	.data    ({8'd0,reg_RAW_1}),
	.rdreq   (rdreq1          ),//
	.wrreq   (sh_HREF         ),
	.rdempty (empty1          ),
	.wrfull  (                ),
	.q       (data_fifo_out1  ),
	.rdusedw (                )
);	

fifo_dvp  fifo_dvp_image2
(
	.wrclk   (pclk            ),
	.rdclk   (clk_sys         ),
	.data    ({8'd0,reg_RAW_2}),
	.rdreq   (rdreq2          ),//
	.wrreq   (sh_HREF         ),
	.rdempty (empty2          ),
	.wrfull  (                ),
	.q       (data_fifo_out2  ),
	.rdusedw (                )
);	

assign valid_RAW_1 = sh_reg[0];
assign valid_RAW_2 = sh_reg[0];
assign RAW_1  = data_fifo_out1[7:0];
assign RAW_2  = data_fifo_out2[7:0];


assign SOF	       = data_fifo_out1[8] & sh_reg[0];	
assign EOF	       = data_fifo_out1[9] & sh_reg[0];	
assign start_frame = p_VSYNC ;//reg_start_frame & !sh_reg_start_frame;
reg [63:0] reg_ddr;
always @(posedge clk_sys, negedge reset_n)
	if(!reset_n)
		reg_ddr <='0;
	else if(valid_RAW_1)
		reg_ddr <={ RAW_1, reg_ddr[63:8]};
always @(posedge clk_sys, negedge reset_n)
	if(!reset_n)
		data_ddr <='0;
	else 
		data_ddr <=reg_ddr;
		
reg [4:0]counter_valid_raw;	
wire end_8_bytes = counter_valid_raw ==4'd8;
always @(posedge clk_sys, negedge reset_n)
	if(!reset_n)
		counter_valid_raw <= '0;
	else if(  SOF)
		counter_valid_raw <= 'd1;
	else if(end_8_bytes )
		counter_valid_raw <= 'd0;
	else if(valid_RAW_1)
		counter_valid_raw <= counter_valid_raw +1; 
always @(posedge clk_sys, negedge reset_n)
	if(!reset_n)
		valid_data_ddr <='0;
	else if(end_8_bytes)
		valid_data_ddr <=1;
	else 
		valid_data_ddr <='0;


endmodule
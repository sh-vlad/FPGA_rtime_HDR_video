//////////////////////////////////////////////////////
//Name File     : convert2avl_stream_raw            //
//Author        : Andrey Papushin                   //
//Email         : andrey.papushin@gmail.com         //
//Standart      : IEEE 1800—2009(SystemVerilog-2009)//
//Start design  : 27.02.2018                        //
//Last revision : 09.04.2018                        //
//////////////////////////////////////////////////////
module convert2avl_stream_raw
(
	input wire             pclk_1   	   ,
	input wire             pclk_2   	   ,
	input wire             clk_sys	       ,
	input wire             reset_n	       ,
	input wire             VSYNC_1  	   ,
	input wire             VSYNC_2  	   ,
	input wire             HREF_1   	   ,
	input wire             HREF_2   	   ,
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
	output logic [7:0]     count_frame_1   ,
	output logic [7:0]     count_frame_2   ,
	output logic [9:0]     count_href_1   ,
	output logic [9:0]     count_href_2   ,
    output logic           valid_data_ddr
	
);
reg [9:0] reg_RAW_1;
reg [9:0] reg_RAW_2;

reg sh_VSYNC_1;
reg sh_VSYNC_2;
reg sh_HREF_1;		
reg sh_HREF_2;		
always @(posedge pclk_1 or negedge reset_n)
	if (~reset_n )
		sh_VSYNC_1 <=1'b0;
	else 
		sh_VSYNC_1 <=VSYNC_1;
always @(posedge pclk_1 or negedge reset_n)
	if (~reset_n )
		sh_HREF_1 <=1'b0;
	else 
		sh_HREF_1 <=HREF_1;
always @(posedge pclk_2 or negedge reset_n)
	if (~reset_n )
		sh_VSYNC_2 <=1'b0;
	else 
		sh_VSYNC_2 <=VSYNC_2;
always @(posedge pclk_2 or negedge reset_n)
	if (~reset_n )
		sh_HREF_2 <=1'b0;
	else 
		sh_HREF_2 <=HREF_2;		
wire p_VSYNC_1 = VSYNC_1 & ! sh_VSYNC_1;		
wire n_VSYNC_1 = !VSYNC_1 & sh_VSYNC_1;		
wire p_VSYNC_2 = VSYNC_2 & ! sh_VSYNC_2;		
wire n_VSYNC_2 = !VSYNC_2 & sh_VSYNC_2;	
wire p_HREF_1  = HREF_1 & ! sh_HREF_1;
wire p_HREF_2  = HREF_2 & ! sh_HREF_2;
reg [1:0] counter_comp;

reg [11:0] count_data_dvp_1;
reg [11:0] count_data_dvp_2;
wire last_data_1 = ( count_data_dvp_1 == 12'd1279 );
wire last_data_2 = ( count_data_dvp_2 == 12'd1279 );
reg sh_last_data_1;
reg sh_last_data_2;
always @(posedge pclk_1 or negedge reset_n)
	if (~reset_n )
		reg_RAW_1 <='0;
	else if(p_HREF_1)
		reg_RAW_1 <= {2'b01, D1};
	else if(last_data_1)
		reg_RAW_1 <= {2'b10, D1};
	else 
		reg_RAW_1 <= {2'b00, D1};

always @(posedge pclk_2 or negedge reset_n)
	if (~reset_n )
		reg_RAW_2 <='0;
	else if(p_HREF_2)
		reg_RAW_2 <= {2'b01, D2};
	else if(last_data_2)
		reg_RAW_2 <= {2'b10, D2};
	else 
		reg_RAW_2 <= {2'b00, D2};		
		
	
		
always @(posedge pclk_1 or negedge reset_n)
	if (~reset_n )
		sh_last_data_1 <='0;
	else 
		sh_last_data_1 <= last_data_1;	
	
always @(posedge pclk_2 or negedge reset_n)
	if (~reset_n )
		sh_last_data_2 <='0;
	else 
		sh_last_data_2 <= last_data_2;
		
		
	
always @(posedge pclk_1, negedge reset_n)
	if(!reset_n)
		count_data_dvp_1 <='0;
	else if(p_HREF_1)
		count_data_dvp_1 <='d1;
	else if(sh_last_data_1)
		count_data_dvp_1 <='0;
	else if(HREF_1)
		count_data_dvp_1 <= count_data_dvp_1 + 1;	
		
always @(posedge pclk_2, negedge reset_n)
	if(!reset_n)
		count_data_dvp_2 <='0;
	else if(p_HREF_2)
		count_data_dvp_2 <='d1;
	else if(sh_last_data_2)
		count_data_dvp_2 <='0;
	else if(HREF_2)
		count_data_dvp_2 <= count_data_dvp_2 + 1;	

always @(posedge pclk_1, negedge reset_n)
	if(!reset_n)
		count_frame_1 <='0;
	else if(p_VSYNC_1)
		count_frame_1 <= count_frame_1 + 1;	
		
always @(posedge pclk_2, negedge reset_n)
	if(!reset_n)
		count_frame_2 <='0;
	else if(p_VSYNC_2)
		count_frame_2 <= count_frame_2 + 1;	
		
always @(posedge pclk_1, negedge reset_n)
	if(!reset_n)
		count_href_1 <='0;
	else if(p_VSYNC_1)
		count_href_1 <='0;
	else if(p_HREF_1)
		count_href_1 <= count_href_1 + 1;	
		
always @(posedge pclk_2, negedge reset_n)
	if(!reset_n)
		count_href_2 <='0;
	else if(p_VSYNC_2)
		count_href_2 <='0;
	else if(p_HREF_2)
		count_href_2 <= count_href_2 + 1;	
		
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
	.wrclk   (pclk_1            ),
	.rdclk   (clk_sys         ),
	.data    ({8'd0,reg_RAW_1}),
	.rdreq   (rdreq1          ),//
	.wrreq   (sh_HREF_1         ),
	.rdempty (empty1          ),
	.wrfull  (                ),
	.q       (data_fifo_out1  ),
	.rdusedw (                )
);	

fifo_dvp  fifo_dvp_image2
(
	.wrclk   (pclk_2            ),
	.rdclk   (clk_sys         ),
	.data    ({8'd0,reg_RAW_2}),
	.rdreq   (rdreq2          ),//
	.wrreq   (sh_HREF_2         ),
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
assign start_frame = p_VSYNC_1 ;//reg_start_frame & !sh_reg_start_frame;
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
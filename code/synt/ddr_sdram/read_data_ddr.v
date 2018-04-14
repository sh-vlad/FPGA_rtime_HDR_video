
module read_data_ddr
(
	input  wire  						    clk_100         ,    
	input  wire 						    reset_b         ,
	input  wire                             line_request	,
	input  wire                             start_read_image_from_ddr	,
	input  wire                             done_write_frame	,
	output  reg                             frame_buffer_ready	,
	output reg  [7:0]                       r_data          ,
	output reg  [7:0]                       g_data          ,
	output reg  [7:0]                       b_data          ,
	output reg                              valid_rgb       ,
	input  wire [29:0]                      addr_read_ddr1   ,
	input  wire [29:0]                      addr_read_ddr2   ,
	sdram_ifc.sdram_read_master_port        f2h_sdram         // avl интерфейс к sdram 
);
reg ctrl_buff;
reg last_burst;
reg ready_start;
reg [13:0] count_burst;
reg start_read;
reg sh_start_read;
reg read_frame;
reg [7:0] count_unit_burst;
reg [3:0] count_burst_in_line;
wire last_unit_burst  = ( count_unit_burst == 'd79 ); 
wire end_frame        = last_unit_burst  & last_burst;
wire end_line         = (count_burst_in_line == 'd15) &  last_unit_burst;
always @( posedge clk_100 or negedge reset_b )
	if ( !reset_b ) 
		{b_data, g_data, r_data} <= 24'd0;	
	else if(f2h_sdram.readdatavalid) 
		{b_data, g_data, r_data} <= f2h_sdram.readdata[23:0];

always @( posedge clk_100 or negedge reset_b )
	if ( !reset_b ) 
		valid_rgb <= 1'd0;	
	else
		valid_rgb <= f2h_sdram.readdatavalid;
always @( posedge clk_100 or negedge reset_b )
	if ( !reset_b ) 
		read_frame <= 1'd0;	
	else if(end_frame)
		read_frame <= 0;	
	else if(sh_start_read)
		read_frame <= 1;	
always @( posedge clk_100 or negedge reset_b )
	if ( !reset_b ) 
		frame_buffer_ready <= 1'd0;	
	else if(done_write_frame)
		frame_buffer_ready <= 1;
always @( posedge clk_100 or negedge reset_b )
	if ( !reset_b ) 
		ready_start <= 1'd0;
	else if(start_read)
		ready_start <= 0;
	else if(frame_buffer_ready & line_request)
		ready_start <= 1;
always_ff @(posedge clk_100  or negedge reset_b)
	if (~reset_b)
		ctrl_buff <= 1'd0;
	else if(done_write_frame)
		ctrl_buff <= ~ctrl_buff;	
// флаг валидности данных на f=100MHz
always_ff @(posedge clk_100  or negedge reset_b)
	if (~reset_b)
		start_read  <= 1'd0;
	else if(ready_start & !start_read & !f2h_sdram.waitrequest )
		start_read  <= 1'd1;
	else 
		start_read  <= 1'd0;
always_ff @(posedge clk_100  or negedge reset_b)
	if (~reset_b)
		count_unit_burst  <= 8'd0;
	else if(last_unit_burst)
		count_unit_burst  <= 8'd0;
	else if(f2h_sdram.readdatavalid & !f2h_sdram.waitrequest)
		count_unit_burst  <= count_unit_burst + 8'd1;
always_ff @(posedge clk_100  or negedge reset_b)
	if (~reset_b)
		count_burst <= 14'd0;
	else if(end_frame)
		count_burst <= 14'd0;
	else if(last_unit_burst & !end_frame)
		count_burst <= count_burst + 14'd1;		
		
always_ff @(posedge clk_100  or negedge reset_b)
	if (~reset_b)
		count_burst_in_line <= 14'd0;
	else if(end_line)
		count_burst_in_line <= 14'd0;
	else if(last_unit_burst )
		count_burst_in_line <= count_burst_in_line + 14'd1;
		
		
always_ff @(posedge clk_100  or negedge reset_b)
	if (~reset_b)
		last_burst <= 1'b0;
	else if(sh_start_read)
		last_burst <= 1'b0;	
	else if(count_burst == 'd11519)
		last_burst <= 1'b1;			
always_ff @(posedge clk_100  or negedge reset_b)
	if (~reset_b)
		sh_start_read  <= 1'd0;
	else if(start_read )
		sh_start_read  <= 1'd1;
	else
		sh_start_read  <= 1'd0;
reg        read      ;  
reg [29:0] address   ;		
reg [ 7:0] burstcount;		
reg        reg_read      ;  
reg [29:0] reg_address   ;		
reg [ 7:0] reg_burstcount;			
/* интерфейс avl к sdram контроллеру */
always_ff @(posedge clk_100  or negedge reset_b)
	if (~reset_b)
	begin
		read        <= 1'd0;
		address     <= 'd0; 
		burstcount  <= 8'd80; 
	end
	else if(sh_start_read & !read_frame & ctrl_buff)
	begin
		read        <= 1'd1;
		address     <= addr_read_ddr1;
	end
	else if(sh_start_read & !read_frame & !ctrl_buff)
	begin
		read        <= 1'd1;
		address     <= addr_read_ddr2;
	end
	else if((last_unit_burst & !end_frame & !end_line) || (read_frame & sh_start_read))
	begin
		read        <= 1'd1;
		address     <= address + 'd80; 
	end
	else 
		read        <= 1'd0;
always_ff @(posedge clk_100  or negedge reset_b)
	if (~reset_b)
	begin
		reg_read        <= 1'd0;
		reg_address     <= 'd0; 
		reg_burstcount  <= 8'd0; 
	end
	else 
	begin
		reg_read        <=  read       ;
		reg_address     <=  address     ;
		reg_burstcount  <=  burstcount ;			
	end
assign f2h_sdram.read       =  reg_read      ;   
assign f2h_sdram.address   	=  reg_address    ;
assign f2h_sdram.burstcount	=  8'd80;




//
endmodule

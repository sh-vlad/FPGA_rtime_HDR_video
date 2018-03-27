//Author: ShVlad / e-mail: shvladspb@gmail.com
//

`timescale 1 ns / 1 ns
module HDMI_tx_test
(
//clocks & reset
	input wire  						pixel_clk,  
	input wire							reset_n,

//vga interface to ADV7513
	output reg							data_enable,
	output reg							hsync,
	output reg							vsync,
	output reg		[ 7: 0]				data_Y,
	output reg		[ 7: 0]				data_Cb_Cr
	
);
//
localparam HFRONT	= 110		- 1;
localparam HSYNC	= 40		- 1;
localparam HBACK	= 220		- 1;
localparam HACTIVE	= 1280		- 1;
localparam VFRONT	= 5			- 1;
localparam VSYNC	= 5			- 1;
localparam VBACK	= 20		- 1;
localparam VACTIVE 	= 720		- 1;
//
localparam HBLANK 	= HFRONT + HSYNC + HBACK;
localparam HTOTAL	= HBLANK + HACTIVE;
localparam VBLANK	= VFRONT + VSYNC + VBACK;
localparam VTOTAL	= VBLANK + VACTIVE;

reg		[12: 0]		h_count;
reg		[12: 0]		v_count;	
reg		[12: 0]		string_num;
wire	[10: 0]  	wrusedw;
reg					rdreq;
reg					Cb_Cr_label;
//making strobes 
always @( posedge pixel_clk or negedge reset_n )
	if ( !reset_n )
		h_count <= 13'h0;
	else
		if ( h_count == HTOTAL )
			h_count <= 13'h0;
		else
			h_count <= h_count + 1'h1;

always @( posedge pixel_clk or negedge reset_n )
	if ( !reset_n )
		v_count	<= 13'h0;
	else
		if ( v_count == VTOTAL )
			v_count <= 13'h0;
		else if ( h_count == HFRONT )
			v_count	<= v_count + 1'h1;
			
always @( posedge pixel_clk )
	if ( ( h_count >= HFRONT  ) && ( h_count <= HFRONT + HSYNC ) ) 
		hsync  <= 1'h0;
	else
		hsync  <= 1'h1;
			
always @( posedge pixel_clk )	
	if ( ( h_count >= 13'h0 && h_count <= HBLANK ) || ( v_count <= VBLANK ) )
		data_enable	<= 1'h0;
	else
		data_enable	<= 1'h1;
		
always @( posedge pixel_clk )
	if ( ( v_count >= VFRONT ) && ( v_count <= VFRONT + VSYNC ) )
		vsync <= 1'h0;
	else
		vsync <= 1'h1;
		
always @( posedge pixel_clk )
	if ( ( h_count >= 13'h0 && h_count <= HBLANK - 1) || ( v_count <= VBLANK ) )
		rdreq	<= 1'h0;
	else
		rdreq	<= 1'h1;		
//
always @( posedge pixel_clk )
	if ( !data_enable )
		Cb_Cr_label <= 1'h0;
	else
		Cb_Cr_label = ~Cb_Cr_label;


localparam GYCb	= {8'd81,8'd90};
localparam GYCr	= {8'd81,8'd240};
localparam RYCb	= {8'd145,8'd54};
localparam RYCr	= {8'd145,8'd34};
localparam BYCb	= {8'd41,8'd240};
localparam BYCr	= {8'd41,8'd110};
localparam WYCb	= {8'd235,8'd128};
localparam WYCr	= {8'd235,8'd128};	
/*			
always @( posedge pixel_clk ) 
	if ( (h_count > HBLANK) && (h_count <= (HBLANK + HACTIVE/4)) && Cb_Cr_label)
		{data_Y,data_Cb_Cr}	<= RYCb;
	else if ( h_count > HBLANK && h_count <= (HBLANK + HACTIVE/4) && !Cb_Cr_label)
		{data_Y,data_Cb_Cr}	<= RYCr;		
	else if ( (h_count > ( HBLANK + HACTIVE/4)) && (h_count <= ( HBLANK + (HACTIVE/4)*2 )) && Cb_Cr_label)
		{data_Y,data_Cb_Cr}	<= GYCb;
	else if ( (h_count > ( HBLANK + HACTIVE/4)) && (h_count <= ( HBLANK + (HACTIVE/4)*2 )) && !Cb_Cr_label)
		{data_Y,data_Cb_Cr}	<= GYCr;			
	else if ( (h_count > ( HBLANK + (HACTIVE/4)*2 )) && (h_count <= ( HBLANK + (HACTIVE/4)*3 )) && Cb_Cr_label)
		{data_Y,data_Cb_Cr}	<= BYCb;
	else if ( (h_count > ( HBLANK + (HACTIVE/4)*2 )) && (h_count <= ( HBLANK + (HACTIVE/4)*3 )) && !Cb_Cr_label)
		{data_Y,data_Cb_Cr}	<= BYCr;		
	else if ( (h_count > ( HBLANK + (HACTIVE/4)*3 )) && (h_count <= ( HBLANK + (HACTIVE/4)*4 )) && Cb_Cr_label)
		{data_Y,data_Cb_Cr}	<= WYCb;
	else if ( (h_count > ( HBLANK + (HACTIVE/4)*3 )) && (h_count <= ( HBLANK + (HACTIVE/4)*4 )) && !Cb_Cr_label)
		{data_Y,data_Cb_Cr}	<= WYCr;	
*/	

localparam VLOGO = 35;
localparam HLOGO = 102;
reg [11:0]  addr;
reg [15:0]  q;
always @( posedge pixel_clk or negedge reset_n )
	if ( !reset_n )
		addr	<= 12'h0;
	else	
		if ( (v_count >= (VBLANK + VACTIVE/2) && v_count < (VBLANK + VACTIVE/2 + VLOGO))/*( v_count >= 300 && v_count < 335 )*/ && ( h_count >= (HBLANK + HACTIVE/2) && h_count < (HBLANK + HACTIVE/2+HLOGO) )/*( h_count >= 600 && h_count <702 )*/ )
			addr <= addr + 1;
		else if ( v_count == (VBLANK + VACTIVE/2 + (VLOGO+1) ) )
			addr <= 0;
			
logo_mem logo_mem_inst
(
	.address	( addr				),
	.clock      ( pixel_clk			),
	.q          ( q	)
);	
assign {data_Cb_Cr, data_Y} = ( (v_count >= (VBLANK + VACTIVE/2) && v_count < (VBLANK + VACTIVE/2 + VLOGO)) && ( h_count >= (HBLANK + HACTIVE/2) && h_count < (HBLANK + HACTIVE/2+HLOGO) ) ) ? q : 24'h0;

endmodule




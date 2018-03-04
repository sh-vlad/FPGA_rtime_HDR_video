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

localparam RYCb	= 16'h1;
localparam RYCr	= 16'h2;
localparam GYCb	= 16'h3;
localparam GYCr	= 16'h4;
localparam BYCb	= 16'h5;
localparam BYCr	= 16'h6;

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
			
always @( posedge pixel_clk ) 
	if ( (h_count > HBLANK) && (h_count < (HBLANK + HACTIVE/3)) && Cb_Cr_label)
		{data_Y,data_Cb_Cr}	<= RYCb;
	else if ( h_count > HBLANK && h_count < (HBLANK + HACTIVE/3) && !Cb_Cr_label)
		{data_Y,data_Cb_Cr}	<= RYCr;		
	else if ( (h_count > (HBLANK + HACTIVE/3)) && (h_count < ( HBLANK + HACTIVE/3 + HACTIVE/3 )) && Cb_Cr_label)
		{data_Y,data_Cb_Cr}	<= GYCb;
	else if ( (h_count > (HBLANK + HACTIVE/3))  && (h_count < ( HBLANK + HACTIVE/3 + HACTIVE/3 )) && !Cb_Cr_label)
		{data_Y,data_Cb_Cr}	<= GYCr;			
	else if ( (h_count > (  HBLANK + HACTIVE/3 + HACTIVE/3)) && (h_count < ( HBLANK + HACTIVE/3 + HACTIVE/3 + HACTIVE/3 )) && Cb_Cr_label)
		{data_Y,data_Cb_Cr}	<= BYCb;
	else if ( (h_count > ( HBLANK + HACTIVE/3 + HACTIVE/3 )) && (h_count < (HBLANK + HACTIVE/3 + HACTIVE/3 + HACTIVE/3 )) && !Cb_Cr_label)
		{data_Y,data_Cb_Cr}	<= BYCr;		
endmodule




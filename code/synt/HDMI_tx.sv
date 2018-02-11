//Author: ShVlad / e-mail: shvladspb@gmail.com
//

`timescale 1 ns / 1 ns
module HDMI_tx
#(
	parameter DATA_WIDTH = 32
)
(
//clocks & reset
	input wire							clk,
	input wire  						pixel_clk,  
	input wire							reset_n,
// sink interface
	input wire							asi_snk_valid_i,
	output wire							asi_snk_ready_o,
	input wire		[DATA_WIDTH-1: 0] 	asi_snk_data_i,
	input wire		[ 0: 0] 			asi_snk_empty_i,
	input wire							asi_snk_startofpacket_i,
	input wire							asi_snk_endofpacket_i,
	input wire							asi_snk_error_i,
	input wire		[ 0: 0] 			asi_snk_channel_i,	
//vga interface to ADV7513
	output reg		[ 7: 0]				data_enable,
	output reg		[ 7: 0]				hsync,
	output reg		[ 7: 0]				vsync,
	output reg		[ 7: 0]				data_r,
	output reg		[ 7: 0]				data_g,
	output reg		[ 7: 0]				data_b
	
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
	if ( ( h_count >= HFRONT  ) && ( h_count >= HFRONT + HSYNC ) ) 
		hsync  <= 1'h0;
	else
		hsync  <= 1'h1;
			
always @( posedge pixel_clk )	
	if ( ( h_count <= HBLANK ) || ( v_count <= VBLANK ) )
		data_enable	<= 1'h0;
	else
		data_enable	<= 1'h1;
		
always @( posedge pixel_clk )
	if ( ( v_count >= VFRONT ) && ( v_count <= VFRONT + VSYNC ) )
		vsync <= 1'h0;
	else
		vsync <= 1'h1;
	

endmodule






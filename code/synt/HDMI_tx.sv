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
	output reg							line_request_o,
	input wire		[DATA_WIDTH-1: 0] 	asi_snk_data_i,
	input wire							asi_snk_startofpacket_i,
	input wire							asi_snk_endofpacket_i,
//vga interface to ADV7513
	output reg							data_enable,
	output reg							hsync,
	output reg							vsync,
	output logic		[ 7: 0]			data_r,
	output logic		[ 7: 0]			data_g,
	output logic		[ 7: 0]			data_b
	
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
reg					line_request_pclk;
reg		[ 2: 0]		line_request_sys_clk;
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
	if ( ( h_count >= HBLANK-10 && h_count <= HBLANK ) && ( v_count >= VBLANK && v_count < VTOTAL-1 ) )
		line_request_pclk <= 1'h1;
	else
		line_request_pclk <= 1'h0;
		
always @( posedge clk )
	begin
		line_request_sys_clk <= {line_request_sys_clk[1:0], line_request_pclk };	
		line_request_o <= line_request_sys_clk[1] & !line_request_sys_clk[2];
	end	
		
//
/*
always @( posedge clk or negedge reset_n )
	if ( !reset_n )	
		string_num	<= 	13'h0;
	else
	
		if ( asi_snk_startofpacket_i )
			string_num	<= string_num  + 1'h1;
		else if ( ( string_num == VACTIVE ) && asi_snk_endofpacket_i )
			string_num	<= 	13'h0;

always @( posedge clk )
	if ( asi_snk_endofpacket_i || ( string_num == 13'h0 && v_count > ( VBLANK - 1 ) ) )
		asi_snk_ready_o <= 1'h0;
	else if ( wrusedw < 11'd600 )
		asi_snk_ready_o <= 1'h1;
*/

`ifdef HDMI_TEST_OFF		
resync_fifo_HDMI_tx resync_fifo_HDMI_tx_inst_0
(
	.data		( asi_snk_data_i			),
	.rdclk      ( pixel_clk					),
	.rdreq      ( rdreq						),
	.wrclk      ( clk						),
	.wrreq      ( asi_snk_valid_i			),
	.q          ({ data_b, data_g, data_r }	),
	.rdempty    (							),
	.rdfull     (							),
	.rdusedw	(							),
	.wrempty    (							),
	.wrfull     (							),
	.wrusedw	( wrusedw					)
);			
`else
localparam R_test = 8'd255;
localparam G_test = 8'd255;
localparam B_test = 8'd255;

always @( posedge pixel_clk ) 
	if ( (h_count > HBLANK) && (h_count <= (HBLANK + HACTIVE/4)))
		{ data_b, data_g, data_r }	<= {8'h0, 8'h0, R_test};
	else if ( (h_count > ( HBLANK + HACTIVE/4)) && (h_count <= ( HBLANK + (HACTIVE/4)*2 )))
		{ data_b, data_g, data_r }	<= {8'h0, G_test, 8'h0};
	else if ( (h_count > ( HBLANK + (HACTIVE/4)*2 )) && (h_count <= ( HBLANK + (HACTIVE/4)*3 )))
		{ data_b, data_g, data_r }	<= {B_test, 8'h0, 8'h0};
	else if ( (h_count > ( HBLANK + (HACTIVE/4)*3 )) && (h_count <= ( HBLANK + (HACTIVE/4)*4 )))
		{ data_b, data_g, data_r }	<= {B_test, G_test, R_test};
`endif


endmodule




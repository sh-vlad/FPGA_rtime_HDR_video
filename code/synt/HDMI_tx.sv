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
	input wire							frame_buffer_ready,
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
localparam HFRONT	= 110	;
localparam HSYNC	= 40	;
localparam HBACK	= 220	;
localparam HACTIVE	= 1280	;
localparam VFRONT	= 5		;
localparam VSYNC	= 5		;
localparam VBACK	= 20	;
localparam VACTIVE 	= 720	;
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
reg					frame_buffer_ready_lock;

logic	[ 7: 0]		data_r_tmp;
logic	[ 7: 0]		data_g_tmp;
logic	[ 7: 0]		data_b_tmp;

logic	[ 7: 0]		test_r;
logic	[ 7: 0]		test_g;
logic	[ 7: 0]		test_b;
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
		if ( v_count == VTOTAL+1 )
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
	if ( ( h_count >= 13'h0 && h_count <= HBLANK - 1) ||( h_count == HTOTAL ) || ( v_count <= VBLANK ) )
		rdreq	<= 1'h0;
	else
		rdreq	<= 1'h1;		
//
always @( posedge pixel_clk )
	if ( ( h_count >= HBLANK-10 && h_count <= HBLANK ) && ( v_count >= VBLANK && v_count < VTOTAL ) )
		line_request_pclk <= 1'h1;
	else
		line_request_pclk <= 1'h0;
		
always @( posedge clk )
	begin
		line_request_sys_clk <= {line_request_sys_clk[1:0], line_request_pclk };	
		line_request_o <= ( line_request_sys_clk[1] & !line_request_sys_clk[2] ) & frame_buffer_ready_lock  ;
	end	

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		frame_buffer_ready_lock <= 1'b0;
	else	
		if ( frame_buffer_ready && ( ( v_count >= VFRONT ) && ( v_count <= VFRONT + VSYNC ) ) )
			frame_buffer_ready_lock <= 1'b1;
		else if ( !frame_buffer_ready )
			frame_buffer_ready_lock <= 1'b0;	


//`ifdef HDMI_TEST_OFF		
resync_fifo_HDMI_tx resync_fifo_HDMI_tx_inst_0
(
	.data		( asi_snk_data_i			),
	.rdclk      ( pixel_clk					),
	.rdreq      ( rdreq						),
	.wrclk      ( clk						),
	.wrreq      ( asi_snk_valid_i			),
	.q          ({ data_b_tmp, data_g_tmp, data_r_tmp }	),
	.rdempty    (							),
	.rdfull     (							),
	.rdusedw	(							),
	.wrempty    (							),
	.wrfull     (							),
	.wrusedw	( wrusedw					)
);			
//`else
localparam R_test = 8'd255;
localparam G_test = 8'd255;
localparam B_test = 8'd255;

always @( posedge pixel_clk ) 
	if ( (h_count > HBLANK) && (h_count <= (HBLANK + HACTIVE/4)))
		{ test_b, test_g, test_r }	<= {8'h0, 8'h0, R_test};
	else if ( (h_count > ( HBLANK + HACTIVE/4)) && (h_count <= ( HBLANK + (HACTIVE/4)*2 )))
		{ test_b, test_g, test_r }	<= {8'h0, G_test, 8'h0};
	else if ( (h_count > ( HBLANK + (HACTIVE/4)*2 )) && (h_count <= ( HBLANK + (HACTIVE/4)*3 )))
		{ test_b, test_g, test_r }	<= {B_test, 8'h0, 8'h0};
	else if ( (h_count > ( HBLANK + (HACTIVE/4)*3 )) && (h_count <= ( HBLANK + (HACTIVE/4)*4 )))
		{ test_b, test_g, test_r }	<= {B_test, G_test, R_test};
//`endif

assign { data_b, data_g, data_r } = ( frame_buffer_ready_lock ) ? { data_b_tmp, data_g_tmp, data_r_tmp } : { test_b, test_g, test_r };

endmodule




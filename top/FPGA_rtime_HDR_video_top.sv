//Author: ShVlad / e-mail: shvladspb@gmail.com
//

`timescale 1 ns / 1 ns
module FPGA_rtime_HDR_video_top
(
//clocks
	input wire  				clk50,             
//tmp
	output wire					led,
//HDMI
	output reg					data_enable,
	output reg					hsync,
	output reg					vsync,
	output reg		[23: 0]		data_HDMI,
	output reg					pixel_clk_out
);

reg		[31: 0]		r_cnt_leg;
wire	[ 7: 0]		data_Y;         
wire	[ 7: 0]		data_Cb_Cr;     
wire				pll_lock;	
wire				pixel_clk;	
always @( posedge clk50 )
	if ( r_cnt_leg == 32'd50_000_000 )
		r_cnt_leg	<= 32'h0;
	else
		r_cnt_leg	<= r_cnt_leg + 1'h1;
		
assign led = ( r_cnt_leg < 25_000_000 ) ? 1'h1 : 1'h0;

pll_0 pll_0_inst
(
	.refclk   ( clk50			),
	.rst      ( 0				),
	.outclk_0 ( pixel_clk		),
	.outclk_1 ( pixel_clk_out	),
	.locked   ( pll_lock		)
);

HDMI_tx_test HDMI_tx_test_inst
(
	.pixel_clk      ( pixel_clk		),
	.reset_n        ( !pll_lock		),
	.data_enable    ( data_enable	),
	.hsync          ( hsync			),
	.vsync          ( vsync			),
	.data_Y         ( data_Y		),
	.data_Cb_Cr     ( data_Cb_Cr	)	
);		
assign data_HDMI = { data_Cb_Cr, data_Y, 8'h0 };
endmodule






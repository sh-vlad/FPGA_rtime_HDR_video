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
	output wire					data_enable,
	output wire					hsync,
	output wire					vsync,
	output wire		[23: 0]		data_HDMI,
	output wire					pixel_clk_out,
	
	input wire              HDMI_TX_INT,	
    inout wire              HDMI_I2C_SCL,
    inout wire              HDMI_I2C_SDA
);

reg		[31: 0]		r_cnt_leg;
wire	[ 7: 0]		data_Y;         
wire	[ 7: 0]		data_Cb_Cr;     
wire				pll_lock;	
wire				pixel_clk;	
always @( posedge clk50 or negedge pll_lock )
	if ( !pll_lock )
		r_cnt_leg	<= 32'h0;
	else
		if ( r_cnt_leg == 32'd50_000_000 )
			r_cnt_leg	<= 32'h0;
		else
			r_cnt_leg	<= r_cnt_leg + 1'h1;
		
assign led = ( r_cnt_leg < 25_000_000 ) ? 1'h1 : 1'h0;

pll_0 pll_0_inst
(
	.refclk   ( clk50			),
	.rst      ( 1'h0			),
	.outclk_0 ( pixel_clk		),
	.outclk_1 ( /*pixel_clk_out*/	),
	.locked   ( pll_lock		)
);
assign pixel_clk_out = pixel_clk;
HDMI_tx_test HDMI_tx_test_inst
(
	.pixel_clk      ( pixel_clk		),
	.reset_n        ( pll_lock		),
	.data_enable    ( data_enable	),
	.hsync          ( hsync			),
	.vsync          ( vsync			),
	.data_Y         ( data_Y		),
	.data_Cb_Cr     ( data_Cb_Cr	)	
);		

//HDMI I2C

I2C_HDMI_Config u_I2C_HDMI_Config 
(
	.iCLK			( clk50				),
	.iRST_N			( pll_lock			),
	.I2C_SCLK		( HDMI_I2C_SCL		),
	.I2C_SDAT		( HDMI_I2C_SDA		),
	.HDMI_TX_INT	( HDMI_TX_INT		),
	.READY			( )
);

assign data_HDMI = { data_Cb_Cr, data_Y, 8'h0 };

endmodule





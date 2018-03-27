//Author: ShVlad / e-mail: shvladspb@gmail.com
//

`timescale 1 ns / 1 ns
module FPGA_rtime_HDR_video_top
(
//clocks
	input wire  				clk50,             
	input wire					clk_cam_0_i,
	input wire					clk_cam_1_i,	
	output wire					clk_cam_0_o,
	output wire					clk_cam_1_o,	
//cameras ports
	input wire         			VSYNC  ,
	input wire         			HREF   ,
	input wire [7:0]   			D1     ,
	input wire [7:0]   			D2     ,
	
	output wire					led,
//HDMI
	output wire					data_enable,
	output wire					hsync,
	output wire					vsync,
	output wire		[23: 0]		data_HDMI,
	output wire					pixel_clk_out,
	
	input wire              	HDMI_TX_INT,	
    inout wire              	HDMI_I2C_SCL,
    inout wire              	HDMI_I2C_SDA/*,
	
//tmp

	output wire [15:0]			HDR_data_o,
	output wire 				HDR_valid_o,	
	
	output wire					HDR_sof_o,	
	output wire					HDR_eof_o	
	*/
);

wire		sys_clk;
wire		sys_clk_b;
wire		pll_lock;
//
wire [7:0] 	Y1     ;
wire [7:0] 	CbCr1  ;
wire [7:0] 	Y2     ;
wire [7:0] 	CbCr2  ;
wire       	validY ;
wire       	validCb;
wire       	validCr;
wire       	SOF    ;
wire       	EOF    ;
//

reg		[31: 0]		r_cnt_leg;
wire	[ 7: 0]		data_Y;         
wire	[ 7: 0]		data_Cb_Cr;     
wire				pll_lock_0;	
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


pll_1 pll_1_inst
(
	.refclk   		( clk50			),		//50MHz
	.rst      		(				),
	.outclk_0 		( sys_clk		),		//100MHz
	.outclk_1 		( clk_cam_0_o	),		//24MHz
	.locked   		( pll_lock		)
);

assign clk_cam_1_o = clk_cam_0_o;
/*
GLOBAL GLOBAL_inst
(
	.in			( sys_clk	), 
	.out		( sys_clk_b	)
);
*/
assign sys_clk_b = sys_clk;
convert2avl_stream convert2avl_stream_inst
(
	.pclk   	( clk_cam_0_i	),
	.clk_sys	( sys_clk_b		),
	.reset_n	( pll_lock		),
	.VSYNC  	( VSYNC			),
	.HREF   	( HREF   		),
	.D1     	( D1     		),
	.D2     	( D2     		),
		
	.Y1     	( Y1     		),
	.CbCr1  	( CbCr1  		),
	.Y2     	( Y2     		),
	.CbCr2  	( CbCr2  		),
	.validY 	( validY 		),
	.validCb	( validCb		),
	.validCr	( validCr		),
	.SOF    	( SOF    		),
	.EOF		( EOF    		)
);

wrp_HDR_algorithm
#(
	.DATA_WIDTH ( 16	)
)
wrp_HDR_algorithm_inst					
(
	.clk							( sys_clk_b			), 	   
	.asi_snk_0_valid_i	            ( validY			),
	.asi_snk_0_ready_o              (					),	
	.asi_snk_0_data_i               ( { Y1, Y2 }		),
	.asi_snk_0_empty_i              (					),	
	.asi_snk_0_startofpacket_i      ( SOF				),
	.asi_snk_0_endofpacket_i        ( EOF				),
	.asi_snk_0_error_i              (					),
	.asi_snk_0_channel_i            (					),

	.asi_snk_1_valid_i              ( validY			),
	.asi_snk_1_ready_o              (					),
	.asi_snk_1_data_i               ( { CbCr1, CbCr2 }	),
	.asi_snk_1_empty_i              (					),
	.asi_snk_1_startofpacket_i      ( SOF				),
	.asi_snk_1_endofpacket_i        ( EOF				),
	.asi_snk_1_error_i              (					),
	.asi_snk_1_channel_i            (					),
	                             
	.aso_src_valid_o                ( HDR_valid_o		),
	.aso_src_ready_i                (					),
	.aso_src_data_o                 ( HDR_data_o		),
	.aso_src_empty_o                (					),
	.aso_src_startofpacket_o        ( HDR_sof_o			),
	.aso_src_endofpacket_o          ( HDR_eof_o			),
	.aso_src_error_o                (					),
	.aso_src_channel_o	            (					)
);


pll_0 pll_0_inst
(
	.refclk   ( clk50			),
	.rst      ( 1'h0			),
	.outclk_0 ( pixel_clk		),
	.outclk_1 ( /*pixel_clk_out*/	),
	.locked   ( pll_lock_0		)
);

assign pixel_clk_out = pixel_clk;
HDMI_tx_test HDMI_tx_test_inst
(
	.pixel_clk      ( pixel_clk		),
	.reset_n        ( pll_lock_0		),
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
	.iRST_N			( pll_lock_0			),
	.I2C_SCLK		( HDMI_I2C_SCL		),
	.I2C_SDAT		( HDMI_I2C_SDA		),
	.HDMI_TX_INT	( HDMI_TX_INT		),
	.READY			( )
);

assign data_HDMI = { data_Cb_Cr, data_Y, 8'h0 };

endmodule





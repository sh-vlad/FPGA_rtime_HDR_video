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
	input wire [7:0]   			cam_0_data,
	input wire [7:0]   			cam_1_data,
	
	input wire [3:0]			switches,
//HDMI
	output wire					data_enable,
	output wire					hsync,
	output wire					vsync,
	output wire		[23: 0]		data_HDMI,
	output wire					pixel_clk_out,
	
	input wire              	HDMI_TX_INT,	
    inout wire              	HDMI_I2C_SCL,
    inout wire              	HDMI_I2C_SDA
);

wire				sys_clk;
wire				sys_clk_b;
wire	[ 1: 0]		pll_lock;
wire				pixel_clk;	
wire				reset_n_b;
//
reg 	[ 3: 0]		switches_resync[2:0];
reg		[ 1: 0]		sh_VSYNC;
//
wire	[ 7: 0]		raw_data_0;
wire	[ 7: 0]		raw_data_1;
wire				raw_data_valid;
wire				raw_data_sop;
wire				raw_data_eop;
//
wire				HDR_valid;			
wire	[ 7: 0]		HDR_data;			
wire				HDR_sop;			
wire				HDR_eop;	
//
logic	[ 7: 0]		raw2rgb_data;
logic				raw2rgb_valid;
logic				raw2rgb_sop;
logic				raw2rgb_eop;
//
wire 	[ 7: 0]		r_data;
wire 	[ 7: 0]		g_data;
wire 	[ 7: 0]		b_data;
wire 				data_rgb_valid;
wire 				sop_rgb		  ;
wire 				eop_rgb	      ;

pll_0 pll_0_inst
(
	.refclk   		( clk50			),
	.rst      		( 1'h0			),
	.outclk_0 		( pixel_clk		),		//74.25MHz
	.locked   		( pll_lock[0]	)
);

pll_1 pll_1_inst
(
	.refclk   		( clk50			),		//50MHz
	.rst      		( 1'h0			),
	.outclk_0 		( sys_clk		),		//100MHz
	.outclk_1 		( clk_cam_0_o	),		//24MHz
	.locked   		( pll_lock[1]	)
);

assign pixel_clk_out = pixel_clk;
assign clk_cam_1_o = clk_cam_0_o;

`ifdef GLOBAL_BUFFERS
	GLOBAL global_sys_clk_inst
		(
			.in			( sys_clk	), 
			.out		( sys_clk_b	)
		);

	GLOBAL GLOBAL_rst_inst
		(
			.in			( pll_lock[1] & pll_lock[0]	), 
			.out		( reset_n_b					)
		);
`else
	assign sys_clk_b = sys_clk;
	assign reset_n_b = pll_lock[1] & pll_lock[0];
`endif

//
always @( posedge sys_clk_b )
	sh_VSYNC <= {sh_VSYNC[0], VSYNC};	
always @( posedge sys_clk_b )
		begin
	//		switches_resync[1:0] <= {switches_resync[0],switches};
			switches_resync[0] <= switches;
			switches_resync[1] <= switches_resync[0];
			if ( sh_VSYNC[1] )
				switches_resync[2] <= switches_resync[1];
		end
	
//resync cam clk to sys clk
convert2avl_stream_raw convert2avl_stream_raw_inst
(
	.pclk   	       	( clk_cam_0_i	),
	.clk_sys	       	( sys_clk_b		),
	.reset_n	       	( reset_n_b		),
	.VSYNC  	       	( VSYNC			),
	.HREF   	       	( HREF			),
	.D1     	       	( cam_0_data	),
	.D2     	       	( cam_1_data	),	                               
	.RAW_1           	( raw_data_0	),
	.RAW_2           	( raw_data_1	),
	.valid_RAW_1     	( raw_data_valid),                                       
	.valid_RAW_2     	(),                                       
	.SOF    	       	( raw_data_sop	),
	.EOF    	       	( raw_data_eop	),
	.start_frame     	(),
	.data_ddr        	(),
    .valid_data_ddr	    ()
	
);

//hdr for raw data
wrp_HDR_algorithm
#(
	.DATA_WIDTH ( 8	)
)
wrp_HDR_algorithm_inst					
(
	.clk							( sys_clk_b			), 	  
	
	.asi_snk_0_valid_i	            ( raw_data_valid	),
	.asi_snk_0_data_i               ( raw_data_0		),
	.asi_snk_0_startofpacket_i      ( raw_data_sop		),
	.asi_snk_0_endofpacket_i        ( raw_data_eop 		),
	.asi_snk_1_data_i               ( raw_data_1		),
	                             
	.aso_src_valid_o                ( HDR_valid			),
	.aso_src_data_o                 ( HDR_data			),
	.aso_src_startofpacket_o        ( HDR_sop			),
	.aso_src_endofpacket_o          ( HDR_eop			)
);

//mode mux
always @( posedge sys_clk_b )
	case ( switches_resync[2]/*switches*/ )
		4'd1:	begin					// cam №0
					raw2rgb_data	<= raw_data_0;
					raw2rgb_valid   <= raw_data_valid;
					raw2rgb_sop     <= raw_data_sop;
					raw2rgb_eop     <= raw_data_eop;
				end
		4'd2:	begin					// cam №1
					raw2rgb_data	<= raw_data_1;
					raw2rgb_valid   <= raw_data_valid;
					raw2rgb_sop     <= raw_data_sop;
					raw2rgb_eop		<= raw_data_eop;
				end
		4'd3:	begin					// HDR
					raw2rgb_data	<= HDR_data;
					raw2rgb_valid   <= HDR_valid;
					raw2rgb_sop     <= HDR_sop;
					raw2rgb_eop		<= HDR_eop;
				end	
		default:
				begin					// cam №0
					raw2rgb_data	<= raw_data_0;
					raw2rgb_valid   <= raw_data_valid;
					raw2rgb_sop     <= raw_data_sop;
					raw2rgb_eop		<= raw_data_eop;
				end
	endcase

//convert raw to rgb
raw2rgb_bilinear_interp 
#(
	.DATA_WIDTH		( 8	)
)
raw2rgb_bilinear_interp_inst
(
	.clk			( sys_clk_b			),
	.reset_n        ( reset_n_b			),
	.raw_data       ( raw2rgb_data		),
	.raw_valid      ( raw2rgb_valid		),
	.raw_sop	    ( raw2rgb_sop		),
	.raw_eop	    ( raw2rgb_eop		),
	.r_data_o       ( r_data			),
	.g_data_o       ( g_data			),
	.b_data_o       ( b_data			),
	.data_o_valid   ( data_rgb_valid	),
	.sop_o	        ( sop_rgb		  	),
	.eop_o	        ( eop_rgb	      	)
);

//instans frame buffer here ->

// 	

HDMI_tx
#(
	.DATA_WIDTH					( 24						)
)
HDMI_tx_inst
(
	.clk						( sys_clk_b					),						
	.pixel_clk                  ( pixel_clk					),
	.reset_n	                ( reset_n_b					),
	.asi_snk_valid_i            ( data_rgb_valid			),
	.line_request_o             (							),
	.asi_snk_data_i             ( {b_data, g_data, r_data} 	),
	.asi_snk_startofpacket_i    ( sop_rgb					),
	.asi_snk_endofpacket_i	    ( eop_rgb					),
	.data_enable                ( data_enable				),
	.hsync                      ( hsync						),
	.vsync                      ( vsync						),
	.data_r                     ( data_HDMI[23:16]			),
	.data_g                     ( data_HDMI[15: 8]			),
	.data_b                     ( data_HDMI[ 7: 0]			)
	
);

//HDMI I2C
I2C_HDMI_Config u_I2C_HDMI_Config 
(
	.iCLK			( clk50				),
	.iRST_N			( reset_n_b			),
	.I2C_SCLK		( HDMI_I2C_SCL		),
	.I2C_SDAT		( HDMI_I2C_SDA		),
	.HDMI_TX_INT	( HDMI_TX_INT		),
	.READY			( )
);

//assign data_HDMI = { data_Cb_Cr, data_Y, 8'h0 };

`ifdef DEBUG_OFF
`else
int sensor;
initial
	begin
		sensor = $fopen("sensor.txt","w");
		forever @( posedge clk_cam_0_i )
			begin
				if (HREF)
					begin
						$fwrite (sensor,cam_0_data,"\n");
					end				
			end   	
	end

int raw;
initial
	begin
		raw  = $fopen("raw.txt","w");
		forever @( posedge sys_clk_b )
			begin
				if (raw2rgb_valid)
					begin
						$fwrite (raw,raw2rgb_data,"\n");
					end				
			end   	
	end

int r,g,b;
initial
	begin
		r  = $fopen("r.txt","w");
		g  = $fopen("g.txt","w");
		b  = $fopen("b.txt","w");
		forever @( posedge sys_clk_b )
			begin
				if (data_rgb_valid)
					begin
						$fwrite (r,r_data,"\n");
						$fwrite (g,g_data,"\n");
						$fwrite (b,b_data,"\n");
					end				
			end   	
	end
`endif	
endmodule

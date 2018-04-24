//Author: ShVlad / e-mail: shvladspb@gmail.com

`timescale 1 ns / 1 ns
module wrp_conv_filter
#(
	parameter DATA_WIDTH = 8,
	parameter COEF_WIDTH = 5	
)
(
//clocks & reset	
	input wire								clk,
	input wire								reset_n,
		
	input wire			[DATA_WIDTH-1:0]	data_r_i,	
	input wire			[DATA_WIDTH-1:0]	data_g_i,	
	input wire			[DATA_WIDTH-1:0]	data_b_i,	
	input wire								valid_i,
	input wire								sop_i,	
	input wire								eop_i,

	input wire signed 	[COEF_WIDTH-1:0]	coef[3][3],
	input wire signed	[COEF_WIDTH-1:0]	div_coef,
	input wire			[ 7: 0]				bias_factor,
	
	output wire			[DATA_WIDTH-1:0]	data_r_o,
	output wire			[DATA_WIDTH-1:0]	data_g_o,
	output wire			[DATA_WIDTH-1:0]	data_b_o,	
	output wire								data_o_valid,
	output wire								sop_o,	
	output wire								eop_o	
);

filter
#(
	.DATA_WIDTH ( DATA_WIDTH ),
	.COEF_WIDTH ( COEF_WIDTH )
)
conv_filter_r
(
	.clk				( clk			),
	.reset_n	        ( reset_n		),
	.data_i             ( data_r_i		),
	.valid_i            ( valid_i 		),
	.sop_i              ( sop_i   		),
	.eop_i              ( eop_i   		),
	.coef               ( coef    		),
	.div_coef	        ( div_coef		),
	.bias_factor		( bias_factor	),
	.data_o             ( data_r_o		),
	.data_o_valid       (),
	.sop_o              (),
	.eop_o	            ()
);

filter
#(
	.DATA_WIDTH ( DATA_WIDTH ),
	.COEF_WIDTH ( COEF_WIDTH )
)
conv_filter_g
(
	.clk				( clk			),
	.reset_n	        ( reset_n		),
	.data_i             ( data_g_i		),
	.valid_i            ( valid_i 		),
	.sop_i              ( sop_i   		),
	.eop_i              ( eop_i   		),
	.coef               ( coef    		),
	.div_coef	        ( div_coef		),
	.bias_factor		( bias_factor	),
	.data_o             ( data_g_o		),
	.data_o_valid       (),
	.sop_o              (),
	.eop_o	            ()
);

filter
#(
	.DATA_WIDTH ( DATA_WIDTH )
)
conv_filter_b
(
	.clk				( clk			),
	.reset_n	        ( reset_n		),
	.data_i             ( data_b_i		),
	.valid_i            ( valid_i 		),
	.sop_i              ( sop_i   		),
	.eop_i              ( eop_i   		),
	.coef               ( coef    		),
	.div_coef	        ( div_coef		),
	.bias_factor		( bias_factor	),
	.data_o             ( data_b_o		),
	.data_o_valid       ( data_o_valid	),
	.sop_o              ( sop_o       	),
	.eop_o	            ( eop_o	    	)
);	

endmodule
//Author: ShVlad / e-mail: shvladspb@gmail.com
//

`timescale 1 ns / 1 ns
module wrp_HDR_algorithm
#(
	parameter DATA_WIDTH = 32
)
(
//clocks & reset
	input wire							clk,
//
	input wire							asi_snk_0_valid_i,
	input wire		[DATA_WIDTH-1: 0] 	asi_snk_0_data_r_i,
	input wire		[DATA_WIDTH-1: 0] 	asi_snk_0_data_g_i,
	input wire		[DATA_WIDTH-1: 0] 	asi_snk_0_data_b_i,	
	input wire							asi_snk_0_startofpacket_i,
	input wire							asi_snk_0_endofpacket_i,	
	input wire		[DATA_WIDTH-1: 0] 	asi_snk_1_data_r_i,	
	input wire		[DATA_WIDTH-1: 0] 	asi_snk_1_data_g_i,
	input wire		[DATA_WIDTH-1: 0] 	asi_snk_1_data_b_i,
	
	output logic						aso_src_valid_o,
	output logic	[DATA_WIDTH+1: 0]	aso_src_data_r_o,
	output logic	[DATA_WIDTH+1: 0]	aso_src_data_g_o,
	output logic	[DATA_WIDTH+1: 0]	aso_src_data_b_o,	
	output logic						aso_src_startofpacket_o,
	output logic						aso_src_endofpacket_o
);
//

HDR_algorithm 
#(
	.DATA_WIDTH		( DATA_WIDTH	) 
)
HDR_algorithm_r
(
	.clk			( clk					),
	.data_i0        ( asi_snk_0_data_r_i 	),
	.data_i1        ( asi_snk_1_data_r_i	),
	.data_o         ( aso_src_data_r_o		)
);

HDR_algorithm 
#(
	.DATA_WIDTH		( DATA_WIDTH	) 
)
HDR_algorithm_g
(
	.clk			( clk					),
	.data_i0        ( asi_snk_0_data_g_i 	),
	.data_i1        ( asi_snk_1_data_g_i	),
	.data_o         ( aso_src_data_g_o		)
);

HDR_algorithm 
#(
	.DATA_WIDTH		( DATA_WIDTH	) 
)
HDR_algorithm_b
(
	.clk			( clk					),
	.data_i0        ( asi_snk_0_data_b_i 	),
	.data_i1        ( asi_snk_1_data_b_i	),
	.data_o         ( aso_src_data_b_o		)
);

delay_rg
#(
	.W				( 3				),
	.D				( 21+2-8+5			)
)
delay_weight
(
	.clk			( clk																		),
	.data_in		( {asi_snk_0_endofpacket_i, asi_snk_0_startofpacket_i, asi_snk_0_valid_i }	),
	.data_out       ( {aso_src_endofpacket_o, aso_src_startofpacket_o, aso_src_valid_o }		)
); 


endmodule
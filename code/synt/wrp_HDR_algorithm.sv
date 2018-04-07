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
	input wire		[DATA_WIDTH-1: 0] 	asi_snk_0_data_i,
	input wire							asi_snk_0_startofpacket_i,
	input wire							asi_snk_0_endofpacket_i,	
	input wire		[DATA_WIDTH-1: 0] 	asi_snk_1_data_i,	
	
	output logic						aso_src_valid_o,
	output logic	[DATA_WIDTH-1: 0]	aso_src_data_o,
	output logic						aso_src_startofpacket_o,
	output logic						aso_src_endofpacket_o
);
//

HDR_algorithm 
#(
	.DATA_WIDTH		( DATA_WIDTH	) 
)
HDR_algorithm_Y
(
	.clk			( clk					),
	.data_i0        ( asi_snk_0_data_i 		),
	.data_i1        ( asi_snk_1_data_i		),
	.data_o         ( aso_src_data_o		)
);

delay_rg
#(
	.W				( 3				),
	.D				( 21			)
)
delay_weight
(
	.clk			( clk																		),
	.data_in		( {asi_snk_0_endofpacket_i, asi_snk_0_startofpacket_i, asi_snk_0_valid_i }	),
	.data_out       ( {aso_src_endofpacket_o, aso_src_startofpacket_o, aso_src_valid_o }		)
); 


endmodule
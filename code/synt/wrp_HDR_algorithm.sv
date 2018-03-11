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
	output logic						asi_snk_0_ready_o,
	input wire		[DATA_WIDTH-1: 0] 	asi_snk_0_data_i,
	input wire		[ 1: 0] 			asi_snk_0_empty_i,
	input wire							asi_snk_0_startofpacket_i,
	input wire							asi_snk_0_endofpacket_i,
	input wire							asi_snk_0_error_i,
	input wire		[ 0: 0] 			asi_snk_0_channel_i,
	
	input wire							asi_snk_1_valid_i,
	output logic						asi_snk_1_ready_o,
	input wire		[DATA_WIDTH-1: 0] 	asi_snk_1_data_i,
	input wire		[ 1: 0] 			asi_snk_1_empty_i,
	input wire							asi_snk_1_startofpacket_i,
	input wire							asi_snk_1_endofpacket_i,
	input wire							asi_snk_1_error_i,
	input wire		[ 0: 0] 			asi_snk_1_channel_i,
	
	output logic						aso_src_valid_o,
	input wire							aso_src_ready_i,
	output logic	[DATA_WIDTH-1: 0]	aso_src_data_o,
	output logic	[ 1: 0] 			aso_src_empty_o,
	output logic						aso_src_startofpacket_o,
	output logic						aso_src_endofpacket_o,
	output logic						aso_src_error_o,
	output logic	[ 7:0]	 			aso_src_channel_o	
);
//

HDR_algorithm 
#(
	.DATA_WIDTH		( DATA_WIDTH/2	) 
)
HDR_algorithm_Y
(
	.clk			( clk					),
	.data_i0        ( asi_snk_0_data_i[7:0] ),
	.data_i1        ( asi_snk_0_data_i[15:8]	),
	.data_o         ( aso_src_data_o[7:0]	)
);

HDR_algorithm 
#(
	.DATA_WIDTH		( DATA_WIDTH/2	) 
)
HDR_algorithm_CrCb
(
	.clk			( clk	),
	.data_i0        ( asi_snk_1_data_i[7:0] ),
	.data_i1        ( asi_snk_1_data_i[15:8] ),
	.data_o         ( aso_src_data_o[15:8]	)
);

delay_rg
#(
	.W				( 3				),
	.D				( 21			)
)
delay_weight
(
	.clk			( clk				),
	.data_in		( {asi_snk_0_endofpacket_i, asi_snk_0_startofpacket_i, asi_snk_0_valid_i }	),
	.data_out       ( {aso_src_endofpacket_o, aso_src_startofpacket_o, aso_src_valid_o }	)
); 


endmodule
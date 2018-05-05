//Author: ShVlad / e-mail: shvladspb@gmail.com

`timescale 1 ns / 1 ns
module gamma_correction
(
	input wire				clk,
	input wire				reset_n,
	
	input wire	[ 7: 0]		raw_data_0,
	input wire	[ 7: 0]		raw_data_1,
	input wire				raw_data_valid,
	input wire				raw_data_sop,
	input wire				raw_data_eop,
	
	output wire	[ 7: 0]		gamma_data_0,
	output wire	[ 7: 0]		gamma_data_1,
	output wire				gamma_data_valid,
	output wire				gamma_data_sop,
	output wire				gamma_data_eop
);

gamma_rom gamma_rom_0
(
	.address	( raw_data_0	),
	.clock      ( clk			),
	.q          ( gamma_data_0	)
);
	
gamma_rom gamma_rom_1
(
	.address	( raw_data_1	),
	.clock      ( clk			),
	.q          ( gamma_data_1	)
);	

delay_rg
#(
	.W				( 3				),
	.D				( 1				)
)
delay_strobes
(
	.clk			( clk						),
	.data_in		( { raw_data_sop, raw_data_eop, raw_data_valid } ),
	.data_out       ( { gamma_data_sop, gamma_data_eop, gamma_data_valid }	)
);	
endmodule
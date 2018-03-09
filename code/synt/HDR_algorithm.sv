//Author: ShVlad / e-mail: shvladspb@gmail.com
//

`timescale 1 ns / 1 ns
module HDR_algorithm
#(
	parameter DATA_WIDTH = 32
)
(
//clocks & reset
	input wire							clk,
//
	input wire	[DATA_WIDTH-1: 0]		data_i0,
	input wire	[DATA_WIDTH-1: 0]		data_i1,
	
	output reg 	[DATA_WIDTH-1: 0]		data_o
);
//
	wire 	[DATA_WIDTH-1: 0] 		weight_coef_0;
	wire 	[DATA_WIDTH-1: 0] 		weight_coef_1;
	
	reg		[DATA_WIDTH-1: 0] 		weight_coef_sum;
	wire 	[DATA_WIDTH-1: 0] 		weight_coef_sum_delay;	
	
	wire 	[DATA_WIDTH-1: 0] 		bright_delay_0;			
	wire 	[DATA_WIDTH-1: 0] 		bright_delay_1;	

	reg 	[(DATA_WIDTH*2)-1: 0]	mult_0;
	reg 	[(DATA_WIDTH*2)-1: 0] 	mult_1;	
	reg	 	[(DATA_WIDTH*2): 0]   	E;	
	
	wire	[15: 0]  				quotient;
	wire	[ 7: 0]  				remain;	
	
delay_rg
#(
	.W				( DATA_WIDTH	),
	.D				( 2				)
)
delay_rg_0
(
	.clk			( clk			),
	.data_in		( data_i0		),
	.data_out       ( bright_delay_0)
);

delay_rg
#(
	.W				( DATA_WIDTH	),
	.D				( 2				)
)
delay_rg_1
(
	.clk			( clk			),
	.data_in		( data_i1		),
	.data_out       ( bright_delay_1)
);
	
calc_weight_coef 
#(
	.DATA_WIDTH 	( DATA_WIDTH	)
)
calc_weight_coef_0
(
	.clk			( clk			),
	.Z              ( data_i0		),
	.weight_coef    ( weight_coef_0	)
);

calc_weight_coef 
#(
	.DATA_WIDTH 	( DATA_WIDTH	)
)
calc_weight_coef_1
(
	.clk			( clk			),
	.Z              ( data_i1		),
	.weight_coef    ( weight_coef_1	)
);

delay_rg
#(
	.W				( DATA_WIDTH	),
	.D				( 2				)
)
delay_weight
(
	.clk			( clk			),
	.data_in		( weight_coef_sum		),
	.data_out       ( weight_coef_sum_delay	)
);

always @( posedge clk )
	weight_coef_sum <= weight_coef_0 + weight_coef_1;
	
always @( posedge clk )
	begin
		mult_0	<= weight_coef_sum*bright_delay_0;
		mult_1	<= weight_coef_sum*bright_delay_1;		
	end

always @( posedge clk )
	E = mult_0 + mult_1;

HDR_divider HDR_divider_inst
(
	.clock			( clk					),
	.denom          ( weight_coef_sum_delay	),
	.numer          ( E						),
	.quotient       ( quotient				),
	.remain         ( remain				)
);

always @( posedge clk )
	if ( remain > 0 )
		data_o	<= quotient + 1'h1;
	else
		data_o	<= quotient;
		
endmodule
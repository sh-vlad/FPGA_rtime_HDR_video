
module wrp_tone_mapping
#(
    parameter W = 10
)
(
	input wire				clk,
	input wire				reset_n,
    input wire				sop,
	input wire				eop,
	input wire				valid,	
	input wire	[W-1: 0]	data[3],
	
	output wire	[W-3: 0]	data_o[3],
    output wire				sop_o,
	output wire				eop_o,
	output wire				valid_o		
);
genvar i; 
generate
	begin
		for ( i = 0; i < 3; i++ )
			begin: tone_mapping_rgb
				tone_mapping 
				#(
					.W			( 10		)
				)
				tone_mapping_inst
				(
					.clk		( clk		),
					.reset_n    ( reset_n	),
					.sop        ( sop  		),
					.eop        ( eop  		),
					.valid      ( valid		),
					.data       ( data[i]	),
					.data_o		( data_o[i] )
				);
			end
	end
	
delay_rg
#(
	.W				( 3				),
	.D				( 20			)
)
delay_strobes
(
	.clk			( clk						),
	.data_in		( { sop, eop, valid }  		),
	.data_out       ( { sop_o, eop_o, valid_o }	)
);	
endgenerate


		
endmodule


module wrp_tone_mapping
#(
    parameter W = 10
)
(
	input wire				clk,
	input wire				reset_n,
	input wire				enable,
    input wire				sop_i,
	input wire				eop_i,
	input wire				valid_i,	
	input wire	[W-1: 0]	data_r_i,
	input wire	[W-1: 0]	data_g_i,
	input wire	[W-1: 0]	data_b_i,	
	input wire	[7:0]		reg_parallax_corr,	
	output reg	[W-3: 0]	data_r_o,
	output reg	[W-3: 0]	data_g_o,
	output reg	[W-3: 0]	data_b_o,	
    output reg				sop_o,
	output reg				eop_o,
	output reg				valid_o		
);
wire				sop;
wire				eop;
wire				valid;	
wire	[W-3: 0]	data_r;
wire	[W-3: 0]	data_g;
wire	[W-3: 0]	data_b;	
	
tone_mapping 
#(
	.W			( W		)
)
tone_mapping_r
(
	.clk		( clk		),
	.reset_n    ( reset_n	),
	.sop        ( sop_i  	),
	.eop        ( eop_i  	),
	.valid      ( valid_i	),
	.data       ( data_r_i	),
	.data_o		( data_r  	),
	.reg_parallax_corr ( reg_parallax_corr )	
);

tone_mapping 
#(
	.W			( W		)
)
tone_mapping_g
(
	.clk		( clk		),
	.reset_n    ( reset_n	),
	.sop        ( sop_i  	),
	.eop        ( eop_i  	),
	.valid      ( valid_i	),
	.data       ( data_g_i	),
	.data_o		( data_g  	),
	.reg_parallax_corr ( reg_parallax_corr )	
);

tone_mapping 
#(
	.W			( W		)
)
tone_mapping_b
(
	.clk		( clk		),
	.reset_n    ( reset_n	),
	.sop        ( sop_i  	),
	.eop        ( eop_i  	),
	.valid      ( valid_i	),
	.data       ( data_b_i	),
	.data_o		( data_b  	),
	.reg_parallax_corr ( reg_parallax_corr )	
);

delay_rg
#(
	.W				( 3				),
	.D				( 20			)
)
delay_strobes
(
	.clk			( clk						),
	.data_in		( { sop_i, eop_i, valid_i } ),
	.data_out       ( { sop, eop, valid }	)
);	

always @( posedge clk )
	if ( enable )
		begin
			data_r_o <= data_r;
			data_g_o <= data_g;
			data_b_o <= data_b;	
			sop_o	 <= sop;
			eop_o    <= eop;
			valid_o	 <= valid;		
		end
	else
		begin
			data_r_o <= data_r_i[8:1];
			data_g_o <= data_g_i[8:1];
			data_b_o <= data_b_i[8:1];
			sop_o    <= sop_i;
			eop_o    <= eop_i;
			valid_o	 <= valid_i	;			
		end
endmodule

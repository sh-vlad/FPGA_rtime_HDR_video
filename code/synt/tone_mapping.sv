
module tone_mapping
#(
    parameter W = 10
)
(
	input wire				clk,
	input wire				reset_n,
    input wire				sop,
	input wire				eop,
	input wire				valid,	
	input wire	[W-1: 0]	data,
	input wire	[7:0]		reg_parallax_corr,		
	output wire	[W-3: 0]	data_o	
);

wire	[W-1:  0]	min;
wire	[W-1:  0]	max;
wire	[W-1:  0]	max_min_diff;
reg		[W-1:  0]	data_min_diff;
reg		[(W-1)*2:0] data_min_diff_mult;
//reg		[W-3:  0] 	data_min_div;

min_max_detector 
#(
    .W	( W		)
)
min_max_detector_inst
(
	.clk			( clk				),
	.reset_n        ( reset_n			),
    .sop            ( sop				),
	.eop            ( eop				),
	.valid          ( valid				),
	.data           ( data				),
	.min            ( min				),
	.max            ( max				),
	.max_min_diff   ( max_min_diff		),
	.reg_parallax_corr (reg_parallax_corr)	
);
	
always @( posedge clk )
	begin
		data_min_diff 		<= data - min;
		data_min_diff_mult 	<= data_min_diff*255;
	end
	
tone_mapping_divider tone_mapping_divider_inst
(
	.clock			( clk					),
	.denom          ( max_min_diff			),
	.numer          ( data_min_diff_mult	),
	.quotient       ( data_o				),
	.remain         (						)
);	
	
endmodule


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
	
	output wire	[W-3: 0]	data_o	
);

wire	[W-1:  0]	min;
wire	[W-1:  0]	max;
wire	[W-1:  0]	max_min_diff;
reg		[(W-1)*2:0] 	data_min_diff;
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
	.max_min_diff   ( max_min_diff		)
);

always @( posedge clk )
	data_min_diff <= { data, 8'h0} - { min, 8'h0 };
	
//assign data_min_div = data_min_diff / max_min_diff; 	
tone_mapping_divider tone_mapping_divider_inst
(
	.clock			( clk			),
	.denom          ( max_min_diff	),
	.numer          ( data_min_diff	),
	.quotient       ( data_o		),
	.remain         (				)
);	
//assign data_o = data_min_div[7:0];		
endmodule

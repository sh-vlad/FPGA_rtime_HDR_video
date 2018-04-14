
module test_pattern
#(
    parameter W = 10
)
(
	input wire				clk,
	input wire				reset_n,
    input wire				sop_i,
	input wire				eop_i,
	input wire				valid_i,	
	input wire	[W-1: 0]	r_i,
	input wire	[W-1: 0]	g_i,	
	input wire	[W-1: 0]	b_i,	
	
    output logic				sop_o,
	output logic				eop_o,
	output logic				valid_o,	
	output logic	[W-1: 0]	r_o,
	output logic	[W-1: 0]	g_o,	
	output logic	[W-1: 0]	b_o		
	
);

reg	[11: 0]		column_cnt;
reg	[11: 0]		line_cnt  ;

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		begin
			column_cnt	<= 12'h0;
		end
	else
		if ( valid_i )
			column_cnt	<= column_cnt + 1'h1;
		else 
			column_cnt	<= 12'h0;
	

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		begin
			line_cnt	<= 12'h0;
		end
	else
		if ( line_cnt == 720 && eop_i )
			line_cnt	<= 12'h0;
		else if ( sop_i )
			line_cnt	<= line_cnt + 1'h1;
	
assign valid_o = valid_i;	
assign eop_o = eop_i;	
assign sop_o = sop_i;	

assign r_o = ( (column_cnt > 12'd500 && column_cnt < 12'd730)&&((line_cnt > 12'd300 && line_cnt < 12'd420)) ) ? 8'd255 : r_i;
assign g_o = ( (column_cnt > 12'd500 && column_cnt < 12'd730)&&((line_cnt > 12'd300 && line_cnt < 12'd420)) ) ? 8'd255 : g_i;
assign b_o = ( (column_cnt > 12'd500 && column_cnt < 12'd730)&&((line_cnt > 12'd300 && line_cnt < 12'd420)) ) ? 8'd255 : b_i;

	
endmodule

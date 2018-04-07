//Author: ShVlad / e-mail: shvladspb@gmail.com
//

`timescale 1 ns / 1 ns
module calc_weight_coef
#(
	parameter DATA_WIDTH = 32
)
(
//clocks & reset
	input wire							clk,
//	input wire							reset_n,
//
	input wire	[DATA_WIDTH-1: 0]		Z,
	output wire	[DATA_WIDTH-1: 0]		weight_coef
);

localparam Zmin = 0;
localparam Zmax = 255;
localparam Zhalf_summ = (Zmax + Zmin)/2;

reg [DATA_WIDTH: 0]		Zsumm;
reg	[DATA_WIDTH-1: 0]	weight_coef_tmp;
always @( posedge clk )
	if ( Z <= Zhalf_summ )
		weight_coef_tmp = Z - Zmin;  
	else
		weight_coef_tmp = Zmax - Z; 


assign weight_coef = ( weight_coef_tmp != 0 ) ? weight_coef_tmp : 1; 
		
endmodule
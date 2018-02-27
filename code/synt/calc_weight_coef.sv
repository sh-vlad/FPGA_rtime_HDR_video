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
	output reg	[DATA_WIDTH-1: 0]		weight_coef
);

localparam Zmin = 0;
localparam Zmax = 255;
localparam Zhalf_summ = (Zmax + Zmin)/2;

reg [DATA_WIDTH: 0]		Zsumm;

always @( posedge clk )
	if ( Z <= Zhalf_summ )
		weight_coef = Z - Zmin;  
	else
		weight_coef = Zmax - Z; 

endmodule
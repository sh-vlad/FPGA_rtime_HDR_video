//Author: ShVlad / e-mail: shvladspb@gmail.com
//

`timescale 1 ns / 1 ns
module FPGA_rtime_HDR_video_top
(
//clocks
	input wire  				clk50,             
//tmp
	output wire					led

);

reg		[31: 0]		r_cnt_leg;

always @( posedge clk50 )
	if ( r_cnt_leg == 32'd50_000_000 )
		r_cnt_leg	<= 32'h0;
	else
		r_cnt_leg	<= r_cnt_leg + 1'h1;
		
assign led = ( r_cnt_leg < 25_000_000 ) ? 1'h1 : 1'h0;
		
endmodule






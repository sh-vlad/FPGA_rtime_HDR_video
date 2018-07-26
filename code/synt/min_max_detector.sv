//Author: ShVlad / e-mail: shvladspb@gmail.com
module min_max_detector
#(
    parameter W = 8
)
(
	input wire				clk,
	input wire				reset_n,
    input wire				sop,
	input wire				eop,
	input wire				valid,
	
	input wire	[W-1: 0]	data,
	output wire	[W-1: 0]	min,
	output wire	[W-1: 0]	max,
	output reg	[W-1: 0]	max_min_diff,
	input wire	[7:0]		reg_parallax_corr
);

   
reg [W-1:0]		min_tmp;
reg [W-1:0]		max_tmp;   
reg [10: 0]		line_cnt;
reg [11: 0]		pixel_cnt;

reg [W-1: 0]	aver_min_arr[4];
reg [W-1: 0]	aver_max_arr[4];
reg [W-1+3: 0]	aver_min;
reg [W-1+3: 0]	aver_max;

reg 			sh_eop;

always @( posedge clk )
	sh_eop <= eop;

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		pixel_cnt <= 12'h0;
	else
		if ( valid )
			pixel_cnt <= pixel_cnt + 1'h1;
		else
			pixel_cnt <= 12'h0;
	
always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		line_cnt <= 11'h0;
	else
		if ( eop && ( line_cnt == 11'd719 ) )
			line_cnt <= 11'h0;
		else if ( eop )
			line_cnt <= line_cnt + 1'h1;			
	
	
always @( posedge clk )
	if ( /*sop && */( line_cnt == 11'd0 ) && ( pixel_cnt == 10 ) )
		begin
			min_tmp	<= data;
			max_tmp	<= data;
		end
	else if ( valid && ( pixel_cnt < 1279 - reg_parallax_corr ) && ( pixel_cnt > 10 ) )	
		begin
			if ( data < min_tmp )
				min_tmp	<= data;
			else if ( data > max_tmp )
				max_tmp	<= data;
		end		
			

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		begin
			aver_min_arr[3] <= '0;
			aver_min_arr[2] <= '0;
			aver_min_arr[1] <= '0;
			aver_min_arr[0] <= '0;
			                   
			aver_max_arr[3] <= '0;
			aver_max_arr[2] <= '0;
			aver_max_arr[1] <= '0;
			aver_max_arr[0] <= '0;
		end
	else
		if ( eop && ( line_cnt == 11'd719 ) )
				begin
					aver_min_arr[3] <= aver_min_arr[2];
					aver_min_arr[2] <= aver_min_arr[1];
					aver_min_arr[1] <= aver_min_arr[0];
					aver_min_arr[0] <= min_tmp;
					
					aver_max_arr[3] <= aver_max_arr[2];
					aver_max_arr[2] <= aver_max_arr[1];
					aver_max_arr[1] <= aver_max_arr[0];
					aver_max_arr[0] <= max_tmp;
				end

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		begin
			aver_max <= {(W+3){1'b0}};;
			aver_min <= {(W+3){1'b0}};;
		end
	else
		begin
			aver_min <= aver_min_arr[0]+aver_min_arr[1]+aver_min_arr[2]+aver_min_arr[3];
			aver_max <= aver_max_arr[0]+aver_max_arr[1]+aver_max_arr[2]+aver_max_arr[3];
		end
				
assign min = aver_min[(W-1+3): 2];
assign max = aver_max[(W-1+3): 2];
assign max_min_diff = max - min;
			
endmodule

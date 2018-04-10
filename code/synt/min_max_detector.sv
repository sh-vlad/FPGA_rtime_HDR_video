
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
	output reg	[W-1: 0]	min,
	output reg	[W-1: 0]	max,
	output reg	[W-1: 0]	max_min_diff
);

   
reg [W-1:0]		min_tmp;
reg [W-1:0]		max_tmp;   
reg [10: 0]		line_cnt;
	
always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		line_cnt <= 11'h0;
	else
		if ( eop && ( line_cnt == 11'd719 ) )
			line_cnt <= 11'h0;
		else if ( eop )
			line_cnt <= line_cnt + 1'h1;			
	
	
always @( posedge clk )
	if ( sop && ( line_cnt == 11'd0 ) )
		begin
			min_tmp	<= data;
			max_tmp	<= data;
		end
	else if ( valid )		
		if ( data < min_tmp )
			min_tmp	<= data;
		else if ( data > max_tmp )
			max_tmp	<= data;
		
always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		begin
			max <= {(W){1'b0}};;
			min <= {(W){1'b0}};;
		end
	else
		if ( eop && ( line_cnt == 11'd719 ) )
			if ( data < min_tmp )
				min	<= data;
			else if ( data > max_tmp )
				max	<= data; 
			else
				begin
					min	<= min_tmp;
					max	<= max_tmp;
				end

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		max_min_diff <= 8'd255;
	else
		if ( eop && ( line_cnt == 11'd719 ) )
			if ( data < min_tmp )
				max_min_diff <= max_tmp - data;
			else if ( data > max_tmp )
				max_min_diff <= data - max_tmp;
			else
				begin
					max_min_diff <= max_tmp - min_tmp;
				end		

			
endmodule

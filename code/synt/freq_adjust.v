
module freq_adjust
#(
	parameter FREQ 		= 240,
	parameter DIV_COEF 	= 10
)
(
	input wire					clk,
	input wire					reset_n,
	input wire					err_ch0,
	input wire					err_ch1,	
	
	output wire					clk24_0,
	output wire					clk24_1	
);

localparam COUNT_ZEROS = FREQ/24;


reg [5:0]	cnt_0;
reg [5:0]	cnt_1;

reg [5:0]	cnt_delay_0;
reg [5:0]	cnt_delay_1;

reg			clk24_0_tmp;
reg			clk24_1_tmp;
reg			clk24_0_tmp_n;
reg			clk24_1_tmp_n;
enum reg [2:0]
{
	idle 		= 3'd1,
	wait_err	= 3'd2,
	err_0		= 3'd3,
	err_1		= 3'd4	
} cs, ns;

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		cs <= idle;
	else
		cs <= ns;
		
always_comb
	begin
		ns = cs;
		case ( cs )
			idle:		if ( reset_n )				ns = wait_err;
			wait_err:	if ( err_ch0 )				ns = err_0;
						else if ( err_ch1 )			ns = err_1;
			err_0:		if ( !err_ch0 )				ns = wait_err;
			err_1:		if ( !err_ch1 )				ns = wait_err;
			default:								ns = idle;	
		endcase
	end

///////////////
always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		cnt_delay_0 <= 6'h0;
	else
		if ( cs != err_0 || ( ( cnt_delay_0 == DIV_COEF-1 ) && ( cnt_0 == 6'd1 ) ) )
			cnt_delay_0	<= '0;
		else if ( cs == err_0 && ( cnt_0 == 1/*COUNT_ZEROS-1*/ ) )
			cnt_delay_0	<= cnt_delay_0 + 1'h1;
		 

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		cnt_delay_1 <= 6'h0;
	else
		if ( cs != err_1 || ( ( cnt_delay_1 == DIV_COEF-1 ) && ( cnt_1 == 6'd1 ) ) )
			cnt_delay_1	<= '0;
		else if ( cs == err_1 && ( cnt_1 == 1/*COUNT_ZEROS-1*/ ) )
			cnt_delay_1	<= cnt_delay_1 + 1'h1;
		
/////////////			
always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		cnt_0 <= 6'h0;
	else
		if ( cs != err_0 || ( cnt_delay_0 != DIV_COEF-1 ) )
			if ( cnt_0 == COUNT_ZEROS-1 )
				cnt_0 <= 6'h0;
			else
				cnt_0 <= cnt_0 + 1'd1;
		else if ( cs == err_0 )
			if ( cnt_0 == COUNT_ZEROS-2 )
				cnt_0 <= 6'h0;
			else
				cnt_0 <= cnt_0 + 1'd1;
				
always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		cnt_1 <= 6'h0;
	else
		if ( cs != err_1 || ( cnt_delay_1 != DIV_COEF-1 ) )
			if ( cnt_1 == COUNT_ZEROS-1 )
				cnt_1 <= 6'h0;
			else
				cnt_1 <= cnt_1 + 1'd1;
		else if ( cs == err_1 )
			if ( cnt_1 == COUNT_ZEROS-2 )
				cnt_1 <= 6'h0;
			else
				cnt_1 <= cnt_1 + 1'd1;				

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		clk24_0_tmp <= 	1'h0;	
	else
		if ( cnt_0 == 6'h1 || cnt_0 == (COUNT_ZEROS/2+1) )
			clk24_0_tmp <= ~clk24_0_tmp;
			
always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		clk24_1_tmp <= 	1'h0;	
	else
		if ( cnt_1 == 6'h1 || cnt_1 == (COUNT_ZEROS/2+1) )
			clk24_1_tmp <= ~clk24_1_tmp;			


assign 	clk_n = ~clk;

always @( posedge clk_n or negedge reset_n )
	if ( !reset_n )
		begin
			clk24_0_tmp_n 		<= 1'h0;	
		end
	else
		begin
			if ( cnt_0 == 6'h1 || cnt_0 == (COUNT_ZEROS/2+1) )
				clk24_0_tmp_n <= ~clk24_0_tmp_n;
		end

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		clk24_1_tmp_n <= 	1'h0;	
	else
		if ( cnt_1 == 6'h1 || cnt_1 == (COUNT_ZEROS/2+1) )
			clk24_1_tmp_n <= ~clk24_1_tmp_n;	

assign clk24_0 = ( cs == err_0 && ( cnt_delay_0 == DIV_COEF-1 ) ) ? clk24_0_tmp & clk24_0_tmp_n : clk24_0_tmp;
assign clk24_1 = ( cs == err_1 && ( cnt_delay_1 == DIV_COEF-1 ) ) ? clk24_1_tmp & clk24_1_tmp_n : clk24_1_tmp;			
endmodule



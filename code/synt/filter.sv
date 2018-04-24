//Author: ShVlad / e-mail: shvladspb@gmail.com
//

`timescale 1 ns / 1 ns
module filter
#(
	parameter DATA_WIDTH = 8,
	parameter COEF_WIDTH = 5	
)
(
//clocks & reset	
	input wire								clk,
	input wire								reset_n,
		
	input wire			[DATA_WIDTH-1:0]	data_i,	
	input wire								valid_i,
	input wire								sop_i,	
	input wire								eop_i,
//
	input wire signed 	[COEF_WIDTH-1:0]	coef[3][3],
	input wire signed	[COEF_WIDTH-1:0]	div_coef,
	input wire			[ 7: 0]				bias_factor,
	output reg			[DATA_WIDTH-1:0]	data_o,
	output reg								data_o_valid,
	output reg								sop_o,	
	output reg								eop_o	
);

wire		[DATA_WIDTH-1:0] 					fifo_0_q;
wire		[DATA_WIDTH-1:0] 					fifo_1_q;
wire		[DATA_WIDTH-1:0] 					fifo_2_q;
reg			[ 2: 0]								sh_raw_valid;
logic 		[ 2: 0]								fifo_wr;
logic 		[ 2: 0]								fifo_rd;
reg 		[11: 0]								line_cnt;
reg			[15: 0]								sh_fifo_rd;
reg												odd_even_column;
reg												sh_odd_even_column;
reg signed	[(DATA_WIDTH+COEF_WIDTH)-1:0]		mult[3][3];
reg signed	[(DATA_WIDTH+COEF_WIDTH)  :0]  		summ_st0[5];
reg signed	[(DATA_WIDTH+COEF_WIDTH)+1:0]		summ_st1[3];
reg signed	[(DATA_WIDTH+COEF_WIDTH)+2:0]		summ_st2[2];
reg signed	[(DATA_WIDTH+COEF_WIDTH)+3:0]		summ_st3;
reg signed	[(DATA_WIDTH+COEF_WIDTH)+3:0]		div_q;
reg signed	[DATA_WIDTH:0]						reg_line[3][3];
wire		[10: 0]								usedw[3];
reg			[ 6: 0]								wait_cnt;
wire											sh_valid;
wire											sh_sop;
wire											sh_eop;
reg			[ 1: 0]								last_line_num;
reg			[DATA_WIDTH-1:0]					data;
reg												data_valid;
reg												sop;	
reg												eop;	
always @( posedge clk or negedge reset_n )
	if ( ~reset_n )
		line_cnt	<= 12'h0;
	else
		if ( line_cnt == 12'd720 && eop_i )
			line_cnt	<= 12'h0;
		else if ( sop_i ) 
			line_cnt <= line_cnt + 1'h1;
//FSM
enum reg [3:0]
{
	s0_idle				= 4'd0,
	s0_wait_first_line 	= 4'd1,
	s0_wait_second_line = 4'd2,	
	s0_wait_third_line 	= 4'd3,	
	s0_line_even		= 4'd4,
	s0_line_odd			= 4'd5,
	s0_wait_line_last	= 4'd6,
	s0_line_last0		= 4'd7,
	s0_line_last1		= 4'd8,
	s0_line_last2		= 4'd9,
	s0_work				= 4'd10
	
}ns,cs,sh_cs;

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		cs <= s0_idle;
	else
		begin
			cs 		<= ns;
			sh_cs	<= cs;
		end

always_comb
	begin
		ns = cs;
		case ( cs )
			s0_idle:			if ( reset_n )											ns = s0_wait_first_line;
			s0_wait_first_line:	if ( line_cnt == 12'd1 && sop_i )						ns = s0_wait_second_line;
			s0_wait_second_line:if ( line_cnt == 12'd2 && sop_i )						ns = s0_wait_third_line;
			s0_wait_third_line:	if ( line_cnt == 12'd3 && sop_i )						ns = s0_work;
			s0_work:			if ( line_cnt == 12'd720 && eop_i )						ns = s0_wait_line_last;
			s0_wait_line_last:	if ( wait_cnt == 7'd100 && last_line_num == 2'h0)		ns = s0_line_last0;
								else if ( wait_cnt == 7'd100 && last_line_num == 2'h1)	ns = s0_line_last1;
								else if ( wait_cnt == 7'd100 && last_line_num == 2'h2)	ns = s0_line_last2;								
			s0_line_last0:		if ( usedw[0] == 11'h0 )								ns = s0_wait_line_last;
			s0_line_last1:		if ( usedw[1] == 11'h0 )								ns = s0_wait_line_last;
			s0_line_last2:		if ( usedw[2] == 11'h0 )								ns = s0_wait_first_line;
			default:																	ns = s0_idle;
		endcase
		
	end

assign sh_raw_valid[0] = valid_i;
always @( posedge clk )
	{sh_raw_valid[2],sh_raw_valid[1]} <= {sh_raw_valid[1],sh_raw_valid[0]};

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		wait_cnt	<= 7'h0;
	else
		if ( cs == s0_wait_line_last )
			wait_cnt <= wait_cnt + 1'h1;
		else
			wait_cnt <= 1'h0;

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		last_line_num	<= 3'h0;
	else
		if ( last_line_num == 2'h2 && wait_cnt == 7'd100 )
			last_line_num	<= 3'h0;
		else if ( wait_cnt == 7'd100 ) 
			last_line_num	<= last_line_num + 1'h1;
			
always_comb
	begin
		case ( ns )
			s0_wait_first_line:		begin 
										fifo_wr = {1'h0,1'h0,sh_raw_valid[0]};
										fifo_rd = 3'h0;
									end
			s0_wait_second_line:	begin 
										fifo_wr = {1'h0,sh_raw_valid[1],sh_raw_valid[0]};
										fifo_rd = {1'h0,1'h0,valid_i};										
									end
			s0_wait_third_line:		begin
										fifo_wr = {sh_raw_valid[1],sh_raw_valid[1],sh_raw_valid[0]};
										fifo_rd = {1'h0,valid_i,valid_i};
									end							
								
			s0_work:				begin
										fifo_wr = {sh_raw_valid[1],sh_raw_valid[1],sh_raw_valid[0]};
										fifo_rd = {valid_i,valid_i,valid_i};
									end	

			s0_wait_line_last:		begin
										fifo_wr = {sh_raw_valid[1],sh_raw_valid[1],sh_raw_valid[0]};
										fifo_rd = {valid_i,valid_i,valid_i};
									end	
			s0_line_last0:			begin
										fifo_wr = 3'b110;
										fifo_rd = 3'b111;			
									end
			s0_line_last1:			begin
										fifo_wr = 3'b100;
										fifo_rd = 3'b111;			
									end	
			s0_line_last2:			begin
										fifo_wr = 3'b000;
										fifo_rd = 3'b111;			
									end											
			default: 				begin	
										fifo_wr = 3'h0;
										fifo_rd = 3'h0;
									end
		endcase
	end
	
fifo_conv_filter fifo_conv_filter_0
(
	.clock		( clk			),
	.data       ( data_i		),
	.rdreq      ( fifo_rd[0]	),
	.wrreq      ( fifo_wr[0]	),
	.empty      (				),
	.full       (				),
	.q          ( fifo_0_q		),
	.usedw      ( usedw[0]		)
);

fifo_conv_filter fifo_conv_filter_1
(
	.clock		( clk			),
	.data       ( fifo_0_q		),
	.rdreq      ( fifo_rd[1]	),
	.wrreq      ( fifo_wr[1]	),
	.empty      (				),
	.full       (				),
	.q          ( fifo_1_q		),
	.usedw      ( usedw[1]		)
);

fifo_conv_filter fifo_conv_filter_2
(
	.clock		( clk			),
	.data       ( fifo_1_q		),
	.rdreq      ( fifo_rd[2]	),
	.wrreq      ( fifo_wr[2]	),
	.empty      (				),
	.full       (				),
	.q          ( fifo_2_q		),
	.usedw      ( usedw[2]		)
);

always @( posedge clk )
	begin
		reg_line[0][2][DATA_WIDTH] 	<= 1'h0;
		reg_line[1][2][DATA_WIDTH] 	<= 1'h0;
		reg_line[2][2][DATA_WIDTH] 	<= 1'h0;
		reg_line[0][2][7:0] 		<= fifo_2_q;
		reg_line[1][2][7:0] 		<= fifo_1_q;
		reg_line[2][2][7:0] 		<= fifo_0_q;			
		for ( int i = 0; i < 3; i++ )
			for ( int j = 0; j < 2; j++ )
				begin
					reg_line[i][j] <= reg_line[i][j+1];
				end
	end

always @( posedge clk )
	sh_fifo_rd	<= {sh_fifo_rd[14:0],fifo_rd[0]};

delay_rg 
#(
	.W	( 3		),         
	.D	( 5		)		
)    
delay_rg_strobes     
(
	.clk		( clk								),
	.data_in    ( { valid_i, sop_i, eop_i }	), 
	.data_out   ( { sh_valid, sh_sop, sh_eop } 		)
	
); 

always @( posedge clk )
		for ( int i = 0; i < 3; i++ )
			for ( int j = 0; j < 3; j++ )					
				mult[i][j] <= reg_line[i][j]*coef[i][j];								
		
always @( posedge clk )
	begin
		summ_st0[0] <= mult[0][0] + mult[0][1];
		summ_st0[1] <= mult[0][2] + mult[1][0];
		summ_st0[2] <= mult[1][1] + mult[1][2];
		summ_st0[3] <= mult[2][0] + mult[2][1];
		summ_st0[4] <= mult[2][2];
		
		summ_st1[0] <= summ_st0[0] + summ_st0[1];
		summ_st1[1] <= summ_st0[2] + summ_st0[3];
		summ_st1[2] <= summ_st0[4];
		
		summ_st2[0] <= summ_st1[0] + summ_st1[1];
		summ_st2[1] <= summ_st1[2];
		
		summ_st3 <= summ_st2[0] + summ_st2[1];
	end	

divider_conv_filter divider_conv_filter_inst
(
	.clock		( clk		),
	.denom      ( div_coef	),
	.numer      ( summ_st3	),
	.quotient   ( div_q		),
	.remain     ()
);	

always @( posedge clk )
	begin
		data <= div_q[15] ? 8'h0 : div_q[7:0];
		data_o <= data + bias_factor;
	end


always @( posedge clk )
	begin
		data_valid 	<= ( cs == s0_work || cs == s0_line_last0 || cs == s0_wait_third_line || cs == s0_line_last1 || cs == s0_wait_line_last ) ? sh_fifo_rd[12]:1'h0;
		sop			<= ((sh_cs!=s0_wait_second_line)&&(sh_cs!=s0_line_last2)&&(sh_cs!=s0_wait_first_line)) ? sh_fifo_rd[12]&(~sh_fifo_rd[13]):1'h0;
		eop			<= ((sh_cs!=s0_wait_second_line)&&(sh_cs!=s0_line_last2)&&(sh_cs!=s0_wait_first_line)) ? sh_fifo_rd[12]&(~sh_fifo_rd[11]):1'h0;
	end							

always @( posedge clk )
	begin
		data_o_valid <= data_valid ;	
		sop_o        <= sop		;	
		eop_o        <= eop		;	
	end
	
endmodule
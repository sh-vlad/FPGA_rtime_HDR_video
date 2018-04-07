//Author: ShVlad / e-mail: shvladspb@gmail.com
//

`define PIPELINE

`timescale 1 ns / 1 ns
module raw2rgb_bilinear_interp
#(
	parameter DATA_WIDTH = 8
)
(
//clocks & reset
	input wire							clk,
	input wire							reset_n,

	input wire		[DATA_WIDTH-1:0]	raw_data,
	input wire							raw_valid,
	input wire							raw_sop,	
	input wire							raw_eop,
	
	output wire		[DATA_WIDTH-1:0]	r_data_o,
	output wire		[DATA_WIDTH-1:0]	g_data_o,
	output wire		[DATA_WIDTH-1:0]	b_data_o,
	output reg							data_o_valid,
	output reg							sop_o,	
	output reg							eop_o	
);

wire	[DATA_WIDTH-1:0] 	fifo_0_q;
wire	[DATA_WIDTH-1:0] 	fifo_1_q;
wire	[DATA_WIDTH-1:0] 	fifo_2_q;
reg		[ 2: 0]				sh_raw_valid;
logic 	[ 2: 0]				fifo_wr;
logic 	[ 2: 0]				fifo_rd;
reg 	[11: 0]				line_cnt;
reg		[ 7: 0]				sh_fifo_rd;
reg							odd_even_column;
reg							sh_odd_even_column;
`ifdef PIPELINE
reg		[DATA_WIDTH-1+1:0]	r_stp0[2];
reg		[DATA_WIDTH-1+1:0]	g_stp0[2];
reg		[DATA_WIDTH-1+1:0]	b_stp0[2];
reg		[DATA_WIDTH-1+1+2:0]r_stp1;
reg		[DATA_WIDTH-1+1+2:0]g_stp1;
reg		[DATA_WIDTH-1+1+2:0]b_stp1;
`else
reg		[DATA_WIDTH-1+3:0]	r_tmp;
reg		[DATA_WIDTH-1+3:0]	g_tmp;
reg		[DATA_WIDTH-1+3:0]	b_tmp;
`endif

reg		[DATA_WIDTH-1:0]	reg_line[3][3];
wire	[10: 0]				usedw[3];
reg		[ 6: 0]				wait_cnt;
wire						sh_valid;
wire						sh_sop;
wire						sh_eop;
reg		[ 1: 0]				last_line_num;
always @( posedge clk or negedge reset_n )
	if ( ~reset_n )
		line_cnt	<= 12'h0;
	else
		if ( line_cnt == 12'd720 && raw_eop )
			line_cnt	<= 12'h0;
		else if ( raw_sop ) 
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
	s0_line_last2		= 4'd9
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
			s0_wait_first_line:	if ( line_cnt == 12'd1 && raw_sop )						ns = s0_wait_second_line;//s0_line_even;
			s0_wait_second_line:if ( line_cnt == 12'd2 && raw_sop )						ns = s0_wait_third_line;
			s0_wait_third_line:	if ( line_cnt == 12'd3 && raw_sop )						ns = s0_line_even;
			s0_line_odd:		if ( raw_sop )											ns = s0_line_even;
			s0_line_even:		if ( line_cnt == 12'd720 && raw_eop )					ns = s0_wait_line_last;
								else if ( raw_sop )										ns = s0_line_odd;
			s0_wait_line_last:	if ( wait_cnt == 7'd100 && last_line_num == 2'h0)		ns = s0_line_last0;
								else if ( wait_cnt == 7'd100 && last_line_num == 2'h1)	ns = s0_line_last1;
								else if ( wait_cnt == 7'd100 && last_line_num == 2'h2)	ns = s0_line_last2;
			s0_line_last0:		if ( usedw[0] == 11'h0 )								ns = s0_wait_line_last;
			s0_line_last1:		if ( usedw[1] == 11'h0 )								ns = s0_wait_line_last;
			s0_line_last2:		if ( usedw[2] == 11'h0 )								ns = s0_wait_first_line;
			default:																	ns = s0_idle;
		endcase
		
	end

assign sh_raw_valid[0] = raw_valid;
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
										fifo_rd = {1'h0,1'h0,raw_valid};										
									end
			s0_wait_third_line:		begin
										fifo_wr = {sh_raw_valid[1],sh_raw_valid[1],sh_raw_valid[0]};
										fifo_rd = {1'h0,raw_valid,raw_valid};
									end							

			s0_line_odd:			begin
										fifo_wr = {sh_raw_valid[1],sh_raw_valid[1],sh_raw_valid[0]};
										fifo_rd = {raw_valid,raw_valid,raw_valid};
									end
			s0_line_even:			begin
										fifo_wr = {sh_raw_valid[1],sh_raw_valid[1],sh_raw_valid[0]};
										fifo_rd = {raw_valid,raw_valid,raw_valid};
									end	
			s0_wait_line_last:		begin
										fifo_wr = {sh_raw_valid[1],sh_raw_valid[1],sh_raw_valid[0]};
										fifo_rd = {raw_valid,raw_valid,raw_valid};
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
//	fifo_wr	= sh_raw_valid;
	end
	
fifo_raw2rgb fifo_raw2rgb_0
(
	.clock		( clk			),
	.data       ( raw_data		),
	.rdreq      ( fifo_rd[0]	),
	.wrreq      ( fifo_wr[0]	),
	.empty      (				),
	.full       (				),
	.q          ( fifo_0_q		),
	.usedw      ( usedw[0]		)
);

fifo_raw2rgb fifo_raw2rgb_1
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

fifo_raw2rgb fifo_raw2rgb_2
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
		reg_line[0][2] <= fifo_2_q;
		reg_line[1][2] <= fifo_1_q;
		reg_line[2][2] <= fifo_0_q;	
		
		for ( int i = 0; i < 3; i++ )
			for ( int j = 0; j < 2; j++ )
				begin
					reg_line[i][j] <= reg_line[i][j+1];
				end
	end
/*
delay_rg 
#(
	.W	( 1		),         
	.D	( 4		)		
)    
delay_rg_fifo_rd     
(
	.clk		( clk			),
	.data_in    ( fifo_rd[0]	), 
	.data_out   ( sh_fifo_rd	)
);  
*/
always @( posedge clk )
	sh_fifo_rd	<= {sh_fifo_rd[6:0],fifo_rd[0]};

delay_rg 
#(
	.W	( 3		),         
	.D	( 5		)		
)    
delay_rg_strobes     
(
	.clk		( clk								),
	.data_in    ( { raw_valid, raw_sop, raw_eop }	), 
	.data_out   ( { sh_valid, sh_sop, sh_eop } 		)
	
); 

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		odd_even_column	<= 1'h0;
	else
		if ( sh_fifo_rd[3] )
			odd_even_column <= ~odd_even_column;
		else
			odd_even_column	<= 1'h0;
			
always @( posedge clk )
	sh_odd_even_column	<= odd_even_column;				
		


		
	
`ifdef PIPELINE
always @( posedge clk )	
	if ( cs == s0_wait_third_line )
		begin
			r_stp0[0] <= reg_line[2][1];			
			g_stp0[0] <= reg_line[2][0] + reg_line[1][1];		
			b_stp0[0] <= reg_line[1][0];		
		end
	else if ( ( cs == s0_line_even ) && ( !odd_even_column ) ) //even line even column
		begin
			r_stp0[0] <= reg_line[1][1];
			g_stp0[0] <= reg_line[1][0]+reg_line[0][1];
			g_stp0[1] <= reg_line[1][2]+reg_line[2][1];				
			b_stp0[0] <= reg_line[0][0]+reg_line[2][0];
			b_stp0[1] <= reg_line[0][2]+reg_line[2][2];
		end
	else if ( ( cs == s0_line_even ) && ( odd_even_column ) ) //even line odd column
		begin		
			r_stp0[0] <= reg_line[1][2] + reg_line[1][0];
			g_stp0[0] <= reg_line[1][1];			
			b_stp0[0] <= reg_line[0][1] + reg_line[2][1];
		end
	else if ( ( cs == s0_line_odd ) && ( !odd_even_column ) ) //odd line even column
		begin		
			r_stp0[0] <= reg_line[2][1] + reg_line[0][1];			
			g_stp0[0] <= reg_line[1][1];					
			b_stp0[0] <= reg_line[1][0] + reg_line[1][2];
		end		
	else if ( ( cs == s0_line_odd ) && ( odd_even_column ) )	 //odd line odd column
		begin		
			r_stp0[0] <= reg_line[2][2]+reg_line[0][0];
			r_stp0[1] <= reg_line[0][2]+reg_line[2][0];			
			g_stp0[0] <= reg_line[1][2]+reg_line[2][1];	
			g_stp0[1] <= reg_line[1][0]+reg_line[0][1];				
			b_stp0[0] <= reg_line[1][1];
		end	
	else if ( ( cs == s0_line_last0 ) && ( !odd_even_column ) ) //odd line even column
		begin		
			r_stp0[0] <= reg_line[2][1] + reg_line[0][1];
			g_stp0[0] <= reg_line[1][1];	
			b_stp0[0] <= reg_line[1][0] + reg_line[1][2];
		end		
	else if ( ( cs == s0_line_last0 ) && ( odd_even_column ) )	 //odd line odd column
		begin		
			r_stp0[0] <= reg_line[2][2]+reg_line[0][0];
			r_stp0[1] <= reg_line[0][2]+reg_line[2][0];			
			g_stp0[0] <= reg_line[1][2]+reg_line[2][1];	
			g_stp0[1] <= reg_line[1][0]+reg_line[0][1];				
			b_stp0[0] <= reg_line[1][1];
		end	
	else if ( ( cs == s0_line_last1 ) && ( odd_even_column ) )
		begin		
			r_stp0[0] <= reg_line[1][1];
			g_stp0[0] <= reg_line[1][0]+reg_line[0][1];	
			b_stp0[0] <= reg_line[0][0];

		end

always @( posedge clk )	
	if ( sh_cs == s0_wait_third_line )
		begin
			r_stp1 <= r_stp0[0];
			g_stp1 <= g_stp0[0]>>1;
			b_stp1 <= b_stp0[0];	
		end
	else if ( ( sh_cs == s0_line_even ) && ( !sh_odd_even_column ) ) //even line even column
		begin
			r_stp1 <= r_stp0[0];
			g_stp1 <= (g_stp0[0]+g_stp0[1])>>2;
			b_stp1 <= (b_stp0[0]+b_stp0[1])>>2;		
		end
	else if ( ( sh_cs == s0_line_even ) && ( sh_odd_even_column ) ) //even line odd column
		begin		
			r_stp1 <= r_stp0[0]>>1;
			g_stp1 <= g_stp0[0];
			b_stp1 <= b_stp0[0]>>1;		
		end
	else if ( ( sh_cs == s0_line_odd ) && ( !sh_odd_even_column ) ) //odd line even column
		begin				
			r_stp1 <= r_stp0[0]>>1;
			g_stp1 <= g_stp0[0];
			b_stp1 <= b_stp0[0]>>1;			
		end		
	else if ( ( sh_cs == s0_line_odd ) && ( sh_odd_even_column ) )	 //odd line odd column
		begin				
			r_stp1 <= (r_stp0[0]+r_stp0[1])>>2;
			g_stp1 <= (g_stp0[0]+g_stp0[1])>>2;
			b_stp1 <= b_stp0[0];			
		end	
	else if ( ( sh_cs == s0_line_last0 ) && ( !sh_odd_even_column ) ) //odd line even column
		begin				
			r_stp1 <= r_stp0[0]>>1;
			g_stp1 <= g_stp0[0];
			b_stp1 <= b_stp0[0]>>1;					
		end		
	else if ( ( sh_cs == s0_line_last0 ) && ( sh_odd_even_column ) )	 //odd line odd column
		begin		
			r_stp1 <= r_stp0[0]+r_stp0[1]>>2;
			g_stp1 <= g_stp0[0]+g_stp0[1]>>2;
			b_stp1 <= b_stp0[0];			
		end		
	else if ( ( sh_cs == s0_line_last1 ) && ( sh_odd_even_column ) )
		begin	
			r_stp1 <= r_stp0[0];
			g_stp1 <= g_stp0[0]>>1;
			b_stp1 <= b_stp0[0];	
		end
	
///////////////////////////////

assign r_data_o = r_stp1;
assign g_data_o = g_stp1;
assign b_data_o = b_stp1;

always @( posedge clk )
	begin
		data_o_valid <= ((sh_cs!=s0_wait_second_line)&&(sh_cs!=s0_line_last2)&&(sh_cs!=s0_wait_first_line)) ? sh_fifo_rd[4]:1'h0;
		sop_o	<= ((sh_cs!=s0_wait_second_line)&&(sh_cs!=s0_line_last2)&&(sh_cs!=s0_wait_first_line)) ? sh_fifo_rd[4]&(~sh_fifo_rd[5]):1'h0;
		eop_o	<= ((sh_cs!=s0_wait_second_line)&&(sh_cs!=s0_line_last2)&&(sh_cs!=s0_wait_first_line)) ? sh_fifo_rd[4]&(~sh_fifo_rd[3]):1'h0;
	end
							
`else	

always @( posedge clk )	
	if ( cs == s0_wait_third_line )
		begin
			r_tmp <= reg_line[2][1];	
			g_tmp <= (reg_line[2][0]+reg_line[1][1])>>1;	
			b_tmp <= reg_line[1][0];			
		end
	else if ( ( cs == s0_line_even ) && ( !odd_even_column ) ) //even line even column
		begin
			r_tmp <= reg_line[1][1];	
			g_tmp <= (reg_line[1][0]+reg_line[0][1]+reg_line[1][2]+reg_line[2][1])>>2;	
			b_tmp <= (reg_line[0][0]+reg_line[2][0]+reg_line[0][2]+reg_line[2][2])>>2;
		end
	else if ( ( cs == s0_line_even ) && ( odd_even_column ) ) //even line odd column
		begin			
			r_tmp <= (reg_line[1][2]+reg_line[1][0])>>1;
			g_tmp <= reg_line[1][1];	
			b_tmp <= (reg_line[0][1]+reg_line[2][1])>>1;
		end
	else if ( ( cs == s0_line_odd ) && ( !odd_even_column ) ) //odd line even column
		begin
			r_tmp <= (reg_line[2][1]+reg_line[0][1])>>1;
			g_tmp <= reg_line[1][1]; 
			b_tmp <= (reg_line[1][0]+reg_line[1][2])>>1;
		end		
	else if ( ( cs == s0_line_odd ) && ( odd_even_column ) )	 //odd line odd column
		begin
			r_tmp <= ( reg_line[2][2]+reg_line[0][0]+reg_line[0][2]+reg_line[2][0] ) >> 2;	 
			g_tmp <= ( reg_line[1][2]+reg_line[2][1]+reg_line[1][0]+reg_line[0][1] ) >> 2; 
			b_tmp <= reg_line[1][1];
		end	
	else if ( ( cs == s0_line_last0 ) && ( !odd_even_column ) ) //odd line even column
		begin
			r_tmp <= (reg_line[2][1]+reg_line[0][1])>>1;
			g_tmp <= reg_line[1][1]; 
			b_tmp <= (reg_line[1][0]+reg_line[1][2])>>1;
		end		
	else if ( ( cs == s0_line_last0 ) && ( odd_even_column ) )	 //odd line odd column
		begin
			r_tmp <= ( reg_line[2][2]+reg_line[0][0]+reg_line[0][2]+reg_line[2][0] ) >> 2;	 
			g_tmp <= ( reg_line[1][2]+reg_line[2][1]+reg_line[1][0]+reg_line[0][1] ) >> 2; 
			b_tmp <= reg_line[1][1];
		end			
	
	else if ( ( cs == s0_line_last1 ) && ( odd_even_column ) )
		begin
			r_tmp <= reg_line[1][1];		 
			g_tmp <= (reg_line[1][0]+reg_line[0][1])>>1; 
			b_tmp <= reg_line[0][0];			
		end

assign r_data_o = r_tmp;
assign g_data_o = g_tmp;
assign b_data_o = b_tmp;		
		
always @( posedge clk )
	begin
		data_o_valid <= ((cs!=s0_wait_second_line)&&(cs!=s0_line_last2)&&(cs!=s0_wait_first_line)) ? sh_fifo_rd[3]:1'h0;	
		sop_o	<= ((cs!=s0_wait_second_line)&&(cs!=s0_line_last2)&&(cs!=s0_wait_first_line)) ? sh_fifo_rd[3]&(~sh_fifo_rd[4]):1'h0;
		eop_o	<= ((cs!=s0_wait_second_line)&&(cs!=s0_line_last2)&&(cs!=s0_wait_first_line)) ? sh_fifo_rd[3]&(~sh_fifo_rd[2]):1'h0;
	end
`endif	
	
endmodule
//Author: ShVlad / e-mail: shvladspb@gmail.com
//

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
	
	output wire		[DATA_WIDTH-1:0]	r_data,
	output wire		[DATA_WIDTH-1:0]	g_data,
	output wire		[DATA_WIDTH-1:0]	b_data,
	output reg							data_o_valid
);

wire	[DATA_WIDTH-1:0] 	fifo_0_q;
wire	[DATA_WIDTH-1:0] 	fifo_1_q;
wire	[DATA_WIDTH-1:0] 	fifo_2_q;
reg		[ 2: 0]				sh_raw_valid;
logic 	[ 2: 0]				fifo_wr;
logic 	[ 2: 0]				fifo_rd;
reg 	[11: 0]				line_cnt;
reg		[DATA_WIDTH-1:0]	reg_line_0[2:0];
reg		[DATA_WIDTH-1:0]	reg_line_1[2:0];
reg		[DATA_WIDTH-1:0]	reg_line_2[2:0];
wire						sh_fifo_rd;
reg							odd_even_column;
reg		[DATA_WIDTH-1+3:0]	r_tmp;
reg		[DATA_WIDTH-1+3:0]	g_tmp;
reg		[DATA_WIDTH-1+3:0]	b_tmp;
reg		[DATA_WIDTH-1:0]	reg_line[3][3];
always @( posedge clk or negedge reset_n )
	if ( ~reset_n )
		line_cnt	<= 12'h0;
	else
		if ( line_cnt == 12'd720 && raw_eop )
			line_cnt	<= 12'h0;
		else if ( raw_sop ) 
			line_cnt <= line_cnt + 1'h1;
//FSM
enum reg [2:0]
{
	s0_idle				= 0,
	s0_wait_first_line 	= 1,
	s0_wait_second_line = 2,	
	s0_wait_third_line 	= 3,	
	s0_line_even		= 4,
	s0_line_odd			= 5	
}ns,cs;

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		cs <= s0_idle;
	else
		cs <= ns;

always_comb
	begin
		case ( cs )
			s0_idle:			if ( reset_n )							ns = s0_wait_first_line;
			s0_wait_first_line:	if ( line_cnt == 12'd1 && raw_sop )		ns = s0_wait_second_line;
			s0_wait_second_line:if ( line_cnt == 12'd2 && raw_sop )		ns = s0_wait_third_line;
			s0_wait_third_line:	if ( line_cnt == 12'd3 && raw_sop )		ns = s0_line_even;
			s0_line_odd:		if ( raw_sop )							ns = s0_line_even;
			s0_line_even:		if ( line_cnt == 12'd0 )				ns = s0_wait_first_line;
								else if ( raw_sop )						ns = s0_line_odd;
			default:													ns = s0_idle;
		endcase
		
	end

assign sh_raw_valid[0] = raw_valid;
always @( posedge clk )
	{sh_raw_valid[2],sh_raw_valid[1]} <= {sh_raw_valid[1],sh_raw_valid[0]};

always_comb
	begin
		case ( ns )
			s0_wait_first_line:		fifo_wr = {1'h0,1'h0,sh_raw_valid[0]};
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
	.usedw      (				)
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
	.usedw      (				)
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
	.usedw      (				)
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
always @( posedge clk )
	begin
		reg_line[2] <= {fifo_2_q,reg_line[2][2],reg_line[2][1]};//{reg_line_0[1],reg_line_0[0],fifo_2_q};
		reg_line[1] <= {fifo_1_q,reg_line[1][2],reg_line[1][1]};//{reg_line_1[1],reg_line_1[0],fifo_1_q};
		reg_line[0] <= {fifo_0_q,reg_line[0][2],reg_line[0][2]};//{reg_line_2[1],reg_line_2[0],fifo_0_q};
	end
*/
always @( posedge clk )
	begin
		reg_line_0 <= {fifo_2_q,reg_line_0[2],reg_line_0[1]};//{reg_line_0[1],reg_line_0[0],fifo_2_q};
		reg_line_1 <= {fifo_1_q,reg_line_1[2],reg_line_1[1]};//{reg_line_1[1],reg_line_1[0],fifo_1_q};
		reg_line_2 <= {fifo_0_q,reg_line_2[2],reg_line_2[1]};//{reg_line_2[1],reg_line_2[0],fifo_0_q};
	end

delay_rg 
#(
	.W	( 1		),         // разрядность входного и выходного сигнала
	.D	( 4		)		// задержка
)    
delay_rg_0     
(
	.clk		( clk			),
	.data_in    ( fifo_rd[0]	), 
	.data_out   ( sh_fifo_rd	)
);  

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		odd_even_column	<= 1'h0;
	else
		if ( sh_fifo_rd )
			odd_even_column <= ~odd_even_column;
		else
			odd_even_column	<= 1'h0;

always @( posedge clk )	
	if ( ( cs == s0_line_even ) && ( !odd_even_column ) ) //even line even column
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



assign r_data = r_tmp;
assign g_data = g_tmp;
assign b_data = b_tmp;

always @( posedge clk )
	data_o_valid <= ((cs==s0_line_odd)||(cs==s0_line_even)) ? sh_fifo_rd:1'h0;
endmodule
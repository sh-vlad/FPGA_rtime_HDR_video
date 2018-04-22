//Author: ShVlad / e-mail: shvladspb@gmail.com
//

`timescale 1 ns / 1 ns
module parallax_fix
#(
	parameter CAM_DIFFERENCE = 32
)
(

	input wire				clk,
	input wire				reset_n,
	
	input wire	[ 7: 0]		raw_data_0,
	input wire	[ 7: 0]		raw_data_1,
	input wire				raw_data_valid,
	input wire				raw_data_sop,
	input wire				raw_data_eop,
	
	output wire	[ 7: 0]		prlx_fxd_data_0,
	output wire	[ 7: 0]		prlx_fxd_data_1,
	output reg				prlx_fxd_data_valid,
	output reg				prlx_fxd_data_sop,
	output reg				prlx_fxd_data_eop
);

reg 	[11: 0]		cnt_wr;
reg 	[11: 0]		cnt_rd;
wire				wr_0;
wire				rd_0;

wire				wr_1;
wire				rd_1;

wire	[7 :0]		q_0;
wire	[7 :0]		q_1;

wire				w_prlx_fxd_data_vali;
wire				w_prlx_fxd_data_sop;
wire				w_prlx_fxd_data_eop;


always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		cnt_wr <= 12'h0;
	else 
		if ( raw_data_valid )
			cnt_wr <= cnt_wr + 1'h1;
		else
			cnt_wr <= 12'h0;

always @( posedge clk or negedge reset_n )
	if ( !reset_n )
		cnt_rd <= 12'h0;
	else
		if ( cnt_rd == 12'd1280 )
			cnt_rd <= 12'h0;
		else if ( cnt_wr == CAM_DIFFERENCE )
			cnt_rd <= 1'h1;
		else if ( cnt_rd != 12'h0 )
			cnt_rd <= cnt_rd + 1'h1;
			
assign wr_1 = raw_data_valid && ( cnt_wr < (1280-CAM_DIFFERENCE) );  			
assign wr_0 = raw_data_valid && ( cnt_wr >= CAM_DIFFERENCE ); 

assign rd_0 = ( cnt_rd > 0 ) ? 1'h1: 1'h0;
	
fifo_parallax_fix fifo_parallax_fix_0
(
	.clock		( clk			),
	.data       ( raw_data_0	),
	.rdreq      ( rd_0			),
	.wrreq      ( wr_0			),
	.empty      (),
	.full       (),
	.q          ( q_0			),
	.usedw      ()
);		

fifo_parallax_fix fifo_parallax_fix_1
(
	.clock		( clk			),
	.data       ( raw_data_1	),
	.rdreq      ( rd_0			),
	.wrreq      ( wr_1			),
	.empty      (),	
	.full       (),	
	.q          ( q_1			),
	.usedw      ()
);		

assign prlx_fxd_data_0 = ( cnt_rd < (1280-CAM_DIFFERENCE) ) ? q_0 : 7'h1;
assign prlx_fxd_data_1 = ( cnt_rd < (1280-CAM_DIFFERENCE) ) ? q_1 : 7'h1;
assign w_prlx_fxd_data_valid = ( cnt_rd > 0 ) ? 1'h1 : 7'h0;
assign w_prlx_fxd_data_sop = ( cnt_rd == 1 ) ? 1'h1 : 7'h0;
assign w_prlx_fxd_data_eop = ( cnt_rd == 1280 ) ? 1'h1 : 7'h0;

always @( posedge clk )
	begin
		prlx_fxd_data_valid  <= w_prlx_fxd_data_valid ;
	    prlx_fxd_data_sop    <= w_prlx_fxd_data_sop 	 ;
	    prlx_fxd_data_eop    <= w_prlx_fxd_data_eop   ;
	end
/*
assign prlx_fxd_data_valid
assign prlx_fxd_data_sop
assign prlx_fxd_data_eop*/
endmodule
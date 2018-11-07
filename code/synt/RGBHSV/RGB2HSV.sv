module RGB2HSV
(
	input wire					clk,
	input wire					rst,
	input wire	[ 7: 0]			r,
	input wire	[ 7: 0]			g,
	input wire	[ 7: 0]			b,
	
	output reg	[ 8: 0]			H,	
	output wire	[10: 0]			S,	
	output wire	[ 7: 0]			V		
);
localparam DIV_DELAY = 9;
//st0
	reg	[ 7: 0] 	max;
	reg	[ 7: 0] 	min;
	
	reg [ 7: 0] 	st1_r;
	reg [ 7: 0] 	st1_g;
	reg [ 7: 0] 	st1_b;	
	reg [ 4: 0]	 	chz;
	wire[ 4: 0]		chz_delay;
	wire[ 7: 0] 	max_for_div;
//st1
	reg 		[ 7: 0] 		max_min_sub_H;
	reg signed 	[18: 0] 		sub_H;
	wire signed	[17: 0] 		div_min_max_S;	
	reg signed 	[18: 0] 		mult_2048_max_V;	
	wire 		[7 : 0]  		remain_S;
//st2	
	wire signed	[17: 0] 		div_sub_maxmin_H;	
	wire		[ 7: 0]			remain_H;
	reg			[11: 0] 		sub_1_div_S;
//st3	
	reg			[23: 0] 		mult60_H;
	wire signed	[8: 0] 			mult60_H_round_H;
//st4	
//	reg			[8:0] 			H;
	
//st0	
//поиск минимума и максимума
	always @( posedge clk /*or posedge rst*/ )
		if ( ( r >= g ) && ( r >= b ) )
			max <= r;
		else if ( ( g >= r ) && ( g >= b ) )
			max <= g;
		else if ( ( b >= r ) && ( b >= g ) )
			max <= b;
				
	always @( posedge clk /*or posedge rst*/ )
		if ( ( r <= g ) && ( r <= b ) )
			min <= r;
		else if ( ( g <= r ) && ( g <= b ) )
			min <= g;
		else if ( ( b <= r ) && ( b <= g ) )
			min <= b;

	always @( posedge clk )
		begin
			st1_r	<= r;
			st1_g	<= g;
			st1_b	<= b;
		end		

//st1			
	always @( posedge clk )
		max_min_sub_H <= max - min;

	always @( posedge clk )
		if ( ( max == st1_r ) )
			sub_H <= {st1_g,10'd0} - {st1_b,10'd0};	
		else if ( max == st1_g ) 
			sub_H <= {st1_b,10'd0} - {st1_r,10'd0};	
		else if ( max == st1_b ) 
			sub_H <= {st1_r,10'd0} - {st1_g,10'd0};		

	always @( posedge clk )
		if ( min == max )
			chz <= 5'b10000;			
		else if ( ( max == st1_r ) && ( st1_g >= st1_b ) )
			chz <= 5'b01000;
		else if( ( max == st1_r ) && ( st1_g < st1_b ) )
			chz <= 5'b00100;	
		else if ( max == st1_g ) 
			chz <= 5'b00010;	
		else if ( max == st1_b ) 
			chz <= 5'b00001;	

assign max_for_div = ( ( max == 0 ) ? 1 : max );
			
rgb2hsv_divider_S rgb2hsv_divider_S_inst
(
	.clock			( clk						),
	.denom          ( max_for_div				),
	.numer          ( { min, 11'h0 }			),
	.quotient       ( div_min_max_S 			),
	.remain		    ( remain_S					)
);			
/*
always @( posedge clk )
	mult_2048_max_V <= { max, 11'h0 };
*/			
//st2			
delay_rg
#(
	.W				( 5				),
	.D				( 6+DIV_DELAY	)
)
delay_rg_1
(
	.clk			( clk			),
	.data_in		( chz			),
	.data_out       ( chz_delay		)
);
		

rgb2hsv_divider0 rgb2hsv_divider0_inst
(
	.clock			( clk				),
	.denom          ( max_min_sub_H		),
	.numer          ( sub_H				),
	.quotient       ( div_sub_maxmin_H	),
	.remain		    ( remain_H			)
);

	always @( posedge clk )
		sub_1_div_S <= ( remain_S[7] == 1 )  ? ( 2047 - div_min_max_S[11:0] ) : ( 2048 - div_min_max_S[11:0] );
	
//st3
	always @( posedge clk )
		mult60_H <= 	( remain_H[7] == 1 )  ?  ( (div_sub_maxmin_H + 1) * 60 ) : ( div_sub_maxmin_H  * 60);	

rounder 
#(
	.BEFORE_ROUND	( 24		),
	.LOW_BIT	  	( 10		),
	.AFTER_ROUND	( 9			)
)
rounder_inst
(
	.clk			( clk			),             
	.reset_b        ( !rst			),
	.data_in        ( mult60_H		),
	.data_out	    ( mult60_H_round_H 	)
);
		
//st4
	always @( posedge clk )
		case ( chz_delay )
			5'b10000:	H <= '0; 
			5'b01000:	H <= mult60_H_round_H;		
			5'b00100:	H <= mult60_H_round_H + 360;	
			5'b00010:	H <= mult60_H_round_H + 120;
			5'b00001:	H <= mult60_H_round_H + 240;
			default: 	H <= '0; 
		endcase

delay_rg
#(
	.W				( 11			),
	.D				( 6				)
)
delay_rg_S
(
	.clk			( clk											),
	.data_in		( ( sub_1_div_S[11]?2047:sub_1_div_S[10:0]	)	),
	.data_out       ( S												)
);
		

delay_rg
#(
	.W				( 8				),
	.D				( 8 + DIV_DELAY	)
)
delay_rg_V
(
	.clk			( clk				),
	.data_in		( max				),
	.data_out       ( V					)
);
		
endmodule

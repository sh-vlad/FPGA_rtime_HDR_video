

module h2f_bridge_dsp
#(
	parameter WIDTH_ADDR 	 =  8,
	          WIDTH_DATA 	 = 32,	
	          WIDTH_BE       =  8
)	
(         
	input  logic  						clk_dsp,             
	input  logic 				        reset_n,
    //шина avalon моста h2f
	input  logic						avl_write          ,
	input  logic						avl_chipselect     ,
	output logic						avl_waitrequest    ,
	input  logic	[WIDTH_ADDR-1:0]	avl_address        ,
	input  logic	[WIDTH_BE  -1:0]    avl_byteenable     ,
	output logic	[WIDTH_DATA-1:0]	avl_readdata       ,
	input  logic	[WIDTH_DATA-1:0]	avl_writedata      ,
	// авалон мастер                                                      
	output  logic						avl_write_dsp      ,
	output  logic						avl_chipselect_dsp ,
	output  logic	[WIDTH_ADDR-1:0]    avl_address_dsp    ,
	output  logic	[WIDTH_BE  -1:0]    avl_byteenable_dsp ,
	input   logic	[WIDTH_DATA-1:0]	avl_readdata_dsp   ,
	output  logic	[WIDTH_DATA-1:0]	avl_writedata_dsp  

);
parameter WIDTH_ALL = WIDTH_ADDR + 2*WIDTH_DATA + WIDTH_BE + 2;

wire [WIDTH_ALL -1 : 0] union_avl_in = {avl_write, avl_chipselect, avl_address, avl_byteenable, avl_readdata_dsp, avl_writedata};
reg  [WIDTH_ALL -1 : 0] reg_avl_dsp;
	
always_ff @( posedge clk_dsp or negedge reset_n )	
	if (~reset_n )
		reg_avl_dsp <= {WIDTH_ALL{1'b0}};
	else 
		reg_avl_dsp <= union_avl_in;
		
// выходы шины avl к ЦОС
assign avl_write_dsp        = reg_avl_dsp[WIDTH_ALL - 1                            ];
assign avl_chipselect_dsp	= reg_avl_dsp[WIDTH_ALL - 2                            ];	
assign avl_address_dsp      = reg_avl_dsp[WIDTH_ALL - 3: 2*WIDTH_DATA+WIDTH_BE     ];
assign avl_byteenable_dsp	= reg_avl_dsp[2*WIDTH_DATA + WIDTH_BE -1 :2*WIDTH_DATA ];	
assign avl_readdata         = reg_avl_dsp[2*WIDTH_DATA -1 :WIDTH_DATA              ];	 
assign avl_writedata_dsp 	= reg_avl_dsp[WIDTH_DATA-1             :              0];				
assign avl_waitrequest      = 1'b0;	

endmodule













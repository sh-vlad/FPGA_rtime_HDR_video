

module hps_register_ov5640
(
	input  logic                        clk_sys        ,             
	input  logic                        reset_n        ,
	input  logic                        ready_ov5640   ,
	output logic                        start_ov5640   ,
	output logic [15:0]                  address_ov5640 ,
	output logic [7:0]                  data_ov5640    ,
	output logic [31:0]                 reg_addr_buf_1  ,
	output logic [31:0]                 reg_addr_buf_2  ,
	output logic                       start_write_image2ddr  ,
	 //шина avalon от моста hps2-to-fpga                          
	avl_ifc.avl_write_slave_port        avl_h2f_write    
);
wire write_hps = avl_h2f_write.chipselect &  avl_h2f_write.write;
always_ff @( posedge clk_sys or negedge reset_n )
	if(~reset_n)
		reg_addr_buf_1 <='0;
	else if( write_hps & (avl_h2f_write.address[15:0] ==16'd0) )
		reg_addr_buf_1 <=  avl_h2f_write.writedata;
		
always_ff @( posedge clk_sys or negedge reset_n )
	if(~reset_n)
		reg_addr_buf_2 <='0;
	else if( write_hps & (avl_h2f_write.address[15:0] ==16'd1) )
		reg_addr_buf_2 <=  avl_h2f_write.writedata;
always_ff @( posedge clk_sys or negedge reset_n )
	if(~reset_n)
		start_write_image2ddr <='0;
	else if( write_hps & (avl_h2f_write.address[15:0] ==16'hFFFF) )
		start_write_image2ddr <=  avl_h2f_write.writedata;		
	else 
		start_write_image2ddr <= '0;

wire [23:0] fifo_in  = { avl_h2f_write.writedata[7:0], avl_h2f_write.address[15:0] };
wire [23:0] fifo_out;
wire empty;
wire rdreq =  !empty & ready_ov5640;		
reg  sh_rdreq;
		
always_ff @( posedge clk_sys or negedge reset_n )	
	if (~reset_n )
		sh_rdreq <= 0;
	else
		sh_rdreq <= rdreq;
fifo_avl_mm  fifo_avl_mm_inst 
(
	.wrclk   (clk_sys        ),
	.rdclk   (clk_sys        ),
	.data    (fifo_in        ),
	.rdreq   (rdreq          ),//
	.wrreq   (write_hps      ),
	.rdempty (empty          ),
	.wrfull  (               ),
	.q       (fifo_out       ),
	.rdusedw (          )
);	
assign start_ov5640   = sh_rdreq;
assign address_ov5640 = fifo_out[15:0];
assign data_ov5640    = fifo_out[23:16];

endmodule
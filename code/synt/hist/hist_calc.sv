//////////////////////////////////////////////////////
//Name File     : hist_calc                         //
//Author        : Andrey Papushin                   //
//Email         : andrey.papushin@gmail.com         //
//Standart      : IEEE 1800—2009(SystemVerilog-2009)//
//Start design  : 07.06.2018                        //
//Last revision : 29.06.2018                        //
//////////////////////////////////////////////////////
module hist_calc
(
	input wire					           clk        ,
	input wire					           reset_n    ,
    input wire                             valid_data ,                                       
	input wire [ 7: 0]   		           data_comp  ,
	input wire [ 7: 0]   		           reg_parallax_corr  ,
	input wire [ 31: 0]   		           addr_buf   ,	
	input wire					           frame_start,	
	input wire					           frame_end,

	sdram_ifc.sdram_write_master_port      f2h_sdram               	
	
);
reg [11:0] count_valid;
wire [11:0] rigth_bound = 12'd1279 - reg_parallax_corr ;
wire stop_stat = count_valid > rigth_bound;
reg [7:0] cnt_clear;
reg valid_clear;	
reg [1:0]reg_valid_clear;
reg [7:0] addr_ram_1;
reg [7:0] addr_ram_2;
reg [7:0] addr_ram_3;

reg [7:0] sh_frame_end;
reg [3:0] sh_reg_read_result_mem;
reg [1:0] sh_reg_1;
reg       sh_reg_2;
reg       sh_reg_3;
reg [2:0] reg_valid_write;
wire      valid_write  = reg_valid_write[2];
wire data_sop = valid_data & !reg_valid_write[0];
wire data_eop = !valid_data & reg_valid_write[0];
wire wren_1 = sh_reg_1[1] & valid_write & !stop_stat;
wire wren_2 = sh_reg_2    & valid_write & !stop_stat;
wire wren_3 = sh_reg_3    & valid_write & !stop_stat;
reg [21:0] sum_1;
reg [21:0] sum_2;
reg [21:0] sum_3;
reg reg_data_sop;
wire [21:0] readdata_1; 
wire [21:0] readdata_2; 
wire [21:0] readdata_3; 
reg read_result_mem;
reg clear;
reg [7:0] count_unit_burst;
wire last_unit_burst =  count_unit_burst[6:0] == 7'd127;
ram_freq_component ram_freq_component_inst_1
(
	.address (addr_ram_1 ),
	.clock   (clk  ),
	.data    (sum_1   ),
	.wren    (wren_1 |reg_valid_clear[1]),
	.q       (readdata_1)
);
ram_freq_component ram_freq_component_inst_2
(
	.address (addr_ram_2  ),
	.clock   (clk   ),
	.data    (sum_2     ),
	.wren    (wren_2  |reg_valid_clear[1]  ),
	.q       (readdata_2)
);
ram_freq_component ram_freq_component_inst_3
(
	.address (addr_ram_3),
	.clock   (clk   ),
	.data    (sum_3     ),
	.wren    (wren_3  |reg_valid_clear[1]  ),
	.q       (readdata_3)
);
reg [7:0] reg_data_comp;
reg [7:0] reg_data_comp2;
reg [21:0] reg_readdata_3;
reg count_burst;
reg [31:0] sum_result_mem_1;
reg [31:0] sum_result_mem_2;
reg [1:0] sh_read_result_mem;
reg [1:0] cnt_addr;
reg [1:0] cnt_addr2;
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		count_valid <= '0;		
	else if(data_eop)
		count_valid <= '0; 
	else if(valid_data)
		count_valid <= count_valid +1 ;
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		cnt_addr <= '0;		
	else if(cnt_addr == 2'b10)
		cnt_addr <= '0; 
	else if(valid_data)
		cnt_addr <= cnt_addr +1 ;
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		cnt_addr2 <= '0;		
	else if(sh_frame_end[5])
		cnt_addr2 <= '0; 
	else if(cnt_addr2== 2'b11)
		cnt_addr2 <= 'd1; 
	else if(sh_reg_read_result_mem[2])
		cnt_addr2 <= cnt_addr2 +1 ;
wire valid_addr_1 = valid_data & (	cnt_addr == 2'b00);	
wire valid_addr_2 = valid_data & (	cnt_addr == 2'b01);	
wire valid_addr_3 = valid_data & (	cnt_addr == 2'b10);	
wire valid_read_1 = (cnt_addr2== 2'b01) & sh_reg_read_result_mem[2];
wire valid_read_2 = (cnt_addr2== 2'b10) & sh_reg_read_result_mem[2];
wire valid_read_3 = (cnt_addr2== 2'b11) & sh_reg_read_result_mem[2];
wire done_write_hist 	=last_unit_burst & count_burst;
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		addr_ram_1 <= '0;	
	else if(sh_frame_end[7])
		addr_ram_1 <= '0;	
	else if(sh_reg_read_result_mem[1])
		addr_ram_1 <= count_unit_burst;	
	else if(valid_addr_1)
		addr_ram_1 <= data_comp;
	else if(valid_clear)
		addr_ram_1 <= cnt_clear;
		
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		addr_ram_2 <= '0;	
	else if(sh_frame_end[7])
		addr_ram_2 <= '0;	
	else if(sh_reg_read_result_mem[1])
		addr_ram_2 <= count_unit_burst;	
	else if(valid_addr_2)
		addr_ram_2 <= data_comp;
	else if(valid_clear)
		addr_ram_2 <= cnt_clear;
		
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		addr_ram_3 <= '0;
	else if(sh_frame_end[7])
		addr_ram_3 <= '0;	
	else if(sh_reg_read_result_mem[1])
		addr_ram_3 <=  count_unit_burst;	
	else if(valid_addr_3)
		addr_ram_3 <= data_comp;
	else if(valid_clear)
		addr_ram_3 <= cnt_clear;

always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		sh_read_result_mem <= '0;		
	else 
		sh_read_result_mem <= {sh_read_result_mem[0], read_result_mem};

always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		sum_result_mem_1 <= '0;		
	else 
		sum_result_mem_1 <= readdata_1 + readdata_2;

always_ff  @(posedge clk  or negedge reset_n)	
	if (~reset_n)
		sum_result_mem_2 <= '0;	
	 else if(sh_reg_read_result_mem[2])
		sum_result_mem_2 <= readdata_1 + readdata_2 +readdata_3;	
	//else if(valid_read_2)
	//	sum_result_mem_2 = readdata_2;		
	//else if(valid_read_3)
	//	sum_result_mem_2 = readdata_3;	
	//else 
	//	sum_result_mem_2 = '0;
   //
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		reg_readdata_3 <= '0;		
	else 
		reg_readdata_3 <= readdata_3;	
		
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		reg_valid_write <= '0;		
	else 
		reg_valid_write <= {reg_valid_write[1:0], valid_data};	

always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		sh_reg_1 <= '0;		
	else 
		sh_reg_1 <= {sh_reg_1[0], (reg_data_sop | wren_2)};

		
	

always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		reg_data_sop <= '0;		
	else 
		reg_data_sop <= data_sop;
		
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		sh_reg_2 <= '0;		
	else 
		sh_reg_2 <= wren_1;	
		
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		sh_reg_3 <= '0;		
	else 
		sh_reg_3 <= wren_2;	
		
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		reg_data_comp <= '0;		
	else 
		reg_data_comp <= data_comp;
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		reg_data_comp2 <= '0;		
	else 
		reg_data_comp2 <= reg_data_comp;
		
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		sum_1 <= '0;	
	else if(valid_clear)
		sum_1 <= '0;
	else 
		sum_1 <= readdata_1 + 1;
		
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		sum_2 <= '0;	
	else if(valid_clear)
		sum_2 <= '0;
	else 
		sum_2 <= readdata_2 + 1;	
		
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		sum_3 <= '0;
	else if(valid_clear)
		sum_3 <= '0;
	else 
		sum_3 <= readdata_3 + 1;	
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		sh_frame_end <= 7'd0;
	else 
		sh_frame_end <= {sh_frame_end[6:0], frame_end};

always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		read_result_mem <= 1'd0;		
	else if(done_write_hist)
		read_result_mem <= 1'd0;	
	else if(sh_frame_end[7] )
		read_result_mem <= 1'd1;

always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		sh_reg_read_result_mem <= '0;	
	else if(done_write_hist)
		sh_reg_read_result_mem <= {sh_reg_read_result_mem[3:2],2'b00};
	else 
		sh_reg_read_result_mem <= {sh_reg_read_result_mem[2:0],read_result_mem};
		
reg [4:0] reg_status;
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		reg_status <= '0;
	else 
		reg_status <= {reg_status[3:0], done_write_hist};
	
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		clear <= 1;		
	else 
		clear <=  done_write_hist;
		
wire end_clear  = cnt_clear == 'd255;
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		cnt_clear <= 0;		
	else if(valid_clear)
		cnt_clear <= cnt_clear + 1;
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		valid_clear <= 0;
	else if(end_clear)
		valid_clear <= 0;	
	else if(reg_valid_clear[0])
		valid_clear <= 1;	

always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		reg_valid_clear <= 0;
	else 
		reg_valid_clear <= {valid_clear,clear};
		
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		count_unit_burst <= '0;		
	else if(end_clear)
		count_unit_burst <= '0;	
	else if(sh_reg_read_result_mem[1])
		count_unit_burst <= count_unit_burst + 1'd1;	

reg [29:0 ] fifo_in_address;
reg valid_fifo_write;
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		valid_fifo_write <= '0;		
	else if(frame_end)
		valid_fifo_write <= 1;
	else if(end_clear)
		valid_fifo_write <= '0;		
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		fifo_in_address <= '0;		
	else if(frame_end)
		fifo_in_address <= addr_buf + 'h19000 ;		
	else if(last_unit_burst & !count_burst)
		fifo_in_address <= addr_buf + 'h19080 ;	
	else if(done_write_hist)
		fifo_in_address <= addr_buf + 'h19100 ;
		
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		count_burst <= 2'd0;		
	else if(last_unit_burst)
		count_burst <= ~count_burst;
reg read_fifo;	
reg sh_read_fifo;	
wire empty;	
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		read_fifo <= 1'd0;		
	else 
		read_fifo <= ~empty;		
always_ff @(posedge clk  or negedge reset_n)
	if (~reset_n)
		sh_read_fifo <= 1'd0;		
	else 
		sh_read_fifo <= read_fifo;	

wire [31:0] fifo_in_data = reg_status[4] ? 32'd1 : sum_result_mem_2 ;
wire [7:0] fifo_in_burstcount = reg_status[4] ? 8'd1 : 8'd128;
/* interface  avl_sdram to  */

wire fifo_in_write = reg_status[4] | sh_reg_read_result_mem[3];
//assign f2h_sdram.write      = reg_status[4] | sh_reg_read_result_mem[3];// 
//assign f2h_sdram.writedata  = reg_status[4] ? 32'd1 : sum_result_mem_2 ;
//assign f2h_sdram.address    = count_unit_burst; //
//assign f2h_sdram.byteenable = 8'HFF; 
//assign f2h_sdram.burstcount = reg_status[4] ? 8'd1 : 8'd128;		
wire [95:0] data_fifo_in = {25'd0, fifo_in_write, fifo_in_burstcount,fifo_in_address, fifo_in_data };
wire [95:0] data_fifo_out;
sdram_fifo sdram_fifo_inst 
(
	.wrclk   (clk            ),
	.rdclk   (clk            ),
	.data    (data_fifo_in   ),
	.rdreq   (!f2h_sdram.waitrequest          ),//
	.wrreq   (valid_fifo_write  ),
	.rdempty (empty          ),
	.wrfull  (           ),
	.q       (data_fifo_out  ),
	.rdusedw (          )
);	


assign f2h_sdram.write      =  data_fifo_out[70]  ;// : '0;
assign f2h_sdram.writedata 	= data_fifo_out[31:0] ;// : '0;
assign f2h_sdram.address 	= data_fifo_out[61:32];// : '0;
assign f2h_sdram.burstcount = data_fifo_out[69:62];// : '0;
assign f2h_sdram.byteenable = 8'HFF;

endmodule
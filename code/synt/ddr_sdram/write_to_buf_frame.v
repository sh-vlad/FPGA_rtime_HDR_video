//////////////////////////////////////////////////////
//Name File     : write_to_buf_frame                //
//Author        : Andrey Papushin                   //
//Email         : andrey.papushin@gmail.com         //
//Standart      : IEEE 1800—2009(SystemVerilog-2009)//
//Start design  : 03.04.2018                        //
//Last revision : 25.04.2018                        //
//////////////////////////////////////////////////////
module write_to_buf_frame
(
	input  wire  						    clk_100         	,     
	input  wire 						    reset_n         	,
	output logic                            end_frame,
	input  wire                             start_frame     	,  // импульс старта цикла синхронизатора
    input logic                             valid_data_ddr      ,
    output logic                            last_burst          ,
	input  wire         [31:0]              reg_addr_buf_1  	,  // адрес 1-го буфера в ddr память                          end_write_buf       ,
	input  wire         [63:0]              data_ddr            ,
	output wire         [95:0]              data_fifo_frame
);


reg [28:0] data_address     ; // avl_address на f=100MHz
reg [ 6:0] count_unit_burst ; // счетчик передач внутри берста
reg [13:0] count_burst      ; // счетчик берстов 
/* упаковываем в шины strbs стробы синхронизатора */
	reg  last_burst_href;
	reg [4:0] cnt;
wire last_unit_burst = (count_unit_burst == 'd31) & valid_data_ddr; // последнее переданное слово в берсте
wire  end_write_buf   = last_unit_burst & last_burst_href; // импульс на последний пиксель фрейма


assign data_fifo_frame   = {last_unit_burst, end_write_buf, valid_data_ddr, data_address, data_ddr} ;
assign end_frame = last_unit_burst  & last_burst_href & last_burst;
// дополнительное время для выгрузки данных из fifo и завершения берста
always_ff @(posedge clk_100  or negedge reset_n)
	if (~reset_n)
		last_burst <= 1'b0;
	else if( end_frame)
		last_burst <= 1'b0;	
	else if(count_burst == 'd14399)
		last_burst <= 1'b1;	
always_ff @(posedge clk_100  or negedge reset_n)
	if (~reset_n)
		last_burst_href <= 1'b0;
	else if(end_write_buf)
		last_burst_href <= 1'b0;	
	else if(cnt== 'd19)
		last_burst_href <= 1'b1;	
// счетчик загружаемых элементов берста в fifo 
always_ff @(posedge clk_100  or negedge reset_n)
	if (~reset_n)
		count_unit_burst <= 7'd0;
	else if(end_write_buf | last_unit_burst)
		count_unit_burst <= 7'd0;
	else if(valid_data_ddr)
		count_unit_burst <= count_unit_burst + 6'd1;
// счетчик записи fifo 64 элементов 
always_ff @(posedge clk_100  or negedge reset_n)
	if (~reset_n)
		count_burst <= 14'd0;
	else if(end_frame)
		count_burst <= 14'd0;
	else if(last_unit_burst & !end_frame)
		count_burst <= count_burst + 14'd1;
		
always_ff @(posedge clk_100  or negedge reset_n)
	if (~reset_n)
		cnt <= 5'd0;
	else if(end_write_buf)
		cnt <= 5'd0;
	else if(last_unit_burst )
		cnt <= cnt + 'd1;
		
		
// адрес шины авалон на f=100MHz
always_ff @(posedge clk_100  or negedge reset_n)
	if (~reset_n)
		data_address <= 29'd0;
	else if(start_frame)
		data_address <= reg_addr_buf_1[28:0];
	else if((count_unit_burst == 'd30) & valid_data_ddr)
		data_address <= data_address + 29'd32;

	
endmodule

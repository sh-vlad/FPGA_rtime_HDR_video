
module sdram_write
(
	input  wire  						    clk_100         	,   
	input  wire  						    clk_200         	,   
	input  wire 						    reset_n         	,
	input  wire                             start_frame     	,  // импульс старта цикла синхронизатора
	input  wire                             start_write_image2ddr     	,  //
	input  wire  [63:0]                     data_ddr            ,
    input  wire                             valid_data_ddr      ,
	input  wire  [31:0]                     reg_addr_buf_1  	,  // адрес 1-го буфера в ddr памяти
	input  wire  [31:0]                     reg_addr_buf_2  	,  // адрес 1-го буфера в ddr памяти
	output wire                             end_frame           ,
	output wire                             _ready_read           ,
	output wire                             ready_write           ,
	sdram_ifc.sdram_write_master_port       f2h_sdram2             // avl интерфейс к sdram 
);

wire         [95:0]     data_fifo_frame  ;

reg [1:0]running_write_ddr;
assign _ready_read = running_write_ddr[1];
wire last_burst;
// запись сырого сигнала во время работы синхронизатора
write_to_buf_frame write_to_buf_frame_inst
(
	.clk_100     		 (clk_100           ),
    .reset_n     		 (reset_n           ),
	.reg_addr_buf_1      (reg_addr_buf_1    ),
	.start_frame         (start_frame     ), 
	.valid_data_ddr      (valid_data_ddr & running_write_ddr[1]   ),
	.data_ddr            (data_ddr          ), 
	.end_frame            (end_frame          ), 
	.last_burst            (last_burst          ), 
    .data_fifo_frame     (data_fifo_frame   )  // ->
);

reg        run_read_fifo_64; // интервал чтения одного берста из fifo
reg        running_read     ; // интервал чтения из fifo 
reg [28:0] data_address     ; // avl_address на f=100MHz
reg [ 7:0] data_burstcount  ; // длина берста
reg [ 6:0] count_unit_burst ; // счетчик передач внутри берста
reg        s                ; // дополнительный сигнал
reg [95:0] reg_data_fifo_out; // регистр на выходе фифо
reg [ 7:0] max_units_in_fifo; // максимальное заполненность очереди
reg [15:0] count_full       ; // число потерянных слов
reg [7:0]  sh_reg_200MHz    ; // сдвиговый регистр на f=200MHz


wire [ 8:0] usedw              ; // текущая заполненность FiFo со стороны чтения
wire [95:0] data_fifo_out      ; // выход очереди
wire        full               ; // сигнал переполнения фифо
wire        empty              ; // очередь пуста
wire        sh_running_read    ; // задержанный на 1 такт  f=200MHz сигнал running_read
wire        sh_ready_read      ; // задержанный на 1 такт  f=200MHz сигнал ready_read   
wire        sh_rdrec           ; // задержанный на 1 такт  f=200MHz сигнал rdrec        
wire        sh3_end_read_fifo  ; // задержанный на 3 такта f=200MHz импульс end_read_fifo
wire        end_read_fifo_burst; // завершено чтение берста из фифо
wire        end_read_fifo      ; // конец чтения из фифо (сигнал записан в ddr)
/* FiFo заполнена 64 элемантами, можно начинать чтение*/ 
//wire ready_read            = (usedw >= 'd34) & !f2h_sdram2.waitrequest & !run_read_fifo_64;
wire ready_read            = data_fifo_frame[95] & !f2h_sdram2.waitrequest & !run_read_fifo_64;
wire p_ready_read          = ready_read & !sh_ready_read; // передний фронт  ready_read
wire start_read            = p_ready_read & !running_read; // импульс начала чтения из FiFo
wire start_read_burst_fifo = p_ready_read & !run_read_fifo_64; // импульс начала чтения берста из FiFo
reg ctrl_buff;
/* сигнал разрешения чтения из FiFo */
wire rdreq                 = run_read_fifo_64 & !f2h_sdram2.waitrequest & !empty;
/* импульс начала чтения из FiFo (один раз выставляется)*/
wire p_rdreq = rdreq & !sh_rdrec & !sh_running_read;

/* вход fifo: полезные данные (64 бита) + адрес(29 бит)  + 2 доп. бита*/
wire [95:0] data_fifo_in  = data_fifo_frame;
wire        data_write     =  data_fifo_in[93] ; // avl_write на f=100MHz
// интервал чтения из fifo 64 элементов
reg [1:0]reg_end;
always_ff @(posedge clk_200  or negedge reset_n)
	if (~reset_n)
		reg_end <= 2'd0;
	else if(end_read_fifo & last_burst)
		reg_end <= 2'd1;
	else if(reg_end == 2'd1)
		reg_end <= 2'd3;
// интервал чтения из fifo 64 элементов
always_ff @(posedge clk_200  or negedge reset_n)
	if (~reset_n)
		running_read <= 1'd0;
	else if(end_read_fifo)
		running_read <= 1'd0;
	else if(start_read  )
		running_read <= 1'd1;
		
always_ff @(posedge clk_200  or negedge reset_n)
	if (~reset_n)
		ctrl_buff <= 1'd0;
	else if(start_frame & running_write_ddr[1])
		ctrl_buff <= ~ctrl_buff;	
// интервал чтения из fifo 64 элементов
always_ff @(posedge clk_200  or negedge reset_n)
	if (~reset_n)
		run_read_fifo_64 <= 1'd0;
	else if(end_read_fifo_burst)
		run_read_fifo_64 <= 1'd0;
	else if(start_read_burst_fifo  )
		run_read_fifo_64 <= 1'd1;
always_ff @(posedge clk_100  or negedge reset_n)
	if (~reset_n)
		running_write_ddr <='0;
	else if(start_write_image2ddr)
		running_write_ddr <=2'b01;
		else if(running_write_ddr ==2'b01 & start_frame)
		running_write_ddr <=2'b11;
// сдвиговый регистр на f=200 MHz
always_ff @(posedge clk_200  or negedge reset_n)
	if (~reset_n)
		sh_reg_200MHz <= 8'd0;
	else             //           [6:4]            [3]        [2]      [1]           [0]
		sh_reg_200MHz <= {f2h_sdram2.write, sh_reg_200MHz[5:3], end_read_fifo, rdreq, ready_read, running_read};
// дополнительный сигнал		
always_ff @(posedge clk_200  or negedge reset_n)
	if (~reset_n)
		s <= 1'd0;
	else if(p_ready_read)
		s <= 1'd1;	
	else if( !(data_fifo_out[94] | data_fifo_out[95])) // ждем пока выходы очереди не обнулятся
		s <= 1'd0;	
// регистр после fifo
always_ff @(posedge clk_200  or negedge reset_n)
	if (~reset_n)
		reg_data_fifo_out <= 96'd0;
	else if(!f2h_sdram2.waitrequest)
		reg_data_fifo_out <=  { (data_fifo_out[93] & run_read_fifo_64 & !p_rdreq) ,data_fifo_out[92:0]};
// длина берста *
always_ff @(posedge clk_200  or negedge reset_n)
	if (~reset_n)
		data_burstcount <= 8'd0;
	else if(!f2h_sdram2.waitrequest)
		data_burstcount <= 8'd32;
		
	//reg [28:0] data_address     ; 
// fifo
sdram_fifo sdram_fifo_inst 
(
	.wrclk   (clk_100        ),
	.rdclk   (clk_200        ),
	.data    (data_fifo_in   ),
	.rdreq   (rdreq          ),//
	.wrreq   (data_write     ),
	.rdempty (empty          ),
	.wrfull  (full           ),
	.q       (data_fifo_out  ),
	.rdusedw (usedw          )
);	
wire n_write_sdram = !f2h_sdram2.write &  sh_reg_200MHz[7];
/* задержанные сигналы на f=200Mhz */
assign sh_running_read            = sh_reg_200MHz[0];
assign sh_ready_read              = sh_reg_200MHz[1];
assign sh_rdrec                   = sh_reg_200MHz[2];
assign sh3_end_read_fifo          = sh_reg_200MHz[5];                           
assign end_read_fifo              = data_fifo_out[94] & running_read & !s;
assign end_read_fifo_burst        = data_fifo_out[95] & run_read_fifo_64 & !s;

/* интерфейс avl к sdram контроллеру */
assign f2h_sdram2.write      = reg_data_fifo_out[93];// & !reg_end[1];
assign f2h_sdram2.writedata  = reg_data_fifo_out[63:0];	
assign f2h_sdram2.address    = data_address; //reg_data_fifo_out[92:64];
assign f2h_sdram2.byteenable = 8'HFF; 
assign f2h_sdram2.burstcount = data_burstcount;		

reg [5:0]count_sdram_burst;
// счетчик загружаемых элементов берста в fifo 
always_ff @(posedge clk_200  or negedge reset_n)
	if (~reset_n)
		count_sdram_burst <= 7'd0;
	else if(f2h_sdram2.write)
		count_sdram_burst <= count_sdram_burst + 6'd1;

// адрес шины авалон на f=100MHz
always_ff @(posedge clk_200  or negedge reset_n)
	if (~reset_n)
		data_address <= 29'd0;
	else if(start_frame & !ctrl_buff & !running_write_ddr[1])
		data_address <= reg_addr_buf_1[28:0];
	else if(start_frame & !ctrl_buff & running_write_ddr[1])
		data_address <= reg_addr_buf_2[28:0];
	else if(start_frame & ctrl_buff & running_write_ddr[1])
		data_address <= reg_addr_buf_1[28:0];
	else if(n_write_sdram)
		data_address <= data_address + 29'd32;

endmodule
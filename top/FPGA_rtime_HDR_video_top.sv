//Author: ShVlad / e-mail: shvladspb@gmail.com
//

`timescale 1 ns / 1 ns
module FPGA_rtime_HDR_video_top
(
//clocks
	input wire  				clk50      ,             
	input wire					clk_cam_0_i,
	input wire					clk_cam_1_i,	
	output wire					clk_cam_0_o,
	output wire					clk_cam_1_o,	
//camera 1 ports
	input wire         			VSYNC_0    ,
	input wire         			HREF_0     ,
	input wire [7:0]   			cam_0_data ,
	output wire                 PWDN_0     , 
	output reg                 	RESETB_0   , 
	output wire                 SIOC_0     , 
	inout  wire                 SIOD_0     , 	
//camera 2 ports
	input wire         			VSYNC_1    ,
	input wire         			HREF_1     ,
	input wire [7:0]   			cam_1_data ,
	output wire                 PWDN_1     , 
	output wire                 RESETB_1   , 
	output wire                 SIOC_1     , 
	inout  wire                 SIOD_1     , 
	
	input wire [3:0]			switches,
//HDMI
	output wire					data_enable,
	output wire					hsync,
	output wire					vsync,
	output wire		[23: 0]		data_HDMI,
	output wire					pixel_clk_out,
	
	input wire              	HDMI_TX_INT,	
    inout wire              	HDMI_I2C_SCL,
    inout wire              	HDMI_I2C_SDA,
	
	output wire        hps_io_hps_io_emac1_inst_TX_CLK   , 
	output wire        hps_io_hps_io_emac1_inst_TXD0     ,
	output wire        hps_io_hps_io_emac1_inst_TXD1     ,
	output wire        hps_io_hps_io_emac1_inst_TXD2     ,
	output wire        hps_io_hps_io_emac1_inst_TXD3     ,
	input  wire        hps_io_hps_io_emac1_inst_RXD0     ,
	inout  wire        hps_io_hps_io_emac1_inst_MDIO     ,
	output wire        hps_io_hps_io_emac1_inst_MDC      ,
	input  wire        hps_io_hps_io_emac1_inst_RX_CTL   ,
	output wire        hps_io_hps_io_emac1_inst_TX_CTL   ,
	input  wire        hps_io_hps_io_emac1_inst_RX_CLK   ,
	input  wire        hps_io_hps_io_emac1_inst_RXD1     ,
	input  wire        hps_io_hps_io_emac1_inst_RXD2     ,
	input  wire        hps_io_hps_io_emac1_inst_RXD3     ,
	inout  wire        hps_io_hps_io_sdio_inst_CMD       ,
	inout  wire        hps_io_hps_io_sdio_inst_D0        ,
	inout  wire        hps_io_hps_io_sdio_inst_D1        ,
	output wire        hps_io_hps_io_sdio_inst_CLK       ,
	inout  wire        hps_io_hps_io_sdio_inst_D2        ,
	inout  wire        hps_io_hps_io_sdio_inst_D3        ,
	inout  wire        hps_io_hps_io_usb1_inst_D0        ,
	inout  wire        hps_io_hps_io_usb1_inst_D1        ,
	inout  wire        hps_io_hps_io_usb1_inst_D2        ,
	inout  wire        hps_io_hps_io_usb1_inst_D3        ,
	inout  wire        hps_io_hps_io_usb1_inst_D4        ,
	inout  wire        hps_io_hps_io_usb1_inst_D5        ,
	inout  wire        hps_io_hps_io_usb1_inst_D6        ,
	inout  wire        hps_io_hps_io_usb1_inst_D7        ,
	input  wire        hps_io_hps_io_usb1_inst_CLK       ,
	output wire        hps_io_hps_io_usb1_inst_STP       ,
	input  wire        hps_io_hps_io_usb1_inst_DIR       ,
	input  wire        hps_io_hps_io_usb1_inst_NXT       ,
	output wire        hps_io_hps_io_spim1_inst_CLK      ,
	output wire        hps_io_hps_io_spim1_inst_MOSI     ,
	input  wire        hps_io_hps_io_spim1_inst_MISO     ,
	output wire        hps_io_hps_io_spim1_inst_SS0      ,
	input  wire        hps_io_hps_io_uart0_inst_RX       ,
	output wire        hps_io_hps_io_uart0_inst_TX       ,
	inout  wire        hps_io_hps_io_i2c0_inst_SDA       ,
	inout  wire        hps_io_hps_io_i2c0_inst_SCL       ,
	inout  wire        hps_io_hps_io_i2c1_inst_SDA       ,
	inout  wire        hps_io_hps_io_i2c1_inst_SCL       ,
	output wire [14:0] memory_mem_a                   ,                  
	output wire [2:0]  memory_mem_ba                  ,                 
	output wire        memory_mem_ck                  ,                 
	output wire        memory_mem_ck_n                ,               
	output wire        memory_mem_cke                 ,                
	output wire        memory_mem_cs_n                ,               
	output wire        memory_mem_ras_n               ,              
	output wire        memory_mem_cas_n               ,              
	output wire        memory_mem_we_n                ,               
	output wire        memory_mem_reset_n             ,            
	inout  wire [31:0] memory_mem_dq                  ,                 
	inout  wire [3:0]  memory_mem_dqs                 ,                
	inout  wire [3:0]  memory_mem_dqs_n               ,              
	output wire        memory_mem_odt                 ,                
	output wire [3:0]  memory_mem_dm                  ,                 
	input  wire        memory_oct_rzqin  
);
`ifdef DEBUG_OFF
avl_ifc        #(    16,    32,      4)      avl_h2f_dsp()  ; 
sdram_ifc      #(   29,    64,      8)      f2h_sdram0()   ; 
sdram_ifc      #(   30,    32,      4)      f2h_sdram1()   ; 
`else
`endif
wire				sys_clk;
wire				sys_clk_b;
wire	[ 1: 0]		pll_lock;
wire				pixel_clk;	
wire				reset_n_b;
//
reg 	[ 3: 0]		switches_resync[2:0];
reg		[ 1: 0]		sh_VSYNC;
//
wire	[ 7: 0]		raw_data_0;
wire	[ 7: 0]		raw_data_1;
wire				raw_data_valid;
wire				raw_data_sop;
wire				raw_data_eop;
//
wire				HDR_valid;			
wire	[ 9: 0]		HDR_data;			
wire				HDR_sop;			
wire				HDR_eop;	
//
logic	[ 9: 0]		raw2rgb_data;
logic				raw2rgb_valid;
logic				raw2rgb_sop;
logic				raw2rgb_eop;
//
wire 	[ 9: 0]		r_data;
wire 	[ 9: 0]		g_data;
wire 	[ 9: 0]		b_data;
wire 				data_rgb_valid;
wire 				sop_rgb		  ;
wire 				eop_rgb	      ;

//
/*wire 	[ 7: 0]		r_tm;
wire 	[ 7: 0]		g_tm;
wire 	[ 7: 0]		b_tm;*/
wire 	[ 7: 0]		rgb_tm[3];
wire 				data_tm_valid;
wire 				sop_tm		  ;
wire 				eop_tm	      ;
//
reg 	[ 7: 0]		r_fb;
reg 	[ 7: 0]		g_fb;
reg 	[ 7: 0]		b_fb;
reg 				data_fb_valid;
reg 				sop_fb		  ;
reg 				eop_fb	      ;
//

wire                start_ov5640;
wire     [15:0]     address_ov5640;
wire      [7:0]     data_ov5640;
wire                ready_ov5640;
wire                start_write_image2ddr;
wire                SIOD_o;
wire                SIOC_o;
wire [31:0]         reg_addr_buf_1;





`ifdef DEBUG_OFF
de10_nan0_hdr de10_nan0_hdr_inst
(
	.avl_h2f_dsp_write                  (avl_h2f_dsp.write           ),
	.avl_h2f_dsp_chipselect             (avl_h2f_dsp.chipselect      ),
	.avl_h2f_dsp_address                (avl_h2f_dsp.address         ),
	.avl_h2f_dsp_byteenable             (avl_h2f_dsp.byteenable      ),
	.avl_h2f_dsp_readdata               (avl_h2f_dsp.readdata        ),
	.avl_h2f_dsp_writedata              (avl_h2f_dsp.writedata       ),
	.f2h_sdram0_address                 ( f2h_sdram0.address         ),
	.f2h_sdram0_burstcount              ( f2h_sdram0.burstcount      ),
	.f2h_sdram0_waitrequest             ( f2h_sdram0.waitrequest     ),
	.f2h_sdram0_writedata               ( f2h_sdram0.writedata       ),
	.f2h_sdram0_byteenable              ( f2h_sdram0.byteenable      ),
	.f2h_sdram0_write                   ( 1'b0                       ),
	.f2h_sdram1_address                 ( f2h_sdram1.address         ),
	.f2h_sdram1_burstcount              ( f2h_sdram1.burstcount      ),
	.f2h_sdram1_waitrequest             ( f2h_sdram1.waitrequest     ),
	.f2h_sdram1_readdata                ( f2h_sdram1.readdata        ),
	.f2h_sdram1_readdatavalid           ( f2h_sdram1.readdatavalid   ),
	.f2h_sdram1_read                    ( f2h_sdram1.read            ),
	.clk_clk                            (clk50                          ),
	.clk_0_clk                          (sys_clk_b                          ),
	.reset_in_reset_n                   (reset_n                          ),
	.h2f_reset_out_reset_n              (reset_n                            ),
	.hps_io_hps_io_emac1_inst_TX_CLK  (  hps_io_hps_io_emac1_inst_TX_CLK  ),
	.hps_io_hps_io_emac1_inst_TXD0    (  hps_io_hps_io_emac1_inst_TXD0    ),
	.hps_io_hps_io_emac1_inst_TXD1    (  hps_io_hps_io_emac1_inst_TXD1    ),
	.hps_io_hps_io_emac1_inst_TXD2    (  hps_io_hps_io_emac1_inst_TXD2    ),
	.hps_io_hps_io_emac1_inst_TXD3    (  hps_io_hps_io_emac1_inst_TXD3    ),
	.hps_io_hps_io_emac1_inst_RXD0    (  hps_io_hps_io_emac1_inst_RXD0    ),
	.hps_io_hps_io_emac1_inst_MDIO    (  hps_io_hps_io_emac1_inst_MDIO    ),
	.hps_io_hps_io_emac1_inst_MDC     (  hps_io_hps_io_emac1_inst_MDC     ),
	.hps_io_hps_io_emac1_inst_RX_CTL  (  hps_io_hps_io_emac1_inst_RX_CTL  ),
	.hps_io_hps_io_emac1_inst_TX_CTL  (  hps_io_hps_io_emac1_inst_TX_CTL  ),
	.hps_io_hps_io_emac1_inst_RX_CLK  (  hps_io_hps_io_emac1_inst_RX_CLK  ),
	.hps_io_hps_io_emac1_inst_RXD1    (  hps_io_hps_io_emac1_inst_RXD1    ),
	.hps_io_hps_io_emac1_inst_RXD2    (  hps_io_hps_io_emac1_inst_RXD2    ),
	.hps_io_hps_io_emac1_inst_RXD3    (  hps_io_hps_io_emac1_inst_RXD3    ),
	.hps_io_hps_io_sdio_inst_CMD      (  hps_io_hps_io_sdio_inst_CMD      ),
	.hps_io_hps_io_sdio_inst_D0       (  hps_io_hps_io_sdio_inst_D0       ),
	.hps_io_hps_io_sdio_inst_D1       (  hps_io_hps_io_sdio_inst_D1       ),
	.hps_io_hps_io_sdio_inst_CLK      (  hps_io_hps_io_sdio_inst_CLK      ),
	.hps_io_hps_io_sdio_inst_D2       (  hps_io_hps_io_sdio_inst_D2       ),
	.hps_io_hps_io_sdio_inst_D3       (  hps_io_hps_io_sdio_inst_D3       ),
	.hps_io_hps_io_usb1_inst_D0       (  hps_io_hps_io_usb1_inst_D0       ),
	.hps_io_hps_io_usb1_inst_D1       (  hps_io_hps_io_usb1_inst_D1       ),
	.hps_io_hps_io_usb1_inst_D2       (  hps_io_hps_io_usb1_inst_D2       ),
	.hps_io_hps_io_usb1_inst_D3       (  hps_io_hps_io_usb1_inst_D3       ),
	.hps_io_hps_io_usb1_inst_D4       (  hps_io_hps_io_usb1_inst_D4       ),
	.hps_io_hps_io_usb1_inst_D5       (  hps_io_hps_io_usb1_inst_D5       ),
	.hps_io_hps_io_usb1_inst_D6       (  hps_io_hps_io_usb1_inst_D6       ),
	.hps_io_hps_io_usb1_inst_D7       (  hps_io_hps_io_usb1_inst_D7       ),
	.hps_io_hps_io_usb1_inst_CLK      (  hps_io_hps_io_usb1_inst_CLK      ),
	.hps_io_hps_io_usb1_inst_STP      (  hps_io_hps_io_usb1_inst_STP      ),
	.hps_io_hps_io_usb1_inst_DIR      (  hps_io_hps_io_usb1_inst_DIR      ),
	.hps_io_hps_io_usb1_inst_NXT      (  hps_io_hps_io_usb1_inst_NXT      ),
	.hps_io_hps_io_spim1_inst_CLK     (  hps_io_hps_io_spim1_inst_CLK     ),
	.hps_io_hps_io_spim1_inst_MOSI    (  hps_io_hps_io_spim1_inst_MOSI    ),
	.hps_io_hps_io_spim1_inst_MISO    (  hps_io_hps_io_spim1_inst_MISO    ),
	.hps_io_hps_io_spim1_inst_SS0     (  hps_io_hps_io_spim1_inst_SS0     ),
	.hps_io_hps_io_uart0_inst_RX      (  hps_io_hps_io_uart0_inst_RX      ),
	.hps_io_hps_io_uart0_inst_TX      (  hps_io_hps_io_uart0_inst_TX      ),
	.hps_io_hps_io_i2c0_inst_SDA      (  hps_io_hps_io_i2c0_inst_SDA      ),
	.hps_io_hps_io_i2c0_inst_SCL      (  hps_io_hps_io_i2c0_inst_SCL      ),
	.hps_io_hps_io_i2c1_inst_SDA      (  hps_io_hps_io_i2c1_inst_SDA      ),
	.hps_io_hps_io_i2c1_inst_SCL      (  hps_io_hps_io_i2c1_inst_SCL      ),
	.memory_mem_a                       (memory_mem_a                     ),
	.memory_mem_ba                      (memory_mem_ba                    ),
	.memory_mem_ck                      (memory_mem_ck                    ),
	.memory_mem_ck_n                    (memory_mem_ck_n                  ),
	.memory_mem_cke                     (memory_mem_cke                   ),
	.memory_mem_cs_n                    (memory_mem_cs_n                  ),
	.memory_mem_ras_n                   (memory_mem_ras_n                 ),
	.memory_mem_cas_n                   (memory_mem_cas_n                 ),
	.memory_mem_we_n                    (memory_mem_we_n                  ),
	.memory_mem_reset_n                 (memory_mem_reset_n               ),
	.memory_mem_dq                      (memory_mem_dq                    ),
	.memory_mem_dqs                     (memory_mem_dqs                   ),
	.memory_mem_dqs_n                   (memory_mem_dqs_n                 ),
	.memory_mem_odt                     (memory_mem_odt                   ),
	.memory_mem_dm                      (memory_mem_dm                    ),
	.memory_oct_rzqin                   (memory_oct_rzqin                 )
);
`else
`endif	
pll_0 pll_0_inst
(
	.refclk   		( clk50			),
	.rst      		( 1'h0			),
	.outclk_0 		( pixel_clk		),		//74.25MHz
	.locked   		( pll_lock[0]	)
);

pll_1 pll_1_inst
(
	.refclk   		( clk50			),		//50MHz
	.rst      		( 1'h0			),
	.outclk_0 		( sys_clk		),		//100MHz
	.outclk_1 		( clk_cam_0_o	),		//24MHz
	.locked   		( pll_lock[1]	)
);

assign pixel_clk_out = pixel_clk;
assign clk_cam_1_o = clk_cam_0_o;

`ifdef GLOBAL_BUFFERS
	GLOBAL global_sys_clk_inst
		(
			.in			( sys_clk	), 
			.out		( sys_clk_b	)
		);

	GLOBAL GLOBAL_rst_inst
		(
			.in			( pll_lock[1] & pll_lock[0]	), 
			.out		( reset_n_b					)
		);
`else
	assign sys_clk_b = sys_clk;
	assign reset_n_b = pll_lock[1] & pll_lock[0];
`endif

//
always @( posedge sys_clk_b )
	sh_VSYNC <= {sh_VSYNC[0], VSYNC_0};	
always @( posedge sys_clk_b )
		begin
	//		switches_resync[1:0] <= {switches_resync[0],switches};
			switches_resync[0] <= switches;
			switches_resync[1] <= switches_resync[0];
			if ( sh_VSYNC[1] )
				switches_resync[2] <= switches_resync[1];
		end
wire start_frame;	
wire valid_data_ddr;	
wire [63:0] data_ddr;
//resync cam clk to sys clk
convert2avl_stream_raw convert2avl_stream_raw_inst
(
	.pclk_1   	       	( clk_cam_0_i	),
	.pclk_2   	       	( clk_cam_1_i	),
	.clk_sys	       	( sys_clk_b		),
	.reset_n	       	( reset_n_b		),
	.VSYNC_1  	       	( VSYNC_0		),
	.VSYNC_2  	       	( VSYNC_1		),
	.HREF_1   	       	( HREF_0     	),
	.HREF_2   	       	( HREF_1     	),
	.D1     	       	( cam_0_data	),
	.D2     	       	( cam_1_data	),	                               
	.RAW_1           	( raw_data_0	),
	.RAW_2           	( raw_data_1	),
	.valid_RAW_1     	( raw_data_valid),                                       
	.valid_RAW_2     	(),                                       
	.SOF    	       	( raw_data_sop	),
	.EOF    	       	( raw_data_eop	),
	.start_frame     	(start_frame),
	.data_ddr        	(data_ddr),
    .valid_data_ddr	    (valid_data_ddr)
	
);
reg [14:0] cnt_clk24;
wire stop = cnt_clk24 == 'd2500;
reg running;
reg sh_reset_n;
wire p_reset_n = reset_n_b & !sh_reset_n;
always @(posedge clk_cam_0_o, negedge reset_n_b)
	if (~reset_n_b) 
		sh_reset_n <='0;
	else 
		sh_reset_n <= 1;
always @(posedge clk_cam_0_o, negedge reset_n_b)
	if (~reset_n_b) 
		running <='0;
	else if(stop)
		running <= '0;
	else if(p_reset_n)
		running <= 1;
always @(posedge clk_cam_0_o, negedge reset_n_b)
	if (~reset_n_b) 
		cnt_clk24 <='0;
	else if(running)
		cnt_clk24 <= cnt_clk24+1;
		
always @(posedge clk_cam_0_o, negedge reset_n_b)
	if (~reset_n_b) 
		RESETB_0 <='0;
	else if(stop)
		RESETB_0 <= 1;
assign 	RESETB_1 =RESETB_0;
assign PWDN_0      = !reset_n_b;
assign PWDN_1      = !reset_n_b;
`ifdef DEBUG_OFF
SCCB_interface SCCB_interface_inst
(
	.clk               (sys_clk_b             ),
	.start             (start_ov5640                ), // <-
	.address           (address_ov5640              ), // <-
	.data              (data_ov5640                 ), // <-
	.ready             (ready_ov5640                ), // ->
	.SIOC_oe           (SIOC_o                     ), // ->
	.SIOD_oe           (SIOD_o                     ) // ->
);

hps_register_ov5640 hps_register_ov5640_inst
(
	.clk_sys               (sys_clk_b                   ),
	.reset_n               (reset_n_b                   ),
	.ready_ov5640          (ready_ov5640                ), // <-
	.start_ov5640          (start_ov5640                ), // ->
	.address_ov5640        (address_ov5640              ), // ->
	.data_ov5640           (data_ov5640                 ), // ->
	.reg_addr_buf_1        (reg_addr_buf_1              ), // ->
	.reg_addr_buf_2        (reg_addr_buf_2              ), // ->
	.start_write_image2ddr (start_write_image2ddr       ), // ->
	.avl_h2f_write     (avl_h2f_dsp.avl_write_slave_port) // <-

);
sdram_write sdram_write_inst
(	
	.clk_100            ( sys_clk_b),
    .clk_200            (sys_clk_b),
    .reset_n            (reset_n_b),
    .start_frame        (start_frame   ),
    .start_write_image2ddr(start_write_image2ddr   ),
    .data_ddr           (data_ddr      ),
    .valid_data_ddr     (valid_data_ddr),
    .reg_addr_buf_1     (reg_addr_buf_1),
    .f2h_sdram2         (f2h_sdram0.sdram_write_master_port)

);
`else
`endif
 assign SIOC_0  =SIOC_o ? 1'b0 : 1'bz;
 assign SIOD_0  =SIOD_o ? 1'b0 : 1'bz;
 
 assign SIOC_1  =SIOC_o ? 1'b0 : 1'bz;
 assign SIOD_1  =SIOD_o ? 1'b0 : 1'bz;
 
 //===========================================//
 //===========================================//
 //===========================================//
 //===========================================//
 //===========================================//
 //===========================================//
 //===========================================//
//hdr for raw data
wrp_HDR_algorithm
#(
	.DATA_WIDTH ( 8	)
)
wrp_HDR_algorithm_inst					
(
	.clk							( sys_clk_b			), 	  
	
	.asi_snk_0_valid_i	            ( raw_data_valid	),
	.asi_snk_0_data_i               ( raw_data_0		),
	.asi_snk_0_startofpacket_i      ( raw_data_sop		),
	.asi_snk_0_endofpacket_i        ( raw_data_eop 		),
	.asi_snk_1_data_i               ( raw_data_1		),
	                             
	.aso_src_valid_o                ( HDR_valid			),
	.aso_src_data_o                 ( HDR_data			),
	.aso_src_startofpacket_o        ( HDR_sop			),
	.aso_src_endofpacket_o          ( HDR_eop			)
);

//mode mux
always @( posedge sys_clk_b )
	casex ( switches_resync[2]/*switches*/ )
		4'b??01:begin					// cam №0
					raw2rgb_data	<= raw_data_0;
					raw2rgb_valid   <= raw_data_valid;
					raw2rgb_sop     <= raw_data_sop;
					raw2rgb_eop     <= raw_data_eop;
				end
		4'b??10:begin					// cam №1
					raw2rgb_data	<= raw_data_1;
					raw2rgb_valid   <= raw_data_valid;
					raw2rgb_sop     <= raw_data_sop;
					raw2rgb_eop		<= raw_data_eop;
				end
		4'b??11:begin					// HDR
					raw2rgb_data	<= HDR_data;
					raw2rgb_valid   <= HDR_valid;
					raw2rgb_sop     <= HDR_sop;
					raw2rgb_eop		<= HDR_eop;
				end	
		default:
				begin					// cam №0
					raw2rgb_data	<= raw_data_0;
					raw2rgb_valid   <= raw_data_valid;
					raw2rgb_sop     <= raw_data_sop;
					raw2rgb_eop		<= raw_data_eop;
				end
	endcase

//convert raw to rgb
raw2rgb_bilinear_interp 
#(
	.DATA_WIDTH		( 10	)
)
raw2rgb_bilinear_interp_inst
(
	.clk			( sys_clk_b			),
	.reset_n        ( reset_n_b			),
	.raw_data       ( raw2rgb_data		),
	.raw_valid      ( raw2rgb_valid		),
	.raw_sop	    ( raw2rgb_sop		),
	.raw_eop	    ( raw2rgb_eop		),
	.r_data_o       ( r_data			),
	.g_data_o       ( g_data			),
	.b_data_o       ( b_data			),
	.data_o_valid   ( data_rgb_valid	),
	.sop_o	        ( sop_rgb		  	),
	.eop_o	        ( eop_rgb	      	)
);

//tone mapping
wire [9:0] rgb_arr[3]; 
assign rgb_arr[2] = r_data;
assign rgb_arr[1] = g_data;
assign rgb_arr[0] = b_data;
wrp_tone_mapping
#(
    .W		( 10		)
)
wrp_tone_mapping_inst
(
	.clk		( sys_clk_b					),
	.reset_n    ( reset_n_b					),
    .sop        ( sop_rgb					),
	.eop        ( eop_rgb					),
	.valid      ( data_rgb_valid			),
	.data       ( rgb_arr/*{r_data, g_data, b_data }*/	),
	.data_o		( rgb_tm					),
    .sop_o		( sop_tm					),
	.eop_o      ( eop_tm					),
	.valid_o	( data_tm_valid				)	
);

always @( posedge sys_clk_b )
	begin
		casex ( switches_resync[2]/**/ )
			4'b?001:begin
						r_fb			<= r_data[7:0]	;			
						g_fb			<= g_data[7:0]	;
						b_fb			<= b_data[7:0]	;
						data_fb_valid	<= data_rgb_valid;
						sop_fb		  	<= sop_rgb		;
						eop_fb	      	<= eop_rgb	    ;				
					end	
			4'b?010:begin
						r_fb			<= r_data[7:0]	;			
						g_fb			<= g_data[7:0]	;
						b_fb			<= b_data[7:0]	;
						data_fb_valid	<= data_rgb_valid;
						sop_fb		  	<= sop_rgb		;
						eop_fb	      	<= eop_rgb	    ;			
					end	
			4'b?011:begin
						r_fb			<= r_data[8:1]	;			
						g_fb			<= g_data[8:1]	;
						b_fb			<= b_data[8:1]	;
						data_fb_valid	<= data_rgb_valid;
						sop_fb		  	<= sop_rgb		 ;
						eop_fb	      	<= eop_rgb	     ;			
					end
			4'b?111:begin
						r_fb			<= rgb_tm[2];			
						g_fb			<= rgb_tm[1];
						b_fb			<= rgb_tm[0];
						data_fb_valid	<= data_tm_valid;
						sop_fb		  	<= eop_tm		;
						eop_fb	      	<= sop_tm		;			
					end
			default:begin
						r_fb			<= r_data[7:0]	;			
						g_fb			<= g_data[7:0]	;
						b_fb			<= b_data[7:0]	;
						data_fb_valid	<= data_rgb_valid;
						sop_fb		  	<= sop_rgb		;
						eop_fb	      	<= eop_rgb	    ;				
					end
		endcase
	end
//instans frame buffer here ->

// 	

//instans frame buffer here ->
wire [7:0] r_data_ddr;
wire [7:0] g_data_ddr;
wire [7:0] b_data_ddr;
wire data_rgb_valid_ddr;
wire read_data_ddr;
wire frame_buffer_ready;
// 	
read_data_ddr read_data_ddr_inst
(
	.clk_100        (sys_clk_b                        ),    
	.reset_b        (reset_n_b                        ),
	.line_request   (line_request                     ),
	.start_read_image_from_ddr   (start_write_image2ddr                     ),
	.frame_buffer_ready (frame_buffer_ready),
	.r_data         (r_data_ddr                       ),
	.g_data         (g_data_ddr                       ),
	.b_data         (b_data_ddr                       ),
	.valid_rgb      (data_rgb_valid_ddr                   ),
	.addr_read_ddr  ('hFC40000                   ),
	.f2h_sdram      (f2h_sdram1.sdram_read_master_port)
);
HDMI_tx
#(
	.DATA_WIDTH					( 24						)
)
HDMI_tx_inst
(
	.clk						( sys_clk_b					),						
	.pixel_clk                  ( pixel_clk					),
	.reset_n	                ( reset_n_b					),
	.asi_snk_valid_i            ( data_rgb_valid_ddr				),
	.line_request_o             ( line_request				),
	.frame_buffer_ready			( frame_buffer_ready		),
	.asi_snk_data_i             ( {b_data_ddr, g_data_ddr, r_data_ddr} 		),
	.asi_snk_startofpacket_i    ( sop_fb					),
	.asi_snk_endofpacket_i	    ( eop_fb					),
	.data_enable                ( data_enable				),
	.hsync                      ( hsync						),
	.vsync                      ( vsync						),
	.data_r                     ( data_HDMI[23:16]			),
	.data_g                     ( data_HDMI[15: 8]			),
	.data_b                     ( data_HDMI[ 7: 0]			)
	
);

//HDMI I2C
I2C_HDMI_Config u_I2C_HDMI_Config 
(
	.iCLK			( clk50				),
	.iRST_N			( reset_n_b			),
	.I2C_SCLK		( HDMI_I2C_SCL		),
	.I2C_SDAT		( HDMI_I2C_SDA		),
	.HDMI_TX_INT	( HDMI_TX_INT		),
	.READY			( )
);

//assign data_HDMI = { data_Cb_Cr, data_Y, 8'h0 };

`ifdef DEBUG_OFF
`else

int sensor;
initial
	begin
		sensor = $fopen("sensor.txt","w");
		forever @( posedge clk_cam_0_i )
			begin
				if (HREF_0)
					begin
						$fwrite (sensor,cam_0_data,"\n");
					end				
			end   	
	end

int raw;
initial
	begin
		raw  = $fopen("raw.txt","w");
		forever @( posedge sys_clk_b )
			begin
				if (raw2rgb_valid)
					begin
						$fwrite (raw,raw2rgb_data,"\n");
					end				
			end   	
	end

int r,g,b;
initial
	begin
		r  = $fopen("r.txt","w");
		g  = $fopen("g.txt","w");
		b  = $fopen("b.txt","w");
		forever @( posedge sys_clk_b )
			begin
				if (data_rgb_valid)
					begin
						$fwrite (r,r_data,"\n");
						$fwrite (g,g_data,"\n");
						$fwrite (b,b_data,"\n");
					end				
			end   	
	end
	
int r__tm,g__tm,b__tm;
initial
	begin
		r__tm  = $fopen("r__tm.txt","w");
		g__tm  = $fopen("g__tm.txt","w");
		b__tm  = $fopen("b__tm.txt","w");
		forever @( posedge sys_clk_b )
			begin
				if (data_tm_valid)
					begin
						$fwrite (r__tm,rgb_tm[2],"\n");
						$fwrite (g__tm,rgb_tm[1],"\n");
						$fwrite (b__tm,rgb_tm[0],"\n");
					end				
			end   	
	end	
	
int rb_fb,gb_fb,bb_fb;
initial
	begin
		rb_fb  = $fopen("rb_fb.txt","w");
		gb_fb  = $fopen("gb_fb.txt","w");
		bb_fb  = $fopen("bb_fb.txt","w");
		forever @( posedge sys_clk_b )
			begin
				if (data_fb_valid)
					begin
						$fwrite (rb_fb,r_fb,"\n");
						$fwrite (gb_fb,g_fb,"\n");
						$fwrite (bb_fb,b_fb,"\n");
					end				
			end   	
	end	
`endif	
endmodule

////////////////////////////////////////////////////////////////////////////
//Name File     : FPGA_rtime_HDR_video_top                                //
//Author_1      : ShVlad            / e-mail: shvladspb@gmail.com         //             
//Author_2      : Andrey Papushin   / e-mail: andrey.papushin@gmail.com   //               
//Standart      : IEEE 1800-2009(SystemVerilog-2009)                      //
//Start design  : 01.03.2018                                              //
//Last revision : 30.06.2018                                              //
////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 1 ns
module FPGA_rtime_HDR_video_top
(
//clocks
	input wire  				clk50        	,             
	input wire					clk_cam_0_i  	,
	input wire					clk_cam_1_i  	,	
	output wire					clk_cam_0_o  	,
	output wire					clk_cam_1_o  	,	
//camera 0 ports                             	
	input wire         			VSYNC_0      	,
	input wire         			HREF_0       	,
	input wire [7:0]   			cam_0_data   	,
	output wire                 PWDN_0       	, 
	output reg                 	RESETB_0     	, 
	output wire                 SIOC_0       	, 
	inout  wire                 SIOD_0       	, 	
//camera 1 ports                             	
	input wire         			VSYNC_1      	,
	input wire         			HREF_1       	,
	input wire [7:0]   			cam_1_data   	,
	output wire                 PWDN_1       	, 
	output wire                 RESETB_1     	, 
	output wire                 SIOC_1       	, 
	inout  wire                 SIOD_1       	, 
//HDMI	
	output wire					data_enable  	,
	output wire					hsync        	,
	output wire					vsync        	,
	output wire		[23: 0]		data_HDMI    	,
	output wire					pixel_clk_out	,
		
	input wire              	HDMI_TX_INT  	,	
    inout wire              	HDMI_I2C_SCL 	,
    inout wire              	HDMI_I2C_SDA 	,
// ddr3		
	ddr3_ifc.ddr3_port          ddr3_mem     	, 
// hps_io	
	hps_ifc.hps_io_port         hps_io       	   
	
);

avl_ifc        #(    16,    32,     4)     avl_h2f_dsp()           ; 
avl_ifc        #(     8,     8,     1)     mem_gamma_0()           ; 
avl_ifc        #(     8,     8,     1)     mem_gamma_1()           ; 
sdram_ifc      #(   29,    64,      8)     f2h_sdram_write()       ; 
sdram_ifc      #(   30,    32,      4)     f2h_sdram_read()        ; 
sdram_ifc      #(   30,    32,      4)     f2h_sdram_write_freq()  ; 

// Camera 0 rgb output interface
wire [7:0]   r_data_0			    ; 
wire [7:0]   g_data_0			    ;
wire [7:0]   b_data_0			    ;
wire         data_rgb_valid_0	    ;
wire         sop_rgb_0		  	    ;
wire         eop_rgb_0	      	    ;
// Camera 1 rgb output interface                             
wire [7:0]   r_data_1			    ;
wire [7:0]   g_data_1			    ;
wire [7:0]   b_data_1			    ;
wire         data_rgb_valid_1	    ;
wire         sop_rgb_1		  	    ;
wire         eop_rgb_1	            ;
// input data for gamma_correction 
wire [7:0]   raw_data_0             ;
wire [7:0]	 raw_data_1             ;
wire		 raw_data_valid         ;
wire		 raw_data_sop           ;
wire		 raw_data_eop           ;  
// input data fot raw2rgb_bilinear_interp 
wire [7:0]   gamma_data_0             ;
wire [7:0]	 gamma_data_1             ;
wire		 gamma_data_valid         ;
wire		 gamma_data_sop           ;
wire		 gamma_data_eop           ;  
// HDR output interface             
wire [9:0]   r_hdr		            ;               
wire [9:0]   g_hdr		            ; 
wire [9:0]   b_hdr		            ; 
wire         data_valid_hdr         ;
wire         sop_hdr		        ; 
wire         eop_hdr	            ; 
// HDR + tone mapping output interface
wire [7:0]   r_tm		            ; 
wire [7:0]   g_tm		            ; 
wire [7:0]   b_tm		            ; 
wire         data_valid_tm          ;  
wire         sop_tm		            ; 
wire         eop_tm                 ;
// input video interface for framebuffer
wire [7:0]	 r_fb                   ;
wire [7:0]	 g_fb                   ;
wire [7:0]	 b_fb                   ;
wire 		 data_fb_valid          ;
wire 		 sop_fb		            ;
wire 		 eop_fb	                ;
                                    
wire [7:0]	 prx_fxd_raw_data_0     ;
wire [7:0]	 prx_fxd_raw_data_1     ;
wire		 prx_fxd_raw_data_valid ;
wire		 prx_fxd_raw_data_sop   ;
wire		 prx_fxd_raw_data_eop   ;
// output conv filter befor framebuffer
wire [7:0]   r_filter               ;
wire [7:0]   g_filter               ;
wire [7:0]   b_filter               ;
wire         filter_valid           ;
                                    
wire [7:0]   r_data_read_ddr        ;
wire [7:0]   g_data_read_ddr        ;
wire [7:0]   b_data_read_ddr        ;
wire         data_rgb_read_valid_ddr;     

wire		 sys_clk                ; 
wire	     sys_clk_b              ;
wire [1:0]	 pll_lock               ;
wire	     reset_n_b              ;   
// HDMI_tx   
wire	     pixel_clk	            ;
wire [23:0]  data_read_ddr          ;
wire         line_request           ;
wire         frame_buffer_ready     ;
                                                            
wire         start_ov5640           ;
wire [15:0]  address_ov5640         ;
wire  [7:0]  data_ov5640            ;
wire         ready_ov5640           ;
wire         start_write_image2ddr  ;

wire [31:0]  reg_addr_buf_1         ;
wire [31:0]  reg_addr_buf_2         ;
wire [31:0]  reg_addr_buf_3         ;
wire [7:0]   y_component            ;
wire         xclk_cam               ;
wire         clk_23                 ;
wire [3:0]   hps_switch             ;
wire [3:0]   hist_switch            ;
wire [7:0]   parallax_corr          ;
                                       
wire [7:0]   div_coef               ;
wire [7:0]   shift_coef             ;
wire [4:0]   coef_conv[3][3]        ;
                        

wire [3:0]   reg_hps_switch         ;
wire [7:0]   reg_parallax_corr      ;
wire[1:0]    select_initial_cam     ;                      
wire         err_ch0                ;
wire         err_ch1                ;

wire         start_frame            ;	
wire         start_frame2           ;	
wire         ready_read             ;
wire         ready_read2            ;
wire         end_frame              ;

wire         enable_hist            ;

wire         valid_data_hist        ;
wire  [7:0]  data_hist              ;   
wire         frame_end_y            ;
wire         frame_end_hist         ;
	
pll_0 pll_0_inst
(
	.refclk   		   ( clk50			),
	.rst      		   ( 1'h0			),
	.outclk_0 		   ( pixel_clk		), //74.25MHz
	.locked   		   ( pll_lock[0]	)
);                     
pll_1 pll_1_inst       
(                      
	.refclk   		   ( clk50			), //50MHz
	.rst      		   ( 1'h0			),
	.outclk_0 		   ( sys_clk		), //100MHz
	.outclk_1 		   ( xclk_cam       ), //24MHz
	.outclk_2 		   ( clk_23         ), //23MHz
	.locked   		   ( pll_lock[1]    )
);


GLOBAL global_sys_clk_inst
(
	.in			                ( sys_clk	                 ), 
	.out		                ( sys_clk_b	                 )
);

GLOBAL GLOBAL_rst_inst
(
	.in			                ( pll_lock[1] & pll_lock[0]	), 
	.out		                ( reset_n_b					)
);
// SoC sub-system module generated by qsys      
de10_nan0_hdr_ifc de10_nan0_hdr_ifc_inst
(
	.clk50                      (clk50                                       ),            
	.clk100                     (sys_clk_b                                   ),          
	.avl_h2f_dsp                (avl_h2f_dsp.avl_master_port                 ),                 
	.mem_gamma_0                (mem_gamma_0.mem_slave_port                  ),                 
	.mem_gamma_1                (mem_gamma_1.mem_slave_port                  ),                 
	.f2h_sdram_write            (f2h_sdram_write.sdram_write_slave_port      ),               	             
	.f2h_sdram_write_freq       (f2h_sdram_write_freq.sdram_write_slave_port ),               	             
	.f2h_sdram_read             (f2h_sdram_read.sdram_read_slave_port        ),                                
	.hps_io_port                (hps_io.hps_io_port                          ),
    .ddr3_mem                   (ddr3_mem.ddr3_port                          )
);
// configurate cameres
SCCB_camera_config SCCB_camera_config_inst
(
	.clk_sys                    (sys_clk_b                      ),   
	.reset_n                    (reset_n_b                      ),
	.select_initial_cam         (select_initial_cam             ), // <-
	.ready_ov5640               (ready_ov5640                   ), // ->
	.start_ov5640               (start_ov5640                   ), // <-
	.address_ov5640             (address_ov5640                 ), // <-
	.data_ov5640                (data_ov5640                    ), // <-
	.xclk_cam                   (xclk_cam                       ), // <- xclk 24 MHz
	.clk_23                     (clk_23                         ),
	.err_ch0                    (err_ch0                        ),
	.err_ch1                    (err_ch1                        ),
	.clk_cam_0_o                (clk_cam_0_o                    ),
    .clk_cam_1_o                (clk_cam_1_o                    ),
	.RESETB_0                   (RESETB_0                       ),
	.RESETB_1                   (RESETB_1                       ),
	.PWDN_0                     (PWDN_0                         ),
	.PWDN_1                     (PWDN_1                         ),
	.SIOC_0                     (SIOC_0                         ),
	.SIOD_0                     (SIOD_0                         ),
	.SIOC_1                     (SIOC_1                         ),
	.SIOD_1                     (SIOD_1                         )
);
// load data to register from hps2fpga bridge
hps_register_ov5640 hps_register_ov5640_inst
(
	.clk_sys                    (sys_clk_b                       ),
	.reset_n                    (reset_n_b                       ),
	.ready_ov5640               (ready_ov5640                    ), // <-
	.start_ov5640               (start_ov5640                    ), // ->
	.address_ov5640             (address_ov5640                  ), // ->
	.data_ov5640                (data_ov5640                     ), // ->
	.reg_addr_buf_1             (reg_addr_buf_1                  ), // ->
	.reg_addr_buf_2             (reg_addr_buf_2                  ), // ->
	.reg_addr_buf_3             (reg_addr_buf_3                  ), // ->
	.hps_switch                 (hps_switch                      ), // ->
	.hist_switch                (hist_switch                     ), // ->
	.hist_enable                (enable_hist                     ), // ->
	.parallax_corr              (parallax_corr                   ), // ->
	.div_coef                   (div_coef                        ),
	.shift_coef                 (shift_coef                      ),
	.coef_conv                  (coef_conv                       ),
	.select_cam_initial         (select_initial_cam              ), // ->
	.start_write_image2ddr      (start_write_image2ddr           ), // ->
	.avl_h2f_write              (avl_h2f_dsp.avl_write_slave_port) // <-
 
);

// 
convert2avl_stream_raw convert2avl_stream_raw_inst         
(                                                               
	.pclk_1   	       	        ( clk_cam_0_i	                ),
	.pclk_2   	       	        ( clk_cam_1_i	                ),
	._ready_read                ( ready_read                    ),
	._ready_read2               ( ready_read                    ),
	.clk_sys	       	        ( sys_clk_b		                ),
	.reset_n	       	        ( reset_n_b		                ),
	.VSYNC_1  	       	        ( VSYNC_0 		                ),
	.VSYNC_2  	       	        ( VSYNC_1		                ),
	.HREF_1   	       	        ( HREF_0  & ready_read  	    ),
	.HREF_2   	       	        ( HREF_1  & ready_read     	    ),
	.D1     	       	        ( cam_0_data	                ),
	.D2     	       	        ( cam_1_data	                ),            
	.RAW_1           	        ( raw_data_0	                ),
	.RAW_2           	        ( raw_data_1	                ),
	.valid_RAW     	            ( raw_data_valid                ),         
	.err_ch0                    (err_ch0                        ),
	.err_ch1                    (err_ch1                        ),
	.SOF    	       	        ( raw_data_sop	                ),
	.EOF    	       	        ( raw_data_eop	                ),
	.start_frame     	        (start_frame                    ),
	.start_frame2     	        (start_frame2                   )
	
);
//gamma correction
gamma_correction gamma_correction_inst
(
	.clk					    ( sys_clk_b			            ),
	.reset_n                    ( reset_n_b                     ),
	.raw_data_0                 ( raw_data_0                    ),
	.raw_data_1                 ( raw_data_1                    ),
	.raw_data_valid             ( raw_data_valid                ),
	.raw_data_sop               ( raw_data_sop                  ),
	.raw_data_eop               ( raw_data_eop                  ),
	                                                            
	.addr_0					    ( mem_gamma_0.address           ),
	.data_0                     ( mem_gamma_0.readdata          ),
                                                                
	.addr_1                     ( mem_gamma_1.address           ),
	.data_1                     ( mem_gamma_1.readdata          ),
	                                                            
	.gamma_data_0               ( gamma_data_0                  ),
	.gamma_data_1               ( gamma_data_1                  ),
	.gamma_data_valid           ( gamma_data_valid              ),
	.gamma_data_sop             ( gamma_data_sop                ),
	.gamma_data_eop             ( gamma_data_eop                )
);
// parallax elimination
parallax_fix parallax_fix_inst
(
	.clk				        ( sys_clk_b					    ),
	.reset_n                    ( reset_n_b					    ),
	.parallax_corr		        ( reg_parallax_corr			    ),
	.raw_data_0                 ( gamma_data_0    	            ),
	.raw_data_1                 ( gamma_data_1    	            ),
	.raw_data_valid             ( gamma_data_valid	            ),
	.raw_data_sop               ( gamma_data_sop  	            ),
	.raw_data_eop               ( gamma_data_eop  	            ),
	                                                           
	.prlx_fxd_data_0            ( prx_fxd_raw_data_0	  	    ),
	.prlx_fxd_data_1            ( prx_fxd_raw_data_1	  	    ),
	.prlx_fxd_data_valid        ( prx_fxd_raw_data_valid  	    ),
	.prlx_fxd_data_sop          ( prx_fxd_raw_data_sop	  	    ),
	.prlx_fxd_data_eop          ( prx_fxd_raw_data_eop	  	    )
);

//convert raw from camera 0 to rgb 
raw2rgb_bilinear_interp 
#(
	.DATA_WIDTH		( 8	)
)
raw2rgb_bilinear_interp_inst_0
(
	.clk			            ( sys_clk_b    		           ),
	.reset_n                    ( reset_n_b	   		           ),
	.raw_data                   ( prx_fxd_raw_data_0  		   ),
	.raw_valid                  ( prx_fxd_raw_data_valid 	   ),
	.raw_sop	                ( prx_fxd_raw_data_sop   	   ),
	.raw_eop	                ( prx_fxd_raw_data_eop   	   ),
	.r_data_o                   ( r_data_0			           ),
	.g_data_o                   ( g_data_0			           ),
	.b_data_o                   ( b_data_0			           ),
	.data_o_valid               ( data_rgb_valid_0	           ),
	.sop_o	                    ( sop_rgb_0		  	           ),
	.eop_o	                    ( eop_rgb_0	      	           )
);                                                             
 //convert raw from camera 1 to rgb 
raw2rgb_bilinear_interp 
#(
	.DATA_WIDTH		( 8	)
)
raw2rgb_bilinear_interp_inst_1
(
	.clk			            ( sys_clk_b                    ),
	.reset_n                    ( reset_n_b	                   ),
	.raw_data                   (prx_fxd_raw_data_1  	       ),
	.raw_valid                  (prx_fxd_raw_data_valid        ),
	.raw_sop	                (prx_fxd_raw_data_sop          ),
	.raw_eop	                (prx_fxd_raw_data_eop          ),
	.r_data_o                   ( r_data_1			           ),
	.g_data_o                   ( g_data_1			           ),
	.b_data_o                   ( b_data_1			           ),
	.data_o_valid               ( data_rgb_valid_1	           ),
	.sop_o	                    ( sop_rgb_1		  	           ),
	.eop_o	                    ( eop_rgb_1	      	           )
);
//hdr algorithm
wrp_HDR_algorithm
#(
	.DATA_WIDTH ( 8	)
)
wrp_HDR_algorithm_inst					
(
	.clk						(sys_clk_b			                    ), 	  
	.asi_snk_0_valid_i	        (data_rgb_valid_1 	                    ),
	.asi_snk_0_data_r_i			(r_data_0                               ),
	.asi_snk_0_data_g_i         (g_data_0                               ),
	.asi_snk_0_data_b_i         (b_data_0                               ),
	                                                                    
	.asi_snk_0_startofpacket_i  (sop_rgb_0		                        ),
	.asi_snk_0_endofpacket_i    (eop_rgb_0 	     	                    ),
	.asi_snk_1_data_r_i			(r_data_1                               ),	
	.asi_snk_1_data_g_i	        (g_data_1                               ),
	.asi_snk_1_data_b_i	        (b_data_1                               ),
	                                                                    
	.aso_src_valid_o            (data_valid_hdr	                        ),
	.aso_src_data_r_o			(r_hdr	                                ),
	.aso_src_data_g_o           (g_hdr	                                ),
	.aso_src_data_b_o			(b_hdr	                                ),
	.aso_src_startofpacket_o    (sop_hdr			                    ),
	.aso_src_endofpacket_o      (eop_hdr			                    )
);
// multiplexer for framebuffer
mux_data_framebuffer mux_data_framebuffer_inst
(
	.clk                        (sys_clk_b                              ),        
	.reset_n                    (reset_n_b                              ),
	.start_frame                (start_frame                            ),
	.hps_switch                 (hps_switch                             ),
	.parallax_corr              (parallax_corr                          ),
	.reg_parallax_corr          (reg_parallax_corr                      ),
	.enable_tone_mapping        (enable_tone_mapping                    ),
    // camera 0 rgb data                                                
	.r_cam_0		            (r_data_0			                    ), 
	.g_cam_0		            (g_data_0			                    ), 
	.b_cam_0		            (b_data_0			                    ), 
	.data_valid_cam_0           (data_rgb_valid_0                       ),
	.sop_cam_0		            (sop_rgb_0		                        ),
	.eop_cam_0	                (eop_rgb_0	                            ),
    // camera 1 rgb data                                                
	.r_cam_1		            (r_data_1			                    ), 
	.g_cam_1		            (g_data_1			                    ), 
	.b_cam_1		            (b_data_1			                    ), 
	.data_valid_cam_1           (data_rgb_valid_1                       ),
	.sop_cam_1		            (sop_rgb_1		                        ),
	.eop_cam_1	                (eop_rgb_1	                            ),
    // HDR rgb comp                                                     
	.r_hdr		                (r_tm  		                            ),
	.g_hdr		                (g_tm 		                            ),
	.b_hdr		                (b_tm 		                            ),
	.data_valid_hdr             (data_valid_tm                          ),
	.sop_hdr		            (sop_tm		                            ),
	.eop_hdr	                (eop_tm	                                ),
    // mux out                                                          
	.r_fb		                (r_fb                                   ),
	.g_fb		                (g_fb                                   ),
	.b_fb		                (b_fb                                   ),
    .data_fb_valid              (data_fb_valid                          ),
    .sop_fb		                (sop_fb		                            ),
    .eop_fb	                    (eop_fb	                                ),
);

wrp_tone_mapping
#(
    .W		( 10 )
)
wrp_tone_mapping_inst
(
	.clk		               ( sys_clk_b			                    ),
	.reset_n                   ( reset_n_b			                    ),
	.enable                    ( enable_tone_mapping                    ),
    .sop_i                     ( sop_hdr			                    ),
	.eop_i                     ( eop_hdr			                    ),
	.valid_i                   ( data_valid_hdr	                        ),
	.data_r_i                  ( r_hdr                                  ),
	.data_g_i                  ( g_hdr                                  ),
	.data_b_i                  ( b_hdr                                  ),
	.data_r_o                  ( r_tm                                   ),
	.data_g_o                  ( g_tm                                   ),
	.data_b_o                  ( b_tm                                   ),
    .sop_o		               ( sop_tm			                        ),
	.eop_o                     ( eop_tm			                        ),
	.valid_o	               ( data_valid_tm	                        ),
	.reg_parallax_corr		   ( reg_parallax_corr						)	
);

wrp_conv_filter 
#(
	.DATA_WIDTH ( 8	),
	.COEF_WIDTH ( 5	)
)
wrp_conv_filter_inst
(
	.clk                       (sys_clk_b                               ), 
    .reset_n                   (reset_n_b                               ),
    .data_r_i                  (r_fb		                            ), 
    .data_g_i                  (g_fb		                            ),
    .data_b_i                  (b_fb		                            ),
    .valid_i                   (data_fb_valid                           ),
    .sop_i	                   (sop_fb                                  ),
    .eop_i                     (eop_fb                                  ),
    .coef                      (coef_conv                               ),
    .div_coef                  (div_coef                                ),
    .bias_factor               (shift_coef                              ),
    .data_r_o                  (r_filter                                ),
    .data_g_o                  (g_filter                                ),
    .data_b_o                  (b_filter                                ),
    .data_o_valid              (filter_valid                            ),
    .sop_o                     ( /*sop_tm   */                          ),
    .eop_o	                   ( /*eop_tm */                            )
);



// Write hdr frame stream to ddr on frequency pixel clock
sdram_write sdram_write_inst
(	
	.clk_100                   (sys_clk_b                              ),
    .reset_n                   (reset_n_b                              ),
    .start_frame               (start_frame                            ),
    .start_write_image2ddr     (start_write_image2ddr                  ),
	.r_fb		               (r_filter                               ),    
	.g_fb		               (g_filter                               ),
	.b_fb		               (b_filter                               ),
	.data_fb_valid             (filter_valid                           ),
    .reg_addr_buf_1            (reg_addr_buf_1                         ),
    .reg_addr_buf_2            (reg_addr_buf_2                         ),
    .end_frame                 (end_frame                              ),
    ._ready_read               (ready_read                             ),
    .f2h_sdram2                (f2h_sdram_write.sdram_write_master_port)

);
// mux 2
select_comp select_comp_inst
(
	.clk                       (sys_clk_b                             ), 
	.reset_n                   (reset_n_b                             ),
	.start_frame               (start_frame                           ),
	.hist_switch               (hist_switch                           ),
	.rgb_valid                 (filter_valid                          ),
	.r_comp                    (r_filter                              ),
	.g_comp                    (g_filter                              ),
	.b_comp                    (b_filter                              ),
	.y_valid                   (valid_out_Y                           ),
	.frame_end_rgb             (end_frame                             ),
	.frame_end_y               (frame_end_y                           ),
	.y_comp                    (y_component                           ),
	.out_comp                  (data_hist                             ),
	.frame_end_hist            (frame_end_hist                        ),
	.out_valid                 (valid_data_hist                       )
);
// y = 0.299*R + 0.587*G + 0.114*B
Y_comp  Y_comp_inst 
(
	.clk                       (sys_clk_b                                   ),
    .reset_n                   (reset_n_b                                   ),
	.R_comp                    (r_filter                                    ),
	.G_comp                    (g_filter                                    ),
	.B_comp                    (b_filter                                    ),
	.valid_in                  (filter_valid                                ),
	.frame_end_in              (end_frame                                   ),
	.frame_end_out             (frame_end_y                                 ),
	.valid_out                 (valid_out_Y                                 ),
	.Y_comp                    (y_component                                 )
);
// 
hist_calc hist_calc_inst
(
	.clk                       (sys_clk_b                                   ),
	.reset_n                   (reset_n_b                                   ),
	.valid_data                (valid_data_hist                             ),
	.reg_parallax_corr         (reg_parallax_corr                           ),
	.data_comp                 (data_hist                                   ),
	.frame_start               (start_frame                                 ),	
	.frame_end                 (frame_end_hist                              ),
	.addr_buf                  ({reg_addr_buf_3,1'b0 }                      ),
	.f2h_sdram                 (f2h_sdram_write_freq.sdram_write_master_port)
);

// Read hdr frame from ddr on frequency HDMI
read_data_ddr read_data_ddr_inst
(
	.clk_100                   (sys_clk_b                            ),    
	.reset_b                   (reset_n_b                            ),
	.line_request              (line_request                         ),
	.enable_hist               (enable_hist                          ),
	.done_write_frame          (end_frame                            ),
	.frame_buffer_ready        (frame_buffer_ready                   ),
	.r_data                    (r_data_read_ddr                      ),
	.g_data                    (g_data_read_ddr                      ),
	.b_data                    (b_data_read_ddr                      ),
	.valid_rgb                 (data_rgb_read_valid_ddr              ),
	.addr_read_ddr1            ({reg_addr_buf_1,1'b0}                ),
	.addr_read_ddr2            ({reg_addr_buf_2,1'b0}                ),
	.addr_read_ddr3            ({reg_addr_buf_3,1'b0}                ),
	.f2h_sdram                 (f2h_sdram_read.sdram_read_master_port)
);


HDMI_tx
#(
	.DATA_WIDTH	( 24)
)
HDMI_tx_inst
(
	.clk					   ( sys_clk_b			                 ),						
	.pixel_clk                 ( pixel_clk			                 ),
	.reset_n	               ( reset_n_b			                 ),
	.asi_snk_valid_i           ( data_rgb_read_valid_ddr             ),
	.line_request_o            ( line_request				         ),
	.frame_buffer_ready		   ( frame_buffer_ready		             ),
	.asi_snk_data_i            ( data_read_ddr 		                 ),
	.data_enable               ( data_enable				         ), // -> pin
	.hsync                     ( hsync					             ), // -> pin
	.vsync                     ( vsync					             ), // -> pin
	.data_r                    ( data_HDMI[23:16]			         ), // -> pin
	.data_g                    ( data_HDMI[15: 8]			         ), // -> pin
	.data_b                    ( data_HDMI[ 7: 0]			         ) // -> pin
	
);

//HDMI I2C
I2C_HDMI_Config u_I2C_HDMI_Config 
(
	.iCLK			          ( clk50				                ),
	.iRST_N			          ( reset_n_b			                ),
	.I2C_SCLK		          ( HDMI_I2C_SCL		                ), // <-> pin
	.I2C_SDAT		          ( HDMI_I2C_SDA		                ), // <-> pin
	.HDMI_TX_INT	          ( HDMI_TX_INT		                    ), // <- pin
	.READY			          (                                     )
);
assign  pixel_clk_out = pixel_clk;
assign  data_read_ddr = {b_data_read_ddr, g_data_read_ddr, r_data_read_ddr} ;
	
endmodule

//////////////////////////////////////////////////////
//Name File     : mux_data_framebuffer              //
//Author        : Andrey Papushin                   //
//Email         : andrey.papushin@gmail.com         //
//Standart      : IEEE 1800—2009(SystemVerilog-2009)//
//Start design  : 25.04.2018                        //
//Last revision : 26.04.2018                        //
//////////////////////////////////////////////////////
module mux_data_framebuffer
(
	input  wire         clk                   ,
	input  wire         reset_n               ,
	input  wire         start_frame           ,
	input  wire  [3:0]  hps_switch            ,
	input  wire  [7:0]  parallax_corr         ,
	output reg   [7:0]  reg_parallax_corr     ,
	output wire         enable_tone_mapping   ,
	                                        
	input  wire [7:0]   r_cam_0		          ,
	input  wire [7:0]   g_cam_0		          ,
	input  wire [7:0]   b_cam_0		          ,
	input  wire         data_valid_cam_0   ,
	input  wire         sop_cam_0		  ,
	input  wire         eop_cam_0	      ,
	                                         
	input  wire [7:0]   r_cam_1		          ,
	input  wire [7:0]   g_cam_1		          ,
	input  wire [7:0]   b_cam_1		          ,
	input  wire         data_valid_cam_1   ,
	input  wire         sop_cam_1		  ,
	input  wire         eop_cam_1	      ,
	                                         
	input  wire [7:0]   r_hdr		          ,
	input  wire [7:0]   g_hdr		          ,
	input  wire [7:0]   b_hdr		          ,
	input  wire         data_valid_hdr     ,
	input  wire         sop_hdr		      ,
	input  wire         eop_hdr	          ,
	                                        
	input  wire [7:0]   r_tm		          ,
	input  wire [7:0]   g_tm		          ,
	input  wire [7:0]   b_tm		          ,
	input  wire         data_valid_tm      ,
	input  wire         sop_tm		      ,
	input  wire         eop_tm             ,
	                                                                                  
	output  wire [7:0]  r_fb		          ,
	output  wire [7:0]  g_fb		          ,
	output  wire [7:0]  b_fb		          ,
	output  wire        data_fb_valid         ,
	output  wire        sop_fb		          ,
	output  wire        eop_fb	              

);

reg [3:0] reg_hps_switch;

always @( posedge clk or negedge reset_n)
	if ( !reset_n )
		reg_parallax_corr <= 8'd10;
	else
		if(start_frame) 
		begin
			reg_hps_switch     <= hps_switch;
			reg_parallax_corr  <= parallax_corr;
		end

assign enable_tone_mapping = reg_hps_switch[2];
	
always @( posedge clk )
	casex (reg_hps_switch )
		4'b??01:begin
					r_fb			<= 	r_cam_0		        ;    
					g_fb			<=  g_cam_0		        ;
					b_fb			<=  b_cam_0		        ;
					data_fb_valid	<=  data_valid_cam_0 ;
					sop_fb		  	<=  sop_cam_0		;
					eop_fb	      	<=  eop_cam_0	    ;
				end	                                        
		4'b??10:begin                                      
					r_fb			<= r_cam_1		        ;
					g_fb			<= g_cam_1		        ;
					b_fb			<= b_cam_1		        ;
					data_fb_valid	<= data_valid_cam_1  ;
					sop_fb		  	<= sop_cam_1		    ;
					eop_fb	      	<= eop_cam_1	        ;
				end	                                        
		4'b??11:begin                                       
					r_fb			<= r_hdr		        ;  			
					g_fb			<= g_hdr		        ;  
					b_fb			<= b_hdr		        ;  
					data_fb_valid	<= data_valid_hdr       ; 
					sop_fb		  	<= sop_hdr		        ;  
					eop_fb	      	<= eop_hdr	            ;  			
				end                              
		default:begin                                     
					r_fb			<= r_cam_0		       	;
					g_fb			<= g_cam_0		        ;
					b_fb			<= b_cam_0		        ;
					data_fb_valid	<= data_valid_cam_0  ;
					sop_fb		  	<= sop_cam_0		    ;
					eop_fb	      	<= eop_cam_0	   		;
				end
	endcase
	
endmodule
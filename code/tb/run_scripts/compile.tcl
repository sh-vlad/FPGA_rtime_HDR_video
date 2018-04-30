global tb_name
     
vlog  -sv -work dsp_work   ../../synt/imitator_dvp/imitator_dvp_ifc.v                                                           
vlog  -sv -work dsp_work   ../../synt/dvp2avl_stream/fifo_dvp.v        
vlog  -sv -work dsp_work   ../tb_imitator_dvp_ifc.v        
    
	
vlog  -sv -work dsp_work ../../synt/mux_data_framebuffer.v
vlog  -sv -work dsp_work ../../synt/wrp_conv_filter.sv
vlog  -sv -work dsp_work ../../synt/filter.sv
vlog  -sv -work dsp_work ../../synt/fifo_conv_filter.v
vlog  -sv -work dsp_work ../../synt/divider_conv_filter.v
vlog  -sv -work dsp_work ../../synt/interface_files/de10_nan0_hdr_ifc.sv
vlog  -sv -work dsp_work ../../synt/SCCB_interface/SCCB_camera_config.v
vlog  -sv -work dsp_work ../../synt/SCCB_interface/SCCB_interface.v
vlog  -sv -work dsp_work ../../synt/parallax_fix.sv
vlog  -sv -work dsp_work ../../synt/fifo_parallax_fix.v
vlog  -sv -work dsp_work ../../synt/pll_2/pll_2_0002.v
vlog  -sv -work dsp_work ../../synt/pll_2.v
vlog  -sv -work dsp_work ../../synt/dvp2avl_stream/fifo_dvp2.v
vlog  -sv -work dsp_work ../../synt/ddr_sdram/read_data_ddr.v
vlog  -sv -work dsp_work ../../synt/min_max_detector.sv
vlog  -sv -work dsp_work ../../synt/wrp_tone_mapping.sv
vlog  -sv -work dsp_work ../../synt/tone_mapping_divider.v
vlog  -sv -work dsp_work ../../synt/tone_mapping.sv
vlog  -sv -work dsp_work ../../synt/ddr_sdram/write_to_buf_frame.v
vlog  -sv -work dsp_work ../../synt/ddr_sdram/sdram_write.v
vlog  -sv -work dsp_work ../../synt/ddr_sdram/sdram_fifo.v
vlog  -sv -work dsp_work ../../synt/h2f_bridge/hps_register_ov5640.v
vlog  -sv -work dsp_work ../../synt/h2f_bridge/fifo_avl_mm.v
vlog  -sv -work dsp_work ../../synt/interface_files/interface_hps.sv
vlog  -sv -work dsp_work ../../synt/resync_fifo_HDMI_tx.v
vlog  -sv -work dsp_work ../../synt/dvp2avl_stream/convert2avl_stream_raw.v
vlog  -sv -work dsp_work ../../synt/raw2rgb_bilinear_interp.sv
vlog  -sv -work dsp_work ../../synt/fifo_raw2rgb.v
vlog  -sv -work dsp_work ../../synt/delay_rg.v
vlog  -sv -work dsp_work ../../synt/HDR_divider.v
vlog  -sv -work dsp_work ../../synt/dvp2avl_stream/fifo_dvp.v
vlog  -sv -work dsp_work ../../synt/dvp2avl_stream/convert2avl_stream.v
vlog  -sv -work dsp_work ../../synt/wrp_HDR_algorithm.sv
vlog  -sv -work dsp_work ../../synt/HDR_algorithm.sv
vlog  -sv -work dsp_work ../../synt/calc_weight_coef.sv
vlog  -sv -work dsp_work ../../synt/pll_1/pll_1_0002.v
vlog  -sv -work dsp_work ../../synt/pll_1.v
vlog  -sv -work dsp_work ../../synt/I2C_WRITE_WDATA.v
vlog  -sv -work dsp_work ../../synt/I2C_HDMI_Config.v
vlog  -sv -work dsp_work ../../synt/I2C_Controller.v
vlog  -sv -work dsp_work ../../synt/HDMI_tx_test.sv
vlog  -sv -work dsp_work ../../synt/pll_0/pll_0_0002.v
vlog  -sv -work dsp_work ../../synt/pll_0.v
vlog  -sv -work dsp_work ../../synt/HDMI_tx.sv


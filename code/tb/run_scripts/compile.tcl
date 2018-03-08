global tb_name
     
vlog  -sv -work dsp_work   ../../synt/imitator_dvp/imitator_dvp_ifc.v                                                   
vlog  -sv -work dsp_work   ../../synt/dvp2avl_stream/convert2avl_stream.v                                                   
vlog  -sv -work dsp_work   ../../synt/dvp2avl_stream/fifo_dvp.v        
vlog  -sv -work dsp_work   ../tb_imitator_dvp_ifc.v        
    

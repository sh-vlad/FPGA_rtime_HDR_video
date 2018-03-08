 #Create compilation libraries
proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }

ensure_lib                     ./libraries/     
ensure_lib                     ./libraries/dsp_work/
ensure_lib                     ./libraries/altera_ver/         
ensure_lib                     ./libraries/altera_mf_ver/         
vmap       altera_ver          ./libraries/altera_ver/  
vmap       altera_mf_ver       ./libraries/altera_mf_ver/ 
vmap       dsp_work            ./libraries/dsp_work/ 

alias lib  {
vlog -sv -work altera_ver    $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_primitives.v                                                                                   
vlog -sv -work altera_mf_ver $env(QUARTUS_ROOTDIR)/eda/sim_lib/altera_mf.v                         
}
alias c "do compile.tcl"
alias c_tb {
	vlog  -sv -work dsp_work   ../tb_imitator_dvp_ifc.v
}
alias s {
	vsim -novopt -L dsp_work -L altera_ver -L altera_mf_ver dsp_work.tb_imitator_dvp_ifc
	#log /* -r
	do ./wave.do 
	run -all
}

alias rs {
	restart -f
	log /* -r
	run -all
}	
proc qs {}  {quit -sim}
proc q {}  {quit}
proc h {}  {
  echo "c            - to compile files"
  echo "s            - to simulate without optimization with waveform"
  echo "rs           - to restart simulation"
}
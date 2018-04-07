## Generated SDC file "FPGA_rtime_HDR_video.out.sdc"

## Copyright (C) 2017  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus Prime"
## VERSION "Version 17.1.0 Build 590 10/25/2017 SJ Lite Edition"

## DATE    "Sat Apr 07 17:34:14 2018"

##
## DEVICE  "5CSEBA6U23I7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3
derive_clock_uncertainty


#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk50} [get_ports {clk50}] -period 20.000 -waveform { 0.000 10.000 } 
create_clock -name {clk_cam_0_i} [get_ports {clk_cam_0_i}] -period 96MHz  
create_clock -name {clk_cam_1_i} [get_ports {clk_cam_1_i}] -period 96MHz  
derive_pll_clocks
#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************
set_clock_groups -logically_exclusive -group [get_clocks {clk_cam_0_i}] -group [get_clocks {pll_1_inst|pll_1_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_clock_groups -logically_exclusive -group [get_clocks {clk_cam_1_i}] -group [get_clocks {pll_1_inst|pll_1_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
set_clock_groups -logically_exclusive -group [get_clocks {pll_1_inst|pll_1_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -group [get_clocks {pll_0_inst|pll_0_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}]
#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************


// megafunction wizard: %LPM_DIVIDE%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: LPM_DIVIDE 

// ============================================================
// File Name: rgb2hsv_divider0.v
// Megafunction Name(s):
// 			LPM_DIVIDE
//
// Simulation Library Files(s):
// 			lpm
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 18.0.0 Build 614 04/24/2018 SJ Lite Edition
// ************************************************************


//Copyright (C) 2018  Intel Corporation. All rights reserved.
//Your use of Intel Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files from any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Intel Program License 
//Subscription Agreement, the Intel Quartus Prime License Agreement,
//the Intel FPGA IP License Agreement, or other applicable license
//agreement, including, without limitation, that your use is for
//the sole purpose of programming logic devices manufactured by
//Intel and sold by Intel or its authorized distributors.  Please
//refer to the applicable agreement for further details.


// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module rgb2hsv_divider0 (
	clock,
	denom,
	numer,
	quotient,
	remain);

	input	  clock;
	input	[7:0]  denom;
	input	[18:0]  numer;
	output	[18:0]  quotient;
	output	[7:0]  remain;

	wire [18:0] sub_wire0;
	wire [7:0] sub_wire1;
	wire [18:0] quotient = sub_wire0[18:0];
	wire [7:0] remain = sub_wire1[7:0];

	lpm_divide	LPM_DIVIDE_component (
				.clock (clock),
				.denom (denom),
				.numer (numer),
				.quotient (sub_wire0),
				.remain (sub_wire1),
				.aclr (1'b0),
				.clken (1'b1));
	defparam
		LPM_DIVIDE_component.lpm_drepresentation = "UNSIGNED",
		LPM_DIVIDE_component.lpm_hint = "LPM_REMAINDERPOSITIVE=TRUE",
		LPM_DIVIDE_component.lpm_nrepresentation = "SIGNED",
		LPM_DIVIDE_component.lpm_pipeline = 10,
		LPM_DIVIDE_component.lpm_type = "LPM_DIVIDE",
		LPM_DIVIDE_component.lpm_widthd = 8,
		LPM_DIVIDE_component.lpm_widthn = 19;


endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone V"
// Retrieval info: PRIVATE: PRIVATE_LPM_REMAINDERPOSITIVE STRING "TRUE"
// Retrieval info: PRIVATE: PRIVATE_MAXIMIZE_SPEED NUMERIC "-1"
// Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "0"
// Retrieval info: PRIVATE: USING_PIPELINE NUMERIC "1"
// Retrieval info: PRIVATE: VERSION_NUMBER NUMERIC "2"
// Retrieval info: PRIVATE: new_diagram STRING "1"
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: CONSTANT: LPM_DREPRESENTATION STRING "UNSIGNED"
// Retrieval info: CONSTANT: LPM_HINT STRING "LPM_REMAINDERPOSITIVE=TRUE"
// Retrieval info: CONSTANT: LPM_NREPRESENTATION STRING "SIGNED"
// Retrieval info: CONSTANT: LPM_PIPELINE NUMERIC "10"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_DIVIDE"
// Retrieval info: CONSTANT: LPM_WIDTHD NUMERIC "8"
// Retrieval info: CONSTANT: LPM_WIDTHN NUMERIC "19"
// Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL "clock"
// Retrieval info: USED_PORT: denom 0 0 8 0 INPUT NODEFVAL "denom[7..0]"
// Retrieval info: USED_PORT: numer 0 0 19 0 INPUT NODEFVAL "numer[18..0]"
// Retrieval info: USED_PORT: quotient 0 0 19 0 OUTPUT NODEFVAL "quotient[18..0]"
// Retrieval info: USED_PORT: remain 0 0 8 0 OUTPUT NODEFVAL "remain[7..0]"
// Retrieval info: CONNECT: @clock 0 0 0 0 clock 0 0 0 0
// Retrieval info: CONNECT: @denom 0 0 8 0 denom 0 0 8 0
// Retrieval info: CONNECT: @numer 0 0 19 0 numer 0 0 19 0
// Retrieval info: CONNECT: quotient 0 0 19 0 @quotient 0 0 19 0
// Retrieval info: CONNECT: remain 0 0 8 0 @remain 0 0 8 0
// Retrieval info: GEN_FILE: TYPE_NORMAL rgb2hsv_divider0.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL rgb2hsv_divider0.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL rgb2hsv_divider0.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL rgb2hsv_divider0.bsf FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL rgb2hsv_divider0_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL rgb2hsv_divider0_bb.v FALSE
// Retrieval info: LIB_FILE: lpm
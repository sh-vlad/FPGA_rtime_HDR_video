//////////////////////////////////////////////////////
//Name File     : de10_nan0_hdr_ifc                 //
//Author        : Andrey Papushin                   //
//Email         : andrey.papushin@gmail.com         //
//Standart      : IEEE 1800—2009(SystemVerilog-2009)//
//Start design  : 03.04.2018                        //
//Last revision : 30.04.2018                        //
//////////////////////////////////////////////////////
module de10_nan0_hdr_ifc
(
	input wire                              clk50          ,
	input wire                              clk100         ,
	avl_ifc.avl_master_port                 avl_h2f_dsp    ,   
	sdram_ifc.sdram_write_slave_port        f2h_sdram_write,
	sdram_ifc.sdram_read_slave_port         f2h_sdram_read ,
	hps_ifc.hps_io_port                     hps_io_port    ,
	ddr3_ifc.ddr3_port                      ddr3_mem     
);
wire reset_n;

de10_nan0_hdr de10_nan0_hdr_inst
(
	.clk_clk                          ( clk50                          ),
	.clk_0_clk                        ( clk100                         ),
	.reset_in_reset_n                 ( reset_n                        ),
	.h2f_reset_out_reset_n            ( reset_n                        ),
	.avl_h2f_dsp_write                ( avl_h2f_dsp.write              ),
	.avl_h2f_dsp_chipselect           ( avl_h2f_dsp.chipselect         ),
	.avl_h2f_dsp_address              ( avl_h2f_dsp.address            ),
	.avl_h2f_dsp_byteenable           ( avl_h2f_dsp.byteenable         ),
	.avl_h2f_dsp_readdata             ( avl_h2f_dsp.readdata           ),
	.avl_h2f_dsp_writedata            ( avl_h2f_dsp.writedata          ),
	.f2h_sdram0_address               ( f2h_sdram_write.address        ),
	.f2h_sdram0_burstcount            ( f2h_sdram_write.burstcount     ),
	.f2h_sdram0_waitrequest           ( f2h_sdram_write.waitrequest    ),
	.f2h_sdram0_writedata             ( f2h_sdram_write.writedata      ),
	.f2h_sdram0_byteenable            ( f2h_sdram_write.byteenable     ),
	.f2h_sdram0_write                 ( f2h_sdram_write.write          ),            
	.f2h_sdram1_address               ( f2h_sdram_read.address         ),
	.f2h_sdram1_burstcount            ( f2h_sdram_read.burstcount      ),
	.f2h_sdram1_waitrequest           ( f2h_sdram_read.waitrequest     ),
	.f2h_sdram1_readdata              ( f2h_sdram_read.readdata        ),
	.f2h_sdram1_readdatavalid         ( f2h_sdram_read.readdatavalid   ),
	.f2h_sdram1_read                  ( f2h_sdram_read.read            ),
	.hps_io_hps_io_emac1_inst_TX_CLK  ( hps_io_port.emac1_inst_TX_CLK  ),
	.hps_io_hps_io_emac1_inst_TXD0    ( hps_io_port.emac1_inst_TXD0    ),
	.hps_io_hps_io_emac1_inst_TXD1    ( hps_io_port.emac1_inst_TXD1    ),
	.hps_io_hps_io_emac1_inst_TXD2    ( hps_io_port.emac1_inst_TXD2    ),
	.hps_io_hps_io_emac1_inst_TXD3    ( hps_io_port.emac1_inst_TXD3    ),
	.hps_io_hps_io_emac1_inst_RXD0    ( hps_io_port.emac1_inst_RXD0    ),
	.hps_io_hps_io_emac1_inst_MDIO    ( hps_io_port.emac1_inst_MDIO    ),
	.hps_io_hps_io_emac1_inst_MDC     ( hps_io_port.emac1_inst_MDC     ),
	.hps_io_hps_io_emac1_inst_RX_CTL  ( hps_io_port.emac1_inst_RX_CTL  ),
	.hps_io_hps_io_emac1_inst_TX_CTL  ( hps_io_port.emac1_inst_TX_CTL  ),
	.hps_io_hps_io_emac1_inst_RX_CLK  ( hps_io_port.emac1_inst_RX_CLK  ),
	.hps_io_hps_io_emac1_inst_RXD1    ( hps_io_port.emac1_inst_RXD1    ),
	.hps_io_hps_io_emac1_inst_RXD2    ( hps_io_port.emac1_inst_RXD2    ),
	.hps_io_hps_io_emac1_inst_RXD3    ( hps_io_port.emac1_inst_RXD3    ),
	.hps_io_hps_io_sdio_inst_CMD      ( hps_io_port.sdio_inst_CMD      ),
	.hps_io_hps_io_sdio_inst_D0       ( hps_io_port.sdio_inst_D0       ),
	.hps_io_hps_io_sdio_inst_D1       ( hps_io_port.sdio_inst_D1       ),
	.hps_io_hps_io_sdio_inst_CLK      ( hps_io_port.sdio_inst_CLK      ),
	.hps_io_hps_io_sdio_inst_D2       ( hps_io_port.sdio_inst_D2       ),
	.hps_io_hps_io_sdio_inst_D3       ( hps_io_port.sdio_inst_D3       ),
	.hps_io_hps_io_usb1_inst_D0       ( hps_io_port.usb1_inst_D0       ),
	.hps_io_hps_io_usb1_inst_D1       ( hps_io_port.usb1_inst_D1       ),
	.hps_io_hps_io_usb1_inst_D2       ( hps_io_port.usb1_inst_D2       ),
	.hps_io_hps_io_usb1_inst_D3       ( hps_io_port.usb1_inst_D3       ),
	.hps_io_hps_io_usb1_inst_D4       ( hps_io_port.usb1_inst_D4       ),
	.hps_io_hps_io_usb1_inst_D5       ( hps_io_port.usb1_inst_D5       ),
	.hps_io_hps_io_usb1_inst_D6       ( hps_io_port.usb1_inst_D6       ),
	.hps_io_hps_io_usb1_inst_D7       ( hps_io_port.usb1_inst_D7       ),
	.hps_io_hps_io_usb1_inst_CLK      ( hps_io_port.usb1_inst_CLK      ),
	.hps_io_hps_io_usb1_inst_STP      ( hps_io_port.usb1_inst_STP      ),
	.hps_io_hps_io_usb1_inst_DIR      ( hps_io_port.usb1_inst_DIR      ),
	.hps_io_hps_io_usb1_inst_NXT      ( hps_io_port.usb1_inst_NXT      ),
	.hps_io_hps_io_spim1_inst_CLK     ( hps_io_port.spim1_inst_CLK     ),
	.hps_io_hps_io_spim1_inst_MOSI    ( hps_io_port.spim1_inst_MOSI    ),
	.hps_io_hps_io_spim1_inst_MISO    ( hps_io_port.spim1_inst_MISO    ),
	.hps_io_hps_io_spim1_inst_SS0     ( hps_io_port.spim1_inst_SS0     ),
	.hps_io_hps_io_uart0_inst_RX      ( hps_io_port.uart0_inst_RX      ),
	.hps_io_hps_io_uart0_inst_TX      ( hps_io_port.uart0_inst_TX      ),
	.hps_io_hps_io_i2c0_inst_SDA      ( hps_io_port.i2c0_inst_SDA      ),
	.hps_io_hps_io_i2c0_inst_SCL      ( hps_io_port.i2c0_inst_SCL      ),
	.hps_io_hps_io_i2c1_inst_SDA      ( hps_io_port.i2c1_inst_SDA      ),
	.hps_io_hps_io_i2c1_inst_SCL      ( hps_io_port.i2c1_inst_SCL      ),
	.memory_mem_a                     ( ddr3_mem.a                     ),
	.memory_mem_ba                    ( ddr3_mem.ba                    ),
	.memory_mem_ck                    ( ddr3_mem.ck                    ),
	.memory_mem_ck_n                  ( ddr3_mem.ck_n                  ),
	.memory_mem_cke                   ( ddr3_mem.cke                   ),
	.memory_mem_cs_n                  ( ddr3_mem.cs_n                  ),
	.memory_mem_ras_n                 ( ddr3_mem.ras_n                 ),
	.memory_mem_cas_n                 ( ddr3_mem.cas_n                 ),
	.memory_mem_we_n                  ( ddr3_mem.we_n                  ),
	.memory_mem_reset_n               ( ddr3_mem.reset_n               ),
	.memory_mem_dq                    ( ddr3_mem.dq                    ),
	.memory_mem_dqs                   ( ddr3_mem.dqs                   ),
	.memory_mem_dqs_n                 ( ddr3_mem.dqs_n                 ),
	.memory_mem_odt                   ( ddr3_mem.odt                   ),
	.memory_mem_dm                    ( ddr3_mem.dm                    ),
	.memory_oct_rzqin                 ( ddr3_mem.rzqin                 )
);


endmodule
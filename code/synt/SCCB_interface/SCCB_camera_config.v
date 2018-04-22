

module SCCB_camera_config
(
	input  logic                        clk_sys           ,             
	input  logic                        reset_n           ,
	input  logic [1:0]                  select_initial_cam,
	output logic                        ready_ov5640      ,
	input  logic                        start_ov5640      ,
	input  logic [15:0]                 address_ov5640    ,
	input  logic [7:0]                  data_ov5640       ,
	output logic                        SIOC_0            , 
	inout  logic                        SIOD_0            ,
	output logic                        SIOC_1            , 
	inout  logic                        SIOD_1     	
);


SCCB_interface SCCB_interface_inst
(
	.clk               (clk_sys                     ),
	.start             (start_ov5640                ), // <-
	.address           (address_ov5640              ), // <-
	.data              (data_ov5640                 ), // <-
	.ready             (ready_ov5640                ), // ->
	.SIOC_oe           (SIOC_o                      ), // ->
	.SIOD_oe           (SIOD_o                      ) // ->
);
always_comb
begin
	case(select_initial_cam)
		2'b00: 
		begin
			SIOC_0  =SIOC_o ? 1'b0 : 1'bz;
	        SIOD_0  =SIOD_o ? 1'b0 : 1'bz;
            SIOC_1  =SIOC_o ? 1'b0 : 1'bz;
            SIOD_1  =SIOD_o ? 1'b0 : 1'bz;
		end
		2'b01:
		begin
			SIOC_0  =SIOC_o ? 1'b0 : 1'bz;
	        SIOD_0  =SIOD_o ? 1'b0 : 1'bz;
            SIOC_1  = 1'bz;
            SIOD_1  = 1'bz;
		end
		2'b10:
		begin
			SIOC_0  = 1'bz;
	        SIOD_0  = 1'bz;
            SIOC_1  = SIOC_o ? 1'b0 : 1'bz;
            SIOD_1  = SIOD_o ? 1'b0 : 1'bz;
		end
		default:
		begin
			SIOC_0  = 1'bz;
	        SIOD_0  = 1'bz;
            SIOC_1  = 1'bz;
            SIOD_1  = 1'bz;
		end
	endcase
end			

endmodule
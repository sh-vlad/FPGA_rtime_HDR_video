onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_imitator_dvp_ifc/clk_sys
add wave -noupdate /tb_imitator_dvp_ifc/pclk
add wave -noupdate /tb_imitator_dvp_ifc/reset_n
add wave -noupdate -divider {DVP ifc}
add wave -noupdate /tb_imitator_dvp_ifc/VSYNC
add wave -noupdate /tb_imitator_dvp_ifc/HREF
add wave -noupdate -radix unsigned /tb_imitator_dvp_ifc/D1
add wave -noupdate -radix unsigned /tb_imitator_dvp_ifc/D2
add wave -noupdate -divider avl_stream
add wave -noupdate /tb_imitator_dvp_ifc/validY
add wave -noupdate -radix unsigned /tb_imitator_dvp_ifc/Y1
add wave -noupdate -radix unsigned /tb_imitator_dvp_ifc/Y2
add wave -noupdate /tb_imitator_dvp_ifc/validCb
add wave -noupdate /tb_imitator_dvp_ifc/validCr
add wave -noupdate -radix unsigned /tb_imitator_dvp_ifc/CbCr1
add wave -noupdate -radix unsigned /tb_imitator_dvp_ifc/CbCr2
add wave -noupdate /tb_imitator_dvp_ifc/SOF
add wave -noupdate /tb_imitator_dvp_ifc/EOF
add wave -noupdate -radix unsigned /tb_imitator_dvp_ifc/count_line
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {74423320 ps} 0} {{Cursor 2} {6030590216 ps} 0} {{Cursor 3} {90445363 ps} 0}
configure wave -namecolwidth 294
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {158439750 ps}

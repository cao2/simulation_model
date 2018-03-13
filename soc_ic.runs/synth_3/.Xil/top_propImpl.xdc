set_property SRC_FILE_INFO {cfile:C:/Users/cao2/Desktop/soci/soci/soc_ic/soc_ic.srcs/constrs_1/imports/zedboard_master_XDC_RevC_D_v3/zedboard_master_XDC_RevC_D_v3.xdc rfile:../../../soc_ic.srcs/constrs_1/imports/zedboard_master_XDC_RevC_D_v3/zedboard_master_XDC_RevC_D_v3.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:87 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN Y9 [get_ports Clock];  # "GCLK"
set_property src_info {type:XDC file:1 line:88 export:INPUT save:INPUT read:READ} [current_design]
set_property IOSTANDARD LVCMOS15 [get_ports Clock]
set_property src_info {type:XDC file:1 line:89 export:INPUT save:INPUT read:READ} [current_design]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports Clock]
set_property src_info {type:XDC file:1 line:92 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN Y11 [get_ports rx_in];
set_property src_info {type:XDC file:1 line:96 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN AA11 [get_ports tx_out];
set_property src_info {type:XDC file:1 line:219 export:INPUT save:INPUT read:READ} [current_design]
set_property PACKAGE_PIN P16 [get_ports reset];  # "BTNC"
set_property src_info {type:XDC file:1 line:220 export:INPUT save:INPUT read:READ} [current_design]
set_property IOSTANDARD LVCMOS15 [get_ports reset]

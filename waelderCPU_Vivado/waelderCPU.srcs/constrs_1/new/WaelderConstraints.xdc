set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { clk }];

set_property -dict { PACKAGE_PIN J2    IOSTANDARD LVCMOS33 } [get_ports { reset }];

set_property -dict { PACKAGE_PIN G1    IOSTANDARD LVCMOS33 } [get_ports { led_out[0] }];
set_property -dict { PACKAGE_PIN G2    IOSTANDARD LVCMOS33 } [get_ports { led_out[1] }];
set_property -dict { PACKAGE_PIN F1    IOSTANDARD LVCMOS33 } [get_ports { led_out[2] }];
set_property -dict { PACKAGE_PIN F2    IOSTANDARD LVCMOS33 } [get_ports { led_out[3] }];
set_property -dict { PACKAGE_PIN E1    IOSTANDARD LVCMOS33 } [get_ports { led_out[4] }];
set_property -dict { PACKAGE_PIN E2    IOSTANDARD LVCMOS33 } [get_ports { led_out[5] }];
set_property -dict { PACKAGE_PIN D1    IOSTANDARD LVCMOS33 } [get_ports { led_out[6] }];
set_property -dict { PACKAGE_PIN D2    IOSTANDARD LVCMOS33 } [get_ports { led_out[7] }];

set_property -dict { PACKAGE_PIN V2  IOSTANDARD LVCMOS33 } [get_ports { switch_in[0] }];
set_property -dict { PACKAGE_PIN U2  IOSTANDARD LVCMOS33 } [get_ports { switch_in[1] }];
set_property -dict { PACKAGE_PIN U1  IOSTANDARD LVCMOS33 } [get_ports { switch_in[2] }];
set_property -dict { PACKAGE_PIN T2  IOSTANDARD LVCMOS33 } [get_ports { switch_in[3] }];
set_property -dict { PACKAGE_PIN T1  IOSTANDARD LVCMOS33 } [get_ports { switch_in[4] }];
set_property -dict { PACKAGE_PIN R2  IOSTANDARD LVCMOS33 } [get_ports { switch_in[5] }];
set_property -dict { PACKAGE_PIN R1  IOSTANDARD LVCMOS33 } [get_ports { switch_in[6] }];
set_property -dict { PACKAGE_PIN P2  IOSTANDARD LVCMOS33 } [get_ports { switch_in[7] }];
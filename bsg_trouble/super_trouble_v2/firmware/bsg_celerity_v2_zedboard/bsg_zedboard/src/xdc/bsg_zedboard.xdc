# cfgvbs and config_voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

# clock 100 MHz
set_property PACKAGE_PIN Y9 [get_ports GCLK]
set_property IOSTANDARD LVCMOS33 [get_ports GCLK]
create_clock -name gclk_0 -period "10" -waveform {0.0 5.0} [get_ports GCLK]

# push button (center)
set_property PACKAGE_PIN P16 [get_ports BTNC];
set_property IOSTANDARD LVCMOS25 [get_ports BTNC];

# LEDs
set_property PACKAGE_PIN T22 [get_ports LD0];
set_property PACKAGE_PIN T21 [get_ports LD1];
set_property PACKAGE_PIN U22 [get_ports LD2];
set_property PACKAGE_PIN U21 [get_ports LD3];
set_property PACKAGE_PIN V22 [get_ports LD4];
set_property PACKAGE_PIN W22 [get_ports LD5];
set_property PACKAGE_PIN U19 [get_ports LD6];
set_property PACKAGE_PIN U14 [get_ports LD7];
set_property IOSTANDARD LVCMOS33 [get_ports LD0];
set_property IOSTANDARD LVCMOS33 [get_ports LD1];
set_property IOSTANDARD LVCMOS33 [get_ports LD2];
set_property IOSTANDARD LVCMOS33 [get_ports LD3];
set_property IOSTANDARD LVCMOS33 [get_ports LD4];
set_property IOSTANDARD LVCMOS33 [get_ports LD5];
set_property IOSTANDARD LVCMOS33 [get_ports LD6];
set_property IOSTANDARD LVCMOS33 [get_ports LD7];

# Switches
set_property PACKAGE_PIN F22 [get_ports SW0];
set_property PACKAGE_PIN G22 [get_ports SW1];
set_property PACKAGE_PIN H22 [get_ports SW2];
set_property PACKAGE_PIN F21 [get_ports SW3];
set_property PACKAGE_PIN H19 [get_ports SW4];
set_property IOSTANDARD LVCMOS25 [get_ports SW0];
set_property IOSTANDARD LVCMOS25 [get_ports SW1];
set_property IOSTANDARD LVCMOS25 [get_ports SW2];
set_property IOSTANDARD LVCMOS25 [get_ports SW3];
set_property IOSTANDARD LVCMOS25 [get_ports SW4];

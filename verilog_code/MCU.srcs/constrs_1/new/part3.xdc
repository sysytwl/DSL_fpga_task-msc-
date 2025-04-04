## Clock signal
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports clk_100M]
create_clock -period 10.000 [get_ports clk_100M]

##7 Segment Display
set_property -dict {PACKAGE_PIN W7 IOSTANDARD LVCMOS33} [get_ports {HEX_OUT[0]}]
set_property -dict {PACKAGE_PIN W6 IOSTANDARD LVCMOS33} [get_ports {HEX_OUT[1]}]
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS33} [get_ports {HEX_OUT[2]}]
set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33} [get_ports {HEX_OUT[3]}]
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports {HEX_OUT[4]}]
set_property -dict {PACKAGE_PIN V5 IOSTANDARD LVCMOS33} [get_ports {HEX_OUT[5]}]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports {HEX_OUT[6]}]
set_property -dict {PACKAGE_PIN V7 IOSTANDARD LVCMOS33} [get_ports {HEX_OUT[7]}]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports {SEG_SELECT_OUT[0]}]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports {SEG_SELECT_OUT[1]}]
set_property -dict {PACKAGE_PIN V4 IOSTANDARD LVCMOS33} [get_ports {SEG_SELECT_OUT[2]}]
set_property -dict {PACKAGE_PIN W4 IOSTANDARD LVCMOS33} [get_ports {SEG_SELECT_OUT[3]}]

##Buttons
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports reset]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports btnU]
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33} [get_ports btnL]
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports btnR]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports btnD]

##USB-RS232 Interface
# set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports RsRx]
# set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports RsTx]

##USB HID (PS/2)
set_property PACKAGE_PIN C17 [get_ports CLK_MOUSE]
set_property IOSTANDARD LVCMOS33 [get_ports CLK_MOUSE]
set_property PULLTYPE PULLUP [get_ports CLK_MOUSE]
set_property PACKAGE_PIN B17 [get_ports DATA_MOUSE]
set_property IOSTANDARD LVCMOS33 [get_ports DATA_MOUSE]
set_property PULLTYPE PULLUP [get_ports DATA_MOUSE]
create_clock -period 83333.336 -name CLK_MOUSE -waveform {0.000 41666.668} [get_ports CLK_MOUSE]

#VGA
set_property PACKAGE_PIN P19 [get_ports VGA_HS]
set_property IOSTANDARD LVCMOS33 [get_ports VGA_HS]
set_property PACKAGE_PIN R19 [get_ports VGA_VS]
set_property IOSTANDARD LVCMOS33 [get_ports VGA_VS]
set_property PACKAGE_PIN L18 [get_ports {VGA_DATA[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_DATA[0]}]
set_property PACKAGE_PIN K18 [get_ports {VGA_DATA[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_DATA[1]}]
set_property PACKAGE_PIN J18 [get_ports {VGA_DATA[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_DATA[2]}]
set_property PACKAGE_PIN G17 [get_ports {VGA_DATA[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_DATA[3]}]
set_property PACKAGE_PIN D17 [get_ports {VGA_DATA[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_DATA[4]}]
set_property PACKAGE_PIN H19 [get_ports {VGA_DATA[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_DATA[5]}]
set_property PACKAGE_PIN J19 [get_ports {VGA_DATA[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_DATA[6]}]
set_property PACKAGE_PIN N19 [get_ports {VGA_DATA[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {VGA_DATA[7]}]

##Quad SPI Flash
##Note that CCLK_0 cannot be placed in 7 series devices. You can access it using the
##STARTUPE2 primitive.
#set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[0]}]
#set_property -dict { PACKAGE_PIN D19   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[1]}]
#set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[2]}]
#set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports {QspiDB[3]}]
#set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports QspiCSn]

## SPI configuration mode options for QSPI boot, can be used for all designs
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

#leds
set_property PACKAGE_PIN E19 [get_ports LEFT]
set_property IOSTANDARD LVCMOS33 [get_ports LEFT]
set_property PACKAGE_PIN U16 [get_ports RIGHT]
set_property IOSTANDARD LVCMOS33 [get_ports RIGHT]

#ir
set_property PACKAGE_PIN P18 [get_ports IR_LED]
set_property IOSTANDARD LVCMOS33 [get_ports IR_LED]

create_generated_clock -name seg7_clk_divider/CLK -source [get_ports clk_100M] -divide_by 262144 [get_pins seg7_clk_divider/divided_clk_reg/Q]

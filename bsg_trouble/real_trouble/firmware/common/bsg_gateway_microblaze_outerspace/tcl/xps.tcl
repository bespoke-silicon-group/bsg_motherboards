#------------------------------------------------------------
# University of California, San Diego - Bespoke Systems Group
#------------------------------------------------------------
# File: xps.tcl
#
# Authors: Luis Vega - lvgutierrez@eng.ucsd.edu
#------------------------------------------------------------

# gateway xilinx xps flow microblaze

set device_tech spartan6
set device_name xc6slx150
set device_package fgg676
set device_speed_grade -3

xload new board_ctrl.xmp
xset arch $device_tech
xset dev $device_name
xset package $device_package
xset speedgrade $device_speed_grade
xset simulator isim
xset hier sub
xset hdl verilog
xset intstyle ise
xset parallel_synthesis yes
save xmp

exit

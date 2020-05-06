
# open hardware manager
open_hw

# connect to local hardware server
connect_hw_server

# open hardware target
open_hw_target

# set programming file
set_property PROGRAM.FILE ./ku11p_test/ku11p_test.runs/impl_1/design_1_wrapper.bit [get_hw_devices xcku11p_0]

# program FPGA
program_hw_devices -verbose [get_hw_devices xcku11p_0]

# exit
close_hw_target
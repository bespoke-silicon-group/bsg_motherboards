**BSG RealTrouble**

This is the first BaseJump Socket 352 compliant motherboard.
It contains Socket 352 ASIC as well as an Spartan-6 FPGA, called the Gateway FPGA.
It supports connection to Xilinx host boards via the high-speed FMC connector,
for use of off-chip DRAM, PCI-e, Ethernet, etc.

The Gateway FPGA has the code for controlling the on-board power supplies, and for forwarding data between the full-duplex high-speed source-synchronous DDR link (called BaseJump FPGA Bridge) to the Socket 352 ASIC and the LPC FMC connector (which goes to an ML-605 or similar Xilinx XUP host.) It also provides resources for clock generation.

Spartan-6 was used to keep the cost low ($200 for the GW FPGA), and because it allows a large voltage range (up to 3.3V) for I/O's, and because it allows tuning of both input and output delays, allowing for high-speed I/O. Termination is external for debug probing and to allow heat to dissipated outside of the chips, which are wirebond BGA and only have 3W budgets.

The board has (unless noted, these are connected to the GW FPGA):

- LPC FMC connector with  approx 16 differential pairs (plus clock) in each direction (~ 1 GHz)
- RS-232 port
- JTAG connector
- 8-pin header for communication in either direction to GW FPGA, or for jumpers
- 4 SMA pairs:
  - two (one in, one out) are connected to the ASIC FPGA, and
  - two (one in, one out) are connected to the GW FPGA.
  The traces on these pairs are 100-ohm impedance and inputs are terminated with a 100-ohm resistor.
- various LEDs
- header for powering fan
- header for powering board externally
- programmable power supplies and power measurement for ASIC core and I/O voltage

The board has been tested and is up and running in our lab.

Version 1 of the board is a 14-layer impedance-controlled board, designed with Mentorgraphics PADS.
It offers some tweaks for better power integrity (capacitors, 14-layers with better stackup and plane arrangement)
as well as optimized capacitor sizing and placement.

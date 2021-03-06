
### Frequently Asked Questions ###

##### Q1: Suggested supplier for PCB fabrication and assembly? #####

A1: Sierra Circuits, Inc.
    1108 West Evelyn Ave., Sunnyvale, CA 94086 USA 
    This supplier is able to finish fabrication, component purchasing and board assembly at once. 

    
##### Q2: Components in BOM are out of stock? #####

A2: There are two chips, ADP1715ARMZ and M25P128, that might be hard to find in US market. 
    One solution is to purchase these chips overseas. 
    Another solution is NOT solder them onto the board. Use Xilinx HW-USB-II-G programmer to program the FPGA (suggested).
    

##### Q3: How to install the BGA socket onto the motherboard? #####

A3: The socket can be installed with screws and nuts, so there is no need to solder it onto the board.
    Also the socket can be easily uninstalled and installed on another motherboard.
    
    
##### Q4: The fabrication company suggests that the thermal-pad-paste of MAX8556 is missing? #####

A4: You may either let the company add it back, or just leave it the original way.


##### Q5: The assembly company says that some capacitors do not have name label? #####

A5: The centroid file (*.rep) indicates the exact position of all components.


##### Q6: The assembly company asks for polarity of LEDs and tantalum capacitors? #####

A6: For LEDs, the negative (-) side has thicker silkscreen outline.
    For tantalum caps, the positive (+) side has thicker silkscreen outline.
    

##### Q7: The assembly company says that the power switch may have wrong ON/OFF labels? #####

A7: Ignore it, the PCB design is correct.


    
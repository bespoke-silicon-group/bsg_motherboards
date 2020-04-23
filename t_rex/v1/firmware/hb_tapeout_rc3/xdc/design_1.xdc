
# Internal Vref for DDR4 Data IO (Bank 67)
set_property INTERNAL_VREF 0.840 [get_iobanks 67]

# Internal Vref for BSG Link (Bank 65, 66)
set_property INTERNAL_VREF 0.900 [get_iobanks 65]
set_property INTERNAL_VREF 0.900 [get_iobanks 66]

# System reset pin
set_property PACKAGE_PIN J16      [get_ports {reset}]
set_property IOSTANDARD  LVCMOS33 [get_ports {reset}]

set_property PACKAGE_PIN C15      [get_ports {reset_gpio}]
set_property IOSTANDARD  LVCMOS33 [get_ports {reset_gpio}]
set_property PULLTYPE    PULLDOWN [get_ports {reset_gpio}]

# PCIe pin assignment
set_property PACKAGE_PIN P5 [get_ports {pcie_refclk_clk_n}]
set_property PACKAGE_PIN P6 [get_ports {pcie_refclk_clk_p}]

set_property PACKAGE_PIN AF20     [get_ports {pcie_perstn}]
set_property IOSTANDARD  LVCMOS18 [get_ports {pcie_perstn}]

# DDR4 Pin Assignment
set_property PACKAGE_PIN Y30    [get_ports {ddr4_sdram_act_n      }]
set_property PACKAGE_PIN AA28   [get_ports {ddr4_sdram_adr[0]     }]
set_property PACKAGE_PIN AD28   [get_ports {ddr4_sdram_adr[1]     }]
set_property PACKAGE_PIN AC28   [get_ports {ddr4_sdram_adr[2]     }]
set_property PACKAGE_PIN AA29   [get_ports {ddr4_sdram_adr[3]     }]
set_property PACKAGE_PIN AA30   [get_ports {ddr4_sdram_adr[4]     }]
set_property PACKAGE_PIN AH30   [get_ports {ddr4_sdram_adr[5]     }]
set_property PACKAGE_PIN AE30   [get_ports {ddr4_sdram_adr[6]     }]
set_property PACKAGE_PIN AH29   [get_ports {ddr4_sdram_adr[7]     }]
set_property PACKAGE_PIN AE29   [get_ports {ddr4_sdram_adr[8]     }]
set_property PACKAGE_PIN AE27   [get_ports {ddr4_sdram_adr[9]     }]
set_property PACKAGE_PIN Y27    [get_ports {ddr4_sdram_adr[10]    }]
set_property PACKAGE_PIN AJ30   [get_ports {ddr4_sdram_adr[11]    }]
set_property PACKAGE_PIN Y29    [get_ports {ddr4_sdram_adr[12]    }]
set_property PACKAGE_PIN AJ29   [get_ports {ddr4_sdram_adr[13]    }]
set_property PACKAGE_PIN AB28   [get_ports {ddr4_sdram_adr[14]    }]
set_property PACKAGE_PIN AF29   [get_ports {ddr4_sdram_adr[15]    }]
set_property PACKAGE_PIN AF30   [get_ports {ddr4_sdram_adr[16]    }]
set_property PACKAGE_PIN AC29   [get_ports {ddr4_sdram_ba[0]      }]
set_property PACKAGE_PIN AG28   [get_ports {ddr4_sdram_ba[1]      }]
set_property PACKAGE_PIN AC30   [get_ports {ddr4_sdram_bg[0]      }]
set_property PACKAGE_PIN AG30   [get_ports {ddr4_sdram_bg[1]      }]
set_property PACKAGE_PIN AF28   [get_ports {ddr4_sdram_ck_c       }]
set_property PACKAGE_PIN AF27   [get_ports {ddr4_sdram_ck_t       }]
set_property PACKAGE_PIN AB30   [get_ports {ddr4_sdram_cke        }]
set_property PACKAGE_PIN W29    [get_ports {ddr4_sdram_cs_n       }]
                                
set_property PACKAGE_PIN M27    [get_ports {ddr4_sdram_dm_n[0]    }]
set_property PACKAGE_PIN R26    [get_ports {ddr4_sdram_dm_n[1]    }]
set_property PACKAGE_PIN P23    [get_ports {ddr4_sdram_dm_n[2]    }]
set_property PACKAGE_PIN W22    [get_ports {ddr4_sdram_dm_n[3]    }]
                                
set_property PACKAGE_PIN P28    [get_ports {ddr4_sdram_dq[0]      }]
set_property PACKAGE_PIN N30    [get_ports {ddr4_sdram_dq[1]      }]
set_property PACKAGE_PIN R29    [get_ports {ddr4_sdram_dq[2]      }]
set_property PACKAGE_PIN N28    [get_ports {ddr4_sdram_dq[3]      }]
set_property PACKAGE_PIN P29    [get_ports {ddr4_sdram_dq[4]      }]
set_property PACKAGE_PIN M30    [get_ports {ddr4_sdram_dq[5]      }]
set_property PACKAGE_PIN N29    [get_ports {ddr4_sdram_dq[6]      }]
set_property PACKAGE_PIN L30    [get_ports {ddr4_sdram_dq[7]      }]
set_property PACKAGE_PIN U26    [get_ports {ddr4_sdram_dq[8]      }]
set_property PACKAGE_PIN T28    [get_ports {ddr4_sdram_dq[9]      }]
set_property PACKAGE_PIN V30    [get_ports {ddr4_sdram_dq[10]     }]
set_property PACKAGE_PIN U27    [get_ports {ddr4_sdram_dq[11]     }]
set_property PACKAGE_PIN V26    [get_ports {ddr4_sdram_dq[12]     }]
set_property PACKAGE_PIN T27    [get_ports {ddr4_sdram_dq[13]     }]
set_property PACKAGE_PIN V25    [get_ports {ddr4_sdram_dq[14]     }]
set_property PACKAGE_PIN U30    [get_ports {ddr4_sdram_dq[15]     }]
set_property PACKAGE_PIN N26    [get_ports {ddr4_sdram_dq[16]     }]
set_property PACKAGE_PIN N25    [get_ports {ddr4_sdram_dq[17]     }]
set_property PACKAGE_PIN M26    [get_ports {ddr4_sdram_dq[18]     }]
set_property PACKAGE_PIN M25    [get_ports {ddr4_sdram_dq[19]     }]
set_property PACKAGE_PIN P27    [get_ports {ddr4_sdram_dq[20]     }]
set_property PACKAGE_PIN N24    [get_ports {ddr4_sdram_dq[21]     }]
set_property PACKAGE_PIN P24    [get_ports {ddr4_sdram_dq[22]     }]
set_property PACKAGE_PIN P26    [get_ports {ddr4_sdram_dq[23]     }]
set_property PACKAGE_PIN R25    [get_ports {ddr4_sdram_dq[24]     }]
set_property PACKAGE_PIN T22    [get_ports {ddr4_sdram_dq[25]     }]
set_property PACKAGE_PIN T25    [get_ports {ddr4_sdram_dq[26]     }]
set_property PACKAGE_PIN U23    [get_ports {ddr4_sdram_dq[27]     }]
set_property PACKAGE_PIN U22    [get_ports {ddr4_sdram_dq[28]     }]
set_property PACKAGE_PIN R22    [get_ports {ddr4_sdram_dq[29]     }]
set_property PACKAGE_PIN T24    [get_ports {ddr4_sdram_dq[30]     }]
set_property PACKAGE_PIN T23    [get_ports {ddr4_sdram_dq[31]     }]
                                
set_property PACKAGE_PIN R30    [get_ports {ddr4_sdram_dqs_c[0]   }]
set_property PACKAGE_PIN V29    [get_ports {ddr4_sdram_dqs_c[1]   }]
set_property PACKAGE_PIN M23    [get_ports {ddr4_sdram_dqs_c[2]   }]
set_property PACKAGE_PIN V24    [get_ports {ddr4_sdram_dqs_c[3]   }]
set_property PACKAGE_PIN T30    [get_ports {ddr4_sdram_dqs_t[0]   }]
set_property PACKAGE_PIN V28    [get_ports {ddr4_sdram_dqs_t[1]   }]
set_property PACKAGE_PIN M22    [get_ports {ddr4_sdram_dqs_t[2]   }]
set_property PACKAGE_PIN V23    [get_ports {ddr4_sdram_dqs_t[3]   }]
                                
set_property PACKAGE_PIN W28    [get_ports {ddr4_sdram_odt        }]
set_property PACKAGE_PIN AD29   [get_ports {ddr4_sdram_reset_n    }]
                                
set_property PACKAGE_PIN AD27   [get_ports {sysclk_300_clk_n}]
set_property PACKAGE_PIN AD26   [get_ports {sysclk_300_clk_p}]

# LEDs
set_property PACKAGE_PIN D8  [get_ports {led[0]}]
set_property PACKAGE_PIN D9  [get_ports {led[1]}]
set_property PACKAGE_PIN E10 [get_ports {led[2]}]
set_property PACKAGE_PIN E11 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]


# CLK125 input
set_property PACKAGE_PIN AG17     [get_ports {clk125_clk_n}]
set_property PACKAGE_PIN AG18     [get_ports {clk125_clk_p}]
set_property IOSTANDARD  LVDS     [get_ports {clk125_clk_p}]

# UART
set_property PACKAGE_PIN D7       [get_ports {rs232_uart_rxd}]
set_property PACKAGE_PIN D6       [get_ports {rs232_uart_txd}]
set_property IOSTANDARD  LVCMOS33 [get_ports {rs232_uart_*}]

# IIC
set_property PACKAGE_PIN F17      [get_ports {iic_main_scl_io[0]}]
set_property PACKAGE_PIN G17      [get_ports {iic_main_sda_io[0]}]
set_property PACKAGE_PIN D17      [get_ports {TPS0_CNTL}]

set_property PACKAGE_PIN E15      [get_ports {iic_main_scl_io[1]}]
set_property PACKAGE_PIN A17      [get_ports {iic_main_sda_io[1]}]
set_property PACKAGE_PIN B17      [get_ports {DIG_POT_PLL_ADDR1}]
set_property PACKAGE_PIN C16      [get_ports {DIG_POT_PLL_ADDR0}]
set_property PACKAGE_PIN D16      [get_ports {DIG_POT_PLL_INDEP}]
set_property PACKAGE_PIN A15      [get_ports {DIG_POT_PLL_NRST}]

set_property PACKAGE_PIN A3       [get_ports {iic_main_scl_io[2]}]
set_property PACKAGE_PIN A4       [get_ports {iic_main_sda_io[2]}]
set_property PACKAGE_PIN A2       [get_ports {DIG_POT_IO_ADDR1}]
set_property PACKAGE_PIN B3       [get_ports {DIG_POT_IO_ADDR0}]
set_property PACKAGE_PIN B1       [get_ports {DIG_POT_IO_INDEP}]
set_property PACKAGE_PIN B2       [get_ports {DIG_POT_IO_NRST}]

set_property IOSTANDARD  LVCMOS33 [get_ports {iic_main_* TPS0_* DIG_POT_*}]
set_property PULLTYPE    PULLUP   [get_ports {iic_main_*}]



# Timing constraint
set_clock_groups -name async_mig_pcie -asynchronous -group [get_clocks -include_generated_clocks design_1_i/xdma_0/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/design_1_xdma_0_0_pcie4_ip_gt_i/inst/gen_gtwizard_gthe4_top.design_1_xdma_0_0_pcie4_ip_gt_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[*].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK] -group [get_clocks -include_generated_clocks mmcm_clkout1]

set_clock_groups -name async_mig_tag -asynchronous -group [get_clocks -include_generated_clocks clk_out1_design_2_clk_wiz_0_0] -group [get_clocks -include_generated_clocks mmcm_clkout1]

# Bitstream
set_property BITSTREAM.GENERAL.COMPRESS        True  [current_design]


# ASIC config signals
set_property PACKAGE_PIN AG27      [get_ports {GW_TAG_CLKO  }];
set_property PACKAGE_PIN AH28      [get_ports {GW_TAG_DATAO }];
set_property PACKAGE_PIN AJ28      [get_ports {GW_IC1_TAG_EN}];
set_property PACKAGE_PIN AH11      [get_ports {GW_CLKA      }];
set_property PACKAGE_PIN AK11      [get_ports {GW_CLKB      }];
set_property PACKAGE_PIN AK12      [get_ports {GW_CLKC      }];
set_property PACKAGE_PIN AG13      [get_ports {GW_SEL0      }];
set_property PACKAGE_PIN AH25      [get_ports {GW_SEL1      }];
set_property PACKAGE_PIN AJ26      [get_ports {GW_SEL2      }];
set_property PACKAGE_PIN AJ12      [get_ports {GW_CLK_RESET }];
set_property PACKAGE_PIN AK26      [get_ports {GW_CORE_RESET}];

set_property IOSTANDARD  SSTL18_I  [get_ports {GW_TAG_* GW_IC1_TAG_* GW_CLK* GW_SEL* GW_CLK_RESET GW_CORE_RESET}];
set_property SLEW        FAST      [get_ports {GW_TAG_* GW_IC1_TAG_* GW_CLK*}];


# Create prev clock
set prev_clk_period         20
create_clock -name prev_clk_in -period $prev_clk_period [get_ports {IC1_GW_CL_CLK}]

# False paths
set_false_path -from [get_clocks prev_clk_in] -to [get_clocks -include_generated_clocks mmcm_clkout1]
set_false_path -from [get_clocks -include_generated_clocks mmcm_clkout1] -to [get_clocks prev_clk_in]

# Input delay
set input_clock            prev_clk_in
set input_clock_period     $prev_clk_period
set dv_bre                 2
set dv_are                 2
set dv_bfe                 2
set dv_afe                 2

set_input_delay -clock $input_clock -max [expr $input_clock_period/2 - $dv_bfe] [get_ports {IC1_GW_CL_D* IC1_GW_CL_V}]
set_input_delay -clock $input_clock -min $dv_are [get_ports {IC1_GW_CL_D* IC1_GW_CL_V}]
set_input_delay -clock $input_clock -max [expr $input_clock_period/2 - $dv_bre] [get_ports {IC1_GW_CL_D* IC1_GW_CL_V}] -clock_fall -add_delay
set_input_delay -clock $input_clock -min $dv_afe [get_ports {IC1_GW_CL_D* IC1_GW_CL_V}] -clock_fall -add_delay

# Output delay
create_generated_clock -name prev_clk_out -source [get_pins {io_complex/prev/uplink/ch[0].oddr_phy/clk_r_o_reg/C}] -edges {1 3 5} -edge_shift {4.998 4.998 4.998} [get_ports {GW_IC1_CL_CLK}]

set fwclk                  prev_clk_out
set fwclk_period           $prev_clk_period
set bre_skew               2
set are_skew               2
set bfe_skew               2
set afe_skew               2

set_output_delay -clock $fwclk -max [expr $fwclk_period/2 - $afe_skew] [get_ports {GW_IC1_CL_D* GW_IC1_CL_V}]
set_output_delay -clock $fwclk -min $bre_skew [get_ports {GW_IC1_CL_D* GW_IC1_CL_V}]
set_output_delay -clock $fwclk -max [expr $fwclk_period/2 - $are_skew] [get_ports {GW_IC1_CL_D* GW_IC1_CL_V}] -clock_fall -add_delay
set_output_delay -clock $fwclk -min $bfe_skew [get_ports {GW_IC1_CL_D* GW_IC1_CL_V}] -clock_fall -add_delay


# Prev Output Channel
set_property PACKAGE_PIN AF23      [get_ports {GW_IC1_CL_CLK}];
set_property PACKAGE_PIN AG25      [get_ports {GW_IC1_CL_V  }];
set_property PACKAGE_PIN AF22      [get_ports {GW_IC1_CL_TKN}];
set_property PACKAGE_PIN AK24      [get_ports {GW_IC1_CL_D0 }];
set_property PACKAGE_PIN AH24      [get_ports {GW_IC1_CL_D1 }];
set_property PACKAGE_PIN AJ24      [get_ports {GW_IC1_CL_D2 }];
set_property PACKAGE_PIN AJ23      [get_ports {GW_IC1_CL_D3 }];
set_property PACKAGE_PIN AK25      [get_ports {GW_IC1_CL_D4 }];
set_property PACKAGE_PIN AJ22      [get_ports {GW_IC1_CL_D5 }];
set_property PACKAGE_PIN AK22      [get_ports {GW_IC1_CL_D6 }];
set_property PACKAGE_PIN AF25      [get_ports {GW_IC1_CL_D7 }];
set_property PACKAGE_PIN AH23      [get_ports {GW_IC1_CL_D8 }];

set_property IOSTANDARD  SSTL18_I  [get_ports {GW_IC1_CL_*  }];
set_property SLEW        FAST      [get_ports {GW_IC1_CL_CLK GW_IC1_CL_V GW_IC1_CL_D*}];
set_property ODT         RTT_40    [get_ports {GW_IC1_CL_TKN}];


# Prev Input Channel
set_property PACKAGE_PIN AD22      [get_ports {IC1_GW_CL_CLK}];
set_property PACKAGE_PIN AE21      [get_ports {IC1_GW_CL_V  }];
set_property PACKAGE_PIN AD23      [get_ports {IC1_GW_CL_TKN}];
set_property PACKAGE_PIN AB22      [get_ports {IC1_GW_CL_D0 }];
set_property PACKAGE_PIN AB21      [get_ports {IC1_GW_CL_D1 }];
set_property PACKAGE_PIN AC20      [get_ports {IC1_GW_CL_D2 }];
set_property PACKAGE_PIN AJ21      [get_ports {IC1_GW_CL_D3 }];
set_property PACKAGE_PIN AD21      [get_ports {IC1_GW_CL_D4 }];
set_property PACKAGE_PIN AK21      [get_ports {IC1_GW_CL_D5 }];
set_property PACKAGE_PIN AB20      [get_ports {IC1_GW_CL_D6 }];
set_property PACKAGE_PIN AC19      [get_ports {IC1_GW_CL_D7 }];
set_property PACKAGE_PIN AD19      [get_ports {IC1_GW_CL_D8 }];

set_property IOSTANDARD  SSTL18_I  [get_ports {IC1_GW_CL_*  }];
set_property ODT         RTT_40    [get_ports {IC1_GW_CL_CLK IC1_GW_CL_V IC1_GW_CL_D*}];
set_property SLEW        FAST      [get_ports {IC1_GW_CL_TKN}];

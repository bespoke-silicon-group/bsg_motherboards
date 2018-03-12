///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2015 Xilinx, Inc.
// All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor     : Xilinx
// \   \   \/     Version    : 14.7
//  \   \         Application: Xilinx CORE Generator
//  /   /         Filename   : bsg_ml605_chipscope_ila.v
// /___/   /\     Timestamp  : Thu Oct 15 18:13:25 PDT 2015
// \   \  /  \
//  \___\/\___\
//
// Design Name: Verilog Synthesis Wrapper
///////////////////////////////////////////////////////////////////////////////
// This wrapper is used to integrate with Project Navigator and PlanAhead

`timescale 1ns/1ps

module bsg_ml605_chipscope_ila(
    CONTROL,
    CLK,
    TRIG0) /* synthesis syn_black_box syn_noprune=1 */;


input [35 : 0] CONTROL;
input CLK;
input [255 : 0] TRIG0;

endmodule

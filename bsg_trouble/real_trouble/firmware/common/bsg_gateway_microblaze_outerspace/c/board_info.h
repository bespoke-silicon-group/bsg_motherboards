//------------------------------------------------------------
// University of California, San Diego - Bespoke Systems Group
//------------------------------------------------------------
// File: board_info.h
//
// Authors: Shengye Wang - shengye@eng.ucsd.edu
//------------------------------------------------------------

#ifndef BOARD_INFO_H        /* prevent circular inclusions */
#define BOARD_INFO_H        /* by using protection macros */

static const char board_desc[32] =
    {'R', 'e', 'a', 'l',' ', 'T', 'r', 'o', 'u', 'b', 'l', 'e', ' ', 'V', '1', '.', '0'};
static const u8 board_ver = 0x01;
static const u8 response_follow_flag = '/';

#define ALLOW_MATCH 0x2D

#endif


/* $Revision: 1.1 $ */
/*
Description: This is the main #define include file for the graphics package

Author: T. F. Ezell

Date: 10-Apr-90
*/
#ifndef dba_g_defs
#define dba_g_defs

#define BUFSIZE 5120

#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE 
#define TRUE (!FALSE)
#endif


#define WG_OPEN 401
#define WG_WINDOW_AREA 500
#define WG_FIT 501
#define WG_PROMPT_FIELD 600
#define WG_MESSAGE_FIELD 601

#define DBR_EOF 1
#define ABS(x) ((x) < 0 ? -(x) : (x))
#define DBR_SMALL 6
#define DBR_PI 3.14159

#define DBR_SCALE_TO_FIT 1
#define DBR_FIT_TO_X 2
#define DBR_FIT_TO_Y 4
#define DBR_NO_SCALING 8

#define MAXSQL 1024
#define MAXLINE 256
#define NETBUFSIZE 30000
#define MAXNETBUF 28000
#define DBR_MAXNAME 128
#define DBR_MAXPNTS 256
#define DBR_FILENAME_LENGTH 64
/*
	Error return codes
*/
#define DBA_ERRMSG 99
#define DBA_STMSG 98
#define WG_SUCCESS 0
#define WG_END_OF_DATA 100

#define WG_SUCCESS 0

#define WG_FAIL 1000
#define WG_NOTYPE9 1001
#define WG_MEMFAIL 1002
#define WG_FOFAIL 1003
#define WG_UNKTYPE 1004
#define WG_RECNOFOU 1005
#define WG_NODENOFOU 1006
#define WG_NETERROR 1007
#define WG_NOCONNECT 1008
#define WG_FOWFAIL 1009
#define WG_FORFAIL 1010
#define WG_NONODE 1011
#define WG_NOUSER 1012
#define WG_NOFILENAME 1013
#define WG_RESET 1014
#define WG_NOT_ACTIVE 1015
#define WG_EMPTY 1016
#define WG_MAXPOINTS 1017
#define WG_TMFAIL 1018
#define WG_FONTFAIL 1019
#define WG_MAX_IML_FILES 1020
#define WG_INVALID_SIZE 1021
#define WG_NO_NOTES 1022
#define WG_OTHER 1023
#define WG_NOT_PROCESSED 1024
#define WG_INVALID_WINDOW 1025
#define WG_INVALID_AREA 1026
#define WG_UNKOWN_TYPE 1027
#define WG_NO_FILES_OPEN 1028
#define WG_GRAPHICS_NOT_ACTIVE 1029
/*
	Tokens for the graphics control file
*/
#define WG_X1 0
#define WG_Y1 1
#define WG_X2 2
#define WG_Y2 3
#define WG_WIDTH 4
#define WG_HEIGHT 5
#define WG_OFFSET_X 6
#define WG_OFFSET_Y 7
#define WG_WINDOW_MODE 8
#define WG_MENU_MODE 9
#define WG_AUTO_LINKS 10
#define WG_LINKS_MODE 11
#define WG_IML_MEMORY 12
#define WG_FONT 13
#define WG_FG_COLOR 14
#define WG_BG_COLOR 15
#define WG_HL_COLOR 16
#define WG_FILES_TABLE 17
#define WG_LINKS_TABLE 18
#define WG_POINTS_TABLE 19
#define WG_PERFORMANCE 20
#define WG_UNKNOWN_KEYWORD -1
#define WG_NUM_KEYWORDS 21

#define WG_CASCADE 0
#define WG_QUADRANT 1
#define WG_SPECIFIED 2

#define WG_PERMANENT 0
#define WG_POP_UP 1
#define WG_OUTLINE 0
#define WG_HIGHLIGHT 1

#define WG_FENCE_CONTENTS 2
#define WG_CHECK_MULTI 1
#define WG_NO_CHECK_MULTI 0
/*
	Linkage types
*/
#define WG_L_RANGE 1
#define WG_L_MULTI 2
#define WG_L_PAINT 3
#define WG_L_NOTE 4
#define WG_L_NOTE_MULTI 5
#define WG_L_FILE 6
#define WG_L_FILE_MULTI 7
#define WG_L_USER 8
#define WG_L_USER_MULTI 9

#define WG_L_ALL 100
/*
	Markup Types
*/
#define WG_M_LINE 10
#define WG_M_SYMBOL 11
#define WG_M_TEXT 12
#define WG_M_POLYGON 14

#define WG_TYPE_FIELD 303
/*
	Fence Types
*/
#define WG_NOFENCE 0
#define WG_RECTANGULAR 1
#define WG_MULTI 2
/*
	Raster Data File Codes
*/
#define E_V_COLORS 2
/*
	Linkage Modes
*/
#define WG_NEW 0
#define WG_EXISTING 1
#define WG_INFO 2
#define WG_NONE -1
/*
	File Types
*/
#define WG_TILED_G4 0
#define WG_ASCII 1
#define WG_REDLINE 2
#define WG_TILED_29 3
#define WG_G4 0
#define WG_NOTE 4
#define WG_IGDS 10
#define WG_TYPE_2 11
#define WG_UNKNOWN 99
/*
	Load Switches
*/
#define WG_NO_OVERVIEW 0
#define WG_YES_OVERVIEW 1
#define WG_NO_SAVE_FITTED 0
#define WG_SAVE_FITTED 1
#define WG_CLEAR_FITTED 2

#define WG_BUTTON1 1
#define WG_BUTTON2 2
#define WG_BUTTON3 3
#define WG_BUTTON4 4
#define WG_BUTTON5 5

#define WG_BUTTON_PRESS 4
#define WG_MOTION_NOTIFY 6

#define WG_LINE_SOLID          0
#define WG_CAP_BUTT            1
#define WG_JOIN_ROUND          1

#define EV_KP_9 -71
#define EV_p 112

#define EV_KP_3 -77
#define EV_n 110

#define EV_KP_7 -73

#define EV_KP_1 -79
#define EV_b 98

#define EV_g 103
#define EV_w 119
#define EV_f 102
#define EV_u 117
#define EV_l 108
#define EV_i 105
#define EV_o 111
#define EV_s 115
#define EV_q 113
#define EV_d 100
#define EV_r 114
#define EV_m 109

#define EV_KP_F1 -11
#define EV_KP_F2 -81
#define EV_KP_F3 -86
#define EV_KP_F4 -85

#endif

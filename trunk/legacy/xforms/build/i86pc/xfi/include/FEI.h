/*****************************************************************/
/* FEI.h -						 	 */
/*	This is an X/Forms ( XFORMSDP SN01252 ) header file.	 */
/*****************************************************************/
/* Copyright 1992 Intergraph Corporation			 */
/* All Rights Reserved, Including this Release Note, the Product */
/* it Describes, its File Formats, and Visual Displays		 */
/*****************************************************************/

#ifndef FI_FEI_DEFINED
#define FI_FEI_DEFINED 1

/* Defines used for FI_modify_env() */

#define  FI_TRANSLATE_COLOR    		  1
#define  FI_FIND_FORM			  2
#define  FI_SET_WINDOW_ATTR		  3
#define  FI_CALC_TEXT			  4
#define  FI_DRAW_TEXT			  5
#define  FI_FIND_SYMBOL_PATH_AND_ID	  6
#define  FI_FIND_FONT_ID		  7
#define  FI_PROCESS_DATA		  8
#define  FI_ACTIVATE_HELP		 10
#define  FI_MAP_CHARACTER		 11
#define  FI_STRLEN			100
#define  FI_MOVE_INDEX			101


#define  FI_COLORMAP_NOTIFY		  9
#define  FI_GET_KEYBOARD_DATA		 12

/* Defines used for FI_set_graphic_env()  */
/*           GMD 1/13/92                  */

#define  FI_NEXT_EVENT                    1
#define  FI_CREATE_WINDOW                 2

/* More added 1/24/91    GMD              */

#define FI_MASK_EVENT                     3
#define FI_CHECK_MASK_EVENT               4
#define FI_IF_EVENT                       5
#define FI_PUT_BACK_EVENT                 6
#define FI_SEND_EVENT                     7

/* GMD 2/24/92 */

#define FI_GRAB_POINTER                   8
#define FI_UNGRAB_POINTER                 9

/* GMD 3/17/92  */

#define FI_CHECK_IF_EVENT                10
#define FI_MAP_RAISED                    11
#define FI_MAP_WINDOW                    12

/* GMD 3/18/92 */

#define FI_CONFIGURE_WINDOW              13
#define FI_DESTROY_WINDOW                14
#define FI_ICONIFY_WINDOW                15
#define FI_QUERY_POINTER                 16
#define FI_UNMAP_WINDOW                  17
#define FI_WITHDRAW_WINDOW               18
#define FI_WINDOW_EVENT                  19
#define FI_CHECK_WINDOW_EVENT            20

/* Defines used for FI_modify_graphic_env() */

#define  FI_CLEAR_TIMER_DATA		 12
#define  FI_COLLAPSE_WIN		 13
#define  FI_CREATE_SR_AREA		 14
#define  FI_CREATE_LEVWIN_NO_BORDER	 15
#define  FI_CREATE_WIN_USER_ICON	 16
#define  FI_DELETE_SR_AREA		 17
#define  FI_DELETE_WIN			 18
#define  FI_DISPLAY_WIN			 19
#define  FI_DISPLAY_WIN_MARQ		 75
#define  FI_ENTER_SR			 20
#define  FI_EXIT_SR			 21
#define  FI_GET_BUTTON_DATA		 22
#define  FI_GET_COLLAPSE_DATA     23
#define  FI_GET_DELETE_DATA     24
#define  FI_GET_REFRESH_AREA_DATA   25
#define   FI_GET_USER_DATA    79
#define  FI_GET_WIN_USER_ICON_DATA   26
#define  FI_INQ_BUTTON_DATA     27
#define  FI_INQ_COLLAPSE_DATA     28
#define  FI_INQ_DELETE_DATA     29
#define  FI_INQ_DISPLAYED_VS     30
#define  FI_INQ_EVENTS       31
#define  FI_INQ_REFRESH_AREA_DATA   32
#define  FI_INQ_SCREEN_INFO     33
#define   FI_INQ_USER_DATA    80
#define  FI_INQ_WIN_COLLAPSE_STAT   34
#define  FI_INQ_WIN_REGION     77
#define  FI_INQ_WIN_USER_ICON_DATA   35
#define  FI_INQ_WIN_VS       76
#define  FI_LOAD_SR_VLT     81
#define  FI_LOAD_SYMBOL_FILE     78
#define  FI_MODIFY_WIN       36
#define  FI_MOUSEPOSITION     37
#define  FI_MOUSEWINPOSITION     74
#define  FI_PROCESS_WIN_ICON_MENU   38
#define  FI_REFRESH_ON_MOVE     39
#define  FI_SET_WIN_BOUNDS     40
#define  FI_SET_WIN_BUTTON_MODE   41
#define  FI_SET_WIN_COLLAPSE_ORG  42
#define  FI_SET_WIN_COLLAPSE_SYMBOL   43
#define  FI_SET_WIN_DELTAS     44
#define  FI_SET_WIN_SYS_ICON     45
#define  FI_SET_WIN_USER_ICON     46
#define  FI_SET_WIN_VS_SWAP     47
#define  FI_START_TIMER     48
#define  FI_STOP_TIMER       49  
#define  FI_UNCOLLAPSE_WIN     50
#define  FI_UPDATE_WIN_ICON     51
#define  FI_WAIT_FOR_NEXT     52

#define  FI_BLENDAREA       53
#define  FI_BLENDLINE       54
#define  FI_CLIPBOX       55
#define  FI_DEFCURSOR       56
#define  FI_DRAW       57
#define  FI_DRAWBITMAP       58
#define  FI_DRAWSYMBOLS     59
#define  FI_FGCOLOR       60
#define  FI_FLUSHBUFFER     61
#define  FI_HIDECURSOR       62
#define  FI_LINESTRING       63
#define  FI_LINESTYLE       64
#define  FI_MOVE       65
#define  FI_PNT       66
#define  FI_POLYF      67
#define  FI_POPATTRIBUTES    72
#define  FI_PUSHATTRIBUTES    73
#define  FI_RECTF       68
#define  FI_SHOWCURSOR       69
#define  FI_VSYNC       70
#define  FI_WEIGHT       71

/* These are the types of commands to be processed */

#define FI_CMD_KEY_DATA		0
#define FI_CMD_STRING_DATA	1
#define FI_HELP_TOPIC_DATA	2


/* defines for FEI_map_character */

#define FI_UP		    16   /* ctrl p	*/
#define FI_DOWN		    14   /* ctrl n	*/
#define FI_LEFT	 	     2   /* ctrl b	*/
#define FI_RIGHT	     6   /* ctrl f	*/
#define FI_BOL		     1   /* ctrl a	*/
#define FI_EOL		     5   /* ctrl e	*/
#define FI_DEL   		 4   /* ctrl d	*/
#define FI_BS_DEL	     8   /* BACKSPACE */
#define FI_KILL_LINE	11   /* ctrl k	*/
#define FI_RESTORE	    25   /* ctrl y	*/
#define FI_UPPER_CASE	 3   /* ctrl c	*/
#define FI_LOWER_CASE	12   /* ctrl l	*/
#define FI_TRANSPOSE	20   /* ctrl t	*/
#define FI_IGNORE	    27   /* esc	*/
#define FI_TOG_PUSH_MODE 18  /* ctrl r  GMD 2/14/92  Implement push mode */

#define FI_NEXT_IN_SEQ  100     /* next in sequence	*/
#define FI_PREV_IN_SEQ  101     /* prev in sequence	*/
#define FI_IGNORE_CHAR  102     /* ignore the character */


#endif

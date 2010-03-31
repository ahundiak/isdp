/*****************************************************************/
/* FI.h -						 	 */
/*	This is an I/Forms ( FORMS SN01014 ) header file.	 */
/*****************************************************************/
/* Copyright 1992 Intergraph Corporation			 */
/* All Rights Reserved, Including this Release Note, the Product */
/* it Describes, its File Formats, and Visual Displays		 */
/*****************************************************************/

#ifndef FI_H_INCLUDED
#define FI_H_INCLUDED 1


	/***************************************************/
	/*** These are FI users' definitions of pointers ***/
	/***************************************************/

typedef char * Form;
typedef char * Gadget;
typedef char * Group;


	/******************/
	/*** Event mask ***/
	/******************/

#define FI_EVENT_MASK ( DELETE_EVENT  | COLLAPSE_EVENT | USER_EVENT  | \
  		       REFRESH_EVENT | BUTTON_EVENT | KEYBOARD_EVENT | \
    		        WINDOW_USER_ICON_EVENT | TIMER_EVENT )


	/********************/
	/*** Window icons ***/
	/********************/

#define	FI_REVERT_TO_ORIG_SIZE	100


  /********************************************************************/
  /*** These are passed to the window completion routine if defined ***/
  /********************************************************************/

#define FI_COLLAPSE		0
#define FI_UNCOLLAPSE		1
#define FI_REFRESH		2
#define FI_DISPLAY		3
#define FI_CHANGED_SIZE		4
#define FI_DELETE		5
#define FI_CHANGED_LOCATION	6


	/******************************************/
	/*** These are the form/menu types	***/
	/******************************************/
#define FI_FORM_TYPE			0
#define FI_BAR_MENU_TYPE		1
#define FI_PANEL_MENU_TYPE		2
#define FI_POCKET_MENU_TYPE		3
#define FI_TEAR_OFF_BAR_MENU_TYPE	4
#define FI_TEAR_OFF_PANEL_MENU_TYPE	5


	/****************************************/
	/*** These are the gadgets type names ***/
	/****************************************/

#define FI_GROUP		0
#define FI_SLIDER		1
#define FI_TOGGLE               2
#define FI_FIELD                3
#define FI_CHECKLIST		4
#define FI_DIAL			5
#define FI_TEXT			6
#define FI_BUTTON		7
#define FI_LINE			8
#define FI_GAUGE		9
#define FI_RECT			10
#define FI_SYM			11
#define FI_SCROLL		12
#define FI_MULTI_COL		13
#define FI_BEZEL		14


	/**********************/
	/*** Types of lines ***/
	/**********************/

#define FI_2D_LINE		0
#define FI_3D_LINE		1


	/*************************/
	/*** Type of rectangle ***/
	/*************************/

#define FI_FILLED		2


	/**********************/
	/*** Types for text ***/
	/**********************/

#define FI_NORMAL_TEXT		0
#define FI_EMBOSSED		1
#define FI_INCISED		2
#define FI_SHADOWED		3


	/****************************************/
	/*** Justification for text and field ***/
	/****************************************/

#define FI_LEFT_JUSTIFIED       0
#define FI_RIGHT_JUSTIFIED      1
#define FI_CENTER_JUSTIFIED     2
#define FI_FITTED	        3


	/*********************************/
	/*** These are the field types ***/
	/*********************************/

#define FI_ALPHA	0
#define FI_INT		1
#define FI_DOUBLE	2


	/*************************************************************/
	/*** These are the field modes by increasing functionality ***/
	/*************************************************************/

#define FI_REVIEW		1
#define FI_SINGLE_SELECT	2
#define FI_MULTI_SELECT		3
#define FI_APPEND		4
#define FI_INSERT		0


	/*******************************************/
	/*** These are the scroll control values ***/
	/*******************************************/

#define FI_TOP		0xefffffff
#define FI_PAGE_UP	0xeffffffe
#define FI_LINE_UP	0xeffffffd
#define FI_LINE_DOWN	0xeffffffc
#define FI_PAGE_DOWN	0xeffffffb
#define FI_BOTTOM	0xeffffffa

#define FI_LEFT_END	0xeffffff9
#define FI_VIEW_LEFT	0xeffffff8
#define FI_COL_LEFT	0xeffffff7
#define FI_COL_RIGHT	0xeffffff6
#define FI_VIEW_RIGHT	0xeffffff5
#define FI_RIGHT_END	0xeffffff4


	/***********************/
	/*** Dial attributes ***/
	/***********************/

#define FI_CLOCKWISE	       -1
#define FI_COUNTER_CLOCKWISE    1

#define FI_DIAL_SHELF_BORDER    0
#define FI_DIAL_NO_BORDER       1


	/*************************/
	/*** Slider attributes ***/
	/*************************/

#define FI_VERTICAL		0	
#define FI_HORIZONTAL		1


  /***************************************************************/
  /*** Gadget labels reserved by the Forms Interface subsystem ***/
  /***************************************************************/

#define FI_FORM_GROUP		0
#define FI_ACCEPT		1
#define FI_EXECUTE		2
#define FI_RESET		3
#define FI_CANCEL		4
#define FI_CVT_TO_PERM_WIN	5
#define FI_HELP			6
#define FI_CTRL_GROUP		7
#define FI_PROMPT_FIELD		9
#define FI_MSG_FIELD		10


	/************************/
	/*** Basic VLT colors ***/
	/************************/

#define   FI_OFF_WHITE		0
#define   FI_MED_GREY		1
#define   FI_BLACK		2
#define   FI_YELLOW		3
#define   FI_LT_GREY		4
#define   FI_DK_GREY		5
#define   FI_WHITE		6
#define   FI_RED		7
#define   FI_GREEN		8
#define   FI_BLUE		9
#define   FI_LT_YELLOW	       10
#define   FI_DK_RED	       11
#define   FI_DK_GREEN	       12
#define   FI_DK_BLUE	       13


	/*************************************************/
	/*** Masks passed in the FIf_set_attr function ***/
	/*************************************************/

#define FI_DEFAULT		0x00000000
#define FI_SAVE_RESTORE		0x00000001
#define FI_NO_BEZEL		0x00000002
#define FI_DISPLAY_COLLAPSED	0x00000004
#define FI_NOT_SCALABLE		0x00000008
#define FI_NOT_RESIZABLE	0x00000010
#define FI_LINE_BORDER		0x00000020


	/***********************************************************/
	/*** Masks for values to be displayed FI_SLIDER, FI_DIAL ***/
	/***********************************************************/

#define FI_LOW_VALUE		0x00000001
#define FI_VALUE 	        0x00000002
#define FI_HIGH_VALUE		0x00000004


	/***************************************/
	/*** Mask for slider's value display ***/
	/***************************************/

#define FI_MAX_MIN		0x00000008	


	/***********************************************/
	/*** Masks for the gadgets "characteristics" ***/
	/***********************************************/

#define FI_NOT_DISPLAYED	0x00000001
#define FI_NOT_ENABLED          0x00000002
#define FI_HILITED		0x00000004
#define FI_INITIAL_NOTIFY       0x00000008
#define FI_NO_COMPLETE_NOTIFY	0x00000010
#define FI_HELP_TOPIC		0x00000020
#define FI_CMD_STRING           0x00000040
#define FI_CMD_KEY 	     	0x00000080
#define FI_TEXT_GADGET          0x00000100
#define FI_NO_DITHERING		0x00000200
#define FI_VERT_SCROLL_NOTIFY   0x00000400


	/*****************************************************/
	/*** Masks for field and multicol field attributes ***/
	/*****************************************************/

#define FI_VERT_SCROLL		0x00000001
#define FI_HORT_SCROLL		0x00000002
#define FI_DISPLAY_VSCROLL	0x00000004
#define FI_DISPLAY_HSCROLL	0x00000008


	/***************************************/
	/*** Masks for field attributes only ***/
	/***************************************/

#define FI_ROLL_THRU		0x00000010   /* mode MUST be	  */
					     /*  FI_SINGLE_SELECT */
#define FI_WRAP			0x00000020
#define FI_CLEAR_ON_SELECTION	0x00000040
#define FI_NOTIFY_BY_LINE	0x00000080

#define FI_ASSOCIATED_LIST	0x80000000
#define FI_POPUP_ASSO_LIST	0x00000200
#define FI_DISMISS_LIST_ON_SEL	0x00000400
#define FI_VALIDATE_BY_LIST	0x00000800

#define FI_ASCII_INPUT_ONLY	0x00001000
#define FI_NO_ECHO		0x00002000
#define FI_REQUIRED		0x00004000
/* Hebrew 30-07-90 */
#define FI_LEFT_TO_RIGHT	0x00000000
#define FI_RIGHT_TO_LEFT	0x00008000
#define FI_REVERSE_INPUT	0x00010000
#define FI_REVERSE_OUTPUT	0x00020000


	/****************************************************/
	/*** Masks for multi-column field attributes only ***/
	/****************************************************/

#define FI_DISABLE_VSCROLL	0x00000010
#define FI_DISABLE_HSCROLL	0x00000020
#define FI_ROW_SELECT		0x00000040
#define FI_NO_ROW_BUTTONS       0x00000080


	/******************************************/
	/*** These are the possible form levels ***/
	/******************************************/

#define FI_HIGH_PRIORITY	    32767
#define FI_NORMAL_PRIORITY		0
#define FI_LOW_PRIORITY		   -32768


	/************************************/
	/*** These are the screen defines ***/
	/************************************/

#define FI_LEFT_SCREEN			0
#define FI_CURRENT_SCREEN		1
#define FI_RIGHT_SCREEN			2
#define FI_BACK_SCREEN			3


	/*************************/
	/*** Other definitions ***/
	/*************************/

#define FI_MAX_FILENAME_LENGTH		15
#define FI_SCROLL_SIZE                  25


	/*******************************/
	/*** "font_type" definitions ***/
	/*******************************/

#define FI_RASTER_8_BIT_FONT_TYPE	0	
#define FI_FS_8_BIT_FONT_TYPE		1
#define FI_FS_7_OR_16_BIT_FONT_TYPE	2


	/**********************************/
	/*** form notification types	***/
	/**********************************/
#define FI_COMPLETION_NOTIFICATION	0
#define FI_INITIAL_NOTIFICATION		1
#define FI_CALL_NOTIFICATION		2


	/***********************************/
	/*** These are error definitions ***/
	/***********************************/

#define FI_SUCCESS			0
#define	FI_FORM_FILE_NOT_FOUND		1
#define	FI_FORM_FILE_READ_ERROR		2
#define FI_FORM_NOT_DISPLAYED		3
#define FI_FORM_DISPLAYED		4
#define FI_QUIET_MODE_ON		5
#define FI_NO_WINDOWS_AVAIL		6
#define FI_NO_SUCH_FORM			7
#define	FI_LABEL_IN_USE			8
#define FI_NO_SUCH_GADGET		9
#define	FI_NO_MEMORY			10
#define FI_NO_SUCH_GROUP		11
#define FI_NO_PASS_ON			12
#define FI_NO_SUCH_VS			13
#define FI_INVALID_GADGET_TYPE		14
#define FI_INVALID_FORMAT		15
#define FI_INVALID_VERSION		16
#define FI_ILLEGAL_VALUES		17
#define	FI_FORM_FILE_OPEN_DENIED	18
#define FI_INVALID_BUFFER		19
#define FI_LOAD_FONT_ERROR		20
#define FI_NO_SUCH_ENV_FUNCTION 	21
#define FI_INVALID_ROW                  22
#define FI_INVALID_COL                  23
#define FI_NO_CONNECTION                24
#define FI_UNABLE_TO_SAVE_FORM		25
#define FI_FORM_FILE_SAVE_ERROR         26
#define FI_INVALID_NEWER_FORM_VERSION	27



    /*******************************************/
    /* Return codes for FIfld_get_notify_info  */
    /*******************************************/

#define FI_SELECTED_UNKNOWN_ACTION -1
#define FI_SELECTED_KEYBOARD 1
#define FI_SELECTED_ASSOCIATED_LIST 2
#define FI_SELECTED_MOUSE_BUTTON 3


#endif

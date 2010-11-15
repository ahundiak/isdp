/* Do not alter this SPC information: $Revision: 1.1.31.1 $ */
/********************************************************************
Name:				rescom.h
Authors:       Rick Kramer
Creation Date: 03/28/95
Description:   Header file for Utility Common Resources

Revision History:

********************************************************************/
/********************************************************
General
********************************************************/
// controls

// Debug Menu ID's
#define IDM_DEBUG				300
#define IDM_GUI_DEBUG		IDM_DEBUG+1
#define IDM_RIS_DEBUG		IDM_DEBUG+2

// Status Bar ID's
#define ID_STATUSBAR			IDM_DEBUG+3
#define ID_MENUFIELD			IDM_DEBUG+4
#define ID_TIMEFIELD			IDM_DEBUG+5


// Menu ID's
#define IDM_FILE						330
#define IDM_FILE_EXIT  				IDM_FILE+1

#define IDM_EDIT_CUT		332
#define IDM_EDIT_COPY	333
#define IDM_EDIT_PASTE	334

#define IDM_UTIL						340
#define IDM_UTIL_DCODE				IDM_UTIL+1
#define IDM_UTIL_CLNSR				IDM_UTIL+2
#define IDM_UTIL_DTYPE				IDM_UTIL+3
#define IDM_UTIL_RECRD				IDM_UTIL+4
#define IDM_UTIL_PLBCK				IDM_UTIL+5
#define IDM_UTIL_UNLOD				IDM_UTIL+6
#define IDM_UTIL_LOD					IDM_UTIL+7
#define IDM_UTIL_BATCH				IDM_UTIL+8
#define IDM_UTIL_GUI					IDM_UTIL+9
#define IDM_UTIL_MGR					IDM_UTIL+10

#define IDM_HELP						360
#define IDM_HELP_PROGRAM			IDM_HELP+1
#define IDM_HELP_CONTENTS			IDM_HELP+2
#define IDM_HELP_SEARCH				IDM_HELP+3
#define IDM_HELP_USE					IDM_HELP+4
#define IDM_HELP_PRODUCT_SUPPORT	IDM_HELP+5
#define IDM_HELP_ABOUT				IDM_HELP+6

//demo
#define IDM_DEMO_MB1	600
#define IDM_DEMO_MB2	601
#define IDM_DEMO_MB3	602
#define IDM_DEMO_MB4	603
#define IDM_DEMO_VIEW50		604
#define IDM_DEMO_VIEW100	605
#define IDM_DEMO_VIEW200	606
#define IDM_DEMO_PWIN	607
#define IDM_DEMO_MRU		608
#define IDS_DEMO_CAPTION  609
#define IDS_DEMO_TEXT     610
#define IDS_DEMO_VIEW50	611
#define IDS_DEMO_VIEW100	612
#define IDS_DEMO_VIEW200	613
#define IDM_DEMO_PH1	620
#define IDM_DEMO_PH2	621
#define IDM_DEMO_PH3	622
#define IDM_DEMO_PH4	623


// String Table
#define IDS_READY				400
#define IDS_DEBUG				401
#define IDS_ACCEL_FAIL		402
#define IDS_SBAR_FAIL		403
#define IDS_HELP_FAIL		404
#define IDS_ERROR				405
#define IDS_UTIL_ERROR	 	406
#define IDS_UTILITIES		407
#define IDS_HELP				408// Menu Item Description
#define IDS_WINERROR			409// For _WinError


/********************************************************
About
********************************************************/
// dialog
#define IDD_ABOUT				320
#define IDC_ABOUT_DESC 		IDD_ABOUT+1
#define IDC_ABOUT_VER		IDD_ABOUT+2 
#define IDC_ABOUT_ICON		IDD_ABOUT+3
#define IDC_ABOUT_CR			IDD_ABOUT+4
#define IDC_ABOUT_TM			IDD_ABOUT+5

//strings
#define IDS_ABOUT	500

/********************************************************
GUI debug
********************************************************/
// dialog
#define IDD_GDEBUG		330
#define BUG_OFF			331	/* debug inactive */
#define BUG_ON				332	/* debug active */
#define BUG_COUNT			333	/* count debug events */
#define BUG_DISPLAY		334	/* display debug events */
#define BUG_FILE_LINE	335	/* display file name & line numbers */
#define BUG_FILTER		336	/* filter debug events */
#define BUG_FILTERLIST	337	/* debug filter list */
#define BUG_LOG			338	/* log debug events */
#define BUG_LOGFILE		339	/* debug log file */
#define BUG_OK				340	/* OK button */
#define BUG_CANCEL		341	/* CANCEL button */


/********************************************************
RIS Debug
********************************************************/
//dialog
#define IDD_RISDBG					350
#define IDC_RDBG_FLAGS			 	IDD_RISDBG+1
#define IDC_RDBG_CMEM			 	IDD_RISDBG+2
#define IDC_RDBG_CSTATE	  			IDD_RISDBG+3
#define IDC_RDBG_HASH	  			IDD_RISDBG+4
#define IDC_RDBG_SCHEMA	  			IDD_RISDBG+5
#define IDC_RDBG_AMEM	  			IDD_RISDBG+6
#define IDC_RDBG_ASTATE	  			IDD_RISDBG+7
#define IDC_RDBG_STRUCTS  			IDD_RISDBG+8
#define IDC_RDBG_SERVERS  			IDD_RISDBG+9
#define IDC_RDBG_GB_FLAGS 			IDD_RISDBG+10
#define IDC_RDBG_GB_SHOW  			IDD_RISDBG+11
#define IDC_RDBG_DISPLAY  			IDD_RISDBG+12
#define IDC_RDBG_ALLOFF	  			IDD_RISDBG+13
#define IDC_RDBG_LBBUTTON 			IDD_RISDBG+14


/********************************************************
Product Support
********************************************************/
// dialog
#define IDD_PRODSUP				12000
#define IDC_PRODSUP_TEXT		IDD_PRODSUP+1
#define IDC_PRODSUP_BITMAP		IDD_PRODSUP+2

// strings
#define IDS_PRODSUP_TEXT		IDD_PRODSUP+3

/********************************************************
demo
********************************************************/
#define IDD_DEMO				699




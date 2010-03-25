#ifndef _EMERROR
#define _EMERROR	0


/************************************************************************/
/*									*/
/*	Error Code Definitions						*/
/*									*/
/*	The following error codes are returned by the emulator		*/
/*	tools routines.							*/
/*									*/
/************************************************************************/

#define	EM_NO_ERROR			 0
#define	EM_MALLOC_FAILED		 1
#define	EM_TCB_LIST_FULL		 2
#define	EM_GLOBAL_INIT_FAILED		 3
#define	EM_OPEN_TRANS_FAILED		 4
#define	EM_READ_TRANS_FAILED		 5
#define	EM_OPEN_MODE_FAILED		 6
#define	EM_READ_MODE_FAILED		 7
#define	EM_LOAD_FONT_FAILED		 8
#define	EM_INVALID_TCBD			 9
#define	EM_INVALID_FONT			10
#define	EM_ROW_OUT_OF_RANGE		11
#define	EM_COLUMN_OUT_OF_RANGE		12
#define	EM_INVALID_EVENT		13
#define	EM_PRINTER_PORT_NOT_OPEN	14
#define	EM_INVALID_PRINTER_PORT		15
#define	EM_C_MENU_ERROR			16
#define	EM_C_HELP_MENU_ERROR		17
#define	EM_G_MENU_ERROR			18
#define	EM_G_HELP_MENU_ERROR		19
#define	EM_D_MENU_ERROR			20
#define	EM_D_HELP_MENU_ERROR		21
#define	EM_K_MENU_ERROR			22
#define	EM_K_HELP_MENU_ERROR		23
#define	EM_T_MENU_ERROR			24
#define	EM_T_HELP_MENU_ERROR		25
#define	EM_P_MENU_ERROR			26
#define	EM_P_HELP_MENU_ERROR		27
#define	EM_M_MENU_ERROR			28
#define	EM_M_HELP_MENU_ERROR		29

#define	EM_LOG_FILE_ERROR		30

#define	EM_LOG_FILE_ERRMSG "Cannot create or overwrite the specified log file"

#endif

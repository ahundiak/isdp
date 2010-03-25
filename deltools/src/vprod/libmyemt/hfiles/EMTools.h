#ifndef _EMTOOLS
#define _EMTOOLS	0


/************************************************************************/
/*									*/
/*	This include file contains all an application needs in		*/
/*	order to use the VT220 emulation tools routines.		*/
/*									*/
/************************************************************************/

#include <EMTerm.h>
#include <EMError.h>



/************************************************************************/
/*									*/
/*	This is for support of old routine names.			*/
/*									*/
/************************************************************************/

#define	EM_VT220_setup_menus		EMSetupMenus
#define	EM_VT220_create			EMCreate
#define	EM_VT220_create_term		EMCreateTerm
#define	EM_VT220_close			EMClose
#define	EM_VT220_translate		EMTranslate
#define	EM_VT220_write			EMWrite
#define	EM_VT220_update			EMUpdate
#define	EM_VT220_setup			EMSetup
#define	EM_VT220_window_size		EMWindowSize
#define	EM_VT220_set_printer_port	EMSetPrinterPort
#define	EM_VT220_clear_screen		EMClearScreen
#define	EM_VT220_reset_terminal		EMResetTerminal
#define	EM_VT220_get_size		EMGetSize
#define	EM_VT220_get_cursor		EMGetCursor
#define	EM_VT220_blink_cursor		EMBlinkCursor
#define	EM_VT220_set_logfile_name	EMSetLogFileName
#define	EM_VT220_set_logfile_stat	EMSetLogFileStatus
#define	EM_VT220_scroll_up		EMScrollUp
#define	EM_VT220_scroll_down		EMScrollDown
#define	EM_VT220_move_scroll		EMMoveScroll
#define	EM_VT220_get_bufsize		EMGetBufferSize
#define	EM_VT220_get_bufpos		EMGetBufferPos
#define	EM_VT220_text_select		EMTextSelect
#define	EM_VT220_clear_selection	EMClearSelection
#define	EM_VT220_selection_buffer	EMGetSelection
#define	EM_VT220_get_macro_key		EMGetMacroKey
#define	EM_VT220_set_macro_key		EMSetMacroKey
#define	EM_VT220_get_parms		EMGetParms
#define	EM_VT220_set_parms		EMSetParms


#endif

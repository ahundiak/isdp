/* Do not alter this SPC information: $Revision: 1.2.27.1 $ */
/*
**	NAME:							ucoanyky.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					6/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#if defined(WIN32S)
#include <windows.h>
#include <windowsx.h>
#include "winport.h"
#include "winio.h"
#include "winhan.h"
#endif
#if !defined(WIN32S)
#include <stdio.h>
#endif
#if defined(WIN32) || defined(DOS)
#include <conio.h>
#endif
#include "ucommon.h"
#include "risutl.h"
#include "utl_inf.h"
#if defined(WIN32S)
#include "prog32s.h"
#endif 

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define dtyanyky_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "ucoanyky.prt"
#include "ucoterm.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RISuco_any_key_to_continue()
{
	char wrk[10];

	UCO_DBG(("RISuco_any_key_to_continue()\n"));

	PRINTF(MSG(RISUTL_I_ANY_KEY));
#if defined(unix)
        RISuco_set_terminal_noecho_raw();                   
#endif 

#if defined(WIN32) || defined(DOS)
	GETS(wrk);
#endif

#if defined(unix)
        getchar();                                             
#endif                                                          

#if defined(unix)
        RISuco_reset_terminal();                                
#endif  

	UCO_DBG(("RISuco_any_key_to_continue:returning\n"));
}

/******************************************************************************/

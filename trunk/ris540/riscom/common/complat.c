/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							complat.c
**	AUTHORS:						Rick Kramer
**	CREATION DATE:					08/22/94
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <windows.h>
#include "riscom.h"
#include "risdebug.h"
#include "ris.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define complat_c
#include "complat.prt"
#include "comdebug.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern int RIScom_get_platform(
	)
{
/* This function returns the WIN32 platform that the user is running under */
	DWORD    win_vers;

    win_vers = GetVersion();
    if( ( win_vers & 0x80000000 ) == 0 )
    {
        /* this is real Windows NT */
		if (LOBYTE( LOWORD( win_vers ) ) ==3 &&
			HIBYTE( LOWORD( win_vers ) ) == 10)
		{
			COM_DBG(("RISget_platform(WIN32 ret_value:<%d>)\n", IS_WIN32));
			return (IS_WIN32);
		}
		else
		{
			COM_DBG(("RISget_platform(DAYTONA ret_value:<%d>)\n", IS_DAYTONA));
			return(IS_DAYTONA);
		}
    }
    else
    {
        if( LOBYTE( LOWORD( win_vers ) ) < 4 )
        {
            /* this is Win32s running on 16-bit Windows 3.1,
               because the program is running in 32-bit mode it
               cannot easily determine the version of Win32s as
               that info comes from a 16-bit DLL - good innit.
               the program *could* work out the version, but it
               would require a 16-bit DLL to thunk to, and that
               just is not worth the effort. */
				COM_DBG(("RISget_platform(WIN32s ret_value:<%d>)\n", IS_WIN32S));
            return(IS_WIN32S);
        }
        else
        {
            /* this is Chicago - Windows 4.x */
				COM_DBG(("RISget_platform(CHICAGO ret_value:<%d>)\n", IS_CHICAGO));
            return(IS_CHICAGO);
        }
    }
}/* RIScom_get_platform */

/******************************************************************************/

/* Do not alter this SPC information: $Revision: 1.3.26.1 $ */
/*
** NAME:       ucoanyky.c
** AUTHORS:	  Terrence McIntyre
** CREATION DATE:	6/93
** ABSTRACT:
** 
** REVISION HISTORY:
*/
 
/*
** INCLUDES
*/
#include <stdio.h>
#if defined(WIN32) || defined(DOS)
#include <conio.h>
#endif
#include "ucommon.h"
#include "risutl.h"
#include "utl_inf.h"
#include "ris.h" /* win95 */
#include "ris.prt" /* win95 */
/*
** DEFINES
*/

/*
** TYPES
*/

/*
** FUNCTION PROTOTYPES
*/
#define ucoanyky_c
#include "comdebug.prt"
#include "comumsg.prt"
#include "ucoanyky.prt"
#include "ucoterm.prt"
#include "sys.prt"

/*
** VARIABLES
*/

/*
** FUNCTIONS
*/

/******************************************************************************/

extern void RISuco_any_key_to_continue()
{
   UCO_DBG(("RISuco_any_key_to_continue()\n"));

   PRINTF(MSG(RISUTL_I_ANY_KEY));

#if defined(unix)
   RISuco_set_terminal_noecho_raw();
#endif

#if defined(DOS)
   _getch();
#elif defined(WIN32)
   if (RISget_platform() == IS_CHICAGO)
      getchar();/* win95 */
   else     
   _getch();
#elif defined(unix)
   getchar();
#endif

#if defined(unix)
   RISuco_reset_terminal();
#endif

   UCO_DBG(("RISuco_any_key_to_continue:returning\n"));
}

/******************************************************************************/

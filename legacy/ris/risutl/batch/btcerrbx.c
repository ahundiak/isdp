/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							btcerrbx.c
**	AUTHORS:						Rick Kramer
**	CREATION DATE:					1/93
**	ABSTRACT:
**		WIN32S version if RISuco_file_error_box
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <windows.h>
#include "risutl.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define btcerrbx_c
#include "btcerrbx.prt"
#include "comdebug.prt"
#include "comumsg.prt"
#include "comdebug.prt"
#include "ucoumsg.prt"

/*
**	VARIABLES
*/


/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIS32s_file_error_box(
	int		type,
	int		name,
	int		number,
	char	*middle_line,
	int		message,
	int		last_line)
{
	char err_code[255];
	char mess[255];
	char tot_strng[255];

	sprintf(err_code,"%s: %s",CHECK_UNINIT_MSG(type, "Error"),
		RIScom_error_code(number),RIScom_umsg(number));

	sprintf(mess,"%s",RIScom_umsg(number));
	sprintf(tot_strng,"%s\n\n%s",err_code,mess);

	MessageBox(NULL,tot_strng,"Error",MB_OK | MB_ICONSTOP | MB_TASKMODAL);
}

/******************************************************************************/

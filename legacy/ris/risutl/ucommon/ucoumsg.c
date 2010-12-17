/* Do not alter this SPC information: $Revision: 1.4.26.1 $ */
/*
**	NAME:							ucoumsg.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					4/93
**	ABSTRACT:
**		The functions gets the ris directory, checks the RIS_LANGUAGE
**		environment variable, and initializes UMS.	This routine can
**		LONGJMP.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "ucommon.h"
#include "riscom.h"
#include "risums.h"
#include "risutl.h"
#include "risver.h"
#include "risprods.h"
#include "risstjmp.h"
#if defined(WIN32)
#include "windows.h"
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
#define ucoumsg_c
#include "ucoumsg.prt"
#include "comdebug.prt"
#include "comumsg.prt"
#include "comgtdir.prt"
#include "comjmp.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern void RISuco_initialize_ums(
	int mask)
{
	int		sts;
	int		development;
	char	*language;
	char	dir[RIS_MAX_PATH_SIZE];

	UCO_DBG(("RISuco_initialize_ums(mask:0x%x)\n", mask));

	sts = RIScom_get_risdir(RIS_CLIENT_RUNTIME_PRODUCT, RIS_version_maj,
		RIS_version_min, RIS_version_rel, MATCH_HIGHEST,
		0, RISCONFIG_FILE, dir, &development, 0);
	if (sts != 0)
	{
		LONGJMP(sts);
	}

	/*
	**  Get language
	*/
#if defined(unix) || defined(DOS)
	language = getenv("RIS_LANGUAGE");
#elif defined(WIN32)
	language = NULL;
#endif

	if (mask & INIT_UTL_UMS_FILE)
	{
		RIScom_init_ums_msg(UTL_UMS_FILE, dir, development, language);
	}
	if (mask & INIT_RIS_UMS_FILE)
	{
		RIScom_init_ums_msg(RIS_UMS_FILE, dir, development, language);
	}
	if (mask & INIT_NET_UMS_FILE)
	{
		RIScom_init_ums_msg(NET_UMS_FILE, dir, development, language);
	}

	UCO_DBG(("RISuco_initialize_ums:returning\n"));
	return;
}

/******************************************************************************/

extern const char *RISuco_check_uninit_msg(
	int no,
	char *default_msg)
{
	const char *msg;

	msg = MSG(no);
	if (!strncmp(msg, "Message file not initialized", 28))
	{
		msg = default_msg;
	}

	return msg;
}

/******************************************************************************/

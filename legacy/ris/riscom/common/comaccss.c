/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							comaccss.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/90
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscl_pa.h"
#include "risdebug.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define comaccss_c
#include "comaccss.prt"
#include "comauth.prt"
#include "comdebug.prt"
#include "sys.prt"

/******************************************************************************/

extern char * RIScom_combine_access(
	risaccess * acc_list,
	char * schname,
	int public_flag,
	char * access)
{
	risaccess * temp;

	COM_DBG(("RIScom_combine_access(acclist:0x%x schname:<%s> public_flag:%d access:0x%x\n", acc_list, STRING(schname), public_flag, access));

	RIScom_init_auth(access);

/* get public and individual access */

	for (temp=acc_list;temp;temp=temp->next)
	{
		if ((public_flag && strcmp("PUBLIC",temp->grantee) == 0) ||
		 strcmp(schname,temp->grantee) == 0)
		{
			RIScom_add_auth(access,temp->auth);
		}
	}
	return(access);
}

/******************************************************************************/

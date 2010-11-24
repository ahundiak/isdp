/* Do not alter this SPC information: $Revision: 1.2.40.1 $ */
/*
**	NAME:							netumsg.c
**	AUTHORS:						Jin Jing
**	CREATION DATE:					8/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include <ctype.h>
#include <string.h>

#include "risnet.h"


#ifdef UMS_SUPPORTED
#include <UMS.h>
#include <pums_pub.h>
#endif


#define LOAD_COMO_MEMORY (UMS_INDEX | UMS_MESSAGE)

static  int NET_umsg_initialized;

/******************************************************************************/
extern int NET_init_error_msg()
{

	int	status;

	NET_DBG(("NET_init_error_msg()\n"));

	if (NET_umsg_initialized)
	{
		return 0;
	}

#ifdef UMS_SUPPORTED
	NET_DBG(("NET_init_error_msg: NET_ums_file:<%s>\n", NET_ums_file));
	
	status = UMSInitMsg(NET_ums_file, LOAD_COMO_MEMORY);
	if (status == UMS_S_SUCCESS || status == UMS_I_DUPINIT)
	{
		NET_umsg_initialized = 1;
	}
	else
	{
		NET_DBG(("UMSInitMsg Error = %d.\n", status));
		return -1;
	}
#else
	NET_umsg_initialized = 1;
#endif
	NET_DBG(("NET_init_error_msg:complete\n"));
	return 0;
}

/******************************************************************************/

extern char *NET_error_msg(int code)
{
	int	status;
	static  char	ums_msg[200];

	NET_DBG(("NET_error_msg(code:0x%x)\n", code)); 

	if (code == NET_SUCCESS)
	{
		strcpy(ums_msg, "Successful Network Event");	
	}
	else
	{
		status = NET_init_error_msg();
		if (!status)
		{
#ifdef UMS_SUPPORTED
  			status = UMSGetByNum(ums_msg, code & 0x7fffffff, 0);
			if (status != UMS_S_SUCCESS)
			{
				sprintf(ums_msg, "Message not found for 0x%x", code);	
			}
#else
			sprintf(ums_msg, "Message file not found for 0x%x", code);	
#endif
		}
		else
		{
			sprintf(ums_msg, "Message file not found for 0x%x", code);	
		}
	}
	
	NET_DBG(("NET_error_msg: ums_msg: <%s>\n", ums_msg));
	return ums_msg;
}

/******************************************************************************/

extern void NET_clear_ums_msg(void)
{
	int	status;

	NET_DBG(("RIScom_clear_ums_msg()\n"));

	if (!NET_umsg_initialized)
	{
		return;
	}
#ifdef UMS_SUPPORTED
	NET_DBG(("NET_clear_ums_msg: NET_ums_file:<%s>\n", NET_ums_file));

	status = UMSClearMsg(NET_ums_file);
	if (status == UMS_S_SUCCESS)
	{
		NET_umsg_initialized = 0;
	}
	else
	{
		NET_DBG(("UMSClearMsg Error = %d.\n", status));
	}
#else
	NET_umsg_initialized = 0;
#endif

	NET_DBG(("NET_clear_ums_msg:complete\n"));
}

/******************************************************************************/

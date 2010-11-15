/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							comexmod.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					3/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define comexmod_c
#include "comexmod.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

extern char *RIScom_get_execute_mode_name(
	unsigned char execute_mode)
{
	char		*ptr;
	static  char	s[48];
	
	switch(execute_mode)
	{
		case 0:					return "ZERO";
		case SYNC_MODE:			return "SYNC_MODE";
		case ASYNC_START_MODE:	return "ASYNC_START_MODE";
		case ASYNC_TEST_MODE:	return "ASYNC_TEST_MODE";
		case ASYNC_WAIT_MODE:	return "ASYNC_WAIT_MODE";
		default:
			ptr = s;	
			if (execute_mode & START_MODE)
			{
				ptr += sprintf(ptr, "START_MODE");
			}

			if (execute_mode & FINISH_MODE)
			{
				if (ptr != s)
				{
					*ptr++ = '|';
				}
				ptr += sprintf(ptr, "FINISH_MODE");
			}

			if (execute_mode & BLOCKING_MODE)
			{
				if (ptr != s)
				{
					*ptr++ = '|';
				}
				ptr += sprintf(ptr, "BLOCKING_MODE");
			}
			break;
	}
	return s;
}

/******************************************************************************/

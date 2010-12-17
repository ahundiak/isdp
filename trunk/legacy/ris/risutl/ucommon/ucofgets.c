/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							ucofgets.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					1/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
/*START_PRT_INCLUDE*/
#include <stdio.h>
/*STOP_PRT_INCLUDE*/

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define ucofgets_c
#include "ucofgets.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern char *RISuco_fgets(
	char	*s,
	int		n,
	FILE	*stream)
{
	char *sts;

	if ((sts = fgets(s,n,stream)) == NULL)
	{
		return(NULL);
	}
	if ((sts = strchr(s,'\n')) != NULL)
	{
		*sts = 0;
	}
	return s;
}

/******************************************************************************/

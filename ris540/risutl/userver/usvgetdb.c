/* Do not alter this SPC information: $Revision: 1.1.53.1 $ */
/*
**	NAME:							usvgetdb.c
**	AUTHORS:						Terrence D. McIntyre
**	CREATION DATE:					2/94
**	ABSTRACT:

	RISusv_get_database() determines the database type associated with
	a schema.

	INPUT: char *schname -- the name of the schema.
	OUTPUT: char **database -- the address of a char ptr to receive the
							   the database type string.

	RETURN:  returns 0 on success, 1 on failure.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdio.h>
#include "userver.h"
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
#define usvgetdb_c
#include "comdebug.prt"
#include "usvgetdb.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern char *RISusv_get_database_string(
	char dtype)
{
	char *return_sts = NULL;

	USV_DBG(("RISusv_get_database(dtype:<%c>)\n",dtype));

	switch(dtype)
	{
		case 'X':	return_sts = "informix"; break;
		case 'O':	return_sts = "oracle"; break;
		case 'I':	return_sts = "ingres"; break;
		case 'R':	return_sts = "rdb"; break;
		case 'D':	return_sts = "db2"; break;
		case 'Y':	return_sts = "sybase"; break;
		case 'M':	return_sts = "mssql"; break;
	}

	USV_DBG(("RISusv_get_database:returning:<%s>\n", STRING(return_sts)));
	return return_sts;
}

/******************************************************************************/

/* Do not alter this SPC information: $Revision: 1.3.26.1 $ */
/*
**	NAME:							ucoshfil.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					7/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "ucommon.h"
#include "risutl.h"
#include "rislimit.h"
#include "utl_inf.h"
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
#define ucoshfil_c
#include "comdebug.prt"
#include "comoutpt.prt"
#include "comumsg.prt"
#include "ucoshfil.prt"
#include "ris.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern void RISuco_show_schfile(
	int             (* output_func)(const char *, ...)
)
{
	char				*schema_filename;
	ris_db_info			*dblist, *db;
	ris_schema_info		*schemalist, *schema;
	ris_grantee_info	*granteelist, *grantee;
	ris_parameters		p;

	UCO_DBG(("RISuco_show_schfile()\n"));

	RISget_parameters(&p);
	if (SQLCODE != RIS_SUCCESS)
	{
		UCO_DBG(("RISuco_show_schfile:RISget_parameters failed: returning\n"));
		return;
	}

	RISget_schema_file(&schema_filename, &dblist, &schemalist, &granteelist);
	if (SQLCODE != RIS_SUCCESS)
	{
		UCO_DBG(("RISuco_show_schfile:RISget_schema_file failed: returning\n"));
		return;
	}

	output_func(MSG(RISUTL_I_SHOW_SCHFILE_1));
	switch(p.schema_file_protocol)
	{
		case 'M':
			output_func(MSG(RISUTL_I_SHOW_SCHFILE_2));
			break;

		case 'T':
			output_func(MSG(RISUTL_I_SHOW_SCHFILE_3), p.schema_file_address);
			break;

		case 'X':
			output_func(MSG(RISUTL_I_SHOW_SCHFILE_4), p.schema_file_address);
			break;

		case 'D':
			output_func(MSG(RISUTL_I_SHOW_SCHFILE_5), p.schema_file_address);
			break;
	}
	output_func(MSG(RISUTL_I_SHOW_SCHFILE_6), schema_filename);

	while(schemalist)
	{
		schema = schemalist;
		schemalist = schemalist->next;

		output_func("\n");
		RIScom_output_schema_info(output_func, schema, 0);
		for(grantee = granteelist; grantee; grantee = grantee->next)
		{
			if (!strcmp(schema->schname, grantee->schname))
			{
				output_func(MSG(RISUTL_I_SHOW_SCHFILE_7), grantee->grantee);
			}
		}

		free(schema);
	}

	while(granteelist)
	{
		grantee = granteelist;
		granteelist = granteelist->next;

		free(grantee);
	}

	while(dblist)
	{
		db = dblist;
		dblist = dblist->next;

		output_func("\n");
		RIScom_output_db_info(output_func, db, 0);

		free(db);
	}

	UCO_DBG(("RISuco_show_schfile: complete\n"));
}

/******************************************************************************/

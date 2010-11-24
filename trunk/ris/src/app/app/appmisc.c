/*
**	NAME:							appmisc.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
#include <stdlib.h>
#include <string.h>

#include "risapp.h"
#include "risasync.h"
#include "rismem.h"
#include "riscom.h"
#include "risdebug.h"
#include "ris_err.h"

/******************************************************************************/

extern void RISapp_net_errhandle(struct net_s *net)
{
	int		len;
	APP_DBG(("RISapp_net_errhandle(net:0x%x)\n", net));

	/*
	**	Fill in dbca
	*/
	dbca->sqlcode = net->error_code;
	dbca->sqlerrm.sqlerrml =
		(short)RIScom_strcpy(dbca->sqlerrm.sqlerrmc, net->error_string);

	dbca->sqlcaid[5] = 'N';
	dbca->sqlcaid[6] = 'E';
	dbca->sqlcaid[7] = 'T';

	/*
	**	This should never be true, but it doesn't hurt to check
	*/
	if (dbca->sqlstmt != RIS_dbstmt)
	{
		dbca->sqlstmt = RIS_dbstmt;
	}

	if ((len = strlen(net->net_error_string)) > 0)
	{
		if (len > sizeof(RIS_dbstmt) - 1)
		{
			len = sizeof(RIS_dbstmt) - 1;
		}
		memcpy(dbca->sqlstmt, net->net_error_string, len);
		dbca->sqlstmt[len] = '\0';
	}
	else
	{
		*dbca->sqlstmt = '\0';
	}

	APP_DBG(("RISapp_net_errhandle: complete\n", net));
	LONGJMP(RIS_E_CLIENT_NETWORK_ERROR);
}

/******************************************************************************/

extern void RISapp_arc_errhandle(struct arc_s *arc)
{
    int     len;

    APP_DBG(("RISapp_arc_errhandle()\n"));

    dbca->sqlcode = arc->error_code;
    dbca->sqlerrm.sqlerrml =
        (short)RIScom_strcpy(dbca->sqlerrm.sqlerrmc, arc->error_string);

    dbca->sqlcaid[5] = 'A';
    dbca->sqlcaid[6] = 'R';
    dbca->sqlcaid[7] = 'C';

    if (dbca->sqlstmt)
    {
        if ((len = strlen((const char *)arc->arc_error_string)) > 0)
        {
            if (len > RIS_MAX_STMT_LEN - 1)
            {
                len = RIS_MAX_STMT_LEN - 1;
            }
            memcpy(dbca->sqlstmt, arc->arc_error_string, len);
            dbca->sqlstmt[len] = '\0';
        }
        else
        {
            *dbca->sqlstmt = '\0';
        }
    }

    APP_DBG(("RISapp_arc_errhandle:complete\n"));
    LONGJMP(RIS_E_ARCH_ERROR);
}

/******************************************************************************/

extern void RISapp_check_alignment()
{
	APP_DBG(("RISapp_check_alignment()\n"));

	if (RIS_APPCLI_HDR_SIZE % 8)
	{
		APP_DBG(("check_alignment: INTERNAL ERROR: RIS_APPCLI_HDR_SIZE:%d\n",
			RIS_APPCLI_HDR_SIZE));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	if (RIS_CLIAPP_HDR_SIZE % 8)
	{
		APP_DBG(("check_alignment: INTERNAL ERROR: RIS_CLIAPP_HDR_SIZE:%d\n",
			RIS_CLIAPP_HDR_SIZE));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	if (sizeof(ris_block_info) % 8)
	{
		APP_DBG(("check_alignment: INTERNAL ERROR: sizeof(ris_block_info):%d\n",
			sizeof(ris_block_info)));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	APP_DBG(("RISapp_check_alignment:complete\n"));
}

/******************************************************************************/

extern void RISapp_process_eot_schname_list(int count, char *data)
{
	int		i;
	char	*schname;

	APP_DBG(("RISapp_process_eot_schname_list(count:%d data:0x%x)\n",
		count, data));

	for(schname = data, i = 0; i < count; schname += RIS_MAX_ID_SIZE, i++)
	{
		if (!strcmp(schname,"all"))
		{
			RISapp_close_all_cursors();
			break;
		}
		else
		{
			RISapp_close_all_cursors_for_schema(schname);
		}
	}

	APP_DBG(("RISapp_process_eot_schname_list:complete\n"));
}

/******************************************************************************/

extern void RISapp_process_clear_stmt_list(int count, char *data)
{
	int		i;
	short	*id;

	APP_DBG(("RISapp_process_clear_stmt_list(count:%d data:0x%x)\n",
		count, data));

	for(id = (short *)data, i = 0; i < count; id++, i++)
	{
		APP_DBG(("RISapp_process_clear_stmt_list: clearing id:%d\n", *id));
		RISapp_clear(id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT, SYNC_MODE);
	}

	APP_DBG(("RISapp_process_clear_stmt_list:complete\n"));
}

/******************************************************************************/

/*
**	NAME:							dicview.c
**	AUTHORS:						David Michal
**	CREATION DATE:					10/90
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "ristoken.h"
#include "ris_err.h"
#include "dict.h"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define dicview_c
#include "dicrem.prt"
#include "dictrans.prt"
#include "dicview.prt"
#include "usrsndrc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "ccoren.prt"
#include "sys.prt"

/******************************************************************************/

extern void RISdic_create_view(
	risstmt *stmt,
	int exec_mode)
{
	ristree *tp = stmt->tree->rhs;
	rissql  *sql = stmt->sql;
	char    *p;
	int     status;
	int     attempts = 0;

	DIC_DBG(("RISdic_create_view(stmt:0x%x exec_mode:%d)\n", stmt, exec_mode));

	if (strlen(tp->info.tab->tabname) > RIS_MAX_OS400_ID_SIZE && 
		sql->schema->db->dtype == '4')
	{
		while (1)
		{
			status = SETJMP();
			if (!status)
			{
				RISusr_send_rec(RIS_CREATE_VIEW_CODE, stmt->sql,
					(unsigned short)exec_mode);
				RESETJMP();
				break;
			}
			else
			{
				char	*pos;

				RESETJMP();
				if (status != RIS_E_TABVIEW_ALREADY_EXISTS)
				{
					LONGJMP(status);
				}
				if (++attempts>RIS_MAX_ATTEMPTS)
				{
					LONGJMP(RIS_E_EXCEED_MAX_ATTEMPTS);
				}
				RIScco_next_extern_table_name(
					tp->info.tab->tabname,
					tp->info.tab->extern_tabname);
				p = tp->info.tab->extern_tabname +
					strlen(tp->info.tab->extern_tabname)-1;
				while ((*p == ' ') || (*p == '\t'))
					*p-- = '\0';
				pos = strstr(sql->query, "/"); /*itbokic */
                if (pos == NULL)
                {
                    LONGJMP(RIS_E_INTERNAL_ERROR);
                }
				strncpy(pos+1, tp->info.tab->extern_tabname, /*itbokic */
					strlen(tp->info.tab->extern_tabname));
				strcpy(sql->ext_relname, tp->info.tab->extern_tabname);
				DIC_DBG(("RETRY ATTEMPTS: [%d] sql->query: <%s>\n", 
					attempts, sql->query));
			}
		}
	}
	else
	{
		RISusr_send_rec(RIS_CREATE_VIEW_CODE, stmt->sql,
			(unsigned short)exec_mode);
	}
	DIC_DBG(("RISdic_create_view:returning\n"));
}

/******************************************************************************/

extern void RISdic_drop_view(
	risstmt *stmt,
	int		exec_mode)
{
	DIC_DBG(("RISdic_drop_view(stmt:0x%x exec_mode:%d)\n",stmt, exec_mode));

	if (IN_START_OR_FINISH_MODE(exec_mode))
	{
		RISusr_send_rec(RIS_DROP_VIEW_CODE, stmt->sql,
			(unsigned short)exec_mode);
	}

	if (IN_FINISH_MODE(exec_mode))
	{
		RISdic_remove_hash(RIS_TOK_TABLE, stmt->tree->rhs->info.tab);
		RISdic_commit_hash();
	}

	DIC_DBG(("RISdic_drop_view:returing\n"));
}

/******************************************************************************/

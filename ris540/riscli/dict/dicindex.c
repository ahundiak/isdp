/*
**	NAME:							dicindex.c
**	AUTHORS:						David Michal
**	CREATION DATE:					11/90
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "dict.h"
#include "ris_err.h"

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
#define dicindex_c
#include "dicindex.prt"
#include "ccoren.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "usrsndrc.prt"
#include "sys.prt"


/******************************************************************************/

extern void RISdic_create_index(
	risstmt *stmt,
	int exec_mode)
{
	ristree *tp = stmt->tree;
	rissql  *sql = stmt->sql;
	char    *p;
	int     status;
	int     attempts = 0;

	DIC_DBG(("RISdic_create_index(stmt:0x%x exec_mode:0x%x)\n",
		stmt,exec_mode));

	if (strlen(tp->rhs->info.val) > RIS_MAX_OS400_ID_SIZE && 
		sql->schema->db->dtype == '4')
	{
		while (1)
		{
			status = SETJMP();
			if (!status)
			{
				RISusr_send_rec(RIS_CREATE_INDEX_CODE, stmt->sql,
					(unsigned short)exec_mode);
				RESETJMP();
				break;
			}
			else
			{
				/*char	*pos;*/

				RESETJMP();
				if (status != RIS_E_CREATE_INDEX)
				{
					LONGJMP(status);
				}
				if (++attempts>RIS_MAX_ATTEMPTS)
				{
					LONGJMP(RIS_E_EXCEED_MAX_ATTEMPTS);
				}
				RIScco_next_extern_table_name(
					(char *)tp->rhs->info.val, (char *)tp->lhs->info.val);
				p = tp->lhs->info.val +
					strlen(tp->lhs->info.val)-1;
				while ((*p == ' ') || (*p == '\t'))
					*p-- = '\0';
				/*pos = strstr(sql->query, "/");  *itbokic*
                if (pos == NULL)
                {
                    LONGJMP(RIS_E_INTERNAL_ERROR);
                }
				strncpy(pos+1, tp->lhs->info.val, strlen(tp->lhs->info.val)); itbokic*/
				strncpy((sql->query)+13,  /*itbokic */
					tp->lhs->info.val, strlen(tp->lhs->info.val));
				strcpy(sql->ext_relname, tp->lhs->info.val);
				DIC_DBG(("RETRY ATTEMPTS: [%d] sql->query: <%s>\n", 
					attempts, sql->query));
			}
		}
	}
	else
	{
		RISusr_send_rec(RIS_CREATE_INDEX_CODE, stmt->sql,
			(unsigned short)exec_mode);
	}
	DIC_DBG(("RISdic_create_index done...\n"));
}

/******************************************************************************/

extern void RISdic_drop_index(
	risstmt *stmt,
	int exec_mode)
{
	DIC_DBG(("RISdic_drop_index(stmt:0x%x exec_mode:0x%x)\n",stmt,
			 exec_mode));

	RISusr_send_rec(RIS_DROP_INDEX_CODE, stmt->sql,
		(unsigned short)exec_mode);

	DIC_DBG(("RISdic_drop_index done...\n"));
}

/******************************************************************************/

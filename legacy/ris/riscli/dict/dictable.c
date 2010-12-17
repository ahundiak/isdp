/*
**	NAME:							dictable.c
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
#include "riscom.h"
#include "rismem.h"
#include "ristoken.h"
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
#define dictable_c
#include "ccostmgr.prt"
#include "comauth.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "ccoren.prt"
#include "dicrem.prt"
#include "dictrans.prt"
#include "dicload.prt"
#include "diclook.prt"
#include "dictable.prt"
#include "usrsndrc.prt"
#include "sys.prt"


/******************************************************************************/

extern void RISdic_alter_table(
	risstmt *stmt,
	int exec_mode)
{
	ristree		*attrtp;
	ristab		*tab;
	risattr		*attr;
	risaccess	*acc;

	DIC_DBG(("RISdic_alter_tab(stmt:0x%x exec_mode:0x%x)\n", stmt, exec_mode));

	RISusr_send_rec(RIS_ALTER_TABLE_CODE, stmt->sql,	
		(unsigned short)exec_mode);

	if (IN_FINISH_MODE(exec_mode))
	{
		attrtp = stmt->tree->lhs->rhs;
		tab = stmt->tree->rhs->info.tab;

		/*
		**	change the tree last since it's hard to rollback
		*/

		/*
		**	go to last attr for table
		*/
		for (attr = tab->attr; attr->next; attr = attr->next);

		/*
		**	copy attr struct into permanent memory
		*/
		attr->next = RIScco_alloc_risattr(tab->schema->schid);
		attr = attr->next;
		memcpy(attr, attrtp->info.attr, sizeof(risattr));

		/*
		**	create access struct for column access of table owner
		*/
		acc = RIScco_alloc_risaccess(tab->schema->schid);
		strcpy(acc->schname,attr->tab->schema->schname);
		strcpy(acc->relname,attr->tab->tabname);
		strcpy(acc->relowner,attr->tab->tabowner);
		strcpy(acc->colname,attr->attrname);
		strcpy(acc->grantor,acc->schname);
		strcpy(acc->grantee,acc->schname);
		RIScom_init_auth(acc->auth);
		RIScom_add_auth(acc->auth,UPDATE_ACCESS);
		acc->relid = attr->tab->tabid;
		acc->flag = 'A';
		acc->ptr.attr = attr;
		attr->acc = acc;
	}
	DIC_DBG(("RISdic_alter_tab:returning\n"));
}

/******************************************************************************/

extern void RISdic_create_table(
	risstmt *stmt,
	int exec_mode)
{
	ristree	*tp = stmt->tree->rhs;
	rissql	*sql = stmt->sql;
	char	*p;
	int		status;
	int		attempts = 0;
	
	DIC_DBG(("RISdic_create_table(stmt:0x%x exec_mode:%d)\n",stmt, exec_mode));

	if (strlen(tp->info.tab->tabname) > RIS_MAX_OS400_ID_SIZE && 
		sql->schema->db->dtype == '4')
	{
		while (1)
		{
			status = SETJMP();
			if (!status)
			{
				RISusr_send_rec(RIS_CREATE_TABLE_CODE, stmt->sql,
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
		RISusr_send_rec(RIS_CREATE_TABLE_CODE, stmt->sql,
			(unsigned short)exec_mode);
	}  
	DIC_DBG(("RISdic_create_table:returning\n"));
}

/******************************************************************************/

extern void RISdic_drop_table(
	risstmt *stmt,
	int exec_mode)
{
	DIC_DBG(("RISdic_drop_table(stmt:0x%x exec_mode:0x%x)\n",stmt, exec_mode));

	RISusr_send_rec(RIS_DROP_TABLE_CODE, stmt->sql,
		(unsigned short)exec_mode);

	if (IN_FINISH_MODE(exec_mode))
	{
		RISdic_remove_hash(RIS_TOK_TABLE, stmt->tree->rhs->info.tab);
		RISdic_commit_hash();
	}

	DIC_DBG(("RISdic_drop_table:returning\n"));
}

/******************************************************************************/

extern void RISdic_declare_table_view(
	risstmt *stmt,
	int exec_mode)
{
	ristree * tp;
	ristab * tablep;

	DIC_DBG(("RISdic_declare_table_view stmt = 0x%x exec_mode = %d\n",
 		stmt,exec_mode));

	tp = stmt->tree;
	tablep = stmt->tree->rhs->info.tab;

	if (IN_START_MODE(exec_mode))
	{
		/* lookup for this table in hash table */
		if( RISdic_lookup_rel_in_hash(tablep->schema,tablep->tabowner,
			tablep->tabname,0) )
		{
			LONGJMP(RIS_E_REL_ALREADY_DECLARED);
		}
	}

	switch(tp->lhs->tok)
	{
		case RIS_TOK_NO_VERIFY:
			/* do nothing */
		break;
		case RIS_TOK_PARTIAL:
		case RIS_TOK_VERIFY:
			RISdic_declare_verify_option(stmt,exec_mode);
		break;
		default:
			LONGJMP(RIS_E_UNKNOWN_VERIFY_OPTION);
		break;
	}

	if (IN_FINISH_MODE(exec_mode))
	{
		RISdic_load_declared_rel(tp->rhs);
	}
}

/******************************************************************************/

extern void RISdic_undeclare_table_view(
	risstmt *stmt,
	int exec_mode)
{
	ristree * tp;

	DIC_DBG(("RISdic_undeclare_table_view(stmt:0x%x exec_mode:%d)\n",
		stmt,exec_mode));

	if (IN_START_MODE(exec_mode))
	{
		tp = stmt->tree;
		if (tp->rhs->tok == RIS_TOK_AUTH_ID)
		{
			tp = tp->rhs;
		}

		RISdic_remove_hash(RIS_TOK_TABLE, tp->rhs->info.tab);
		RISdic_commit_hash();
	}

	DIC_DBG(("RISdic_undeclare_table_view: returning\n"));
}

/******************************************************************************/

/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							clitab.c
**	AUTHORS:						Hitesh Patel
**	CREATION DATE:					11/91
**	ABSTRACT:
**		The short cut method is to update the hash table for secondary schemas
**		based on the tables referenced in the primary schemas. The tables
**		referenced in the primary schema stmt are listed in ristablist struct.
**		If the table is not found in the hash table (for secondary schema) then
**		copy all necessary structures (ristab, risattr, risaccess) to update
**		hash table.
**		
**	REVISION HISTORY: 
**                   
*/
 
/*
**	INCLUDES
*/
#include "rismem.h"
#include "ristoken.h"
#include "client.h"

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
#define clitab_c
#include "clitab.prt"
#include "sys.prt"
#include "comdebug.prt"
/*#include "comalloc.prt"*/
#include "comjmp.prt"
/*#include "comtree.prt"*/
#include "dicload.prt"
#include "diclook.prt"
#include "dictrans.prt"

/******************************************************************************/

extern void RIScli_put_tables_in_hash(
	int			prev_id,
	risschema	*prime_sch,
	risschema	*second_sch)
{
	ristablist	*tablistp;
	int			status;

	CLI_DBG(("\nRIScli_put_tables_in_hash prev_id %d prime_sch <%s> second_sch <%s> \n", prev_id, prime_sch->schname, second_sch->schname));

	status = SETJMP();
	if (!status)
	{
		switch(RIS_stmts[prev_id]->tree->tok)
		{
			case RIS_TOK_DEFAULT_SCHEMA:
			case RIS_TOK_CREATE_SCHEMA:
			case RIS_TOK_DROP_SCHEMA:
			case RIS_TOK_ALTER_SCHEMA:
			case RIS_TOK_OPEN_SCHEMA:
			case RIS_TOK_CLOSE_SCHEMA:
			case RIS_TOK_DECLARE_SUPERSCHEMA:
			case RIS_TOK_REDECLARE_SUPERSCHEMA:
			case RIS_TOK_UNDECLARE_SUPERSCHEMA:
			case RIS_TOK_DEBUG:
			case RIS_TOK_SET:
			case RIS_TOK_CREATE_TABLE:
			case RIS_TOK_CREATE_VIEW:
			case RIS_TOK_GRANT_SCHEMA:
			case RIS_TOK_GRANT_CONNECT:
			case RIS_TOK_GRANT_RESOURCE:
			case RIS_TOK_REVOKE_SCHEMA:
			case RIS_TOK_REVOKE_CONNECT:
			case RIS_TOK_REVOKE_RESOURCE:
			break;
			case RIS_TOK_DROP_TABLE:
			case RIS_TOK_DROP_VIEW:
			case RIS_TOK_ALTER_TABLE:
			case RIS_TOK_CREATE_INDEX:
			case RIS_TOK_DROP_INDEX:
			case RIS_TOK_GRANT_ON_TABLE:
			case RIS_TOK_REVOKE_ON_TABLE:
			case RIS_TOK_LOCK_TABLES:
			case RIS_TOK_COMMIT:
			case RIS_TOK_ROLLBACK:
			case RIS_TOK_INSERT:
			case RIS_TOK_DELETE:
			case RIS_TOK_UPDATE:
			case RIS_TOK_SELECT:
			case RIS_TOK_EXEC:
			case RIS_TOK_DECLARE_TABLE:
			case RIS_TOK_DECLARE_VIEW:
			case RIS_TOK_UNDECLARE_TABLE: 
			case RIS_TOK_UNDECLARE_VIEW: 
				for(tablistp = RIS_stmts[prev_id]->tablist; 
						tablistp; 
				 			tablistp = tablistp->next )
				{
					CLI_DBG(("tabname <%s>\n", tablistp->tab->tabname));
					RIScli_put_table_in_hash(tablistp->tab, prime_sch,
					 second_sch);
				}
			break;
			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
			break;
		}
		RISdic_commit_hash();
		RESETJMP();
	}
	else
	{
		RESETJMP();
		RISdic_rollback_hash();
		LONGJMP(status);
	}
}

/******************************************************************************/

static void RIScli_put_table_in_hash(
	ristab		*tabp,
	risschema 	*prime_sch,
	risschema 	*second_sch)
{
	ristab		*newtabp;

	CLI_DBG(("RIScli_put_table_in_hash: tabp 0x%x prime_sch 0x%x second_sch 0x%x\n", tabp, prime_sch, second_sch));

	/* check if primary schema owns this table */
	if (tabp->schema == prime_sch)
	{
		if(RISdic_lookup_rel_in_hash(second_sch,tabp->tabowner,tabp->tabname,0))
		{
			CLI_DBG(("secondary schema table found in hash\n"));
			/* so do nothing */
		}
		else 
		{
			RISdic_load_rel(second_sch,tabp->tabowner,tabp->tabname,1);
			if (!(newtabp = RISdic_lookup_rel_in_hash(
				second_sch,tabp->tabowner,tabp->tabname,0)))
			{
				LONGJMP(RIS_E_INCONSISTENT_RESULTS);
			}
			/*newtabp = RIScli_alloc_n_copy(tabp,second_sch);
			RISdic_add_hash(RIS_TOK_TABLE,newtabp);*/
			CLI_DBG(("put secondary schema table in hash\n"));
		}
	}
}

/******************************************************************************/
/*
static ristab *RIScli_alloc_n_copy(
	ristab		*tabp,
	risschema	*second_sch)
{
	ristab		*newtabp;
	risattr		*attr1;
	risattr		*attr2 = 0;

	CLI_DBG(("RIScli_alloc_n_copy(tabp 0x%x second_sch 0x%x)\n",
	 tabp,second_sch));

	newtabp = (ristab *) ALLOCTS(second_sch->schid,ristab);

	memcpy((char *)newtabp,(char *)tabp, sizeof(ristab));

	newtabp->schema = second_sch;

	newtabp->ref_count = 0;

	RIScli_copy_tab_acc(newtabp,tabp);

	for (attr1=tabp->attr;attr1;attr1=attr1->next)
	{
		if (attr2)
		{
			attr2->next = ALLOCTS(second_sch->schid,risattr);
			attr2 = attr2->next;
		}
		else
		{
			attr2 = ALLOCTS(second_sch->schid,risattr);
			newtabp->attr = attr2;
		}

		memcpy((char *)attr2, (char *)attr1, sizeof(risattr));
		attr2->tab = newtabp;

		RIScli_copy_attr_acc(attr2,attr1);
	}

	CLI_DBG(("RIScli_alloc_n_copy: complete\n"));

	return(newtabp);
}
*/
/******************************************************************************/
/*
static void RIScli_copy_tab_acc(
	ristab *newtabp,
	ristab *tabp)
{
	risaccess *acc;

	CLI_DBG(("RIScli_copy_tab_acc(newtabp 0x%x tabp 0x%x)\n",newtabp,tabp));

	newtabp->acc = RIScom_copy_access_list(newtabp->schema->schid,tabp->acc);
	for(acc=newtabp->acc; acc; acc=acc->next )
	{
		strcpy(acc->schname, newtabp->schema->schname);
		if(strcmp(acc->grantor,tabp->schema->schname) == 0)
		{
			strcpy(acc->grantor, newtabp->schema->schname);
		}
		if(strcmp(acc->grantee,tabp->schema->schname) == 0)
		{
			strcpy(acc->grantee, newtabp->schema->schname);
		}
		acc->ptr.tab = newtabp;
	}
	CLI_DBG(("RIScli_copy_tab_acc: complete\n"));
}
*/
/******************************************************************************/
/*
static void RIScli_copy_attr_acc(
	risattr *newattr,
	risattr *attr)
{
	risaccess *acc;

	CLI_DBG(("RIScli_copy_attr_acc(newattr 0x%x attr 0x%x)\n",newattr,attr));

	newattr->acc = RIScom_copy_access_list(newattr->tab->schema->schid,
	 attr->acc);
	for(acc=newattr->acc; acc; acc=acc->next )
	{
		strcpy(acc->schname,newattr->tab->schema->schname);
		if(strcmp(acc->grantor,attr->tab->schema->schname) == 0)
		{
			strcpy(acc->grantor,newattr->tab->schema->schname);
		}
		if(strcmp(acc->grantee,attr->tab->schema->schname) == 0)
		{
			strcpy(acc->grantee,newattr->tab->schema->schname);
		}
		acc->ptr.attr = newattr;
	}
	CLI_DBG(("RIScli_copy_attr_acc: complete\n")); 
}
*/
/******************************************************************************/

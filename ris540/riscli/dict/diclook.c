/*
**	NAME:							diclook.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					3/88
**	ABSTRACT:
**	RISdic_lookup_rel(schema*, rel*, auth*)
**		returns a pointer to the tree for the relation
**
**	RISdic_lookup_col(relistlist, col_desc)
**		looks for the column in the relistlist, checking for ambiguity.
**		returns a pointer to the column tree.  The col_desc can be:
**			COL_NAME,
**			TABLE_NAME --> COL_NAME,
**			USR --> TABLE_NAME --> COL_NAME.
**			AUTH_ID --> TABLE_NAME --> COL_NAME.
**			AUTH_ID --> USR --> TABLE_NAME --> COL_NAME.
**		
**	
**	REVISION HISTORY:
**			Modified for the security schema stuff by Jin Jing 6/93
**
*/
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "riscl_pa.h"
#include "riscom.h"
#include "rismem.h"
#include "ristoken.h"
#include "dict.h"

#define TEMP_FIX

/* temp fix put in by Shiva on 2-22-94 : Jin, make it permanent please */

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
#define diclook_c
#include "comalloc.prt"
#include "comauth.prt"
#include "comjmp.prt"
#include "comdebug.prt"
#include "comdict.prt"
#include "comgtnme.prt"
#include "dicacc.prt"
#include "dicmisc.prt"
#include "dicload.prt"
#include "diclook.prt"
#include "dicopsch.prt"
#include "fildb.prt"
#include "filsch.prt"
#include "sys.prt"

/******************************************************************************/

extern ristree *RISdic_lookup_col(
	ristree *relistlist,
	ristree	*col_desc,
	char *auth)
{
	ristree		*relist, *reltp, *coltp, *ret_colp;
	ristab		*tab;
	risschema	*col_schema, *schema;
	char		*rel, *rel_col, *usr;
	int			rel_pos, col_pos, usr_pos;

DIC_DBG(("RISdic_lookup_col relistlist = 0x%x col_desc = 0x%x auth = <%s>\n",
 relistlist,col_desc,auth ? auth : "NONE"));
DIC_DBG(("RISdic_lookup_col: col_desc->tok:%s\n",
					 RIScom_get_token_name(col_desc->tok)));

	if (!col_desc)
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}
	ret_colp = 0;

/* if col_desc includes schema, get schema to look up col with */

	if (col_desc->tok == RIS_TOK_AUTH_ID)
	{
		col_schema = RISdic_open_schema(col_desc->info.val, SYNC_MODE);
		col_desc = col_desc->rhs;
	}
	else
	{
		col_schema = 0;
	}

/* if col_desc includes usr, get usr */

	if (col_desc->tok == RIS_TOK_USR_NAME)
	{
		usr = col_desc->info.val;
		col_desc = col_desc->rhs;

/* remember error pos info */

		usr_pos = col_desc->pos;
	}
	else
	{
		usr = 0;
	}

/* if col_desc includes rel, get rel */

	if (col_desc->tok == RIS_TOK_TABLE_NAME)
	{
		rel = col_desc->info.val;
		rel_col = col_desc->rhs->info.val;

/* remember error pos info */

		rel_pos = col_desc->pos;
		col_pos = col_desc->rhs->pos; 
	}
	else
	{
		rel = 0;
		rel_col = col_desc->info.val;

/* remember error pos info */

		rel_pos = 0;
		col_pos = col_desc->pos; 
	}

DIC_DBG(("RISdic_lookup_col: name:<%s.%s> mask:<%s>\n",rel ? rel : "",rel_col,
 auth ? auth : "NONE"));

/* lookup column */

	for ( ; relistlist; relistlist = relistlist->rhs)
	{
		if (relistlist->tok == RIS_TOK_LIST)
		{
			relist = relistlist->lhs;
		}
		else
		{
			relist = relistlist;
		}
		for ( ; relist; relist = relist->rhs)
		{
			if (relist->tok == RIS_TOK_LIST)
			{
				reltp = relist->lhs;
			}
			else 
			{
				reltp = relistlist;
			}
			if (reltp->tok == RIS_TOK_TABLE)
			{
				tab = reltp->info.tab;

DIC_DBG(("RISdic_lookup_col: looking in table:<%s>\n",tab->tabname));

/* if relation name doesn't match, go to next relation */

#ifdef TEMP_FIX
				if (rel && strcmp(rel, tab->tabname) != 0)  
#else
				if ((rel && strcmp(rel, tab->tabname) != 0) || 
					(usr && strcmp(usr, tab->tabowner) != 0)) 
#endif
				{
					continue;
				}
	
/* if alias table, get schema of real table */

				if (tab->tabtype == 'A')
				{
					schema = tab->tab->schema;
				}
				else
				{
					schema = tab->schema;
				}

			}
			else
			{
				RIS_ERRPOS = rel_pos; 
                                LONGJMP(RIS_E_INV_SQL_STATEMENT);
/*                              LONGJMP(RIS_E_INTERNAL_ERROR); */
/* The error returned at this point was RIS_E_INTERNAL_ERROR, however,
   to resolve TR# 439409692, the error message was changed.  If this 
   else condition is reached, it would mean some kind of internal error,
   but as a quick fix for the special case for this TR, the error message
   was changed, the other alternative would be to make a change in the
   parser, in order to catch the "update" statement situation there.
*/
			}

/* look for column */

DIC_DBG(("RISdic_lookup_col: looking for column\n"));

			for (coltp = reltp->rhs; coltp; coltp = coltp->rhs)
			{
DIC_DBG(("RISdic_lookup_col: attrname <%s> rel_col <%s>\n",
	coltp->lhs->info.attr->attrname, rel_col));
				if (strcmp(coltp->lhs->info.attr->attrname, rel_col) == 0)
				{
					if (RISdic_check_col_access(reltp->info.tab,
						coltp->lhs->info.attr, auth))
					{
						/* disallow dups */
						if (ret_colp)
						{
							RIS_ERRPOS = col_pos; 
							LONGJMP(RIS_E_AMBIGUOUS_COLUMN);
						}
						ret_colp = coltp->lhs;
						break;
					}
				}
			}
			if (relist == reltp)
			{
				break;
			}
		}
		if (ret_colp)
		{
			return(ret_colp);
		}
		if (relistlist == relist)
		{
			break;
		}
	}
	RIS_ERRPOS = col_pos; 
	LONGJMP(RIS_E_UNKNOWN_COLUMN);

/* make the compiler happy */

	return (ristree *)0;
}

/******************************************************************************/

/* Hitesh static rm-ed */
extern ristab *RISdic_lookup_rel_in_hash(
	risschema	*rel_schema,
	char		*rel_usr,
	char		*rel,
	char		*auth)
{
	ristab			*tab;
	risaccess		*next_acc;
	risaccess		**acc;
	risschema		*schema;
	hashnode		*hashp;
	unsigned int	hashval;
	int				schema_flag;
	int				public_flag;

	DIC_DBG(("RISdic_lookup_rel_in_hash(rel_schema:0x%x rel_usr:<%s> rel:<%s> auth:<%s>)\n", rel_schema, rel_usr ? rel_usr : "NONE", STRING(rel), auth ? auth : "NONE"));

	/*
	**	get relation from hash table
	*/
	hashval = RISdic_hash_on_name(rel);
	for (hashp = RIS_hashtab[hashval]; hashp; hashp = hashp->next)
	{
		switch(hashp->tok)
		{
			case RIS_TOK_TABLE:
				tab = (ristab *)hashp->ptr;
#ifdef TEMP_FIX
				if (strcmp(rel, tab->tabname) != 0)  
#else
				if ((strcmp(rel, tab->tabname) != 0) || 
					(strcmp(rel_usr, tab->tabowner) != 0))
#endif
				{
					continue;
				}
				acc = &tab->acc;
				schema = tab->schema;
				break;

			default:
				continue;
		}

		/*
		**	check access if schema and rel match
		*/
		if (schema == rel_schema)
		{
			DIC_DBG(("RISdic_lookup_rel_in_hash: tabname: <%s> tabowner: <%s>\n",
				tab->tabname, tab->tabowner));
            if (!auth)
            {
				DIC_DBG(("RISdic_lookup_rel_in_hash:returning 0x%x\n", tab));
                return(tab);
            }
			schema_flag = 0;
			public_flag = 0;
			for (next_acc = *acc;next_acc;next_acc =next_acc->next)
			{
				if (strcmp(next_acc->grantee, "PUBLIC") == 0)
				{
					schema_flag = 1;
					if (RIScom_has_auth(next_acc->auth, auth))
					{
						DIC_DBG(("RISdic_lookup_rel_in_hash:returning 0x%x\n",
							tab));
						return(tab);
					}
				}
				if (strcmp(RIS_default->schname, next_acc->grantee) == 0)
				{
					public_flag = 1;
					if (RIScom_has_auth(next_acc->auth, auth))
					{
						DIC_DBG(("RISdic_lookup_rel_in_hash:returning 0x%x\n",
							tab));
						return(tab);
					}
				}
			}
			if (!schema_flag)
			{
				RISdic_get_access(tab,RIS_default->schname);
				for (next_acc = *acc;next_acc;next_acc =next_acc->next)
				{
					if (strcmp(RIS_default->schname, next_acc->grantee) == 0)
					{
						if (RIScom_has_auth(next_acc->auth, auth))
						{
							DIC_DBG(("RISdic_lookup_rel_in_hash:"
								"returning 0x%x\n", tab));
							return(tab);
						}
					}
				}
			}
			if (!public_flag)
			{
				RISdic_get_access(tab,"PUBLIC");
				for (next_acc = *acc;next_acc;next_acc =next_acc->next)
				{
					if (strcmp(next_acc->grantee, "PUBLIC") == 0)
					{
						if (RIScom_has_auth(next_acc->auth, auth))
						{
							DIC_DBG(("RISdic_lookup_rel_in_hash:"
								"returning 0x%x\n", tab));
							return(tab);
						}
					}
				}
			}
			if (RIS_app_cli_version < 5)
			{
				LONGJMP(RIS_E_UNKNOWN_RELATION);
			}
			else
			{
				LONGJMP(RIS_E_NEED_ACCESS_PRIVILEGE);
			}
		}
	}

	DIC_DBG(("RISdic_lookup_rel_in_hash:returning 0x0\n"));
	return 0;
}

/******************************************************************************/

extern ristab *RISdic_lookup_rel(
	risschema	*rel_schema,
	char		*rel_usr,
	char		*rel,
	char		*auth)
{
	ristab 	*tab = NULL;
	int    	index = -1;

	DIC_DBG(("RISdic_lookup_rel(rel_schema:0x%x rel_usr:<%s> rel:<%s> auth:<%s>\n", rel_schema, STRING(rel_usr), STRING(rel), auth ? auth : "NONE"));

	DIC_DBG(("RISdic_lookup_rel: strlen(rel_usr): %d\n", strlen(rel_usr)));

    if ((index = RIScom_get_dict_tabid(rel)) != -1 )
	{
		rel_usr = rel_schema->dict_dbusr;
	}

	if (!strlen(rel_usr) || (rel_usr == NULL))
	{
		rel_usr = rel_schema->schown_dbusr;
	}

	if (!(tab = RISdic_lookup_rel_in_hash(rel_schema, rel_usr,rel,auth)))
	{
		RISdic_load_rel(rel_schema,rel_usr,rel,1);
		if (!(tab = RISdic_lookup_rel_in_hash(rel_schema,rel_usr,rel,auth)))
		{
			LONGJMP(RIS_E_UNKNOWN_RELATION);
		}
	}
	DIC_DBG(("RISdic_lookup_rel:returning 0x%x\n", tab));
	return tab;
}

/******************************************************************************/

/*
** look up relation and make sure the tabtype is set
*/

extern ristab *RISdic_lookup_reltype(
	risschema	*rel_schema,
	char		*rel_usr,
	char		*rel,
	char		*auth)
{
	ristab	*tab;

	DIC_DBG(("RISdic_lookup_reltype(rel_schema:0x%x rel_usr:<%s> rel:<%s> auth:<%s>\n", rel_schema, rel_usr, STRING(rel), auth ? auth : "NONE"));

	tab = RISdic_lookup_rel(rel_schema, rel_usr, rel, auth);
	if (!tab->tabtype)
	{
		RISdic_load_reltype(rel_schema, tab->tabowner, rel, tab, 1);
	}

	DIC_DBG(("RISdic_lookup_reltype: returning 0x%x\n", tab));
	return tab;
}

/******************************************************************************/

extern risschema *RISdic_lookup_schema(
	char	*name,
	int		mode_mask)
{
	hashnode	*hashp;
	risschema	*schema;
	int status;

	DIC_DBG(("RISdic_lookup_schema(name:<%s> mode_mask:%d)\n",
		STRING(name), mode_mask));

	if (mode_mask & HASH_TABLE)
	{
		/*
		**	Look for schema in hash table
		*/
		for(hashp = RIS_hashtab[RISdic_hash_on_name(name)];
			hashp;
			hashp=hashp->next)
		{
			if (hashp->tok == RIS_TOK_SCHEMA &&
				strcmp(name, ((risschema *)hashp->ptr)->schname) == 0)
			{
				return (risschema *)hashp->ptr;
			}
		}
	}

	if (mode_mask & SCHEMA_FILE)
	{
		/*
		**	look for schema in schema file
		*/

		schema = ALLOCT(risschema);
		strcpy(schema->schname, name);
		status = SETJMP();
		if (!status)
		{
			RISfil_get_schema(schema, ALL_FLAG);
			RESETJMP();
			return schema;
		}
		else
		{
			RESETJMP();
			if (status != RIS_E_UNKNOWN_SCHEMA)
			{
				LONGJMP(status);
			}
		}
	}

	return 0;
}


/******************************************************************************/

extern risdb *RISdic_lookup_db(
	int dbid,
	int mode_mask)
{
	hashnode	*hashp;
	risdb		*db;
	int status;

	DIC_DBG(("RISdic_lookup_db(dbid:%d, mode_mask:%d)\n",dbid, mode_mask));

	if (mode_mask & HASH_TABLE)
	{
		for (hashp=RIS_hashtab[RISdic_hash_on_id(dbid)];hashp;hashp=hashp->next)
		{
			if (hashp->tok == RIS_TOK_DATABASE &&
				((risdb *)hashp->ptr)->dbid == (unsigned short)dbid)
			{
				return (risdb *)hashp->ptr;
			}
		}
	}

	if (mode_mask & SCHEMA_FILE)
	{
		db = ALLOCT(risdb);
		db->dbid = (unsigned short)dbid;
		status = SETJMP();
		if (!status)
		{
			RISfil_get_db(db, ALL_FLAG);
			RESETJMP();
			return db;
		}
		else
		{
			RESETJMP();
			if (status != RIS_E_UNKNOWN_DATABASE)
			{
				LONGJMP(status);
			}
		}
	}
	return 0;
}

/******************************************************************************/

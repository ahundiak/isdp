/*
**	NAME:							dicacc.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					12/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**
**	8/91	Dan Karier		Added mechanism to assume total access if
**								the default schema is the owner.  This
**								eliminates the need to go to the 
**								dictionary in most cases.
*/
 
#define DICT_GLOBAL_DEFINE
 
/*
**	INCLUDES
*/
#include "risasync.h"
#include "riscom.h"
#include "rismem.h"
#include "dict.h"
#include "risdict.h"

/*
**	DEFINES
*/
#define GET_ACCESS				0
#define GET_ALL_ACCESS			1
#define COMMIT_ALL_ACCESS		2
#define ROLLBACK_ALL_ACCESS		3
#define ACTION_COUNT			4

/*
**	TYPES
*/
typedef struct save_access_s
{
	risaccess				*acc;
	struct save_access_s	*next;
} save_access;

/*
**	FUNCTION PROTOTYPES
*/
#define dicacc_c
#include "ccostmgr.prt"
#include "comalloc.prt"
#include "comauth.prt"
#include "comdebug.prt"
#include "comdict.prt"
#include "comjmp.prt"
#include "dicacc.prt"
#include "usrmisc.prt"
#include "usrsndrc.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static char *action_name[] = 
{
	"GET_ACCESS",
	"GET_ALL_ACCESS",
	"COMMIT_ALL_ACCESS",
	"ROLLBACK_ALL_ACCESS"
};

/*
**	FUNCTIONS
*/

/****************************************************************************/

extern risaccess	*RISdic_get_old_acclist(
	risaccess	*new_acc)
{
	risaccess	*old_acc_hd = 0;

	DIC_DBG(("RISdic_get_old_acclist(new_acc:0x%x)\n",new_acc));

	DIC_DBG(("RISdic_get_old_acclist acc_flag:<%c>\n",new_acc->flag));

	switch (new_acc->flag)
	{
		case 'A':	/* ATTR */
			old_acc_hd = new_acc->ptr.attr->acc; 
		break;
		case 'T':	/* TABLE */
			old_acc_hd = new_acc->ptr.tab->acc; 
		break;
		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
		break;
	}
	return(old_acc_hd);
}

/****************************************************************************/

static void remove_grantee_from_access_list(
	char		*grantee,
	risaccess	**accp,
	risschema	*schema)
{
	risaccess	*temp;

	DIC_DBG(("remove_grantee_from_access_list(grantee:<%s> accp:0x%x "
		"schema:0x%x)\n", grantee, accp, schema));

	while (accp && *accp)
	{
		if (!strcmp((*accp)->grantee, grantee))
		{
			temp = *accp;
			DIC_DBG(("removing access:0x%x relowner:<%s> relname:<%s>)\n",
				temp, temp->relowner, temp->relname));
			DIC_DBG(("         relid:<%d> colname:<%s>)\n",
				temp->relid, temp->colname));
			DIC_DBG(("         grantor:<%s> grantee:<%s>\n",
				temp->grantor, temp->grantee));

			*accp = (*accp)->next;
			RIScco_free_risaccess(schema->schid, temp);
		}
		else
		{
			accp = &(*accp)->next;
		}
	}
}

/****************************************************************************/

/*
** get the access list for a table/view regarding a given schema
*/

static void get_access(
	int			action,
	ristab		*tab,
	char 		*grantee)
{
	int					more_to_follow;
	int					new_acc_info_count;
	char				opcode = 0;
	risaccess			inaccess;
	risaccess			*new_acc_struct;
	ris_access_info		*new_acc_info;
	ris_access_info		*new_acc_info_list;
	risattr				*attr;
	save_access			**save_access_ptr;
	static save_access	*save_access_list[RIS_MAX_STMTS - RIS_MAX_DICT_STMTS] = {0};
	static ristab		*save_tab[RIS_MAX_STMTS - RIS_MAX_DICT_STMTS] = {0};
	int 				index=0;


	DIC_DBG(("get_access(action:%s tab:0x%x grantee:<%s>)\n"
		"get_access: tabname:<%s.%s>\n", action_name[action], tab, 
		STRING(grantee), tab ? tab->tabowner : "", tab ? tab->tabname : ""));

	switch(action)
	{
		case GET_ACCESS:
			/*
			**	Remove any access structs where acc->grantee = grantee
			*/
			remove_grantee_from_access_list(grantee,&tab->acc,tab->schema);
			for (attr = tab->attr; attr; attr = attr->next)
			{
				remove_grantee_from_access_list(grantee,&attr->acc,tab->schema);
			}

			/*
			**	fill in the input access structure
			*/
			memset(&inaccess, 0, sizeof(risaccess));
			strcpy(inaccess.relname, tab->tabname);
			strcpy(inaccess.relowner, tab->tabowner);
			strcpy(inaccess.schname, tab->schema->schname);
			strcpy(inaccess.grantee, grantee);
			inaccess.relid = tab->tabid;
			opcode = RIS_GET_ACCESS_CODE;
			break;

		case GET_ALL_ACCESS:
			/*
			**	If save_access_list has a value, RISdic_get_all_access
			**	has been called twice without doing a commit or rollback.
			*/
			if (save_access_list[RIS_stmt->stmt_id]) 
				LONGJMP(RIS_E_INTERNAL_ERROR);
			if (save_tab[RIS_stmt->stmt_id]) LONGJMP(RIS_E_INTERNAL_ERROR);

			save_tab[RIS_stmt->stmt_id] = tab;

			/*
			**	Initialize save access pointer
			*/
			save_access_ptr = &save_access_list[RIS_stmt->stmt_id];

			/*
			**	Save the table access
			*/
			(*save_access_ptr) = ALLOCT(save_access);
			(*save_access_ptr)->acc = tab->acc;
			save_access_ptr = &((*save_access_ptr)->next);
			tab->acc = 0;

			for (attr = tab->attr; attr; attr = attr->next)
			{
				/*
				**	Save the attributes access
				*/
				(*save_access_ptr) = ALLOCT(save_access);
				(*save_access_ptr)->acc = attr->acc;
				save_access_ptr = &((*save_access_ptr)->next);
				attr->acc = 0;
			}

			/*
			**	fill in the input access structure
			*/
			memset(&inaccess, 0, sizeof(risaccess));
			strcpy(inaccess.relname, tab->tabname);
			strcpy(inaccess.relowner, tab->tabowner);
			strcpy(inaccess.schname, tab->schema->schname);
			inaccess.relid = tab->tabid;
			opcode = RIS_GET_ALL_ACCESS_CODE;
			break;

		case COMMIT_ALL_ACCESS:
			/*
			**	if both save_access_list and save_tab don't have a value,
			**		then there's nothing to commit
			**	if only one of them has a value,
			**		then it's an error
			*/
			if (!save_access_list[RIS_stmt->stmt_id] && !save_tab[RIS_stmt->stmt_id]) return;
			if (!save_access_list[RIS_stmt->stmt_id] || !save_tab[RIS_stmt->stmt_id])
				LONGJMP(RIS_E_INTERNAL_ERROR);

			/*
			**	Free the saved access lists
			*/
			for (;save_access_list[RIS_stmt->stmt_id];
				  save_access_list[RIS_stmt->stmt_id] = 
				  save_access_list[RIS_stmt->stmt_id]->next)
			{
				RIScco_free_risaccess_list(save_tab[RIS_stmt->stmt_id]->schema->schid,
					save_access_list[RIS_stmt->stmt_id]->acc);
				save_access_list[RIS_stmt->stmt_id]->acc = 0;
			}
			save_tab[RIS_stmt->stmt_id] = 0;
			return;

		case ROLLBACK_ALL_ACCESS:
			/*
			**	if both save_access_list and save_tab don't have a value,
			**		then there's nothing to rollback
			**	if only one of them has a value,
			**		then it's an error
			*/
			if (!save_access_list[RIS_stmt->stmt_id] && !save_tab[RIS_stmt->stmt_id]) return;
			if (!save_access_list[RIS_stmt->stmt_id] || !save_tab[RIS_stmt->stmt_id]) LONGJMP(RIS_E_INTERNAL_ERROR);
			/*
			**	Free the new access structs then restore the old access structs.
			**	First the table access.
			*/
			tab = save_tab[RIS_stmt->stmt_id];

			RIScco_free_risaccess_list(tab->schema->schid, tab->acc);
			tab->acc = save_access_list[RIS_stmt->stmt_id]->acc;
			save_access_list[RIS_stmt->stmt_id] = 
			save_access_list[RIS_stmt->stmt_id]->next;

			for (attr = tab->attr; attr; attr = attr->next)
			{
				if (!save_access_list[RIS_stmt->stmt_id]) 
					LONGJMP(RIS_E_INTERNAL_ERROR);
				/*
				**	Then the attributes access
				*/
				RIScco_free_risaccess_list(tab->schema->schid, attr->acc);
				attr->acc = save_access_list[RIS_stmt->stmt_id]->acc;
				save_access_list[RIS_stmt->stmt_id] = 
				save_access_list[RIS_stmt->stmt_id]->next;
			}
			if (save_access_list[RIS_stmt->stmt_id]) 
				LONGJMP(RIS_E_INTERNAL_ERROR);
			save_tab[RIS_stmt->stmt_id] = 0;
			return;

		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	RIS_sdp->query = (char*)&inaccess;
    RIS_sdp->schema = tab->schema;

	/*
	** There are 3 basic cases here, and the order is important.
	** 1)	If this is a dictionary table, then access is
	** 		table-select (no grant) to public.  Nothing more.
	** 2)	If this is not a dictionary table, then if the default
	**		schema is the same as the schema that owns the table and
	**      this is the only schema that we need privileges for then
	**		this schema is assumed to have all privileges.
	** 3)	In all other cases, we must go to the database tables
	**		to check access.
	*/

	index = RIScom_get_dict_tabid(inaccess.relname); 
/*
    if(index != -1
    	    && RIScom_dict_tables[index].version == 4 && 
			RIS_default->sql->schema->db->dtype == '4')
    {
        index = -1;
    }
*/

/*
**  Added condition for RIS_upgrade_flag so that during risupgrade
**  the client will allow the utility to insert and update into
**  the dictionary objects.
*/

	if  (index  != -1 && !RIS_upgrade_flag)
	{
		/*
		** Case 1: The table is an RIS dictionary table.
		*/
		DIC_DBG(("get_access: ACCESS MECHANISM I: RIS dictionary table\n"));

		/*
		** For RIS tables we provide only public access, so if they
		** are not asking for public access, return nothing.
		*/
		if (strcmp(grantee,"PUBLIC"))
		{
			DIC_DBG(("get_access: no action (not PUBLIC)\n"));
			return;
		}

		/* 
		** get one access struct; 
		** ristables have table access only (select);
		**  set it for PUBLIC
		*/
		new_acc_struct = RIScco_alloc_risaccess(tab->schema->schid);
		strcpy(new_acc_struct->schname,inaccess.schname);
		strcpy(new_acc_struct->relowner,inaccess.relowner);
		new_acc_struct->relid = inaccess.relid;
		strcpy(new_acc_struct->relname,inaccess.relname);
		new_acc_struct->colname[0] = '\0';
		strcpy(new_acc_struct->grantor,inaccess.schname);
		strcpy(new_acc_struct->grantee,"PUBLIC");
		strcpy(new_acc_struct->auth,"s------");	       /* select, no grant */
		new_acc_struct->ptr.tab = tab;
		new_acc_struct->flag = 'T';
		new_acc_struct->next = tab->acc;
		tab->acc = new_acc_struct;
	}
	else if (!strcmp(inaccess.schname, RIS_default->schname) &&
		opcode != RIS_GET_ALL_ACCESS_CODE &&
		!strcmp(inaccess.schname,inaccess.grantee))
	{
		/*
		** Case 2: default schema owns this object and is therefore
		**        assumed to have all access
		*/
		DIC_DBG(("get_access:ACCESS MECHANISM II:default schema owns table\n"));


		/*
		** Add access structs to the proper lists.
		*/
		/* Add an access struct for the table */
		DIC_DBG(("get_access: adding owner access for table\n"));

		new_acc_struct = RIScco_alloc_risaccess(tab->schema->schid);
		strcpy(new_acc_struct->schname,inaccess.schname);
		strcpy(new_acc_struct->relowner,inaccess.relowner);
		new_acc_struct->relid = inaccess.relid;
		strcpy(new_acc_struct->relname,inaccess.relname);
		new_acc_struct->colname[0] = '\0';
		strcpy(new_acc_struct->grantor,inaccess.schname);
		strcpy(new_acc_struct->grantee,inaccess.schname);
		strcpy(new_acc_struct->auth,"SIDU---");	       /* all privs */
		new_acc_struct->ptr.tab = tab;
		new_acc_struct->flag = 'T';
		new_acc_struct->next = tab->acc;
		tab->acc = new_acc_struct;

		/* Add access structs for each column */

		for (attr = tab->attr; attr; attr = attr->next)
		{
			DIC_DBG(("get_access: adding access for column:<%s>\n",
				attr->attrname));

			new_acc_struct = RIScco_alloc_risaccess(tab->schema->schid);
			strcpy(new_acc_struct->schname,inaccess.schname);
			strcpy(new_acc_struct->relowner,inaccess.relowner);
			new_acc_struct->relid = inaccess.relid;
			strcpy(new_acc_struct->relname,inaccess.relname);
			strcpy(new_acc_struct->colname,attr->attrname);
			strcpy(new_acc_struct->grantor,inaccess.schname);
			strcpy(new_acc_struct->grantee,inaccess.schname);
			strcpy(new_acc_struct->auth,"---U---");	       /* all privs */
			new_acc_struct->ptr.attr = attr;
			new_acc_struct->flag = 'A';
			new_acc_struct->next = attr->acc;
			attr->acc = new_acc_struct;
		}
	}
	else
	{
		/*
		** Case 3:	Get access from the dictionary
		*/

		DIC_DBG(("get_access:ACCESS MECHANISM III:get access from dict.\n"));

		do
		{
			/*
			** get a buffer full of access structs from the server
			*/
			RISusr_send_rec(opcode,RIS_sdp,SYNC_MODE);
			more_to_follow = RIS_srv_read->buf.get_access.more_to_follow;
			new_acc_info_count = RIS_srv_read->buf.get_access.count;
			new_acc_info_list =
				(ris_access_info *)RIS_srv_read->buf.get_access.data;
			DIC_DBG(("new_acc_info_count:%d\n", new_acc_info_count));
	
			if (!new_acc_info_count)
			{
				return;
			}

			/*
			** Add the access structs to the proper lists.
			** The structures no longer come in any specified order
			*/
			for (new_acc_info = new_acc_info_list;
				 new_acc_info_count > 0;
				 new_acc_info++, new_acc_info_count--)
			{
				if (!new_acc_info->colname[0])
				{
					DIC_DBG(("found access for table\n"));
	
					new_acc_struct = RIScco_alloc_risaccess(tab->schema->schid);
					RISusr_access_info_to_access(new_acc_info, new_acc_struct);
					new_acc_struct->ptr.tab = tab;
					new_acc_struct->flag = 'T';
					new_acc_struct->next = tab->acc;
					tab->acc = new_acc_struct;
				}
				else
				{
					DIC_DBG(("found access for column:<%s>\n",
						new_acc_info->colname));
	
					/* find the appropriate attr struct */
	
					for (attr = tab->attr; attr; attr = attr->next)
					{
						if (!strcmp(attr->attrname, new_acc_info->colname))
						{
							break;
						}
					}
	
					if (!attr) LONGJMP(RIS_E_INTERNAL_ERROR);
	
					new_acc_struct = RIScco_alloc_risaccess(tab->schema->schid);
					RISusr_access_info_to_access(new_acc_info, new_acc_struct);
					new_acc_struct->ptr.attr = attr;
					new_acc_struct->flag = 'A';
					new_acc_struct->next = attr->acc;
					attr->acc = new_acc_struct;
				}	/* table vs column access */
			}	/* for loop */
		} while(more_to_follow);
	}	/* current schema and default schema different */
}

/******************************************************************************/

extern void RISdic_get_access(
	ristab		*tab,
	char 		*grantee)
{
	DIC_DBG(("RISdic_get_access(tab:0x%x, grantee:0x%x)\n", tab, grantee));
	get_access(GET_ACCESS, tab, grantee);
}

/******************************************************************************/

extern void RISdic_get_all_access(
	ristab		*tab)
{
	DIC_DBG(("RISdic_get_all_access(tab:0x%x)\n", tab));
	get_access(GET_ALL_ACCESS, tab, (char *)0);
}

/******************************************************************************/

extern void RISdic_commit_all_access()
{
	DIC_DBG(("RISdic_commit_all_access()\n"));
	get_access(COMMIT_ALL_ACCESS, (ristab *)0, (char *)0);
}

/******************************************************************************/

extern void RISdic_rollback_all_access()
{
	DIC_DBG(("RISdic_rollback_all_access()\n"));
	get_access(ROLLBACK_ALL_ACCESS, (ristab *)0, (char *)0);
}

/******************************************************************************/

extern int RISdic_check_col_access(
	ristab *tabp,
	risattr *attrp,
	char *auth)
{
	int schema_flag = 0;
	int public_flag = 0;
	risaccess * next_acc;

DIC_DBG(("RISdic_check_col_access(tabp:0x%x attrp:0x%x auth:<%s>\n",tabp,
 attrp,auth ? auth : "NONE"));

	if (auth)
	{

/* check for existing access */

		for (next_acc = attrp->acc;
		 next_acc && !(public_flag && schema_flag);next_acc=next_acc->next)
		{
			if (strcmp(next_acc->grantee, "PUBLIC") == 0)
			{
				public_flag = 1;
				if (RIScom_has_auth(next_acc->auth, auth))
				{
					return 1;
				}
			}
			if (strcmp(RIS_default->schname, next_acc->grantee) == 0)
			{
				schema_flag = 1;
				if (RIScom_has_auth(next_acc->auth, auth))
				{
					return 1;
				}
			}
		}

/* get default schema access and check again */

		if (!schema_flag)
		{
			RISdic_get_access(tabp,RIS_default->schname);
			for (next_acc = attrp->acc;next_acc;next_acc=next_acc->next)
			{
				if (strcmp(RIS_default->schname, next_acc->grantee) == 0)
				{
					if (RIScom_has_auth(next_acc->auth, auth))
					{
						return 1;
					}
					break;
				}
			}
		}

/* get public access and check again */

		if (!public_flag)
		{
			RISdic_get_access(tabp,"PUBLIC");
			for (next_acc = attrp->acc;next_acc;next_acc=next_acc->next)
			{
				if (strcmp(next_acc->grantee, "PUBLIC") == 0)
				{
					if (RIScom_has_auth(next_acc->auth, auth))
					{
						return 1;
					}
					break;
				}
			}
		}
	}
	else
	{
		return 1;
	}
	return 0;
}

/******************************************************************************/

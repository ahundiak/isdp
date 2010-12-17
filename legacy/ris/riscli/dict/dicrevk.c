/*
**	NAME:							dicrevk.c
**	AUTHORS:						David Michal
**	CREATION DATE:					4/88
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include "risasync.h"
#include "riscl_pa.h"
#include "riscom.h"
#include "rismem.h"
#include "dict.h"

/*
**	DEFINES
*/
#define DUMP_ACC(str, acc) \
	if (RISdic_debug) { DIC_DBG((str)); RIScom_output_acc(RIScom_output_debug, acc, 1); }

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define dicrevk_c
#include "comalloc.prt"
#include "comauth.prt"
#include "comdebug.prt"
#include "comexmod.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "comoutpt.prt"
#include "ccosqlca.prt"
#include "ccostmgr.prt"
#include "dicacc.prt"
#include "dicgrnte.prt"
#include "diclook.prt"
#include "dicrevk.prt"
#include "dicundss.prt"
#include "filtrans.prt"
#include "usracc.prt"
#include "usrsndrc.prt"
#include "sys.prt"


/******************************************************************************/

extern void RISdic_revoke(
	ristree *tp,
	int exec_mode)
{
	risaccess	*newacc;
	risaccess	*lastacc = 0;
	risaccess   *oldacc;
	risaccess   *pre_oldacc;
	risschema	*schema;
	int			status;
	char		old_auth[RIS_MAX_ID_SIZE];
    ris_acc_link_list_node *sp2=NULL,*temp2=NULL;

    rissuperschema   *sschema;
    risschema   *subschema=0;
	risaccess	*chk_supsch_acc;
	risaccess	*subsch_acc;
	risaccess	*temp_next_acc;
	risaccess	*temp_revoke_acc = 0;
	risaccess	*start_acc = 0;
	int			start_flag = 0;

DIC_DBG(("RISdic_revoke tp = 0x%x exec_mode:%s\n",tp, 
	RIScom_get_execute_mode_name((unsigned char)exec_mode)));
	
/* set the schema to send the access request to */

	schema = RISdic_lookup_schema(tp->info.access->schname, HASH_TABLE);
	if (!schema)
	{
		LONGJMP(RIS_E_UNKNOWN_SCHEMA);
	}

	status = SETJMP();
	if (status) {
		RESETJMP();
		if (status != STATEMENT_NOT_COMPLETE)
		{
			RIScco_push_risca_dbca();

			if (lastacc)
			{
				lastacc->next = 0;
			}

			RISdic_rollback_all_access();

			if( !IS_SERVER_DEAD(status) )
			{
				RIS_sdp->schema = schema;
				if (!SETJMP())
				{
					RISusr_send_rec(RIS_ROLLBACK_WORK_CODE,RIS_sdp,SYNC_MODE);
				}
				RESETJMP();
			}

			RISfil_rollback_schema_transact();

			RIScco_pop_risca_dbca();
		}
		LONGJMP(status);
	}
	
	if (IN_START_MODE(exec_mode))
	{
	/*
	** Copy access structure linked list into a temporary linked list. This 
	** temp list is used for manipulating the access structures for the 
	** superschema revoke mechanism. Basically the original list is untouched.
	*/
		for(newacc=tp->info.access; newacc; newacc=newacc->next)
		{
			temp_revoke_acc = ALLOCT(risaccess);
			memcpy(temp_revoke_acc, newacc, sizeof(risaccess));

	/*
	** Saving the start access list, that is, 'tp->info.access'
	*/
			if(!start_flag)
			{
				start_acc = temp_revoke_acc;
			}
			temp_revoke_acc = temp_revoke_acc->next;
			start_flag = 1;
		}

		temp_revoke_acc = start_acc;

	/*
	** Check to see if any of the grantors is a superschema
	*/
		for(chk_supsch_acc=temp_revoke_acc; chk_supsch_acc;
			chk_supsch_acc=chk_supsch_acc->next)
		{

			if(sschema = RISdic_find_supersch(chk_supsch_acc->grantor))
			{
				strcpy(chk_supsch_acc->grantor, sschema->sub_schp->schname);

	/*
	** If the grantor is a superschema, then add new nodes with the involved 
	** schemas to the access linked list.
	*/
				for(subschema = sschema->sub_schp; subschema; 
					subschema = subschema->sub_schp)
				{
					if(subschema->sub_schp)
					{
						temp_next_acc = chk_supsch_acc->next;

						subsch_acc = ALLOCT(risaccess);
						memcpy(subsch_acc, chk_supsch_acc, sizeof(risaccess));

						strcpy(subsch_acc->grantor, subschema->sub_schp->schname);

						subsch_acc->next = temp_next_acc;

						chk_supsch_acc->next = subsch_acc;
						chk_supsch_acc = chk_supsch_acc->next;
					}
				}
			}
		}

	/*
	** Check to see if any of the grantees is a superschema
	*/
		for(chk_supsch_acc=temp_revoke_acc; chk_supsch_acc;
			chk_supsch_acc=chk_supsch_acc->next)
		{

	/*
	** If the grantee is a superschema, then add new nodes with the involved 
	** schemas to the access linked list.
	*/
			if(sschema = RISdic_find_supersch(chk_supsch_acc->grantee))
			{
				strcpy(chk_supsch_acc->grantee, sschema->sub_schp->schname);

				for(subschema = sschema->sub_schp; subschema; 
					subschema = subschema->sub_schp)
				{
					if(subschema->sub_schp)
					{
						temp_next_acc = chk_supsch_acc->next;

						subsch_acc = ALLOCT(risaccess);
						memcpy(subsch_acc, chk_supsch_acc, sizeof(risaccess));

						strcpy(subsch_acc->grantee, 
						subschema->sub_schp->schname);

						subsch_acc->next = temp_next_acc;
						chk_supsch_acc->next = subsch_acc;
						chk_supsch_acc = chk_supsch_acc->next;
					}
				}
			}
		}	

	/* The server implicity locks the ris_privs table */
	
	/* get the latest access from the server */
	
    	RISdic_get_all_access(RISdic_lookup_rel(
			schema,temp_revoke_acc->relowner,temp_revoke_acc->relname,0));
		
	/* find the last access struct */
	
		for (newacc=temp_revoke_acc;newacc && newacc->next;newacc=newacc->next);
		lastacc = newacc;
	
	/* add access structs for priviliges revoked due to cascading */
	
		RISdic_cascade_revoke(temp_revoke_acc,lastacc,temp_revoke_acc);
	
		for (newacc=temp_revoke_acc;newacc;newacc=newacc->next)
		{
			DUMP_ACC("NEW ACCESS: ", newacc);
	
	/* get old access list */
	
			oldacc = RISdic_get_old_acclist(newacc);
	
	/* look for existing access struct for this grantee */
	
			for (pre_oldacc=0;oldacc;pre_oldacc=oldacc,oldacc=oldacc->next)
			{
				if (strcmp(newacc->grantor,oldacc->grantor) == 0 &&
					strcmp(newacc->grantee, oldacc->grantee) == 0)
				{
					break;
				}
			}
	
	/* if access struct for this grantee already exists, modify it */
	
			if (oldacc)
			{
	
				DUMP_ACC("OLD ACCESS: ", oldacc);

				strcpy(old_auth, oldacc->auth);
				RIScom_del_auth(oldacc->auth, newacc->auth);
				if (!RIScom_has_auth(oldacc->auth,old_auth))
				{
	
					DUMP_ACC("UPDATED ACCESS: ", oldacc);

	/* remove this access from the ris_privs table */
	
   	             	sp2 = temp2;
   	             	temp2 = ALLOCT(ris_acc_link_list_node);
   	             	temp2->racc = oldacc;
               		temp2->racc->insert_flag = 0;
               		temp2->next = sp2;

	/* if no access is left remove this access struct */
	
					if (!RIScom_has_auth(oldacc->auth,ANY_ACCESS))
					{
						if (pre_oldacc)
						{
							pre_oldacc->next = oldacc->next;
						}
						else
						{
							switch (newacc->flag)
							{
								case 'A':
									newacc->ptr.attr->acc = oldacc->next;
								break;
								case 'T':
									newacc->ptr.tab->acc = oldacc->next;
								break;
								default:
									LONGJMP(RIS_E_INTERNAL_ERROR);
								break;
							}
						}
						RIScco_free_risaccess(schema->schid, oldacc);
					}
				}
				else
				{
	
DIC_DBG(("GRANTEE DOES NOT HAVE THIS ACCESS:\n"));
	
				}
			}
			else
			{
	
DIC_DBG(("ACCESS DOESN'T EXIST:\n"));
	
			}
		}
		sp2 = temp2;

		if (lastacc)
		{
			lastacc->next = 0;
		}
	}
	
	RISusr_update_access(sp2, schema, exec_mode);
	
	if (IN_FINISH_MODE(exec_mode))
	{
		/* get grantees */
		RISdic_update_grantees(schema, GRANT_REVOKE, SYNC_MODE);

		/* commit changes */
		RISfil_commit_schema_transact();
	
		RISdic_commit_all_access();
	}
	
	RESETJMP();
}	
/****************************************************************************/


static void RISdic_cascade_revoke(
	risaccess *new_list,
	risaccess *new_list_end,
	risaccess *total_list)
{
	static risaccess *last_acc;
	risaccess *new_acc;
	char cascade_auth[RIS_MAX_ID_SIZE];
	risaccess *cascade_list;

DIC_DBG(("RISdic_cascade_revoke new_list = 0x%x new_list_end = 0x%x total_list 0x%x\n",new_list,new_list_end,total_list));

/* first time only: set last_acc to the last access struct on the original list
*/

	if (new_list == total_list)
	{
		last_acc = new_list_end;
	}

/* cascade for each of the access structs on the new list */

	for (new_acc=new_list;new_acc;new_acc=new_acc->next)
	{

/* no need to cascade for public access */

		if (strcmp(new_acc->grantee,"PUBLIC") == 0)
		{
			continue;
		}

/* determine what access priviliges to cascade */

		RISdic_what_auth_to_cascade(total_list, new_acc, cascade_auth);

/* if there are no priviliges then don't cascade */

		if (!RIScom_has_auth(cascade_auth,ANY_ACCESS)) 
		{
			continue;
		}

/* get the access structs that can be revoked because of direct dependence */

		cascade_list = RISdic_what_acc_to_cascade(new_acc, cascade_auth);
		last_acc->next = cascade_list;
		for (;last_acc && last_acc->next;last_acc=last_acc->next);

/* recurse for the these access structs to see if we can cascade more */

		RISdic_cascade_revoke(cascade_list,last_acc,total_list);

/* if this was the last access in the new access list then we are done */

		if (new_acc == new_list_end)
		{
			break;
		}
	}
}

/******************************************************************************/

static void RISdic_what_auth_to_cascade(
	risaccess	*new_acclist,
	risaccess	*new_acc,
	char		*cascade_auth)
{
	risaccess	*old_acc;
	risaccess	*new_acc2;
	int	i;	

DIC_DBG(("RISdic_what_auth_to_cascade: new_acclist 0x%x new_acc 0x%x cascade_auth <%s>\n",new_acclist,new_acc,cascade_auth));

/* initialize cascade_auth */

	RIScom_init_auth(cascade_auth);

/* get existing grantable auth */

	for (old_acc=RISdic_get_old_acclist(new_acc);old_acc;old_acc=old_acc->next)
	{
		if (strcmp(old_acc->grantee, new_acc->grantee) == 0 &&
			strcmp(old_acc->grantor, new_acc->grantor) == 0)
		{
			strcpy(cascade_auth, new_acc->auth);
			RISdic_map_grantable_auth(old_acc->auth, cascade_auth);
			break;
		}
	}

/* for each grantable priv check if there is a second source that is not also
   being revoked */

	for (i = ACC_SELECT; i <= ACC_UPDATE; i++)
	{	

/* check if this priv is grantable */

		if (cascade_auth[i] != '-')
		{

/* look for second source */

			for (old_acc=RISdic_get_old_acclist(new_acc);old_acc;
			 old_acc=old_acc->next)
			{

/* if grantees are same but grantors are not then found potential 2nd source */

				if (strcmp(old_acc->grantee, new_acc->grantee) == 0 &&
					 strcmp(old_acc->grantor, new_acc->grantor) != 0)
				{

/* the 2nd source must have grantable priv */

					if (RIScom_isupper(old_acc->auth[i]))
					{

/* look for revokes of this priv from this source in the access list */

						for (new_acc2=new_acclist;new_acc2;
						 new_acc2=new_acc2->next)
						{

/* if grantees, grantors, and colnames are same then the priv may be revoked */

							if (strcmp(new_acc2->grantee, old_acc->grantee) == 0
							 && strcmp(new_acc2->grantor, old_acc->grantor) == 0
							 && strcmp(new_acc2->colname, old_acc->colname) == 0
							 )
							{

/* the priv is being revoked from this source */

								if (new_acc2->auth[i] != '-')
								{
									break;
								}
							}
							
						}

/* second source is not being revoked no need to cascade for this priv */

						if (!new_acc2)
						{
							cascade_auth[i] = '-';
							break;
						}
					}
				}
			}
		}
	}
}

/******************************************************************************/

static void RISdic_map_grantable_auth(
	char	*old_auth,
	char	*cascade_auth)
{
	int	i;
	
DIC_DBG(("RISdic_map_grantable_auth old_auth = <%s> cascade_auth = <%s>\n",
 old_auth,cascade_auth);)

	for (i = ACC_SELECT; i <= ACC_UPDATE; i++)
	{
		if (!RIScom_isupper(old_auth[i]))
		{
			cascade_auth[i] = '-';		
		}	
	}

DIC_DBG(("cascade_auth = <%s>\n", cascade_auth);)

}

/******************************************************************************/

static risaccess * RISdic_what_acc_to_cascade(
	risaccess	*new_acc,
	char		*cascade_auth)
{
	risaccess	*old_acc;
	char		new_auth[RIS_MAX_ID_SIZE];
	risaccess 	*temp;
	risaccess	*cascade_list = 0;

DIC_DBG(("RISdic_what_acc_to_cascade new_acc = 0x%x cascade_auth = <%s>\n",
 new_acc,cascade_auth);)

/* look for access that will be revoked because of cascading */

	for (old_acc=RISdic_get_old_acclist(new_acc);old_acc;old_acc=old_acc->next)
	{

/* check for grantors that are dependent on the access being revoked */

		if (strcmp(old_acc->grantor, new_acc->grantee) == 0)
		{

/* check for grants of priviliges that being revoked */

			strcpy(new_auth, cascade_auth);
			RISdic_map_common_auth(old_acc->auth, new_auth);
			if (RIScom_has_auth(new_auth,ANY_ACCESS))
			{

/* create a new access struct to remove the priviliges */

				temp = ALLOCT(risaccess);
				memcpy((char*)temp ,(char*)old_acc,sizeof(risaccess)); 
				strcpy(temp->auth,new_auth);
				temp->next = cascade_list;
				cascade_list = temp;
			}
		}
	}
	return(cascade_list);
}

/******************************************************************************/

static void RISdic_map_common_auth(
	char	*old_auth,
	char	*new_auth)
{
	int	i;

DIC_DBG(("RISdic_map_common_auth old_auth = <%s> new_auth = <%s>\n",
 old_auth,new_auth);)

	for (i = ACC_SELECT; i <= ACC_UPDATE; i++)
	{
		if (old_auth[i] == '-')
		{
			new_auth[i] = '-';		
		}	
	}

DIC_DBG(("new_auth = <%s>\n",new_auth);)

}

/******************************************************************************/

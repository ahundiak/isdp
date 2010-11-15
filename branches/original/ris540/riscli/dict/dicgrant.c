/*
**	NAME:							dicgrant.c
**	AUTHORS:						David Michal
**	CREATION DATE:					11/90
**	ABSTRACT:
**		
**	
**	REVISION HISTORY: Modified to pass a linked list of 'UPD_ACCESS_CODEs' 
**		  instead of sending them individually to 'RISusr_send_rec'
**		  by Prasad Challa on 9/91.
**		  Implemented superschema grant mechanism Prasad Challa 9/92.
**
**	Modified so that a "grant all to public" statement doesn't do a lot of 
**      unecessary getting and putting of schema file and schema.LCK file.
**      Bug fix TR 249407162 and speed enhancement.  Dianne Ferrans 10/94
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
#define dicgrant_c
#include "comaccss.prt"
#include "comalloc.prt"
#include "comauth.prt"
#include "comdebug.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "comoutpt.prt"
#include "ccosqlca.prt"
#include "ccostmgr.prt"
#include "dicacc.prt"
#include "dicgrant.prt"
#include "dicgrnte.prt"
#include "diclook.prt"
#include "dicundss.prt"
#include "filtrans.prt"
#include "usracc.prt"
#include "usrsndrc.prt"
#include "sys.prt"


/******************************************************************************/

extern void RISdic_grant(
	ristree *tp,
	int exec_mode)
{
	risaccess		*newacc;
	risaccess   	*oldacc;
	risaccess   	*oldacc_list;
	risaccess   	*temp=0;
	risschema		*schema;
	int				status;
	char			temp_auth1[RIS_MAX_ID_SIZE];
	char			temp_auth2[RIS_MAX_ID_SIZE];
	int 			i;
	ris_acc_link_list_node *sp2=NULL,*temp2=NULL;

	risschema		*grantee_subschema=0;
	rissuperschema	*grantee_ssch;
	int				grantee_supsch_flag=0;
	risaccess   	*temp_grant;
	risaccess   	temp_grant_acc;
	risschema		*grantor_subschema=0;
	int				grantor_supsch_flag=0;
	rissuperschema	*grantor_ssch;


	DIC_DBG(("RISdic_grant(tp:0x%x exec_mode:%d)\n", tp, exec_mode));
	
/* set the schema to send the access request to */

	schema = RISdic_lookup_schema(tp->info.access->schname, HASH_TABLE);
	if (!schema)
	{
		LONGJMP(RIS_E_UNKNOWN_SCHEMA);
	}

	status = SETJMP();
	if (status)
	{
		RESETJMP();
		if (status != STATEMENT_NOT_COMPLETE)
		{
			RIScco_push_risca_dbca();
				
			RISfil_rollback_schema_transact();

            if( !IS_SERVER_DEAD(status) )
            {
				RIS_sdp->schema = schema;
				if (!SETJMP())
					RISusr_send_rec(RIS_ROLLBACK_WORK_CODE,RIS_sdp, SYNC_MODE);
				RESETJMP();
			}

			RISdic_rollback_all_access();

			RIScco_pop_risca_dbca();
		}
		LONGJMP(status);
	}

	if (exec_mode & START_MODE)
	{

/* The server implicitly locks the ris_privs table */

/* get the latest access from the server */

		RISdic_get_all_access(RISdic_lookup_rel(schema,
			tp->info.access->relowner,tp->info.access->relname,0));

		for(newacc=tp->info.access;newacc;newacc=newacc->next)
		{

/*
** if the grantor is a superschema, then we need to grant the permissions to
** the grantee from all the schemas defined for the grantor.
*/
			if(grantor_ssch = RISdic_find_supersch(newacc->grantor))
			{
				grantor_supsch_flag = 1;
				grantor_subschema = grantor_ssch->sub_schp;
			}
			else
			{
				grantor_supsch_flag = 0;
			}

			do
			{
				if(grantor_supsch_flag)
				{
					memcpy(&temp_grant_acc,newacc,sizeof(risaccess));
					strcpy(temp_grant_acc.grantor, grantor_subschema->schname);
					temp_grant = &temp_grant_acc;
				}
				else
				{
					temp_grant = newacc;
				}

/*
** if the grantee is a superschema, then we need to grant the permissions to
** all the schemas defined for the grantee.
*/
				if(grantee_ssch = RISdic_find_supersch(newacc->grantee))
				{
					grantee_supsch_flag = 1;
					grantee_subschema = grantee_ssch->sub_schp;
				}
				else
				{
					grantee_supsch_flag = 0;
				}

				do
				{
					if(grantee_supsch_flag && grantor_supsch_flag)
					{
						strcpy(temp_grant->grantee, grantee_subschema->schname);
					}
					else if(grantee_supsch_flag)
					{
						memcpy(&temp_grant_acc,newacc,sizeof(risaccess));
						strcpy(temp_grant_acc.grantee, grantee_subschema->schname);
						temp_grant = &temp_grant_acc;
					}

					DUMP_ACC("NEW ACCESS: ",temp_grant);
	
/* get old access list */

					oldacc_list = RISdic_get_old_acclist(temp_grant);

/* grantor needs granted priviliges to be grantable */

					memcpy(temp_auth1,temp_grant->auth,RIS_MAX_ID_SIZE);
					RIScom_make_grantable(temp_auth1);

/* get grantor's access */

					RIScom_combine_access(oldacc_list,temp_grant->grantor,1,temp_auth2);
	
/* verify that the grantor has the privileges that are being granted */

					if (RIScom_has_auth(temp_auth2,temp_auth1) == 0)
					{
						LONGJMP(RIS_E_INVALID_ACCESS);
					}
	
/* only grant those privileges that have been granted to the grantor,
   and not just to the public */

					RIScom_combine_access(oldacc_list,temp_grant->grantor,0,temp_auth1);
					memcpy(temp_auth2 ,temp_grant->auth,RIS_MAX_ID_SIZE);
					RIScom_intersect_auth(temp_auth2,temp_auth1);
					if (!RIScom_has_auth(temp_auth1,ANY_ACCESS))
					{
						continue;
					}
	
					temp = RIScco_alloc_risaccess(schema->schid);
					memcpy(temp, temp_grant, sizeof(risaccess));
					strcpy(temp->auth,temp_auth2);
					temp->next = 0;
	
					DUMP_ACC("MODIFIED NEW ACCESS: ",temp);

/* merge the new access list with the existing access list. */

/* look for existing access struct for this grantee */
			
					for (oldacc=oldacc_list;oldacc;oldacc=oldacc->next)
					{
	
DIC_DBG(("new grantor = <%s> old grantor = <%s>\nnew grantee = <%s> old grantee = <%s>\n",temp->grantor,oldacc->grantor,temp->grantee,oldacc->grantee));

						if (strcmp(temp->grantor,oldacc->grantor) == 0 &&
							strcmp(temp->grantee, oldacc->grantee) == 0)
						{
							break;
						}
					}
		
/* if access struct for this grantee already exists, modify it */

					if (oldacc)
					{

						DUMP_ACC("OLD ACCESS: ",oldacc);

						if (!RIScom_has_auth(oldacc->auth,temp->auth))
						{
							RIScom_auth_tobe_added(oldacc->auth,temp->auth);
							for (i = ACC_SELECT; i <= ACC_UPDATE; i++)
							{
								if (temp->auth[i] != '-')
								{
									RISdic_det_cyclic_grant(oldacc_list, temp->grantor, 
                                        temp->grantee, i);
								}
							}
							RIScom_add_auth(oldacc->auth, temp->auth);
		
							DUMP_ACC("UPDATING ACCESS: ", oldacc);
	
							sp2 = temp2;
							temp2 = ALLOCT(ris_acc_link_list_node);
							temp2->racc = oldacc;
							temp2->racc->insert_flag = 0;
							temp2->next = sp2;
						}
						else
						{
	
DIC_DBG(("ACCESS ALREADY GRANTED:\n"));

						}
						RIScco_free_risaccess(schema->schid, temp);

					}
	
/* otherwise add this access struct to the list */

					else
					{
						for (i = ACC_SELECT; i <= ACC_UPDATE; i++)
						{
							if (temp->auth[i] != '-')
							{
								RISdic_det_cyclic_grant(oldacc_list, 
													temp->grantor, 
													temp->grantee, 
													i);
							}
						}
						temp->next = oldacc_list;
						switch (temp_grant->flag)
						{
							case 'A':   /* ATTR */
								temp->ptr.attr->acc = temp;
							break;
							case 'T':   /* TABLE */
								temp->ptr.tab->acc = temp;
							break;
							default:
								LONGJMP(RIS_E_INTERNAL_ERROR);
							break;
						}
		
						DUMP_ACC("INSERTING NEW ACCESS: ", temp);
	
						sp2 = temp2;
						temp2 = ALLOCT(ris_acc_link_list_node);
						temp2->racc = temp;
						temp2->racc->insert_flag = 1;
						temp2->next = sp2;

					}

/*
** continue grant operation for all the schemas defined on the grantee 
** superschema
*/
					if(grantee_supsch_flag)
					{
						grantee_subschema = grantee_subschema->sub_schp;
					}
				} while (grantee_subschema);

/*
** continue grant operation for all the schemas defined on the grantor 
** superschema, if the owner and the grantor are not same.
*/
				if(grantor_supsch_flag && grantor_subschema)
				{
					grantor_subschema = grantor_subschema->sub_schp;
				}
			}while (grantor_subschema);

		} /* end of the first for */
		sp2 = temp2;

	}

	RISusr_update_access(sp2, schema, exec_mode);

	if (exec_mode & FINISH_MODE)
	{
	/* get grantees */
	if (temp && strcmp(temp->grantee,"PUBLIC") == 0) /* DDF 10/94 change for TR 249407162*/
		RISdic_update_grantees2(schema, GRANT_REVOKE, SYNC_MODE,1);
	else
		RISdic_update_grantees(schema, GRANT_REVOKE, SYNC_MODE);

/* commit changes */

		RISfil_commit_schema_transact();
		RISdic_commit_all_access();
	}

	RESETJMP();
}

/****************************************************************************/

static void RISdic_det_cyclic_grant(
	risaccess	*oldacc_list,
	char		*grantor,
	char		*grantee,
	int			auth_indx)
{
	risaccess	*oldacc;

DIC_DBG(("RISdic_det_cyclic_grant oldacc_list = 0x%x grantor = <%s> grantee = <%s>, auth_indx = %d\n",oldacc_list, grantor, grantee, auth_indx);)

	if (!strcmp(oldacc_list->schname, grantor))
	{
		return;
	}
	for (oldacc=oldacc_list;oldacc;oldacc=oldacc->next)
	{
		if (strcmp(oldacc->grantee, grantor) == 0 &&
			RIScom_isupper(oldacc->auth[auth_indx]))
		{
			if (strcmp(oldacc->grantor, grantee) == 0)
			{
				LONGJMP(RIS_E_CIRCULAR_GRANT);
			}
			else
			{
				RISdic_det_cyclic_grant(oldacc_list,oldacc->grantor,grantee,
				 auth_indx);
			}
		}
	} 
}

/****************************************************************************/

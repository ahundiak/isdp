/* Do not alter this SPC information: $Revision: 1.2.30.1 $ */
/*
**	NAME:							trnpriv.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routines that handle ddl privilege statements.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "riscli.h"
#include "riscom.h"
#include "rismem.h"
#include "trans.h"
/*
**	FUNCTION PROTOTYPES
*/
#define trnpriv_c
#include "comalloc.prt"
#include "comdebug.prt"
#include "comauth.prt"
#include "comjmp.prt"
#include "trnpriv.prt"
#include "trnshare.prt"
#include "sys.prt"

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

/*
** transforms grant parse tree to rax
** grantp = grant parse tree
** 6.6 <privilege definition> syntax rule 1
** 6.6 <privilege definition> syntax rule 2
** 6.6 <privilege definition> syntax rule 3
** 6.6 <privilege definition> syntax rule 4
** 6.6 <privilege definition> syntax rule 5
*/

extern void RIStrn_grant(
	ristree * grantp)
{
	ristree * privp;
	ristree * tablep;
	ristree * granteep;
	ristree * withgrantp = 0;
	risaccess * access_list;

	TRN_DBG(("RIStrn_grant(grantp:0x%x)\n",grantp));

/* set up pointers */

	privp = grantp->rhs->lhs;
	tablep = grantp->rhs->rhs->lhs;
	granteep = grantp->rhs->rhs->rhs->lhs;
	if (grantp->rhs->rhs->rhs->rhs)
	{
		withgrantp = grantp->rhs->rhs->rhs->rhs->lhs;
	}

/* replace RIS_TOK_TABLE_NAME with RIS_TOK_TABLE */

	RIStrn_table_name(tablep,0,0,0);
	
    RIStrn_det_dic_tab_mod(tablep->info.tab->tabname, RIS_TOK_GRANT);
    RIStrn_check_dict_select(tablep->info.tab->tabname, RIS_TOK_GRANT);

/* create access list for table and column privileges */

	access_list = RIStrn_privileges(privp,tablep,withgrantp);

/* make a copy of the access list for each grantee */

	access_list = RIStrn_grantees(granteep,access_list);

/* make RIS_TOK_GRANT point to the access list */

	grantp->info.access = access_list;
	grantp->rhs = 0;

	TRN_DBG(("RIStrn_grant:complete\n"));
}

/******************************************************************************/

/*
** add all columns of a table to the access list
** tablep = grant table access_list = list of access structs
** priv = the privilege being granted
*/

static void RIStrn_grant_all_cols(
	ristree * tablep,
	risaccess * access_list,
	char * priv)
{
	ristree * temp1;
	risaccess * temp;
	char * ptr = 0;
	char * name = 0;
	char flag = 0;

	TRN_DBG(("RIStrn_grant_all_cols(tablep:0x%x access_list:0x%x priv:<%s>)\n",
		tablep, access_list, priv));

	for (temp1=tablep->rhs;temp1;temp1=temp1->rhs)
	{
		switch(temp1->lhs->tok)
		{
			case RIS_TOK_ATTR:
				ptr = (char *)temp1->lhs->info.attr;
				name = temp1->lhs->info.attr->attrname;
				flag = 'A';
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,temp1->lhs->pos);
			break;
		}

/*
** or this privilege into the access struct for this column or create a new
** access struct if necessary
*/

		for (temp=access_list->next;temp;temp=temp->next)
		{
			if (ptr == (char *)temp->ptr.attr)
			{
				RIScom_add_auth(temp->auth,priv);
				break;
			}
		}
		if (!temp)
		{
			temp = ALLOCT(risaccess);
			strcpy(temp->grantor,access_list->grantor);
			strcpy(temp->grantee,access_list->grantee);
			strcpy(temp->relowner,access_list->relowner);
			strcpy(temp->relname,access_list->relname);
			strcpy(temp->schname,access_list->schname);
			temp->relid = access_list->relid;
			temp->ptr.attr = (risattr *)ptr;
			strcpy(temp->auth,priv);
			strcpy(temp->colname,name);
			temp->flag = flag;
			temp->next = access_list->next;
			access_list->next = temp;
		}
	}
	TRN_DBG(("RIStrn_grant_all_cols:complete\n"));
}

/******************************************************************************/

/*
** gets info for columns and checks for dups
** tablep = grant table colp = column list
** 6.6 <privilege definition > syntax rule 2
*/

static void RIStrn_grant_col_list(
	ristree * tablep,
	ristree * colp,
	risaccess * access_list,
	char * priv)
{
	ristree * temp1;
	ristree * temp2;
	risaccess * temp;
	char * ptr = 0;
	char * name = 0;
	char flag = 0;

	TRN_DBG(("RIStrn_grant_col_list(tablep:0x%x colp:0x%x access_list:0x%x"
		" priv:<%s>)\n", tablep, colp, access_list, priv));

	for (temp1=colp;temp1;temp1=temp1->rhs)
	{

/* replace RIS_TOK_COL_NAME with RIS_TOK_ATTR */

		RIStrn_col_name(temp1->lhs,tablep,0);

/* check for duplicate columns */

		switch(temp1->lhs->tok)
		{
			case RIS_TOK_ATTR:
				ptr = (char *)temp1->lhs->info.attr;
				name = temp1->lhs->info.attr->attrname;
				flag = 'A';
				for (temp2=colp;temp2 != temp1;temp2=temp2->rhs)
				{
					if (temp2->lhs->info.attr == temp1->lhs->info.attr)
					{
						TRN_ERR_RETURN(RIS_E_DUP_GRANT_COL,temp1->lhs->pos);
					}
				}
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,temp1->lhs->pos);
			break;
		}

		temp = ALLOCT(risaccess);
		strcpy(temp->grantor,access_list->grantor);
		strcpy(temp->grantee,access_list->grantee);
		strcpy(temp->relowner,access_list->relowner);
		strcpy(temp->relname,access_list->relname);
		strcpy(temp->schname,access_list->schname);
		temp->relid = access_list->relid;
		temp->ptr.attr = (risattr *)ptr;
		strcpy(temp->auth,priv);
		strcpy(temp->colname,name);
		temp->flag = flag;
		temp->next = access_list->next;
		access_list->next = temp;
	}
	TRN_DBG(("RIStrn_grant_col_list:complete\n"));
}

/******************************************************************************/

static risaccess * RIStrn_grantees(
	ristree * granteep,
	risaccess * access_list)
{
	ristree * tp1;
	ristree * tp2;
	risaccess * temp1;
	risaccess * temp2;
	risaccess * temp_list;
	char	  * schname1;
	char	  * schname2;
	int len = 0;
	int i;
	/* rissuperschema * sschema; */

	TRN_DBG(("RIStrn_grantees(granteep:0x%x access_list:0x%x)\n",
 		granteep,access_list));

	for (tp1=granteep->rhs;tp1;tp1=tp1->rhs)
	{
		switch(tp1->lhs->tok)
		{
			case RIS_TOK_AUTH_ID:

/* make RIS_TOK_AUTH_ID into an RIS_TOK_SCHEMA or RIS_TOK_SUPERSCHEMA */
                   
/************************************************************************
Someday we'll add this change for secure schema grant verifying thru
schema file and not by default schema, but for now causes coredump
on NT because stmt id's don't get incremented correctly and RISfil_schema_list
loses it's memory after ALLOTS call in RIScco_alloc_risaccess..when
"prepare...execute immed...prepare...execute immed" pattern follwed like
in the rislod process
------------------------------------------------------------------------

                        if (sschema = RISdic_find_supersch(tp1->lhs->info.val))
			{
			
				tp1->lhs->info.sschema = sschema;
				tp1->lhs->tok = RIS_TOK_SUPERSCHEMA;
                        }
                        else
			{
				tp1->lhs->info.schema = RISdic_lookup_schema(tp1->lhs->info.val, SCHEMA_FILE);

                                if (!tp1->lhs->info.schema)
                                {
					TRN_ERR_RETURN(RIS_E_UNKNOWN_SCHEMA, tp1->lhs->pos);
                                } 
				tp1->lhs->tok = RIS_TOK_SCHEMA;
                       }
 *************************************************************/
	 RIStrn_auth_id(tp1->lhs); /* and remove this when we do*/ 
/* *************************************************************/
			break;
			case RIS_TOK_PUBLIC:
				tp1->lhs->info.schema = ALLOCT(risschema);
				strcpy(tp1->lhs->info.schema->schname,"PUBLIC");
			break;
			default:
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp1->lhs->pos);
			break;
		}

		if( tp1->lhs->tok == RIS_TOK_SUPERSCHEMA )
		{
			/* if grantee is a superschema */
			schname1 = tp1->lhs->info.sschema->schname;
		}
		else
		{
			/* if grantee is schema or "public" */
			schname1 = tp1->lhs->info.schema->schname;
		}

/* check for grantor equals grantee */

		if (strcmp(schname1,access_list->grantor) == 0)
		{
			TRN_ERR_RETURN(RIS_E_GRANTOR_EQ_GRANTEE,tp1->lhs->pos);
		}

/* check for duplicate grantees */

		for (tp2=granteep->rhs;tp2 && tp2 != tp1;tp2=tp2->rhs)
		{
			if( tp2->lhs->tok == RIS_TOK_SUPERSCHEMA )
			{
				/* if grantee is a superschema */
				schname2 = tp2->lhs->info.sschema->schname;
			}
			else
			{
				/* if grantee is schema or "public" */
				schname2 = tp2->lhs->info.schema->schname;
			}
			if (strcmp(schname2,schname1) == 0 )
			{
				TRN_ERR_RETURN(RIS_E_DUP_GRANTEE,tp1->lhs->pos);
			}
		}
		
/* first time only count the number of access structs */

		if (tp1 == granteep->rhs)
		{
			for (temp1=access_list;temp1;temp1=temp1->next)
			{
				len++;
			}
		}

/* set grantees in first len access structs to schema */

		if (tp1->rhs)
		{

/* also make a copy of the access structs for the next grantee */

			temp_list = ALLOCN(risaccess, len);
			temp2 = temp_list;
			for (temp1=access_list,i=1;i <= len;temp1=temp1->next,i++)
			{
				memcpy((char*)temp2,(char*)temp1,sizeof(risaccess));
				if (i == len)
				{
					temp2->next = access_list;
				}
				else
				{
					temp2->next = temp2+1;
					temp2++;
				}
				strcpy(temp1->grantee,schname1);
			}
			access_list = temp_list;
		}
		else
		{
			for (temp1=access_list,i=1;i <= len;temp1=temp1->next,i++)
			{
				strcpy(temp1->grantee,schname1);
			}
		}
	}
	TRN_DBG(("RIStrn_grantees: returning access_list:0x%x\n", access_list));
	return(access_list);
}

/******************************************************************************/

static risaccess * RIStrn_privileges(
	ristree * privp,
	ristree * tablep,
	ristree * withgrantp)
{
	ristree * tp;
	risaccess * access_list;
	char * priv;

	TRN_DBG(("RIStrn_privileges(privp:0x%x tablep:0x%x withgrantp:0x%x\n",
		privp, tablep, withgrantp));

	access_list = ALLOCT(risaccess);
	RIScom_init_auth(access_list->auth);
	switch(tablep->tok)
	{
		case RIS_TOK_TABLE:
			access_list->ptr.tab = tablep->info.tab;
			strcpy(access_list->relowner,tablep->info.tab->tabowner);
			strcpy(access_list->relname,tablep->info.tab->tabname);
			strcpy(access_list->schname,tablep->info.tab->schema->schname);
			access_list->relid = tablep->info.tab->tabid;
			access_list->flag = 'T';
		break;
		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tablep->pos);
		break;
	}

/*
** if the grantor is a superschema and grantor != owner
*/

	if(RIS_default->superschema_flag 
	  && RIS_default != tablep->info.tab->schema)
	{
		strcpy(access_list->grantor,RIS_default->super_schp->schname);
	}
	else
	{
		strcpy(access_list->grantor,RIS_default->schname);
	}
	if (privp->tok == RIS_TOK_ALL)
	{
		if (withgrantp)
		{
			RIScom_add_auth(access_list->auth,GRANTABLE_ALL_ACCESS);
			RIStrn_grant_all_cols(tablep,access_list,GRANTABLE_UPDATE_ACCESS);
		}
		else
		{
			RIScom_add_auth(access_list->auth,ALL_ACCESS);
			RIStrn_grant_all_cols(tablep,access_list,UPDATE_ACCESS);
		}
	}
	else
	{
		for (tp=privp->rhs;tp;tp=tp->rhs)
		{
			switch(tp->lhs->tok)
			{
				case RIS_TOK_SELECT:
					if (withgrantp)
					{
						priv = GRANTABLE_SELECT_ACCESS;
					}
					else
					{
						priv = SELECT_ACCESS;
					}
					if (RIScom_has_auth(access_list->auth,priv) != 0)
					{
						TRN_ERR_RETURN(RIS_E_DUP_PRIV,tp->lhs->pos);
					}
					RIScom_add_auth(access_list->auth,priv);
				break;
				case RIS_TOK_INSERT:
					if (withgrantp)
					{
						priv = GRANTABLE_INSERT_ACCESS;
					}
					else
					{
						priv = INSERT_ACCESS;
					}
					if (RIScom_has_auth(access_list->auth,priv) != 0)
					{
						TRN_ERR_RETURN(RIS_E_DUP_PRIV,tp->lhs->pos);
					}
					RIScom_add_auth(access_list->auth,priv);
				break;
				case RIS_TOK_UPDATE:
					if (withgrantp)
					{
						priv = GRANTABLE_UPDATE_ACCESS;
					}
					else
					{
						priv = UPDATE_ACCESS;
					}
					if (RIScom_has_auth(access_list->auth,priv) != 0)
					{
						TRN_ERR_RETURN(RIS_E_DUP_PRIV,tp->lhs->pos);
					}
					if (tp->lhs->rhs)
					{
						RIStrn_grant_col_list(tablep,tp->lhs->rhs->rhs,
						 access_list,priv);
						RIStrn_col_unsupported(tp->lhs->rhs->rhs);
					}
					else
					{
						RIScom_add_auth(access_list->auth,priv);
						RIStrn_grant_all_cols(tablep,access_list,priv);
					}
				break;
				case RIS_TOK_DELETE:
					if (withgrantp)
					{
						priv = GRANTABLE_DELETE_ACCESS;
					}
					else
					{
						priv = DELETE_ACCESS;
					}
					if (RIScom_has_auth(access_list->auth,priv) != 0)
					{
						TRN_ERR_RETURN(RIS_E_DUP_PRIV,tp->lhs->pos);
					}
					RIScom_add_auth(access_list->auth,priv);
				break;
				default:
					TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->lhs->pos);
				break;
			}
		}
	}

	if (RIScom_has_auth(access_list->auth,ANY_ACCESS))
	{
		TRN_DBG(("RIStrn_privileges:complete\n"));
		return(access_list);
	}
	else
	{
		TRN_DBG(("RIStrn_privileges:complete\n"));
		return(access_list->next);
	}
}

/******************************************************************************/

/*
** transforms revoke parse tree to rax
** revokep = revoke parse tree
** revoke is an RIS extension so the sql standard
*/

extern void RIStrn_revoke(
	ristree * revokep)
{
	ristree * privp;
	ristree * tablep;
	ristree * granteep;
	risaccess * access_list;

	TRN_DBG(("RIStrn_revoke(revokep:0x%x)\n",revokep));

/* set up pointers */

	privp = revokep->rhs->lhs;
	tablep = revokep->rhs->rhs->lhs;
	granteep = revokep->rhs->rhs->rhs->lhs;

/* replace RIS_TOK_TABLE_NAME with RIS_TOK_TABLE */

	RIStrn_table_name(tablep,0,0,0);

    RIStrn_det_dic_tab_mod(tablep->info.tab->tabname, RIS_TOK_REVOKE);
    RIStrn_check_dict_select(tablep->info.tab->tabname, RIS_TOK_REVOKE);

/* create access list for table and column privileges */

	access_list = RIStrn_privileges(privp,tablep,(ristree *)0);

/* make a copy of the access list for each grantee */

	access_list = RIStrn_grantees(granteep,access_list);

/* make RIS_TOK_REVOKE point to the access list */

	revokep->info.access = access_list;
	revokep->rhs = 0;

	TRN_DBG(("RIStrn_revoke:complete\n"));
}

/******************************************************************************/

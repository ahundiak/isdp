/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							trnsch.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routines that handle ddl schema statements
**		except for create schema.
**	
**	REVISION HISTORY:
**
**	11/94:	Changed the call strchr to RIScom_strchr for INTERNATINALIZATION. Dianne
*/
 
/*
**	INCLUDES
*/
#include "riscom.h"
#include "rismem.h"
#include "trans.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trnsch_c
#include "ccooutpt.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comstrng.prt"
#include "trnpaths.prt"
#include "trnsch.prt"
#include "sys.prt"
#include "comuni.prt"

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
** transform declare schema parse tree to rax
** tp = declare parse tree
** declare schema is an RIS statement for secure schema 
*/

extern void RIStrn_declare_schema(
	ristree * tp)
{

	TRN_DBG(("\nRIStrn_declare_schema tp = 0x%x\n",tp));

	/*
	**	trans
    **		  declare schema
    **  			 \
	**                \____
    **   		 		   \
	**			          LIST
    **   				   /\
    **      		  ____/  \____
    **      		 /            \
	**           AUTH_ID         LIST
	**                            /
    **          			 ____/
    **  					/
    **                    USER
    **                      \ 
    **					     \____
    **        			          \
    **      				   PASSWORD
    **
	**	to
    **		  declare schema
    **  		   / \
	**            /   \
    **     		 /     \
	**       AUTH_ID  USER
    **                   \ 
    **      	          \
    **      		   PASSWORD
    **
	*/
	switch(tp->tok)
	{
		case RIS_TOK_DECLARE_SCHEMA:
			tp->lhs = tp->rhs->lhs;
			tp->rhs = tp->rhs->rhs->lhs;
			break;

		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->pos);
	}
}

/******************************************************************************/

/*
** transform open/close/default schema parse tree to rax
** tp = open/close/default parse tree
** open/close/default schema is an RIS extension to the sql standard
*/

extern void RIStrn_open_default_schema(
	ristree * tp)
{

	TRN_DBG(("\nRIStrn_open_default_schema tp = 0x%x\n",tp));

	/*
	**	make the schema list the rhs of RIS_TOK_OPEN/DEFAULT_SCHEMA
	*/
	tp->rhs = tp->rhs->lhs->rhs;
}

/******************************************************************************/

extern void RIStrn_close_schema(
	ristree * tp)
{

TRN_DBG(("\nRIStrn_close_schema tp = 0x%x\n",tp));

	/*
	**	make the schema list or RIS_TOK_ALL the rhs of CLOSE_SCHEMA
	*/

	switch(tp->rhs->lhs->tok)
	{
		case RIS_TOK_SCHEMA_LIST:
			tp->rhs = tp->rhs->lhs->rhs;
			break;

		case RIS_TOK_ALL:
			tp->rhs = tp->rhs->lhs;
			break;

		default:
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->rhs->lhs->pos);
	}
}

/******************************************************************************/

/*
** transform alter schema parse tree into rax
** alterp = alter schema parse tree
** alter schema is an RIS extension to the sql standard
*/

extern void RIStrn_alter_schema(
	ristree * alterp)
{
	ristree *tp, **tpp;
	ristree *authidp;
	ristree *sch_pass = 0;
	ristree *inc_exc = 0;
	ristree *db2_pass = 0;
	ristree	*remote = 0;
	ristree	*usr_pass = 0;
	ristree	*osuser = 0;
	ristree *secure = 0;
	ristree *mode = 0;
	ristree *major = 0;
	risdb *dp;
	/* James rename */
	ristree *inc_ristab = 0;
	ristree *inc_risindex = 0;
	ristree *inc_riscols = 0;

	TRN_DBG(("RIStrn_alter_schema(alterp:0x%x)\n",alterp));
	if (RIStrn_debug)
	{
		RIScco_output_internal_tree(RIScom_output_debug, alterp);
	}

	/*
	**	make RIS_TOK_ALTER_SCHEMA point to the schema name
	*/
	authidp = alterp->rhs->lhs;
	alterp->info.val = authidp->info.val;

	for (tp = alterp->rhs->rhs; tp; tp = tp->rhs)
	{
		switch (tp->lhs->tok)
		{
			case RIS_TOK_SCHEMA:
				if (sch_pass)
				{
					TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->lhs->pos);
				}
				sch_pass = tp->lhs;
				break;

			case RIS_TOK_INCLUDE:
			case RIS_TOK_EXCLUDE:
				if (inc_exc)
				{
					TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->lhs->pos);
				}
				inc_exc = tp->lhs;
				break;

			case RIS_TOK_SECURE:
				if (secure)
				{
					TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->lhs->pos);
				}
				secure = tp->lhs;
				break;

			case RIS_TOK_DB2:
				if (db2_pass)
				{
					TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->lhs->pos);
				}
				db2_pass = tp->lhs;
				break;

			case RIS_TOK_REMOTE:
				if (remote)
				{
					TRN_ERR_RETURN(RIS_E_MULT_REMOTE_DEF,tp->lhs->pos);
				}
				remote = tp->lhs;
				break;

			case RIS_TOK_USER:
				if (usr_pass)
				{
					TRN_ERR_RETURN(RIS_E_MULT_USR_PASS_DEF,tp->lhs->pos);
				}
				usr_pass = tp->lhs;
				break;

			case RIS_TOK_OSUSER:
				if (osuser)
				{
					TRN_ERR_RETURN(RIS_E_MULT_OSUSER_DEF,tp->lhs->pos);
				}
				osuser = tp->lhs;
				break;

			case RIS_TOK_MAJOR:
				if (major)
				{
					TRN_ERR_RETURN(RIS_E_MULT_SERVER_VERSION_DEF,tp->lhs->pos);
				}
				major = tp->lhs;
				break;

			default:
				TRN_DBG(("RIStrn_alter_schema:ERROR:invalid token:%d\n",
					tp->lhs->tok));
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->lhs->pos);
		}
	}

	/*
	**	Set up authid password
	*/
	alterp->rhs = authidp->rhs;

	if (sch_pass)
	{
		if (secure || inc_exc || db2_pass || remote || usr_pass || osuser)
		{
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR, alterp->pos);
		}

		/*
		**	Set up the password
		*/
		get_password(sch_pass);

		/*
		**	hang action off lhs of RIS_TOK_ALTER_SCHEMA
		*/
		alterp->lhs = sch_pass;
	}
	else if (secure)
	{
		if (sch_pass || inc_exc || db2_pass || remote || usr_pass || osuser)
		{
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR, alterp->pos);
		}

		/*
		**      hang action off lhs of RIS_TOK_ALTER_SCHEMA
		*/
		alterp->lhs = secure;
	}
	else if (inc_exc)
	{
		if (secure || sch_pass || db2_pass || remote || usr_pass || osuser)
		{
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR, alterp->pos);
		}
/*
		if (inc_exc->rhs->rhs->lhs->tok == RIS_TOK_AUTH_ID)
		{
			TRN_ERR_RETURN(RIS_E_NO_SCHNAME_ALLOWED, alterp->pos);
		}
		else 
				* allow schema name for rename . James
*/
		/* Rename */
		if (inc_exc->rhs->rhs->rhs)
		{
			int tok;
			ristree	*inc_as;
			
			inc_as = inc_exc->rhs->rhs->rhs;
			tok = inc_exc->rhs->rhs->lhs->tok;
			if (tok == RIS_TOK_TABLE_NAME  || tok == RIS_TOK_USR_NAME)
			{	
			      inc_ristab = inc_as->lhs->rhs->lhs;
			      if (inc_as->lhs->rhs->rhs)
					inc_riscols = inc_as->lhs->rhs->rhs->lhs;
			}
			else if (tok == RIS_TOK_INDEX_NAME )
			{	
				inc_risindex = inc_as->lhs->rhs->lhs;
			}
		}	

		if (inc_exc->rhs->rhs->lhs->tok == RIS_TOK_USR_NAME)
		{
			TRN_DBG(("RIStrn_alter_schema: usrname -> tabname\n"));
			inc_exc->rhs->info.val = inc_exc->rhs->rhs->lhs->rhs->info.val;
			inc_exc->lhs = inc_exc->rhs->rhs->lhs;
			inc_exc->rhs->rhs = 0;
		}
		else if (inc_exc->rhs->rhs->lhs->tok == RIS_TOK_TABLE_NAME)
		{
			TRN_DBG(("RIStrn_alter_schema: tabname\n"));
			inc_exc->rhs->info.val = inc_exc->rhs->rhs->lhs->info.val;
                        /*disallow @, #, or $ as part of a table name, non-ansi-standard, unless followed by an alias. */

		        if ((inc_exc->tok == RIS_TOK_INCLUDE) && 
		            (!inc_exc->rhs->rhs->rhs) &&  /* no rename */
                             ((RIScom_strchr(inc_exc->rhs->info.val,'#')) || 
                             (RIScom_strchr(inc_exc->rhs->info.val,'@'))  || 
                             (RIScom_strchr(inc_exc->rhs->info.val,'$'))))
                        {
			   TRN_ERR_RETURN(RIS_E_INV_ALSCH_INCL_TABNAME, alterp->pos);
                        }

			inc_exc->rhs->rhs = 0;
		}
		else if (inc_exc->rhs->rhs->lhs->tok == RIS_TOK_INDEX_NAME)
		{
			TRN_DBG(("RIStrn_alter_schema: indexname\n"));
			inc_exc->rhs->info.val = inc_exc->rhs->rhs->lhs->info.val;
			inc_exc->rhs->rhs = 0;
		}
		else
		{
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR, alterp->pos);
		}

		/*
		**	hang action off lhs of RIS_TOK_ALTER_SCHEMA
		*/
		alterp->lhs = inc_exc;

		/*
		**	hang ris tab and cols of TABLE node 
		*/

		if( inc_ristab )
		{ 
			inc_exc->rhs->lhs=inc_ristab;
			inc_exc->rhs->rhs=inc_riscols;
		}

		if( inc_risindex)
		{ 
			inc_exc->rhs->lhs=inc_risindex;
		}

	}
	else if (db2_pass)
	{
		if (secure || sch_pass || inc_exc || remote || usr_pass || osuser)
		{
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR, alterp->pos);
		}

		/*
		**	Check for mode
		*/
		if (db2_pass->rhs->rhs->rhs)
		{
			mode = db2_pass->rhs->rhs->rhs->lhs;
			if (mode && strlen(mode->info.val) >= RIS_MAX_MODE_NAME_SIZE)
			{
				sprintf(RIS_ERRMSGC, "The maximum length is %d.",
					RIS_MAX_MODE_NAME_SIZE - 1);
				TRN_ERR_RETURN(RIS_E_MODE_TOO_LONG,mode->pos);
			}
		}
		db2_pass->lhs = mode;

		/*
		**	Check passwords
		*/
		db2_pass->rhs->rhs = db2_pass->rhs->rhs->lhs;
		if (strlen(db2_pass->rhs->rhs->info.val) >= RIS_MAX_RACF_PASSWD_SIZE)
		{
			sprintf(RIS_ERRMSGC, "The maximum length is %d.",
				RIS_MAX_RACF_PASSWD_SIZE - 1);
			TRN_ERR_RETURN(RIS_E_RACF_PASSWD_TOO_LONG,db2_pass->rhs->rhs->pos);
		}

        /*
        ** Convert the OLD and NEW passwords to upper case (since in some cases,
        ** IBM converts user passwords to upper case and our risschema file
        ** needs to be consistent with that.
        ** Modified 2/18/92 - Sunil
        */
		RIScom_uppercase(strlen(db2_pass->rhs->lhs->info.val),
			(unsigned char *)db2_pass->rhs->lhs->info.val);
		RIScom_uppercase(strlen(db2_pass->rhs->rhs->info.val),
			(unsigned char *)db2_pass->rhs->rhs->info.val);

		/*
		**	hang action off lhs of RIS_TOK_ALTER_SCHEMA
		*/
		alterp->lhs = db2_pass;

	}
	else if (remote || usr_pass || osuser || major)
	{
		if (secure || sch_pass || inc_exc || db2_pass)
		{
			TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR, alterp->pos);
		}

		tpp = &alterp->lhs;

		if (remote)
		{
			dp = ALLOCT(risdb);
			RIStrn_setup_remote_pathways(remote, dp);

			remote->info.db = dp;
			remote->rhs = 0;
			remote->lhs = 0;

			*tpp = remote;
			tpp = &remote->lhs;
		}

		if (usr_pass)
		{
			get_password(usr_pass);

			*tpp = usr_pass;
			tpp = &usr_pass->lhs;
		}

		if (osuser)
		{
			*tpp = osuser;
			tpp = &osuser->lhs;
		}

		if (major)
		{
			*tpp = major;
			tpp = &major->lhs;
		}
	}
	else
	{
		TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR, alterp->pos);
	}

	TRN_DBG(("RIStrn_alter_schema: returing\n"));
}

/******************************************************************************/

static void get_password(
	ristree *tp)
{
	if (tp->rhs)
	{
		tp->info.val = tp->rhs->info.val;
		tp->rhs = 0;
	}
	else
	{
		tp->info.val = ALLOCB(1);
		*(tp->info.val) = '\0';
	}
}

/******************************************************************************/

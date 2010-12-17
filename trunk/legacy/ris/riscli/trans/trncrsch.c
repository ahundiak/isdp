/* Do not alter this SPC information: $Revision: 1.8.3.1 $ */
/*
**	NAME:							trncrsch.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		This file contains the routines that handle ddl create schema
**		statements.
**	
**	REVISION HISTORY:
**          changed fieldname 'usr' to 'schowner' in risschema structure
**              -- Shiva 11/11/93
**			10/24/94 -Radha
**				Added changes for MSSQL data server.
**
*/
 
/*
**	INCLUDES
*/
#include "riscli.h"
#include "risver.h"
#include "riscom.h"
#include "rismem.h"
#include "trans.h"
#include "dict.h"
#include "net.h"

/*
**	FUNCTION PROTOTYPES
*/
#define trncrsch_c
#include "ccover.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "compd.prt"
#include "comstrng.prt"
#include "trncrsch.prt"
#include "trnparse.prt"
#include "trnpaths.prt"
#include "sys.prt"


/*
**	DEFINES
*/
#define ARCH_DEF		"s370"
#define OS_DEF			"mvs"
#define ENV_DEF			"cics"
#define PROTOCOL_DEF	"lu6.2"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

/*
** transform create schema parse tree into schema struct
** createp = create schema parse tree
** 6.1 <schema> syntax rule 1 checked by dictionary
*/

extern void RIStrn_create_schema(
	ristree * createp)
{
	int			len;
	ristree		*tp;
	ristree		*securep = 0;
	ristree		*authidp = 0;
	ristree		*userp = 0;
	ristree		*usingp = 0;
	ristree		*ostypep = 0;
	ristree		*osuserp = 0;
	ristree		*forcep = 0;
	ristree		*inc_excp = 0;
	ristree		*dbspecp = 0;
	ristree		*optionp = 0;
	ristree		*dbtypep = 0;
	ristree		*dbnamep = 0;
	ristree		*ris_dict_dbnamep = 0;
	ristree		*dirp = 0;
	ristree		*remotep = 0;
	ristree		*gatewayp = 0;
	ristree		*majorp = 0;
	risdb		*dp;
	risschema	*sp;

TRN_DBG(("RIStrn_create_schema(createp:0x%x)\n",createp));

/* set up pointers */

	if (createp->lhs)
	{
		securep = createp->lhs;
	}
	for (tp = createp->rhs; tp; tp = tp->rhs)
	{
		switch (tp->lhs->tok)
		{
			case RIS_TOK_AUTH_ID:
				authidp = tp->lhs;
				len = strlen (authidp->info.val);
				if(len > RIS_max_id_size)
				{
					TRN_ERR_RETURN(RIS_E_NAME_TOO_LONG,authidp->pos);
				}
			break;

			case RIS_TOK_DATABASE:
				dbspecp = tp->lhs;
				createp->rhs = createp->rhs->rhs;
			break;

			case RIS_TOK_USER:
				userp = tp->lhs;
			break;

			case RIS_TOK_FORCE:
				forcep = tp->lhs;
			break;

			case RIS_TOK_INCLUDE:
			case RIS_TOK_EXCLUDE:
				inc_excp = tp->lhs;
			break;

			case RIS_TOK_USING_DICT_OWNER:
				usingp = tp->lhs;
			break;

			case RIS_TOK_MAJOR:
				majorp = tp->lhs;
			break;

			default:
				LONGJMP(RIS_E_INTERNAL_ERROR);
			break;
		}
	}	
	
	if (dbspecp)
	{
		for (tp=dbspecp->rhs;tp;tp=tp->rhs)
		{
			switch(tp->lhs->tok)
			{
				case RIS_TOK_INFORMIX:
				case RIS_TOK_INGRES:
				case RIS_TOK_ORACLE:
				case RIS_TOK_SQLDS:
				case RIS_TOK_DB2:
				case RIS_TOK_RDB:
				case RIS_TOK_SYBASE:
				case RIS_TOK_MSSQL:
				case RIS_TOK_OS400:
					if (!dbtypep)
					{
						dbtypep = tp->lhs;
					}
					else
					{
						TRN_ERR_RETURN(RIS_E_MULT_DBTYPE_DEF,tp->lhs->pos);
					}
				break;
				case RIS_TOK_DBNAME:
					if (!dbnamep)
					{
						dbnamep = tp->lhs;
					}
					else
					{
						TRN_ERR_RETURN(RIS_E_MULT_DBNAME_DEF,tp->lhs->pos);
					}
				break;
				case RIS_TOK_RIS_DICT_DBNAME:
					if (!ris_dict_dbnamep)
					{
						ris_dict_dbnamep = tp->lhs;
					}
					else
					{
						TRN_ERR_RETURN(RIS_E_MULT_DBNAME_DEF,tp->lhs->pos);
					}
				break;
				case RIS_TOK_DIR:
					if (!dirp)
					{
						dirp = tp->lhs;
					}
					else
					{
						TRN_ERR_RETURN(RIS_E_MULT_DIR_DEF,tp->lhs->pos);
					}
				break;
				case RIS_TOK_OSTYPE:
					if (!ostypep)
					{
						ostypep = tp->lhs;
					}
					else
					{
						TRN_ERR_RETURN(RIS_E_MULT_OSTYPE_DEF,tp->lhs->pos);
					}
				break;
				case RIS_TOK_OSUSER:
					if (!osuserp)
					{
						osuserp = tp->lhs;
					}
					else
					{
						TRN_ERR_RETURN(RIS_E_MULT_OSUSER_DEF,tp->lhs->pos);
					}
				break;
				case RIS_TOK_OPTION:
					if (!optionp)
					{
						optionp = tp->lhs;
					}
					else
					{
						TRN_ERR_RETURN(RIS_E_MULT_OPTION_DEF,tp->lhs->pos);
					}
				break;
				case RIS_TOK_REMOTE:
					if (!remotep)
					{
						remotep = tp->lhs;
					}
					else
					{
						TRN_ERR_RETURN(RIS_E_MULT_REMOTE_DEF,tp->lhs->pos);
					}
				break;
				case RIS_TOK_GATEWAY:
					if (!gatewayp)
					{
						gatewayp = tp->lhs;
					}
					else
					{
						TRN_ERR_RETURN(RIS_E_MULT_GATEWAY_DEF,tp->lhs->pos);
					}
				break;
				default:
					TRN_DBG(("RIStrn_create_schema:ERROR:invalid token:%d\n",
						tp->lhs->tok));
					TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,tp->lhs->pos);
				break;
			}
		}

/* allocate and fill in db struct */

/*
**	valid parms
**
**	INFORMIX:	dbname,[dir],[options]
**	INGRES:		dbname,[dir]
**	ORACLE:		dbname,dir,osuser
**	DB2:		dbname,osuser,gateway
**	OS400:		ris_dict_dbname,dbname,osuser,gateway
**	RDB:		dbname
**	SQLDS:		Undefined
**	SYBASE:		dbname,osuser, [dir],[options]
**	MSSQL:		dbname,osuser, [dir],[options]
*/


		dp = ALLOCT(risdb);
		if (!dbtypep)
		{
			TRN_ERR_RETURN(RIS_E_MISSING_DBTYPE_DEF,dbspecp->pos);
		}

		if (dbnamep)
		{
			if ((len = strlen(dbnamep->info.val)+1) > RIS_MAX_PATH_SIZE)
			{
				TRN_ERR_RETURN(RIS_E_DBNAME_TOO_LONG,dbnamep->pos);
			}
			memcpy(dp->dbname , dbnamep->info.val,len );
			if  (dbtypep->tok == RIS_TOK_SYBASE ||
					dbtypep->tok == RIS_TOK_MSSQL)
           	{

				if( !strncmp(dp->dbname, "master", len) || /*itbokic */
                    !strncmp(dp->dbname, "tempdb", len) || /*itbokic */
                    !strncmp(dp->dbname, "model", len)  || /*itbokic */
                    !strncmp(dp->dbname, "sybsecurity", len)  || /*itbokic */
                    !strncmp(dp->dbname, "sybsyntax", len)  || /*itbokic */
                    !strncmp(dp->dbname, "sybsystemprocs", len) /*itbokic */
                    )
                TRN_ERR_RETURN(RIS_E_INV_DATABASE, dbnamep->pos);
            }

		} 
		else
		{
			TRN_ERR_RETURN(RIS_E_MISSING_DBNAME_DEF,dbtypep->pos);
		}

		if (ris_dict_dbnamep)
		{
			if(dbtypep->tok != RIS_TOK_OS400)
			{
				TRN_ERR_RETURN(RIS_E_OS400_ONLY,ris_dict_dbnamep->pos);
			}	
			if ((len = strlen(ris_dict_dbnamep->info.val)+1) > 
					RIS_MAX_OS400_DIC_DBNAME_SIZE)
			{
				TRN_ERR_RETURN(RIS_E_DICT_DBNAME_TOO_LONG,dbnamep->pos);
			}
			memcpy(dp->parms.os400.ris_dict_dbname , ris_dict_dbnamep->info.val,len );
		}

		if (ostypep)
		{
			/* No need to check for ostype. Assumed that parser checks it */

			RIScom_uppercase(1, (unsigned char *)ostypep->info.val);
			dp->ostype = ostypep->info.val[0];
		}
		else
		{
			TRN_ERR_RETURN(RIS_E_MISSING_OSTYPE_DEF,dbtypep->pos);
		}

		switch(dbtypep->tok)
		{
			case RIS_TOK_INFORMIX:
				dp->dtype = 'X';

				if (dirp)
				{
					if ((len = strlen(dirp->info.val)+1) > RIS_MAX_PATH_SIZE)
					{
						TRN_ERR_RETURN(RIS_E_DIR_TOO_LONG,dirp->pos);
					}
					memcpy(dp->parms.ifx.dir, dirp->info.val,len );
				}
				/*
				** Made the dir option mandatory.
				** Sunil 1/7/92
				*/
				else
				{
					TRN_ERR_RETURN(RIS_E_MISSING_DIR_DEF,dbtypep->pos);
				}

				if (optionp)
				{
					RIStrn_parse_ifx_option(optionp, &dp->parms.ifx);
				}

				if (gatewayp)
				{
					TRN_ERR_RETURN(RIS_E_INV_INFORMIX_SPEC,gatewayp->pos);
				}
			break;

			case RIS_TOK_INGRES:
				dp->dtype = 'I';

				if (dirp)
				{
					if ((len = strlen(dirp->info.val)+1) > RIS_MAX_PATH_SIZE)
					{
						TRN_ERR_RETURN(RIS_E_DIR_TOO_LONG,dirp->pos);
					}
					memcpy(dp->parms.igs.dir, dirp->info.val,len );
				}
				/*
				** Made the dir option mandatory.
				** Sunil 1/7/92
				*/
				else
				{
					TRN_ERR_RETURN(RIS_E_MISSING_DIR_DEF,dbtypep->pos);
				}

				if (optionp)
				{
					TRN_ERR_RETURN(RIS_E_INV_INGRES_SPEC, optionp->pos);
				}

				if (gatewayp)
				{
					TRN_ERR_RETURN(RIS_E_INV_INGRES_SPEC,gatewayp->pos);
				}
			break;

			case RIS_TOK_ORACLE:
				dp->dtype = 'O';

				if (dirp)
				{
					if ((len = strlen(dirp->info.val)+1) > RIS_MAX_PATH_SIZE)
					{
						TRN_ERR_RETURN(RIS_E_DIR_TOO_LONG,dirp->pos);
					}
					memcpy(dp->parms.ora.dir, dirp->info.val,len );
				}
				else
				{
					TRN_ERR_RETURN(RIS_E_MISSING_DIR_DEF,dbtypep->pos);
				}

				if (osuserp)
				{
					if ((len = strlen(osuserp->info.val)+1) > RIS_MAX_ID_SIZE)
					{
						TRN_ERR_RETURN(RIS_E_OSUSER_TOO_LONG, osuserp->pos);
					}
					memcpy(dp->parms.ora.osuser, osuserp->info.val,len );
					if (osuserp->rhs)
					{
						RIScom_pd(osuserp->rhs->info.val,dp->parms.ora.ospass);
					}
				}

				if (optionp)
				{
					TRN_ERR_RETURN(RIS_E_INV_ORACLE_SPEC, optionp->pos);
				}

				if (gatewayp)
				{
					TRN_ERR_RETURN(RIS_E_INV_ORACLE_SPEC,gatewayp->pos);
				}
			break;

			case RIS_TOK_DB2:
				dp->dtype = 'D';

				if (dirp)
				{
					TRN_ERR_RETURN(RIS_E_INV_DB2_SPEC,dirp->pos);
				}

				if (optionp)
				{
					TRN_ERR_RETURN(RIS_E_INV_DB2_SPEC, optionp->pos);
				}

				if (osuserp)
				{
					if ((len = strlen(osuserp->info.val)+1) > RIS_MAX_ID_SIZE)
					{
						TRN_ERR_RETURN(RIS_E_OSUSER_TOO_LONG, osuserp->pos);
					}
					memcpy(dp->parms.db2.osuser, osuserp->info.val,len );
					if (osuserp->rhs)
					{
						RIScom_pd(osuserp->rhs->info.val,dp->parms.db2.ospass);
					}
				}

				if (gatewayp)
				{
					RIStrn_parse_db2_gateway(gatewayp, &dp->parms.db2);
				}
				else
				{
					TRN_ERR_RETURN(RIS_E_MISSING_GATEWAY_DEF,dbtypep->pos);
				}
			break;

			case RIS_TOK_OS400:
				dp->dtype = '4';

				if (dirp)
				{
					TRN_ERR_RETURN(RIS_E_INV_OS400_SPEC,dirp->pos);
				}

				if (optionp)
				{
					TRN_ERR_RETURN(RIS_E_INV_OS400_SPEC, optionp->pos);
				}

				if (osuserp)
				{
					if ((len = strlen(osuserp->info.val)+1) > RIS_MAX_ID_SIZE)
					{
						TRN_ERR_RETURN(RIS_E_OSUSER_TOO_LONG, osuserp->pos);
					}
					memcpy(dp->parms.os400.osuser, osuserp->info.val,len );
					if (osuserp->rhs)
					{
						RIScom_pd(osuserp->rhs->info.val,dp->parms.os400.ospass);
					}
				}

				if (gatewayp)
				{
					RIStrn_parse_os400_gateway(gatewayp, &dp->parms.os400);
				}
				else
				{
					TRN_ERR_RETURN(RIS_E_MISSING_GATEWAY_DEF,dbtypep->pos);
				}

				if (!ris_dict_dbnamep)
				{
					TRN_ERR_RETURN(RIS_E_DICT_DBNAME_REQUIRED, optionp->pos);
				}

			break;

            case RIS_TOK_RDB:
                dp->dtype = 'R';

                if (dirp)
                {
                    TRN_ERR_RETURN(RIS_E_INV_RDB_SPEC,dirp->pos);
                }

                if (optionp)
                {
                    TRN_ERR_RETURN(RIS_E_INV_RDB_SPEC,optionp->pos);
                }

                if (gatewayp)
                {
                    TRN_ERR_RETURN(RIS_E_INV_RDB_SPEC,gatewayp->pos);
                }
                break;

			case RIS_TOK_SQLDS:
				dp->dtype = 'S';

				if (dirp)
				{
					TRN_ERR_RETURN(RIS_E_INV_SQLDS_SPEC,dirp->pos);
				}
				if (optionp)
				{
					TRN_ERR_RETURN(RIS_E_INV_SQLDS_SPEC,optionp->pos);
				}
				if (gatewayp)
				{
					TRN_ERR_RETURN(RIS_E_INV_SQLDS_SPEC,gatewayp->pos);
				}
			break;

			case RIS_TOK_SYBASE:
				dp->dtype = 'Y';
				if (dirp)
				{
					if ((len = strlen(dirp->info.val)+1) > 
						RIS_MAX_PATH_SIZE)
					{
						TRN_ERR_RETURN(RIS_E_DIR_TOO_LONG,dirp->pos);
					}
					memcpy(dp->parms.syb.dir, dirp->info.val,len );
				}
				/*
				** Made the dir optional.
				** Sunil 1/7/92
				*/
				else
				{
						TRN_ERR_RETURN(RIS_E_MISSING_DIR_DEF,dbtypep->pos);
				}

				if (osuserp) 
				{
				    if ((len = strlen(osuserp->info.val)+1) > RIS_MAX_ID_SIZE)
				    {
					TRN_ERR_RETURN(RIS_E_OSUSER_TOO_LONG, osuserp->pos);
				    }
				    memcpy(dp->parms.syb.osuser, osuserp->info.val,len );
				    if (osuserp->rhs)
				    {
					RIScom_pd(osuserp->rhs->info.val,dp->parms.syb.ospass);
				    }
				}
				if (optionp)
				{
					RIStrn_parse_syb_option(optionp, &dp->parms.syb);
				}
				if (gatewayp)
				{
					TRN_ERR_RETURN(RIS_E_INV_SYBASE_SPEC,gatewayp->pos);
				}
			break;
			case RIS_TOK_MSSQL:
				dp->dtype = 'M';
				if (dirp)
				{
				    if (dp->ostype != 'N')
                    {
					if ((len = strlen(dirp->info.val)+1) > 
						RIS_MAX_PATH_SIZE)
					{
						TRN_ERR_RETURN(RIS_E_DIR_TOO_LONG,dirp->pos);
					}
					memcpy(dp->parms.mssql.dir, dirp->info.val,len );
				    }
				}
				/*
				** Made the dir optional.
				** Sunil 1/7/92
				*/
				else
				{
					if (dp->ostype != 'N')
					{
						TRN_ERR_RETURN(RIS_E_MISSING_DIR_DEF,dbtypep->pos);
					}
				}
				if (osuserp)
				{
					if ((len = strlen(osuserp->info.val)+1) > RIS_MAX_ID_SIZE)
					{
						TRN_ERR_RETURN(RIS_E_OSUSER_TOO_LONG, osuserp->pos);
					}
					memcpy(dp->parms.mssql.osuser, osuserp->info.val,len );
					if (osuserp->rhs)
					{
						RIScom_pd(osuserp->rhs->info.val,dp->parms.mssql.ospass);
					}
				}

				if (optionp)
				{
					RIStrn_parse_mssql_option(optionp, &dp->parms.mssql);
				}
				if (gatewayp)
				{
					TRN_ERR_RETURN(RIS_E_INV_MSSQL_SPEC,gatewayp->pos);
				}
			break;
			default:
				TRN_DBG(("RIStrn_create_schema:ERROR:Invalid dbtype token:%d\n",
					dbtypep->tok));
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR,dbtypep->pos);
			break;
		}
		if (remotep)
		{
			RIStrn_setup_remote_pathways(remotep,dp);
		}
		else
		{
			if (RIS_local_xns_addr[0])
			{
				dp->pathways[0].protocol = 'X';
				strcpy(dp->pathways[0].netaddr, RIS_local_xns_addr);
			}
			else if (RIS_local_tcp_addr[0])
			{
				dp->pathways[0].protocol = 'T';
				strcpy(dp->pathways[0].netaddr, RIS_local_tcp_addr);
			}
			else if (RIS_local_dnp_addr[0])
			{
				dp->pathways[0].protocol = 'D';
				strcpy(dp->pathways[0].netaddr, RIS_local_dnp_addr);
			}
			else
			{
				TRN_DBG(("RIStrn_create_schema:ERROR:no local address\n"));
				TRN_ERR_RETURN(RIS_E_NO_LOCAL_ADDR,0);
			}
		}
	}
	else
	{
		if (!RIS_default) TRN_ERR_RETURN(RIS_E_NO_DATABASE,0);
		dp = RIS_default->db;
	}

/* allocate and fill in schema struct */

	sp = ALLOCT(risschema);
	if (securep)
	{
		sp->secure = 'S';
	}
	strcpy(sp->schname,authidp->info.val);
	if (authidp->rhs)
	{
		RIScom_pd(authidp->rhs->info.val,sp->schpass);
	}
	if (userp)
	{
		if (dp->dtype == 'D' || dp->dtype == '4' ||
			dp->dtype == 'O' || dp->dtype == 'R')
		{
			RIScom_uppercase(strlen(userp->info.val),
				(unsigned char *)userp->info.val);
		}
		strcpy(sp->schowner,userp->info.val);
		if (userp->rhs)
		{
			/*
			** If we are creating a schema on a DB2 database, convert the 
			** password to upper case (since in some cases, IBM converts 
			** user passwords to upper case and our risschema file needs 
			** to be consistent with that.
			*/
			if (dp->dtype == 'D' || dp->dtype == '4' ||
				dp->dtype == 'O' || dp->dtype == 'R')
			{
				RIScom_uppercase(strlen(userp->rhs->info.val),
					(unsigned char *)userp->rhs->info.val);
			}
			RIScom_pd(userp->rhs->info.val,sp->passwd);
		}
	}	
	if (usingp)
	{
		if (dp->dtype == 'D' || dp->dtype == '4' ||
			dp->dtype == 'O' || dp->dtype == 'R')
		{
			RIScom_uppercase(strlen(usingp->info.val),
				(unsigned char *)usingp->info.val);
		}
		strcpy(sp->dictowner, usingp->info.val);
	}
	sp->db = dp;

	/*
	** By default, the major and feature numbers are assumed to be XX
	*/
	sp->major = -1;
	sp->feature = -1;
	if (majorp)
	{
		if (strlen(majorp->info.val) > 0 )
		{
			if ((sp->major =
					RIScco_ver_str_to_number(majorp->info.val)) == -2)
			{
				LONGJMP(RIS_E_INVALID_MAJOR_SPEC);
			}

			if (strlen(majorp->rhs->info.val) > 0 )
			{
				if ((sp->feature =
						RIScco_ver_str_to_number(majorp->rhs->info.val)) == -2)
				{
					LONGJMP(RIS_E_INVALID_FEATURE_SPEC);
				}
				if (sp->major == -1 && sp->feature >=0)
				{
					LONGJMP(RIS_E_UNEXPECTED_FEATURE_SPEC);
				}
			}
		}
		else
		{
			LONGJMP(RIS_E_INTERNAL_ERROR);
		}
		if (sp->major != -1 && sp->major < RIS_version_maj)
		{
			LONGJMP(RIS_E_CLISRV_INCOMPATIBLE);
		}
		TRN_DBG(("major: <%d> feature: <%d>\n", sp->major, sp->feature));
	}

/* hang the risschema struct off of RIS_TOK_CREATE_SCHEMA */

	createp->tok = RIS_TOK_CREATE_SCHEMA;
	createp->info.schema = sp;
	
	/*
	createp->rhs->tok = RIS_TOK_ALL if both "force" and "exclude" required;
	createp->rhs->tok = RIS_TOK_FORCE if only "force" required;
	createp->rhs->tok = RIS_TOK_EXCLUDE if only "exclude" required;
	createp->rhs = NULL if neither "force" nor "exclude" required;
	
	added by Jin 11/29/93 for include/exclude clause
	*/
						
	if (forcep && inc_excp)
	{
		if (inc_excp->tok == RIS_TOK_EXCLUDE)
		{
			forcep->tok = RIS_TOK_ALL;
		}
		createp->rhs = forcep;
	}
	else if (inc_excp)
	{
		if (inc_excp->tok == RIS_TOK_EXCLUDE)
		{
			createp->rhs = inc_excp;
		}
		else
		{
			createp->rhs = NULL;
		}
	}
	else
	{
		createp->rhs = forcep;
	}
	
	if (createp->rhs != NULL)
	{
		TRN_DBG(("RIStrn_create_schema: createp->rhs->tok: <%d>\n",
			createp->rhs->tok));
	}
	else
	{
		TRN_DBG(("RIStrn_create_schema: createp->rhs->tok: NULL\n"));
	}

	TRN_DBG(("RIStrn_create_schema:complete\n"));
}

/******************************************************************************/

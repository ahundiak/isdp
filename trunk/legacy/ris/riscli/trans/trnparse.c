/* Do not alter this SPC information: $Revision: 1.2.33.1 $ */
/*
**	NAME:							trnparse.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					11/91
**	ABSTRACT:
**		This file contains the routines to parse various db strings
**		statements.
**	
**	REVISION HISTORY:
**              Added RIS_TOK_RIS_DICT_DBNAME to RIStrn_parse_os400_gateway()
**              by Linda wang 03/31/94.
**		10/24/94 -Radha
**			Added changes for MSSQL data server.
**
**		11/94:	Added support for INTERNATIONALIZATION. Dianne
*/
 
#define ACCEPT_VERSION_2_SCHEMA_FILES

/*
**	INCLUDES
*/
#include <ctype.h>
#include "riscli.h"
#include "trans.h"
#include "schfile.h"
#include "commacro.h"

#if defined (WIN32)
#include <wchar.h>
#endif

/*
**	FUNCTION PROTOTYPES
*/
#define trnparse_c
#include "trnparse.prt"
#include "comdebug.prt"
#include "ccodb2.prt"
#include "ccoos400.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "comstcmi.prt"
#include "comstrcp.prt"
#include "comuni.prt"
#include "sys.prt"


/*
**	DEFINES
*/
#define ARCH_DEF				"s370"
#define OS_DEF					"mvs"
#define ENV_DEF_TCP				"native"
#define ENV_DEF_LU				"cics"

#define CHECK_INV_GATEWAY_OPTION(parameter)                             \
	if (!strcmp(protocolp->info.val, parameter))                        \
	{                                                                   \
		TRN_ERR_RETURN(RIS_E_INV_GATEWAY_OPTION, gatewayp->pos);       \
	}                                                                   \

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIStrn_parse_ifx_option(
	ristree		*optionp,
	risifxparms	*ifxp)
{
	char		*src;
	char		*dst;
	char		*tok;

	TRN_DBG(("RIStrn_parse_ifx_option(optionp:0x%x ifxp:0x%x)\n",
		optionp, ifxp));

	/*
	**	Remove white space from parms & copy into temp
	*/
	for (src = optionp->info.val, dst = optionp->info.val; *src; src++)
	{
		if (!RIScom_isspace(*src)) *dst++ = *src;
	}
	*dst = '\0';

	TRN_DBG(("RIStrn_parse_ifx_option: option str:<%s>\n", optionp->info.val));

	/*
	**	Get first token
	*/
	tok = strtok(optionp->info.val, ","); /*itbokic */
	while (tok)
	{
		if (!RIScom_strncmp_ic(tok, SQLEXEC, SQLEXEC_SIZE))
		{
			tok += SQLEXEC_SIZE;
			strcpy(ifxp->sqlexec, tok);
		}
		else if (!RIScom_strncmp_ic(tok, DBTEMP, DBTEMP_SIZE))
		{
			tok += DBTEMP_SIZE;
			strcpy(ifxp->dbtemp, tok);
		}
		else if (!RIScom_strncmp_ic(tok, TBCONFIG, TBCONFIG_SIZE))
		{
			tok += TBCONFIG_SIZE;
			strcpy(ifxp->tbconfig, tok);
		}
		else if (!RIScom_strncmp_ic(tok, NEWDATABASE, NEWDATABASE_SIZE))
		{
			ifxp->new_database = 1;
		}
		else if (!RIScom_strncmp_ic(tok, NEWUSER, NEWUSER_SIZE))
		{
			ifxp->new_user = 1;
		}
		else if (!RIScom_strncmp_ic(tok, NEWRESOURCEUSER, NEWRESOURCEUSER_SIZE))
		{
			ifxp->new_resource_user = 1;
		}
		else if (!RIScom_strncmp_ic(tok, NEWDBAUSER, NEWDBAUSER_SIZE))
		{
			ifxp->new_dba_user = 1;
		}
		else
		{
			TRN_ERR_RETURN(RIS_E_INV_IFX_OPTION, optionp->pos);
		}

		tok = strtok(NULL, ","); /*itbokic */
	}

	if (RIStrn_debug)
	{
		RIScom_output_debug("RIStrn_parse_ifx_option:\n");
		RIScom_output_debug("\tdir:<%s>\n", ifxp->dir);
		RIScom_output_debug("\tsqlexec:<%s>\n", ifxp->sqlexec);
		RIScom_output_debug("\tdbtemp:<%s>\n", ifxp->dbtemp);
		RIScom_output_debug("\ttbconfig:<%s>\n", ifxp->tbconfig);
		RIScom_output_debug("\tnew_database:%d\n",	ifxp->new_database);
		RIScom_output_debug("\tnew_user:%d\n",	ifxp->new_user);
		RIScom_output_debug("\tnew_resource_user:%d\n", ifxp->new_resource_user);
		RIScom_output_debug("\tnew_dba_user:%d\n",	ifxp->new_dba_user);
		RIScom_output_debug("RIStrn_parse_ifx_option: complete\n");
	}
}

/******************************************************************************/

extern void RIStrn_parse_syb_option(
	ristree		*optionp,
	rissybparms	*sybp)
{
#if defined(WIN32)
	wchar_t		*src;
	wchar_t		*dst;
	wchar_t		*tok;
#else
	char		*src;
	char		*dst;
	char		*tok;
#endif

	TRN_DBG(("RIStrn_parse_syb_option(optionp:0x%x sybp:0x%x)\n",
		optionp, sybp));

	/*
	**	Remove white space from parms & copy into temp
	*/

#if defined(WIN32)
	RIScom_multiwide(&RISwide_ptr,&optionp->info.val,&RISwide_size,MULTITOWIDE,0);

	for (src = RISwide_ptr, dst = RISwide_ptr; *src; src++)
#else
	for (src = optionp->info.val, dst = optionp->info.val; *src; src++)
#endif
	{
		if (!ISSPACE(*src)) *dst++ = *src;
	}
	*dst = WIDECHAR('\0');

	TRN_DBG(("RIStrn_parse_syb_option: option str:<%s>\n", optionp->info.val));

	/*
	**	Get first token
	*/
#if defined(WIN32)

	tok = RIScom_wcstok(RISwide_ptr, L",");
#else
	tok = strtok(optionp->info.val, ","); /*itbokic */
#endif

	while (tok)
	{
#if defined(WIN32)
		RIScom_multiwide(&tok,&RISmulti_ptr,&RISmulti_size,WIDETOMULTI,0);
		if (!RIScom_strncmp_ic(RISmulti_ptr, DSQUERY, DSQUERY_SIZE))
		{
			RISmulti_ptr += DSQUERY_SIZE;
			strcpy(sybp->dsquery, RISmulti_ptr);
		}
		else if (!RIScom_strncmp_ic(RISmulti_ptr, FILENAME, FILENAME_SIZE))
		{
			RISmulti_ptr += FILENAME_SIZE;
			strcpy(sybp->sybifile, RISmulti_ptr);
		}
		else
		{
			TRN_ERR_RETURN(RIS_E_INV_SYB_OPTION, optionp->pos);
		}

		tok = RIScom_wcstok(WIDECHAR('\0'), L",");
#else
		if (!RIScom_strncmp_ic(tok, DSQUERY, DSQUERY_SIZE))
		{
			tok += DSQUERY_SIZE;
			strcpy(sybp->dsquery, tok);
		}
		else if (!RIScom_strncmp_ic(tok, FILENAME, FILENAME_SIZE))
		{
			tok += FILENAME_SIZE;
			strcpy(sybp->sybifile, tok);
		}
		else
		{
			TRN_ERR_RETURN(RIS_E_INV_SYB_OPTION, optionp->pos);
		}

		tok = strtok(NULL, ","); /*itbokic */
#endif
	}

	if (RIStrn_debug)
	{
		RIScom_output_debug("RIStrn_parse_syb_option:\n");
		RIScom_output_debug("\tdir:<%s>\n", sybp->dir);
		RIScom_output_debug("\tdsquery:<%s>\n", sybp->dsquery);
		RIScom_output_debug("\tfilename:<%s>\n", sybp->sybifile);
		RIScom_output_debug("RIStrn_parse_syb_option: complete\n");
	}
}

/******************************************************************************/

extern void RIStrn_parse_mssql_option(
	ristree		*optionp,
	rismssqlparms	*mssqlp)
{
	char		*src;
	char		*dst;
	char		*tok;

	TRN_DBG(("RIStrn_parse_mssql_option(optionp:0x%x mssqlp:0x%x)\n",
		optionp, mssqlp));

	/*
	**	Remove white space from parms & copy into temp
	*/
	for (src = optionp->info.val, dst = optionp->info.val; *src; src++)
	{
		if (!RIScom_isspace(*src)) *dst++ = *src;
	}
	*dst = '\0';

	TRN_DBG(("RIStrn_parse_mssql_option: option str:<%s>\n", optionp->info.val));

	/*
	**	Get first token
	*/
	tok = strtok(optionp->info.val, ","); /*itbokic */
	while (tok)
	{
		if (!RIScom_strncmp_ic(tok, DSQUERY, DSQUERY_SIZE))
		{
			tok += DSQUERY_SIZE;
			strcpy(mssqlp->dsquery, tok);
		}
		else if (!RIScom_strncmp_ic(tok, FILENAME, FILENAME_SIZE))
		{
			tok += FILENAME_SIZE;
			strcpy(mssqlp->mssqlifile, tok);
		}
		else
		{
			TRN_ERR_RETURN(RIS_E_INV_MSSQL_OPTION, optionp->pos);
		}

		tok = strtok(NULL, ","); /*itbokic */
	}

	if (RIStrn_debug)
	{
		RIScom_output_debug("RIStrn_parse_mssql_option:\n");
		RIScom_output_debug("\tdir:<%s>\n", mssqlp->dir);
		RIScom_output_debug("\tdsquery:<%s>\n", mssqlp->dsquery);
		RIScom_output_debug("\tfilename:<%s>\n", mssqlp->mssqlifile);
		RIScom_output_debug("RIStrn_parse_mssql_option: complete\n");
	}
}

/******************************************************************************/

extern void RIStrn_parse_db2_gateway(
	ristree		*gatewayp,
	risdb2parms	*db2p)
{
	ristree	*tp;
	ristree *temp_tp;
	ristree	*archp = 0;
	ristree	*osp = 0;
	ristree	*envp = 0;
	ristree	*protocolp = 0;
	ristree	*host_programp = 0;
	ristree	*ris_lup = 0;
	ristree	*host_lup = 0;
	ristree	*modep = 0;
	ristree	*groupp = 0;
	ristree *nodep = 0;
	ristree *portp = 0;

	char *ptr;

	TRN_DBG(("RIStrn_parse_db2_gateway(gatewayp:0x%x db2p:0x%x)\n",
		gatewayp, db2p));

	for (tp = gatewayp->rhs; tp; tp = tp->rhs)
	{
		switch(tp->lhs->tok)
		{
			case RIS_TOK_ARCH:
				if (archp)
				{
					TRN_ERR_RETURN(RIS_E_MULT_ARCH_DEF, tp->lhs->pos);
				}

				archp = tp->lhs;
				if (!RIScco_valid_db2_arch(archp->info.val))
				{
					TRN_ERR_RETURN(RIS_E_INV_ARCH_DEF, archp->pos);
				}
				break;

			case RIS_TOK_OS:
				if (osp)
				{
					TRN_ERR_RETURN(RIS_E_MULT_OS_DEF, tp->lhs->pos);
				}

				osp = tp->lhs;
				if (!RIScco_valid_db2_os(osp->info.val))
				{
					TRN_ERR_RETURN(RIS_E_INV_OS_DEF, osp->pos);
				}
				break;

			case RIS_TOK_NET_PROTOCOL:
				if (protocolp)
				{
					TRN_ERR_RETURN(RIS_E_MULT_NET_PROTOCOL_DEF, tp->lhs->pos);
				}

				protocolp = tp->lhs;
				if (!RIScco_valid_db2_net_protocol(protocolp->info.val))
				{
					TRN_ERR_RETURN(RIS_E_INV_NET_PROTOCOL_DEF, protocolp->pos);
				}
				break;

			case RIS_TOK_ENV:
				if (envp)
				{
					TRN_ERR_RETURN(RIS_E_MULT_ENV_DEF, tp->lhs->pos);
				}

				envp = tp->lhs;
				if (protocolp)
				{
					if (!RIScco_valid_db2_env(envp->info.val, protocolp->info.val))
					{
						TRN_ERR_RETURN(RIS_E_INV_ENV_DEF, envp->pos);
					}
				}
				else
				{
					/*
					** Search the rest of the tree if net_protocol is
					** defined. If it is defined, check if the env is valid
					** for the defined protocol. If it is not defined,
					** return error.
					*/
					for(temp_tp=tp->rhs; temp_tp; temp_tp=temp_tp->rhs)
					{
						if (temp_tp->lhs->tok == RIS_TOK_NET_PROTOCOL)
						{
							if (!RIScco_valid_db2_env(envp->info.val,
								temp_tp->lhs->info.val))
							{
								TRN_ERR_RETURN(RIS_E_INV_ENV_DEF, envp->pos);
							}
							break;
						}
					}
					if (!temp_tp)
					{
						LONGJMP(RIS_E_MISSING_PROTOCOL_DEF);
					}
				}
				break;

			case RIS_TOK_HOST_PROGRAM:
				if (host_programp)
				{
					TRN_ERR_RETURN(RIS_E_MULT_HOST_PROGRAM_DEF, tp->lhs->pos);
				}

				host_programp = tp->lhs;
				if (strlen(host_programp->info.val) >=
					RIS_MAX_HOST_PROGRAM_SIZE)
				{
					sprintf(RIS_ERRMSGC, "The maximum length is %d.",
						RIS_MAX_HOST_PROGRAM_SIZE - 1);
					TRN_ERR_RETURN(RIS_E_HOST_PROGRAM_TOO_LONG,
						host_programp->pos);
				}
				break;

			case RIS_TOK_RIS_LU:
				if (ris_lup)
				{
					TRN_ERR_RETURN(RIS_E_MULT_RIS_LU_DEF, tp->lhs->pos);
				}
			
				ris_lup = tp->lhs;
				if (strlen(ris_lup->info.val) >= RIS_MAX_LU_NAME_SIZE)
				{
					sprintf(RIS_ERRMSGC, "The maximum length is %d.",
						RIS_MAX_LU_NAME_SIZE - 1);
					TRN_ERR_RETURN(RIS_E_RIS_LU_TOO_LONG,ris_lup->pos);
				}
				break;

			case RIS_TOK_HOST_LU:
				if (host_lup)
				{
					TRN_ERR_RETURN(RIS_E_MULT_HOST_LU_DEF, tp->lhs->pos);
				}

				host_lup = tp->lhs;
				if (strlen(host_lup->info.val) >= RIS_MAX_LU_NAME_SIZE)
				{
					sprintf(RIS_ERRMSGC, "The maximum length is %d.",
						RIS_MAX_LU_NAME_SIZE - 1);
					TRN_ERR_RETURN(RIS_E_HOST_LU_TOO_LONG,host_lup->pos);
				}
				break;

			case RIS_TOK_MODE:
				if (modep)
				{
					TRN_ERR_RETURN(RIS_E_MULT_MODE_DEF, tp->lhs->pos);
				}
				modep = tp->lhs;
				if (strlen(modep->info.val) >= RIS_MAX_MODE_NAME_SIZE)
				{
					sprintf(RIS_ERRMSGC, "The maximum length is %d.",
						RIS_MAX_MODE_NAME_SIZE - 1);
					TRN_ERR_RETURN(RIS_E_MODE_TOO_LONG,modep->pos);
				}
				break;

			case RIS_TOK_GROUP:
				if (groupp)
				{
					TRN_ERR_RETURN(RIS_E_MULT_GROUP_DEF, tp->lhs->pos);
				}
				groupp = tp->lhs;
				if (strlen(groupp->info.val) >= RIS_MAX_GROUP_SIZE)
				{
					sprintf(RIS_ERRMSGC, "The maximum length is %d.",
						RIS_MAX_GROUP_SIZE - 1);
					TRN_ERR_RETURN(RIS_E_GROUP_TOO_LONG,groupp->pos);
				}
				break;

			case RIS_TOK_NODE:
				if (nodep)
				{
					TRN_ERR_RETURN(RIS_E_MULT_NODE_DEF, tp->lhs->pos);
				}
				nodep = tp->lhs;
				if (strlen(nodep->info.val) > RIS_MAX_ID_SIZE)
				{
					sprintf(RIS_ERRMSGC, "The maximum length is %d.",
						RIS_MAX_ID_SIZE);
					TRN_ERR_RETURN(RIS_E_NODE_TOO_LONG,nodep->pos);
				}
				break;

			case RIS_TOK_PORT:
				if (portp)
				{
					TRN_ERR_RETURN(RIS_E_MULT_PORT_DEF, tp->lhs->pos);
				}
				portp = tp->lhs;
				ptr = portp->info.val;

				TRN_DBG(("portp->info.val = <%s>\n", portp->info.val));

				while (*ptr && RIScom_isdigit(*ptr))
				{
					TRN_DBG(("ptr = %c\n",ptr));
					ptr++;
				}
				if (*ptr)
				{
					sprintf(RIS_ERRMSGC,"Must be an unsigned number");
					TRN_ERR_RETURN(RIS_E_INV_PORT_NUMBER,portp->pos);
				}
				break;

			default:
				TRN_DBG(("RIStrn_parse_db2_gateway:ERROR:invalid gateway "
					"token:%d\n", tp->lhs->tok));
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR, tp->lhs->pos);
			break;
		}
	}

	if (archp)
	{
		strcpy(db2p->arch , archp->info.val);
	}
	else
	{
		strcpy(db2p->arch, ARCH_DEF);
	}

	if (osp)
	{
		strcpy(db2p->os, osp->info.val);
	}
	else
	{
		strcpy(db2p->os, OS_DEF);
	}

	if (protocolp)
	{
		strcpy(db2p->net_protocol, protocolp->info.val);
	}
	else
	{
		TRN_ERR_RETURN(RIS_E_MISSING_PROTOCOL_DEF, gatewayp->pos);
	}

	if (envp)
	{
		if (!(strcmp(protocolp->info.val, PROTOCOL_DEF_TCP)) &&
			(strcmp(envp->info.val, ENV_DEF_TCP)))
		{
			TRN_ERR_RETURN(RIS_E_INV_ENV_DEF, envp->pos);
		}
		strcpy(db2p->env, envp->info.val);
	}
	else
	{
		if (!strcmp(protocolp->info.val, PROTOCOL_DEF_TCP))
		{
			strcpy(db2p->env, ENV_DEF_TCP);
		}
		else if (!strcmp(protocolp->info.val, PROTOCOL_DEF_LU))
		{
			strcpy(db2p->env, ENV_DEF_LU);
		}
	}

	if (host_programp)
	{
		CHECK_INV_GATEWAY_OPTION(PROTOCOL_DEF_TCP) ;
		strcpy(db2p->host_program, host_programp->info.val);
	}
	else
	{
		if (!strcmp(protocolp->info.val, PROTOCOL_DEF_LU))
		{
			TRN_ERR_RETURN(RIS_E_MISSING_HOST_PROGRAM_DEF, gatewayp->pos);
		}
	}

	if (ris_lup)
	{
		CHECK_INV_GATEWAY_OPTION(PROTOCOL_DEF_TCP) ;
		strcpy(db2p->ris_lu, ris_lup->info.val);
	}
	else
	{
		if (!strcmp(protocolp->info.val, PROTOCOL_DEF_LU))
		{
			TRN_ERR_RETURN(RIS_E_MISSING_RIS_LU_DEF,gatewayp->pos);
		}
	}

	if (host_lup)
	{
		CHECK_INV_GATEWAY_OPTION(PROTOCOL_DEF_TCP) ;
		strcpy(db2p->host_lu, host_lup->info.val);
	}
	else
	{
		if (!strcmp(protocolp->info.val, PROTOCOL_DEF_LU))
		{
			TRN_ERR_RETURN(RIS_E_MISSING_HOST_LU_DEF, gatewayp->pos);
		}
	}

	if (modep)
	{
		CHECK_INV_GATEWAY_OPTION(PROTOCOL_DEF_TCP) ;
		strcpy(db2p->mode, modep->info.val);
	}
	else
	{
		if (!strcmp(protocolp->info.val, PROTOCOL_DEF_LU))
		{
			TRN_ERR_RETURN(RIS_E_MISSING_MODE_DEF,gatewayp->pos);
		}
	}

	if (groupp)
	{
		strcpy(db2p->group, groupp->info.val);
	}

	if (nodep)
	{
		CHECK_INV_GATEWAY_OPTION(PROTOCOL_DEF_LU) ;
		strcpy(db2p->node, nodep->info.val);
	}
	else
	{
		if (!strcmp(protocolp->info.val, PROTOCOL_DEF_TCP))
		{
			TRN_ERR_RETURN(RIS_E_MISSING_NODE_DEF, gatewayp->pos);
		}
    }

	if (portp)
	{
		CHECK_INV_GATEWAY_OPTION(PROTOCOL_DEF_LU) ;
		db2p->port = (unsigned short)atoi(portp->info.val);
	}
	else
	{
		if (!strcmp(protocolp->info.val, PROTOCOL_DEF_TCP))
		{
			TRN_ERR_RETURN(RIS_E_MISSING_PORT_DEF, gatewayp->pos);
		}
	}

	if (RIStrn_debug)
	{
		RIScom_output_debug("RIStrn_parse_db2_gateway:\n");
		RIScom_output_debug("\tarch:<%s>\n", STRING(db2p->arch));
		RIScom_output_debug("\tos:<%s>\n", STRING(db2p->os));
		RIScom_output_debug("\tnet_protocol:<%s>\n", STRING(db2p->net_protocol));
		RIScom_output_debug("\tenv:<%s>\n", STRING(db2p->env));
		RIScom_output_debug("\thost_program:<%s>\n", STRING(db2p->host_program));
		RIScom_output_debug("\tris_lu:<%s>\n", STRING(db2p->ris_lu));
		RIScom_output_debug("\thost_lu:<%s>\n", STRING(db2p->host_lu));
		RIScom_output_debug("\tmode:<%s>\n", STRING(db2p->mode));
		RIScom_output_debug("\tgroup:<%s>\n", STRING(db2p->group));
		RIScom_output_debug("\tnode:<%s>\n", STRING(db2p->node));
		RIScom_output_debug("\tport:<%d>\n", db2p->port);
		RIScom_output_debug("RIStrn_parse_db2_gateway:complete\n");
	}
}

/******************************************************************************/

extern void RIStrn_parse_os400_gateway(
	ristree		*gatewayp,
	risos400parms	*os400p)
{
	ristree	*tp;
	ristree	*protocolp = 0;
	ristree	*host_programp = 0;
	ristree	*ris_lup = 0;
	ristree	*host_lup = 0;
	ristree	*modep = 0;
	ristree	*groupp = 0;
	ristree *nodep = 0;
	ristree *dictp = 0;
	ristree *portp = 0;

	char *ptr;

	TRN_DBG(("RIStrn_parse_os400_gateway(gatewayp:0x%x os400p:0x%x)\n",
		gatewayp, os400p));

	for (tp = gatewayp->rhs; tp; tp = tp->rhs)
	{
		switch(tp->lhs->tok)
		{

			case RIS_TOK_NET_PROTOCOL:
				if (protocolp)
				{
					TRN_ERR_RETURN(RIS_E_MULT_NET_PROTOCOL_DEF, tp->lhs->pos);
				}

				protocolp = tp->lhs;
				if (!RIScco_valid_os400_net_protocol(protocolp->info.val))
				{
					TRN_ERR_RETURN(RIS_E_INV_NET_PROTOCOL_DEF, protocolp->pos);
				}
				break;

			case RIS_TOK_HOST_PROGRAM:
				if (host_programp)
				{
					TRN_ERR_RETURN(RIS_E_MULT_HOST_PROGRAM_DEF, tp->lhs->pos);
				}

				host_programp = tp->lhs;
				if (strlen(host_programp->info.val) >=
					 RIS_MAX_OS400_HOST_PROGRAM_SIZE )
				{
					sprintf(RIS_ERRMSGC, "The maximum length is %d.",
						RIS_MAX_OS400_HOST_PROGRAM_SIZE - 1);
					TRN_ERR_RETURN(RIS_E_HOST_PROGRAM_TOO_LONG,
						host_programp->pos);
				}
				break;

			case RIS_TOK_RIS_LU:
				if (ris_lup)
				{
					TRN_ERR_RETURN(RIS_E_MULT_RIS_LU_DEF, tp->lhs->pos);
				}
			
				ris_lup = tp->lhs;
				if (strlen(ris_lup->info.val) >= RIS_MAX_LU_NAME_SIZE)
				{
					sprintf(RIS_ERRMSGC, "The maximum length is %d.",
						RIS_MAX_LU_NAME_SIZE - 1);
					TRN_ERR_RETURN(RIS_E_RIS_LU_TOO_LONG,ris_lup->pos);
				}
				break;

			case RIS_TOK_HOST_LU:
				if (host_lup)
				{
					TRN_ERR_RETURN(RIS_E_MULT_HOST_LU_DEF, tp->lhs->pos);
				}

				host_lup = tp->lhs;
				if (strlen(host_lup->info.val) >= RIS_MAX_LU_NAME_SIZE)
				{
					sprintf(RIS_ERRMSGC, "The maximum length is %d.",
						RIS_MAX_LU_NAME_SIZE - 1);
					TRN_ERR_RETURN(RIS_E_HOST_LU_TOO_LONG,host_lup->pos);
				}
				break;

			case RIS_TOK_MODE:
				if (modep)
				{
					TRN_ERR_RETURN(RIS_E_MULT_MODE_DEF, tp->lhs->pos);
				}
				modep = tp->lhs;
				if (strlen(modep->info.val) >= RIS_MAX_MODE_NAME_SIZE)
				{
					sprintf(RIS_ERRMSGC, "The maximum length is %d.",
						RIS_MAX_MODE_NAME_SIZE - 1);
					TRN_ERR_RETURN(RIS_E_MODE_TOO_LONG,modep->pos);
				}
				break;

			case RIS_TOK_GROUP:
				if (groupp)
				{
					TRN_ERR_RETURN(RIS_E_MULT_GROUP_DEF, tp->lhs->pos);
				}
				groupp = tp->lhs;
				if (strlen(groupp->info.val) >= RIS_MAX_GROUP_SIZE)
				{
					sprintf(RIS_ERRMSGC, "The maximum length is %d.",
						RIS_MAX_GROUP_SIZE - 1);
					TRN_ERR_RETURN(RIS_E_GROUP_TOO_LONG,groupp->pos);
				}
				break;

			case RIS_TOK_NODE:
				if (nodep)
				{
					TRN_ERR_RETURN(RIS_E_MULT_NODE_DEF, tp->lhs->pos);
				}
				nodep = tp->lhs;
				if (strlen(nodep->info.val) > RIS_MAX_ID_SIZE)
				{
					sprintf(RIS_ERRMSGC, "The maximum length is %d.",
						RIS_MAX_ID_SIZE);
					TRN_ERR_RETURN(RIS_E_NODE_TOO_LONG,nodep->pos);
				}
				break;

			case RIS_TOK_RIS_DICT_DBNAME:
				if (dictp)
				{
					TRN_ERR_RETURN(RIS_E_MULT_RIS_DICT_DBNAME_DEF, tp->lhs->pos);
				}
				dictp = tp->lhs;
				if (strlen(dictp->info.val) > RIS_MAX_ID_SIZE)
				{
					sprintf(RIS_ERRMSGC, "The maximum length is %d.",
						RIS_MAX_ID_SIZE);
					TRN_ERR_RETURN(RIS_E_RIS_DICT_DBNAME_TOO_LONG,dictp->pos);
				}
				break;

			case RIS_TOK_PORT:
				if (portp)
				{
					TRN_ERR_RETURN(RIS_E_MULT_PORT_DEF, tp->lhs->pos);
				}
				portp = tp->lhs;
				ptr = portp->info.val;

				TRN_DBG(("portp->info.val = <%s>\n", portp->info.val));

				while (*ptr && RIScom_isdigit(*ptr))
				{
					TRN_DBG(("ptr = %c\n",ptr));
					ptr++;
				}
				if (*ptr)
				{
					sprintf(RIS_ERRMSGC,"Must be an unsigned number");
					TRN_ERR_RETURN(RIS_E_INV_PORT_NUMBER,portp->pos);
				}
				break;

			default:
				TRN_DBG(("RIStrn_parse_os400_gateway:ERROR:invalid gateway "
					"token:%d\n", tp->lhs->tok));
				TRN_ERR_RETURN(RIS_E_INTERNAL_ERROR, tp->lhs->pos);
			break;
		}
	}


	if (protocolp)
	{
		RIScom_lower_strcpy(os400p->net_protocol, protocolp->info.val);
	}
	else
	{
		TRN_ERR_RETURN(RIS_E_MISSING_PROTOCOL_DEF, gatewayp->pos);
	}


	if (host_programp)
	{
		CHECK_INV_GATEWAY_OPTION(PROTOCOL_DEF_TCP) ;
		strcpy(os400p->host_program, host_programp->info.val);
	}
	else
	{
		if (!strcmp(protocolp->info.val, PROTOCOL_DEF_LU))
		{
			TRN_ERR_RETURN(RIS_E_MISSING_HOST_PROGRAM_DEF, gatewayp->pos);
		}
	}

	if (ris_lup)
	{
		CHECK_INV_GATEWAY_OPTION(PROTOCOL_DEF_TCP) ;
		strcpy(os400p->ris_lu, ris_lup->info.val);
	}
	else
	{
		if (!strcmp(protocolp->info.val, PROTOCOL_DEF_LU))
		{
			TRN_ERR_RETURN(RIS_E_MISSING_RIS_LU_DEF,gatewayp->pos);
		}
	}

	if (host_lup)
	{
		CHECK_INV_GATEWAY_OPTION(PROTOCOL_DEF_TCP) ;
		strcpy(os400p->host_lu, host_lup->info.val);
	}
	else
	{
		if (!strcmp(protocolp->info.val, PROTOCOL_DEF_LU))
		{
			TRN_ERR_RETURN(RIS_E_MISSING_HOST_LU_DEF, gatewayp->pos);
		}
	}

	if (modep)
	{
		CHECK_INV_GATEWAY_OPTION(PROTOCOL_DEF_TCP) ;
		strcpy(os400p->mode, modep->info.val);
	}
	else
	{
		if (!strcmp(protocolp->info.val, PROTOCOL_DEF_LU))
		{
			TRN_ERR_RETURN(RIS_E_MISSING_MODE_DEF,gatewayp->pos);
		}
	}

	if (groupp)
	{
		strcpy(os400p->group, groupp->info.val);
	}

	if (nodep)
	{
		CHECK_INV_GATEWAY_OPTION(PROTOCOL_DEF_LU) ;
		strcpy(os400p->node, nodep->info.val);
	}
	else
	{
		if (!strcmp(protocolp->info.val, PROTOCOL_DEF_TCP))
		{
			TRN_ERR_RETURN(RIS_E_MISSING_NODE_DEF, gatewayp->pos);
		}
    }

	if (portp)
	{
		CHECK_INV_GATEWAY_OPTION(PROTOCOL_DEF_LU) ;
		os400p->port = (unsigned short)atoi(portp->info.val);
	}
	else
	{
		if (!strcmp(protocolp->info.val, PROTOCOL_DEF_TCP))
		{
			TRN_ERR_RETURN(RIS_E_MISSING_PORT_DEF, gatewayp->pos);
		}
	}

	if (RIStrn_debug)
	{
		RIScom_output_debug("RIStrn_parse_os400_gateway:\n");
		RIScom_output_debug("\tnet_protocol:<%s>\n", STRING(os400p->net_protocol));
		RIScom_output_debug("\thost_program:<%s>\n", STRING(os400p->host_program));
		RIScom_output_debug("\tris_lu:<%s>\n", STRING(os400p->ris_lu));
		RIScom_output_debug("\thost_lu:<%s>\n", STRING(os400p->host_lu));
		RIScom_output_debug("\tmode:<%s>\n", STRING(os400p->mode));
		RIScom_output_debug("\tgroup:<%s>\n", STRING(os400p->group));
		RIScom_output_debug("\tnode:<%s>\n", STRING(os400p->node));
		RIScom_output_debug("\tport:<%d>\n", os400p->port);
		RIScom_output_debug("RIStrn_parse_os400_gateway:complete\n");
	}
}

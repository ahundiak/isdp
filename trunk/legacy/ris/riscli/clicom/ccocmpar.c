/*
**	NAME:							ccocmpar.c
**	AUTHORS:						Sunil Murthy
**	CREATION DATE:					2/93
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**		-10/24/94 Radha
**		added changes for MSSQL data server
*/

/*
**	DEFINES
*/

/*
**	INCLUDES
*/
#include "clicom.h"

/*
**      FUNCTION PROTOTYPES
*/
#define ccocmpar_c
#include "comjmp.prt"
#include "ccocmpar.prt"
#include "comdebug.prt"
#include "sys.prt"

/******************************************************************************/

static int compare_protocols_netaddr(
	risdb *db1,
	risdb *db2)
{
	/*
	**	Returns SAME_DATABASE for the same machine
	**	Returns DIFF_DATABASE for different machines
	**	Longjmps on inconsistent addresses
	*/

	int		i,j;
	int		same_machine = 0;
	int		diff_machine = 0;
	int		return_sts;

    CCO_DBG(("compare_protocols_netaddr(db1:0x%x db2:0x%x)\n", db1, db2));

	for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
	{
		if (!db1->pathways[i].protocol) continue;

		for (j = 0; j < RIS_MAX_PROTOCOLS; j++)
		{
			if (db1->pathways[i].protocol == db2->pathways[j].protocol)
			{
                CCO_DBG(("comparing '%c' addrs\ndb1 addr:<%s>\ndb2 addr:<%s>\n",
                    db1->pathways[i].protocol,
                    db1->pathways[i].netaddr,
                    db2->pathways[j].netaddr));
				if (!strcmp(db1->pathways[i].netaddr,db2->pathways[j].netaddr))
				{
                    CCO_DBG(("same machine\n"));
					same_machine = 1;
				}
				else
				{
                    CCO_DBG(("diff machine\n"));
					diff_machine = 1;
				}
				break;
			}
		}
	}

	if (same_machine && diff_machine)
	{
		CCO_DBG(("dbs have inconsistent addresses\n"));
		LONGJMP(RIS_E_INCONSISTENT_ADDRS);
	}

	if (same_machine)
		return_sts = SAME_DATABASE;
	else
		return_sts = DIFF_DATABASE;

	CCO_DBG(("compare_protocols_netaddr: returning %s\n",
		(return_sts == SAME_DATABASE) ? "SAME_DATABASE" : "DIFF_DATABASE"));
	return return_sts;
}

/******************************************************************************/

static int compare_parms(
	risdb *db1,
	risdb *db2)
{
	/*
	**	Returns SAME_DATABASE for the same machine
	**	Returns DIFF_DATABASE for different machines
	**
	**	This function is called only after dbtypes are compared, so I can
	**	refer to either dbtype to determine which parms to compare.
	*/

	int		return_sts = 0;

    CCO_DBG(("compare_parms(db1:0x%x db2:0x%x)\n", db1, db2));
	
	switch(db1->dtype)
	{
		case 'X':
		case 'I':
		case 'R':
		case 'Y':
		case 'M':
			/*
			**	the parameters for these databases do not determine
			**	uniqueness
			*/

			return_sts = SAME_DATABASE;
			break;

		case 'O':
			if (!strcmp(db1->parms.ora.dir, db2->parms.ora.dir))
			{
				return_sts = SAME_DATABASE;
			}
			else
			{
				return_sts = DIFF_DATABASE;
			}
			break;

		case 'D':
		{
			risdb2parms	*p1 = &db1->parms.db2;
			risdb2parms	*p2 = &db1->parms.db2;
			if (!strcmp(p1->net_protocol, PROTOCOL_DEF_LU))
			{
				if (!strcmp(p1->arch, p2->arch) &&
					!strcmp(p1->os, p2->os) &&
					!strcmp(p1->env, p2->env) &&
					!strcmp(p1->net_protocol, p2->net_protocol) &&
					!strcmp(p1->host_program, p2->host_program) &&
					!strcmp(p1->ris_lu, p2->ris_lu) &&
					!strcmp(p1->host_lu, p2->host_lu) &&
					!strcmp(p1->mode, p2->mode))
				{
					return_sts = SAME_DATABASE;
				}
				else
				{
					return_sts = DIFF_DATABASE;
				}
			}
			else if (!strcmp(p1->net_protocol, PROTOCOL_DEF_TCP))
			{
				if (!strcmp(p1->arch, p2->arch) &&
					!strcmp(p1->os, p2->os) &&
					!strcmp(p1->env, p2->env) &&
					!strcmp(p1->net_protocol, p2->net_protocol) &&
					!strcmp(p1->node, p2->node) &&
					!strcmp(p1->group, p2->group) &&
					p1->port == p2->port)
				{
					return_sts = SAME_DATABASE;
				}
				else
				{
					return_sts = DIFF_DATABASE;
				}
			}
		}
		break;

		case '4':
		{
			risos400parms	*p1 = &db1->parms.os400;
			risos400parms	*p2 = &db1->parms.os400;
			if (!strcmp(p1->net_protocol, PROTOCOL_DEF_LU))
			{
				if ( !strcmp(p1->net_protocol, p2->net_protocol) &&
					!strcmp(p1->host_program, p2->host_program) &&
					!strcmp(p1->ris_lu, p2->ris_lu) &&
					!strcmp(p1->host_lu, p2->host_lu) &&
					!strcmp(p1->mode, p2->mode))
				{
					return_sts = SAME_DATABASE;
				}
				else
				{
					return_sts = DIFF_DATABASE;
				}
			}
			else if (!strcmp(p1->net_protocol, PROTOCOL_DEF_TCP))
			{
				if ( !strcmp(p1->net_protocol, p2->net_protocol) &&
					!strcmp(p1->node, p2->node) &&
					!strcmp(p1->group, p2->group) &&
					p1->port == p2->port)
				{
					return_sts = SAME_DATABASE;
				}
				else
				{
					return_sts = DIFF_DATABASE;
				}
			}
		}
		break;
		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	CCO_DBG(("compare_parms: returning %s\n",
		(return_sts == SAME_DATABASE) ? "SAME_DATABASE" : "DIFF_DATABASE"));
	return return_sts;
}
/******************************************************************************/

static int compare_all_parms(
	risdb *db1,
	risdb *db2)
{
	/*
	**	Returns SAME_DATABASE for the same machine
	**	Returns DIFF_DATABASE for different machines
	**
	**	This function is called only after dbtypes are compared, so I can
	**	refer to either dbtype to determine which parms to compare.
	*/

	int		return_sts = 0;

    CCO_DBG(("compare_all_parms(db1:0x%x db2:0x%x)\n", db1, db2));
	
	switch(db1->dtype)
	{
		case 'X':
			if (!strcmp(db1->parms.ifx.dir, db2->parms.ifx.dir) &&
				!strcmp(db1->parms.ifx.sqlexec, db2->parms.ifx.sqlexec) &&
				!strcmp(db1->parms.ifx.dbtemp, db2->parms.ifx.dbtemp) &&
				!strcmp(db1->parms.ifx.tbconfig, db2->parms.ifx.tbconfig))
			{
				return_sts = SAME_DATABASE;
			}
			else
			{
				return_sts = DIFF_DATABASE;
			}
			break;

		case 'I':
			if (!strcmp(db1->parms.igs.dir, db2->parms.igs.dir))
			{
				return_sts = SAME_DATABASE;
			}
			else
			{
				return_sts = DIFF_DATABASE;
			}
			break;

		case 'R':
			return_sts = SAME_DATABASE;
			break;

		case 'Y':
			if (!strcmp(db1->parms.syb.dir, db2->parms.syb.dir) &&
				!strcmp(db1->parms.syb.osuser, db2->parms.syb.osuser) &&
				!strcmp(db1->parms.syb.dsquery, db2->parms.syb.dsquery) &&
				!strcmp(db1->parms.syb.sybifile, db2->parms.syb.sybifile))
			{
				return_sts = SAME_DATABASE;
			}
			else
			{
				return_sts = DIFF_DATABASE;
			}
			break;

        case 'M':
            if (!strcmp(db1->parms.mssql.dir, db2->parms.mssql.dir) &&
                !strcmp(db1->parms.mssql.osuser, db2->parms.mssql.osuser) &&
                !strcmp(db1->parms.mssql.dsquery, db2->parms.mssql.dsquery) &&
                !strcmp(db1->parms.mssql.mssqlifile, db2->parms.mssql.mssqlifile))
            {
                return_sts = SAME_DATABASE;
            }
            else
            {
                return_sts = DIFF_DATABASE;
            }
            break;


		case 'O':
			if (!strcmp(db1->parms.ora.dir, db2->parms.ora.dir) &&
				!strcmp(db1->parms.ora.osuser, db2->parms.ora.osuser))
			{
				return_sts = SAME_DATABASE;
			}
			else
			{
				return_sts = DIFF_DATABASE;
			}
			break;

		case 'D':
		{
			risdb2parms	*p1 = &db1->parms.db2;
			risdb2parms	*p2 = &db1->parms.db2;
			if (!strcmp(p1->net_protocol, PROTOCOL_DEF_LU))
			{
				if (!strcmp(p1->osuser, p2->osuser) &&
					!strcmp(p1->arch, p2->arch) &&
					!strcmp(p1->os, p2->os) &&
					!strcmp(p1->env, p2->env) &&
					!strcmp(p1->net_protocol, p2->net_protocol) &&
					!strcmp(p1->host_program, p2->host_program) &&
					!strcmp(p1->ris_lu, p2->ris_lu) &&
					!strcmp(p1->host_lu, p2->host_lu) &&
					!strcmp(p1->mode, p2->mode))
				{
					return_sts = SAME_DATABASE;
				}
				else
				{
					return_sts = DIFF_DATABASE;
				}
			}
			else if (!strcmp(p1->net_protocol, PROTOCOL_DEF_TCP))
			{
				if (!strcmp(p1->osuser, p2->osuser) &&
					!strcmp(p1->arch, p2->arch) &&
					!strcmp(p1->os, p2->os) &&
					!strcmp(p1->env, p2->env) &&
					!strcmp(p1->net_protocol, p2->net_protocol) &&
					!strcmp(p1->node, p2->node) &&
					!strcmp(p1->group, p2->group) &&
					p1->port == p2->port)
				{
					return_sts = SAME_DATABASE;
				}
				else
				{
					return_sts = DIFF_DATABASE;
				}
			}
		}
		break;
		case '4':
		{
			risos400parms	*p1 = &db1->parms.os400;
			risos400parms	*p2 = &db1->parms.os400;
			if (!strcmp(p1->net_protocol, PROTOCOL_DEF_LU))
			{
				if (!strcmp(p1->osuser, p2->osuser) &&
					!strcmp(p1->net_protocol, p2->net_protocol) &&
					!strcmp(p1->host_program, p2->host_program) &&
					!strcmp(p1->ris_lu, p2->ris_lu) &&
					!strcmp(p1->host_lu, p2->host_lu) &&
					!strcmp(p1->mode, p2->mode))
				{
					return_sts = SAME_DATABASE;
				}
				else
				{
					return_sts = DIFF_DATABASE;
				}
			}
			else if (!strcmp(p1->net_protocol, PROTOCOL_DEF_TCP))
			{
				if (!strcmp(p1->osuser, p2->osuser) &&
					!strcmp(p1->net_protocol, p2->net_protocol) &&
					!strcmp(p1->node, p2->node) &&
					!strcmp(p1->group, p2->group) &&
					p1->port == p2->port)
				{
					return_sts = SAME_DATABASE;
				}
				else
				{
					return_sts = DIFF_DATABASE;
				}
			}
		}
		break;
		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	CCO_DBG(("compare_all_parms: returning %s\n",
		(return_sts == SAME_DATABASE) ? "SAME_DATABASE" : "DIFF_DATABASE"));
	return return_sts;
}

/******************************************************************************/

extern int RIScco_compare_dbs(
	risdb *db1,
	risdb *db2,
	int allflag)
{
	int return_sts;
	int checkparms;

	/*
	**	Check for duplicate dbs
	**	Returns SAME_DATABASE for the same db
	**	Returns DIFF_DATABASE for different db
	*/
    CCO_DBG(("RIScco_compare_dbs(db1:0x%x db2:0x%x allflag:%d)\n",
		db1, db2, allflag));

	if (strcmp(db1->dbname,db2->dbname) == 0 &&
		db1->dtype == db2->dtype &&
		db1->ostype == db2->ostype &&
		compare_protocols_netaddr(db1, db2) == SAME_DATABASE)
	{
		if (allflag)
		{
			checkparms = compare_all_parms(db1, db2);
		}
		else
		{
			checkparms = compare_parms(db1, db2);
		}
		if (checkparms == SAME_DATABASE)
		{
			return_sts = SAME_DATABASE;
		}
		else
		{
			return_sts = DIFF_DATABASE;
		}
	}
	else
	{
		return_sts = DIFF_DATABASE;
	}

	CCO_DBG(("RIScco_match_dbs: returning %s\n",
		(return_sts == SAME_DATABASE) ? "SAME_DATABASE" : "DIFF_DATABASE"));

	return return_sts;
}

/******************************************************************************/

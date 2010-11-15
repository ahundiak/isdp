/* Do not alter this SPC information: $Revision: 1.1.56.1 $ */
/*
**	NAME:							clistmst.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					8/92
**	ABSTRACT:
**                    RIScli_init_error_struct() initializes risstmtstat structs
**                    for superschema execution and clear.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "rismem.h"
#include "client.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define clistmst_c
#include "clistmst.prt"
#include "comalloc.prt"
#include "comrealc.prt"
#include "comsqlca.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void RIScli_init_error_structs(
	rissuperschema *sschema,
	short stmtstat_indx,
	int stmt_id,
	char *schname,
	char *rissqlstmt)
{

	CLI_DBG(("RIScli_init_error_structs(sschema: 0x%x stmtstat_indx: %d stmt_id: %d schname: %s rissqlstmt: 0x%x)\n",
			sschema, stmtstat_indx, stmt_id, STRING(schname), rissqlstmt));

	if ((stmt_id >= 0 && (unsigned int)stmt_id < (unsigned int)(RIS_parms.max_user_stmts + RIS_max_secondary_stmts)) &&
		RIS_stmts[stmt_id])
	{
		risstmtstat	*stmtstat = sschema->stmtstat[stmtstat_indx];
		int			len;
		char		*save_sqlstmt;

		if( stmtstat )
		{
			/*
			**	clear risca and dbca structures
			*/

			RIScli_clear_stmtstat(stmtstat);
		}
		else
		{
			/*
			**	allocate risstmtstat structure
			*/
			sschema->stmtstat[stmtstat_indx] = 
				RIScli_alloc_risstmtstat(sschema->ssid);
			stmtstat = sschema->stmtstat[stmtstat_indx];
		}
		if( stmtstat_indx == 0 )
		{
			/*
			** This id is used by RIScli_clear() to initialize risstmtstat
			** structures.
			*/
			sschema->primary_id = (short)stmt_id;
		}
		strcpy(stmtstat->schname,schname);
		stmtstat->stmt_id = (short)stmt_id; 

		/*
		** allocate or reallocate sqlstmt in risca structure and then copy
		** the rissqlstmt into stmtstat->risca->sqlstmt.
		** dbsqlstmt is copied only if the stmt fails.
		*/
		save_sqlstmt = stmtstat->risca->sqlstmt;
		len = strlen(rissqlstmt);
		len++;
		CLI_DBG(("rissqlstmt's len: %d\n", len));

		/*
		** For risca use RISSQLSTMT_SS_MARK
		*/
		if( save_sqlstmt )
		{
			/*
			** stmtstat's rissqlstmt was already allocated and therefore
			** reallocate only if needed
			*/
			if( strlen(save_sqlstmt) < (unsigned int)len )
			{
				/*
				**  Reallocate stmtstat->risca->sqlstmt to len size
				**  RISSQLSTMT_SS_MARK is used to generate unique mark for
				**  each schema's rissqlstmt (schema involved in current
				**  superschema)
				*/
				CLI_DBG(("Reallocating risca->sqlstmt\n"));
				save_sqlstmt =
					(char *) RIScom_realloc(len, sschema->ssid,
					RISSQLSTMT_SS_MARK + stmtstat_indx, SUPERSCHEMA_MEMORY);
			}
			stmtstat->risca->sqlstmt = save_sqlstmt;
		}
		else
		{
			/*
			**  stmtstat's rissqlstmt was not allocated before
			*/
			save_sqlstmt =
				(char *) RIScom_alloc(len, sschema->ssid,
				RISSQLSTMT_SS_MARK + stmtstat_indx, SUPERSCHEMA_MEMORY);
			stmtstat->risca->sqlstmt = save_sqlstmt;
		}
		memcpy(stmtstat->risca->sqlstmt,rissqlstmt,len);
	}	
	else
	{
		RIScom_clear_sqlca(risca);
		RIScom_clear_sqlca(dbca);
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	CLI_DBG(("RIScli_init_error_structs: complete\n"));
}

/******************************************************************************/

static risstmtstat *RIScli_alloc_risstmtstat(
	short ssid)
{
	struct risstmtstat	*stmtstat;
	CLI_DBG(("RIScli_alloc_risstmtstat(ssid: %d)\n", ssid));

	/*
	**	All allocation for a particular superschema uses DEFAULT_MARK except
	**	allocation for risca->sqlstmt and dbca->sqlstmt for a particular stmt
	**	within the current definition of superschema.
	**	Any unique mark is required for each risca->sqlstmt and dbca->sqlstmt
	**	For risca->sqlstmt it is RISSQLSTMT_MARK + stmtstat_indx and
	**	for dbca->sqlstmt it is DBSQLSTMT_MARK + stmtstat_indx
	*/

	/*
	**	Allocate memory for stmtstat
	*/
	stmtstat = ALLOCTSS(ssid,risstmtstat);
	memset(stmtstat, 0, sizeof(risstmtstat));

	/*
	**	Allocate memory for stmtstat->risca
	*/
	stmtstat->risca = ALLOCTSS(ssid, rissqlca);
	memset(stmtstat->risca, 0, sizeof(rissqlca));

	/*
	**	Allocate memory for stmtstat->dbca
	*/
	stmtstat->dbca = ALLOCTSS(ssid, rissqlca);
	memset(stmtstat->dbca, 0, sizeof(rissqlca));

	CLI_DBG(("RIScli_alloc_risstmtstat: complete\n"));
	return(stmtstat);
}

/******************************************************************************/

extern void RIScli_copy_sqlcas(
	rissuperschema	*sschema,
	int	 			stmtstat_indx,
	int				sqlcode)
{
	int  		len;
	char		*sqlstmt;
	char 		*save_sqlstmt;
	risstmtstat *stmtstat;

	CLI_DBG(("RIScli_copy_sqlcas(sschema:0x%x stmtstat_indx:%d sqlcode:%d)\n", 
			sschema, stmtstat_indx, sqlcode));

	stmtstat = sschema->stmtstat[stmtstat_indx];

	/*
	** risca
	*/
	if( !stmtstat->risca || !stmtstat->dbca )
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	/*
	** risca
	*/

	/*
	** rissqlstmt was already copied at the time of when clear or execute was
	** started and therefore donot copy rissqlstmt
	*/
	stmtstat->risca->sqlcode = sqlcode;

	/*
	** dbca
	*/
	save_sqlstmt = stmtstat->dbca->sqlstmt;
	sqlstmt = dbca->sqlstmt;
	len = strlen(sqlstmt);
	len++;
	CLI_DBG(("dbsqlstmt's len: %d\n", len));
	memcpy(stmtstat->dbca, dbca, sizeof (rissqlca));

	/*
	** For risca use DBSQLSTMT_SS_MARK
	*/
	if( save_sqlstmt )
	{
		/*
		** stmtstat's dbsqlstmt was already allocated and therefore reallocate
		** only if needed
		** DBSQLSTMT_SS_MARK is used to generate unique mark for each
		** schema's dbsqlstmt (schema involved in current superschema)
		*/
		if( strlen(save_sqlstmt) < (unsigned int)len )
		{
			/*
			**	Reallocate stmtstat->dbca->sqlstmt the sizeof(dbca->sqlstmt)
			*/
			CLI_DBG(("Reallocating dbca->sqlstmt\n"));
    		save_sqlstmt = 
				(char *) RIScom_realloc(len, sschema->ssid, 
					DBSQLSTMT_SS_MARK + stmtstat_indx, SUPERSCHEMA_MEMORY);
		}
		stmtstat->dbca->sqlstmt = save_sqlstmt;
	}
	else
	{
		/*
		**	stmtstat's dbsqlstmt not allocated before
		*/
    	save_sqlstmt = 
			(char *) RIScom_alloc(len, sschema->ssid, 
				DBSQLSTMT_SS_MARK + stmtstat_indx, SUPERSCHEMA_MEMORY);
		stmtstat->dbca->sqlstmt = save_sqlstmt;
	}
	memcpy(stmtstat->dbca->sqlstmt,sqlstmt,len);

	CLI_DBG(("RIScli_copy_sqlcas:returning\n"));
}

/******************************************************************************/

extern void RIScli_clear_stmtstat(
	struct risstmtstat *stmtstat)
{
	CLI_DBG(("RIScli_clear_stmtstat(stmtstat: 0x%x)\n", stmtstat));

	if( !stmtstat )
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	if( stmtstat->risca )
	{
		RIScom_clear_sqlca(stmtstat->risca);
	}
	if( stmtstat->dbca )
	{
		RIScom_clear_sqlca(stmtstat->dbca);
	}

	CLI_DBG(("RIScli_clear_stmtstat: complete\n"));
}

/******************************************************************************/


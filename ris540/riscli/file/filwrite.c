/* Do not alter this SPC information: $Revision: 1.3.27.1 $ */
/*
**	NAME:							filwrite.c
**	AUTHORS:						Sunil Murthy
**	CREATION DATE:					11/92
**	ABSTRACT:
**  	schema file write functions. (originally in FILfile.c)
**		
**	
**	REVISION HISTORY:
**		10/24/94 - Radha
**			Added changes for MSSQL data server
**
**		11/94 - Dianne
**			Changed the size from temp[80] to temp[RIS_MAX_ID_SIZE * 4]
**
*/

/*
**	DEFINES
*/

#define ACCEPT_VERSION_2_SCHEMA_FILES
#define ACCEPT_VERSION_3_SCHEMA_FILES

/*
**	INCLUDES
*/
#include <stdarg.h>
#include "file.h"
#include "schfile.h"

/*
**      FUNCTION PROTOTYPES
*/
#define filwrite_c
#include "filwrite.prt"
#include "ccover.prt"
#include "comjmp.prt"
#include "comdebug.prt"
#include "comwrap.prt"
#include "comstrcp.prt"
#include "filcksum.prt"
#include "filshare.prt"
#include "sys.prt"


/******************************************************************************/

extern int RISfil_write_next_line(
	char * fmt, 
	... )
{
	va_list args;
	auto	int		sts;
	static	char	buffer[LINE_BUFFER_SIZE];

	va_start(args,fmt);
	sts = vsprintf(buffer, fmt, args);
	va_end(args);

	/*
	** See filcksum.c (TR #439502001)
	** surjit (June 5, 1995)
	*/
	RISfil_get_check_sum(buffer,0);
	RISfil_linenum++;

	if (RISfil_write_flag)
		return (RIScom_fputs(buffer, RISfil_fp));
	return sts;
}

/******************************************************************************/

static void write_grantees(
			risgrantee	*grantee)
{
	auto	int			i;
	auto	char		*ptr;
	auto	char		temp[RIS_MAX_ID_SIZE * 4];

	while (grantee)
	{
		ptr = temp;
		for (i = 0; i < 4 && grantee; i++, grantee = grantee->next)
		{
			ptr += RIScom_strncpy(ptr, grantee->schname, RIS_MAX_ID_SIZE - 1);
			if (grantee->next)
				*ptr++ = ',';
		}
		*ptr = '\0';
		if (RISfil_write_next_line("%s\n", temp) < 0)
			LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	}
}

/******************************************************************************/

extern void RISfil_write_schema(
	risschema	*schemap)
{
	char *majstr, *feastr;

	FIL_DBG(("RISfil_write_schema(schemap:0x%x)\n", schemap));
	/*
	**	SEPARATOR
	*/
	if (RISfil_write_next_line("--------------------------------------------------------------------------------\n") < 0)
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);

	/*
	**	SCHNAME
	*/
	if (RISfil_write_next_line("%s%s\n", SCHNAME, schemap->schname) < 0)
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	FIL_DBG(("\nwrote schname:<%s>\n", schemap->schname));

	/*
	**	SERVER_VERSION
	*/
	majstr = RIScco_ver_number_to_str(schemap->major);
	feastr = RIScco_ver_number_to_str(schemap->feature);
	if (RISfil_write_next_line("%s%s.%s\n", SERVER_VERSION, majstr, feastr) < 0)
	{
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	}
	FIL_DBG(("\nwrote server_version major:<%s> feature:<%s>\n",majstr,feastr));

	/*
	**	SECURE
	*/
	if (RISfil_write_next_line("%s%c\n", SECURE, 
		schemap->secure == 'S' ? '1' : '0') < 0)
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	FIL_DBG(("wrote secure:<%c>\n", schemap->secure));

	/*
	**	DICTOWNER
	*/
	if (RISfil_write_next_line("%s%s\n", DICTOWNER, 
		schemap->dictowner ? schemap->dictowner : "") < 0)
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	FIL_DBG(("wrote dicowner:<%s>\n", schemap->dictowner));

	/*
	**	SCHOWNER
	*/
	if (RISfil_write_next_line("%s%s\n", SCHOWNER, schemap->schowner) < 0)
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	FIL_DBG(("wrote schowner:<%s>\n", schemap->schowner));

	/*
	**	SCHOWNPASS
	*/
	if (RISfil_write_next_line("%s%s\n", SCHOWNPASS, 
		schemap->secure == 'S' ? "" : schemap->passwd) < 0)
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	FIL_DBG(("wrote passwd:<%s>\n", schemap->passwd));

	/*
	**	GRANTEES
	*/
	if (RISfil_write_next_line("%s\n", BEGIN_GRANTEES) < 0)
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	FIL_DBG(("wrote begin grantees\n"));

	write_grantees(schemap->grantee);

	if (RISfil_write_next_line("%s\n", END_GRANTEES) < 0)
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	FIL_DBG(("wrote end grantees\n"));

	/*
	**	DBID
	*/
	if (RISfil_write_next_line("%s%d\n", DBID, schemap->dbid) < 0)
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	FIL_DBG(("wrote dbid:%d\n", schemap->dbid));
}

/******************************************************************************/

extern void RISfil_write_db(
	risdb	*dbp)
{
	int				i;
	int				prot_count;
	unsigned char	protocol;
	char			*netaddr;

	FIL_DBG(("RISfil_write_db(dbp:0x%x)\n", dbp));
	/*
	**	SEPARATOR
	*/
	if (RISfil_write_next_line("--------------------------------------------------------------------------------\n") < 0)
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);

	/*
	**	DBID
	*/
	if (RISfil_write_next_line("%s%d\n", DBID, dbp->dbid) < 0)
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	FIL_DBG(("\nwrote dbid:<%d>\n", dbp->dbid));

	/*
	**	DTYPE
	*/
	if (RISfil_write_next_line("%s%c\n", DTYPE, dbp->dtype) < 0)
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	FIL_DBG(("wrote dtype:<%c>\n", dbp->dtype));

	/*
	**	DBNAME
	*/
	if (RISfil_write_next_line("%s%s\n", DBNAME, dbp->dbname) < 0)
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	FIL_DBG(("wrote dbname:<%s>\n", dbp->dbname));

	/*
	**	OSTYPE
	*/
	if (dbp->ostype)
	{
		if (RISfil_write_next_line("%s%c\n", OSTYPE, dbp->ostype) < 0)
			LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
		FIL_DBG(("wrote ostype:<%c>\n", dbp->ostype));
	}
	else
	{
		if (RISfil_write_next_line("%s\n", OSTYPE) < 0)
			LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
		FIL_DBG(("wrote ostype:\n"));
	}

	prot_count = 0;
	for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
	{
		protocol = dbp->pathways[i].protocol;
		netaddr = dbp->pathways[i].netaddr;
		if (protocol)
		{
			if (RISfil_write_next_line("%s%c\n", PROTOCOL, protocol) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote pathway[%d].protocol:<%c>\n",prot_count,protocol));
		}
		else
		{
			if (RISfil_write_next_line("%s\n", PROTOCOL) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote pathway[%d].protocol:\n",prot_count));
		}

		if (*netaddr) 
		{
			if (RISfil_write_next_line("%s%s\n", NETADDR, netaddr) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote pathway[%d].netaddr:<%s>\n", prot_count, netaddr));
		}
		else
		{
			if (RISfil_write_next_line("%s\n", NETADDR) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote pathway[%d].netaddr:\n", prot_count));
		}

		prot_count++;
	}

	/*
	**	PARMS
	*/
	switch(dbp->dtype)
	{
		case 'X':
		{
			risifxparms	*ifx = &dbp->parms.ifx;

#if defined(WIN32) || defined(vms)
			if (RISfil_write_next_line("%s%s\n", DIR, ifx->dir) < 0)
#elif defined(unix)
			if (RISfil_write_next_line("%s%s\n", SCHFILE_DIR, ifx->dir) < 0)
#else
ERROR -- NO CODE
#endif
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote dir:<%s>\n", ifx->dir));

			if (RISfil_write_next_line("%s%s\n", SQLEXEC, ifx->sqlexec) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote sqlexec:<%s>\n", ifx->sqlexec));

			if (RISfil_write_next_line("%s%s\n", DBTEMP, ifx->dbtemp) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote dbtemp:<%s>\n", ifx->dbtemp));

			if (RISfil_write_next_line("%s%s\n", TBCONFIG, ifx->tbconfig) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote tbconfig:<%s>\n", ifx->tbconfig));
		}
		break;

		case 'Y':
		{
			rissybparms	*syb = &dbp->parms.syb;

			if (RISfil_write_next_line("%s%s\n", OSUSER, syb->osuser) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote osuser:<%s>\n", syb->osuser));

			if (RISfil_write_next_line("%s%s\n", OSPASS, syb->ospass) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote ospass:<%s>\n", syb->ospass));

#if defined(WIN32) || defined(vms)
			if (RISfil_write_next_line("%s%s\n", DIR, syb->dir) < 0)
#elif defined(unix)
			if (RISfil_write_next_line("%s%s\n", SCHFILE_DIR, syb->dir) < 0)
#else
ERROR -- NO CODE
#endif
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote dir:<%s>\n", syb->dir));

			if (RISfil_write_next_line("%s%s\n", DSQUERY, syb->dsquery) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote dsquery:<%s>\n", syb->dsquery));

			if (RISfil_write_next_line("%s%s\n", FILENAME, syb->sybifile) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote sybifile:<%s>\n", syb->sybifile));

		}
		break;
		case 'M':
		{
			rismssqlparms	*mssql = &dbp->parms.mssql;

			if (RISfil_write_next_line("%s%s\n", OSUSER, mssql->osuser) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote osuser:<%s>\n", mssql->osuser));

			if (RISfil_write_next_line("%s%s\n", OSPASS, mssql->ospass) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote ospass:<%s>\n", mssql->ospass));

#if defined(WIN32) || defined(vms)
			if (RISfil_write_next_line("%s%s\n", DIR, mssql->dir) < 0)
#elif defined(unix)
			if (RISfil_write_next_line("%s%s\n", SCHFILE_DIR, mssql->dir) < 0)
#else
ERROR -- NO CODE
#endif
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote dir:<%s>\n", mssql->dir));

			if (RISfil_write_next_line("%s%s\n", DSQUERY, mssql->dsquery) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote dsquery:<%s>\n", mssql->dsquery));

			if (RISfil_write_next_line("%s%s\n", FILENAME, mssql->mssqlifile) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote ifile:<%s>\n", mssql->mssqlifile));
		}
			break;
		case 'I':
		{
			risigsparms	*igs = &dbp->parms.igs;

#if defined(WIN32) || defined(vms)
			if (RISfil_write_next_line("%s%s\n", DIR, igs->dir) < 0)
#elif defined(unix)
			if (RISfil_write_next_line("%s%s\n", SCHFILE_DIR, igs->dir) < 0)
#else
ERROR -- NO CODE
#endif
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote dir:<%s>\n", igs->dir));
		}
		break;

		case 'O':
		{
			risoraparms	*ora = &dbp->parms.ora;

			if (RISfil_write_next_line("%s%s\n", OSUSER, ora->osuser) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote osuser:<%s>\n", ora->osuser));

			if (RISfil_write_next_line("%s%s\n", OSPASS, ora->ospass) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote ospass:<%s>\n", ora->ospass));

#if defined(WIN32) || defined(vms)
			if (RISfil_write_next_line("%s%s\n", DIR, ora->dir) < 0)
#elif defined(unix)
			if (RISfil_write_next_line("%s%s\n", SCHFILE_DIR, ora->dir) < 0)
#else
ERROR -- NO CODE
#endif
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote dir:<%s>\n", ora->dir));
		}
		break;

		case 'D':
		{
			risdb2parms	*db2 = &dbp->parms.db2;

			if (RISfil_write_next_line("%s%s\n", OSUSER, db2->osuser) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote osuser:<%s>\n", db2->osuser));

			if (RISfil_write_next_line("%s%s\n", OSPASS, db2->ospass) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote ospass:<%s>\n", db2->ospass));

			if (RISfil_write_next_line("%s%s\n", ARCH, db2->arch) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote arch:<%s>\n", db2->arch));

			if (RISfil_write_next_line("%s%s\n", OS, db2->os) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote os:<%s>\n", db2->os));

			if (RISfil_write_next_line("%s%s\n", NET_PROTOCOL, db2->net_protocol) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote net protocol:<%s>\n", db2->net_protocol));

			if (RISfil_write_next_line("%s%s\n", ENV, db2->env) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote env:<%s>\n", db2->env));

			if (RISfil_write_next_line("%s%s\n", HOST_PROGRAM, db2->host_program) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote host program:<%s>\n", db2->host_program));

			if (RISfil_write_next_line("%s%s\n", RIS_LU, db2->ris_lu) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote ris lu:<%s>\n", db2->ris_lu));

			if (RISfil_write_next_line("%s%s\n", HOST_LU, db2->host_lu) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote host lu:<%s>\n", db2->host_lu));

			if (RISfil_write_next_line("%s%s\n", MODE, db2->mode) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote mode:<%s>\n", db2->mode));

			if (RISfil_write_next_line("%s%s\n", GROUP, db2->group) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote group:<%s>\n", db2->group));

			if (RISfil_write_next_line("%s%s\n", NODE, db2->node) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote node:<%s>\n", db2->node));

			if (RISfil_write_next_line("%s%d\n", PORT, db2->port) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote port:<%d>\n", db2->port));
		}
		break;
		
		case '4':
		{
			risos400parms	*os400 = &dbp->parms.os400;

			if (RISfil_write_next_line("%s%s\n", RIS_DICT_DBNAME, 
										os400->ris_dict_dbname) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote ris_dict_dbname:<%s>\n", os400->ris_dict_dbname));

			if (RISfil_write_next_line("%s%s\n", OSUSER, os400->osuser) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote osuser:<%s>\n", os400->osuser));

			if (RISfil_write_next_line("%s%s\n", OSPASS, os400->ospass) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote ospass:<%s>\n", os400->ospass));

			if (RISfil_write_next_line("%s%s\n", NET_PROTOCOL, os400->net_protocol) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote net protocol:<%s>\n", os400->net_protocol));

			if (RISfil_write_next_line("%s%s\n", HOST_PROGRAM, os400->host_program) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote host program:<%s>\n", os400->host_program));

			if (RISfil_write_next_line("%s%s\n", RIS_LU, os400->ris_lu) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote ris lu:<%s>\n", os400->ris_lu));

			if (RISfil_write_next_line("%s%s\n", HOST_LU, os400->host_lu) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote host lu:<%s>\n", os400->host_lu));

			if (RISfil_write_next_line("%s%s\n", MODE, os400->mode) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote mode:<%s>\n", os400->mode));

			if (RISfil_write_next_line("%s%s\n", GROUP, os400->group) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote group:<%s>\n", os400->group));

			if (RISfil_write_next_line("%s%s\n", NODE, os400->node) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote node:<%s>\n", os400->node));

			if (RISfil_write_next_line("%s%d\n", PORT, os400->port) < 0)
				LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
			FIL_DBG(("wrote port:<%d>\n", os400->port));
		}
		break;
		case 'R':
			/* Nothing to write */
		break;
	}
}

/******************************************************************************/

extern void RISfil_write_schema_file(
	char			*filename)
{
	int				sts;
	unsigned int	save_checksum;
	fildb_list		*dbp;
	filsch_list		*schemap;

	FIL_DBG(("RISfil_write_schema_file(filename:<%s>)\n", filename));

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		strcpy(RIS_ERRMSGC,
			"The error occured while writing to the schema file.");
		LONGJMP(sts);
	}
	RISfil_verify_db_list();
	RISfil_verify_schema_list();
	RESETJMP();


	if ((RISfil_fp = RIScom_fopen(filename, "w")) == NULL)
	{
        sprintf(RIS_ERRMSGC, "\nCannot open '%s' ", filename);
		LONGJMP(RIS_E_CANT_OPEN_SCHEMA_FILE_WRITE);
	}

	sts = SETJMP();
	if (sts)
	{
		RESETJMP();
		RIScom_fclose(RISfil_fp);
		LONGJMP(sts);
	}

	RISfil_calculate_checksum();
	/*
	**	CHECKSUM
	*/
	if (fprintf(RISfil_fp, "%s%d\n", CHECKSUM, RISfil_checksum) < 0)
	{
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	}
	save_checksum = RISfil_checksum;

	RISfil_linenum = 0;
	RISfil_checksum = 0;
	RISfil_write_flag = 1;
	/*
	**	TIMESTAMP
	*/
	if (RISfil_write_next_line("%s%d\n", TIMESTAMP, RISfil_timestamp) < 0)
	{
		LONGJMP(RIS_E_CANT_WRITE_SCHEMA_FILE);
	}

	/*
	**	DBS
	*/
	for (dbp = RISfil_db_list; dbp; dbp = dbp->next)
	{
		/*
		**	Write db to file
		*/
		RISfil_write_db(dbp->dbp);
	}

	/*
	**	SCHEMAS
	*/
	for (schemap = RISfil_schema_list; schemap; schemap = schemap->next)
	{
		/*
		**	Write schema to file
		*/
		RISfil_write_schema(schemap->schemap);
	}

	if (RISfil_checksum != save_checksum)
	{
		FIL_DBG(("Calculated different checksums: 1st pass:%d  2nd pass:%d\n",
			save_checksum, RISfil_checksum));
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	RESETJMP();

	/*
	**	Close the file
	*/
	RIScom_fclose(RISfil_fp);
}


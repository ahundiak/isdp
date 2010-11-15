/*
**	NAME:							filread.c
**	AUTHORS:						Sunil Murthy
**	CREATION DATE:					11/92
**	ABSTRACT:
**  	schema file read functions. (originally in FILfile.c)
**		
**	
**	REVISION HISTORY:
**		10/24/94 -Radha
**			Added changes for MSSQL data server.
**	
**		11/94:	Added support for INTERNATIONALIZATION. Dianne
*/

/*
**	DEFINES
*/
#define REPORT_VERSION3_SCHEMA_FILE

/*
**	INCLUDES
*/
#include <stdio.h>
#include <stdarg.h>
#include <ctype.h>
#include "file.h"
#include "schfile.h"
#include "commacro.h"
/*
**      FUNCTION PROTOTYPES
*/
#define filread_c
#include "filread.prt"
#include "comuni.prt"
#include "ccodb2.prt"
#include "ccoos400.prt"
#include "ccover.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "comwrap.prt"
#include "filshare.prt"
#include "filcksum.prt"
#include "sys.prt"

/******************************************************************************/

static char *read_next_line()
{
	auto	char	temp[LINE_BUFFER_SIZE];
	static	char	buffer[LINE_BUFFER_SIZE];

#if defined(WIN32)
	auto	wchar_t	wide_temp[LINE_BUFFER_SIZE];
	static	wchar_t	wide_buffer[LINE_BUFFER_SIZE];
	auto	wchar_t	*src;
	auto	wchar_t	*dst;
#else
	auto	char	*src;
	auto	char	*dst;
#endif

	temp[LINE_BUFFER_SIZE - 2] = 0;

	if (RIScom_fgets(temp, LINE_BUFFER_SIZE, RISfil_fp) == NULL) 
		return NULL;

	if (strlen(temp) >= (LINE_BUFFER_SIZE - 2))
		LONGJMP(RIS_E_SCHEMA_FILE_LINE_TOO_LONG);

#if defined(WIN32)
	RIScom_mbstowcs(wide_temp,temp,LINE_BUFFER_SIZE);
	for (dst = wide_buffer, src = wide_temp; *src; src++)
#else
	for (dst = buffer, src = temp; *src; src++)
#endif
	{
/* this is no longer a valid check with internationalized code
		if (!ISASCII(*src))
		{
			LONGJMP(RIS_E_NON_ASCII_IN_SCHEMA_FILE);
		}
*/
		if (ISSPACE(*src))
		{
			continue;
		}
		*dst++ = *src;
	}
	*dst = WIDECHAR('\0');

	RISfil_linenum++;
#if defined(WIN32)
	RIScom_wcstombs(buffer,wide_buffer,LINE_BUFFER_SIZE);
#endif

	return buffer;
}

/******************************************************************************/
static void get_grantees_from_buffer(
	risschema	*schemap,
	char		*buffer)
{
#if defined(WIN32)
	auto	wchar_t		*tok;
#else
	auto	char		*tok;
#endif
	auto	risgrantee	**granteep;

	FIL_DBG(("get_grantees_from_buffer(schemap:0x%x buffer:<%s>)\n",
		schemap, buffer));

#if defined (WIN32)
	RIScom_multiwide(&RISwide_ptr,&buffer,	&RISwide_size,MULTITOWIDE,0);
	if ((tok = RIScom_wcstok(RISwide_ptr,L"\n,")) == NULL)
		READ_ERROR(RIS_E_READ_NO_GRANTEE);
#else
	if ((tok = strtok(buffer,"\n,")) == NULL)/*itbokic 3/30 */
		READ_ERROR(RIS_E_READ_NO_GRANTEE);
#endif
	
	while(tok)
	{
#if defined(WIN32)
	RIScom_multiwide(&tok,&RISmulti_ptr,&RISmulti_size,WIDETOMULTI,0);
		if (strlen(RISmulti_ptr) > RIS_MAX_ID_SIZE - 1)
			READ_ERROR(RIS_E_READ_INV_GRANTEE);
#else
		if (strlen(tok) > RIS_MAX_ID_SIZE - 1)
			READ_ERROR(RIS_E_READ_INV_GRANTEE);
#endif

		for (granteep = &(schemap->grantee);
			(*granteep);
			granteep = &((*granteep)->next))
		{
#if defined(WIN32)
			if (!strcmp((*granteep)->schname, RISmulti_ptr))
				break;
#else
			if (!strcmp((*granteep)->schname, tok))
				break;
#endif
		}

		if (!(*granteep))
		{
			/*
			**	Grantee isn't in the list, so add it
			*/
			(*granteep) = ALLOCT(risgrantee); 
#if defined(WIN32)
			strcpy((*granteep)->schname, RISmulti_ptr);
#else
			strcpy((*granteep)->schname, tok);
#endif
		}

#if defined(WIN32)
		tok = RIScom_wcstok(L'\0',L"\n,");
#else
		tok = strtok(NULL,"\n,");/*itbokic 3/30 */
#endif
	}
}

/******************************************************************************/

static void read_schema(
	risschema	*schemap)
{
	int				len;
	char			*server_version;
	char			*buffer;
	char			secure;
	char			*dicowner;
	char			*usr;
	char			*usrpass;
	unsigned short	dbid;

	FIL_DBG(("read_schema(schemap:0x%x)\n", schemap));

	/*
	** SERVER_VERSION
	*/
	if ((buffer = read_next_line()) == NULL)
		LONGJMP(RIS_E_UNEXPECTED_EOF);

	if (strncmp(buffer, SERVER_VERSION, SERVER_VERSION_SIZE))
		READ_ERROR(RIS_E_READ_NO_SERVER_VERSION);

	server_version = ALLOCB(strlen((buffer + SERVER_VERSION_SIZE))+1);
	strcpy(server_version, (buffer + SERVER_VERSION_SIZE));
	if ((schemap->major =
			RIScco_ver_str_to_number(strtok(server_version, "."))) == -2) /*itbokic 3/30 */
	{
		READ_ERROR(RIS_E_READ_INVALID_SERVER_VERSION);
	}
	if ((schemap->feature = RIScco_ver_str_to_number(strtok(0, "."))) == -2) /*itbokic 3/30 */
	{
		READ_ERROR(RIS_E_READ_INVALID_SERVER_VERSION);
	}
	if (strtok(0, ".")) /*itbokic 3/30 */
	{
		READ_ERROR(RIS_E_READ_INVALID_SERVER_VERSION);
	}
	if (!schemap->major && !schemap->feature)
	{
		schemap->major = -1;
		schemap->feature = -1;
	}

	FIL_DBG(("read server_version major:<%d> feature:<%d>\n",
		schemap->major, schemap->feature));


	/*
	**	SECURE
	*/
	if ((buffer = read_next_line()) == NULL)
		LONGJMP(RIS_E_UNEXPECTED_EOF);

	if (strncmp(buffer, SECURE, SECURE_SIZE))
		READ_ERROR(RIS_E_READ_NO_SECURE);

	secure = *(buffer + SECURE_SIZE);
	if (secure == '0')
	{
		schemap->secure = ' ';
	}
	else if (secure == '1')
	{
		schemap->secure = 'S';
	}
	else
	{
		READ_ERROR(RIS_E_READ_INV_SECURE);
	}
	FIL_DBG(("read secure:<%c>\n", schemap->secure));

	/*
	**	DICTOWNER
	*/
	if ((buffer = read_next_line()) == NULL)
		LONGJMP(RIS_E_UNEXPECTED_EOF);

	FIL_DBG(("read dictowner \n buffer:<%s>\n DICTOWNER:<%s>\n", buffer, DICTOWNER));
	if (strncmp(buffer, DICTOWNER, DICTOWNER_SIZE))
		READ_ERROR(RIS_E_READ_NO_DICOWNER);

	dicowner = buffer + DICTOWNER_SIZE;
	if ((len = strlen(dicowner)) == 0 || len > RIS_MAX_ID_SIZE - 1)
		READ_ERROR(RIS_E_READ_INV_DICOWNER);

	/*
	**  add dict_user into the schema structure
	*/
	memcpy(schemap->dictowner, dicowner, len + 1);
	FIL_DBG(("read dicowner:<%s>\n", schemap->dictowner));

	/*
	**	SCHOWNER
	*/
	if ((buffer = read_next_line()) == NULL)
		LONGJMP(RIS_E_UNEXPECTED_EOF);

	if (strncmp(buffer, SCHOWNER, SCHOWNER_SIZE))
		READ_ERROR(RIS_E_READ_NO_USR);

	usr = buffer + SCHOWNER_SIZE;
	if ((len = strlen(usr)) == 0 || len > RIS_MAX_ID_SIZE - 1)
		READ_ERROR(RIS_E_READ_INV_USR);

	memcpy(schemap->schowner, usr,len + 1);
	FIL_DBG(("read usr:<%s>\n", schemap->schowner));

	/*
	**	SCHOWNPASS
	*/
	if ((buffer = read_next_line()) == NULL)
		LONGJMP(RIS_E_UNEXPECTED_EOF);

	if (strncmp(buffer, SCHOWNPASS, SCHOWNPASS_SIZE))
		READ_ERROR(RIS_E_READ_NO_USRPASS);

	usrpass = buffer + SCHOWNPASS_SIZE;
	if (*usrpass)
	{
		len = strlen(usrpass);
		if (len != RIS_MAX_PASSWD_SIZE - 1) 
			READ_ERROR(RIS_E_READ_INV_USRPASS);
	}

	memcpy(schemap->passwd, usrpass, RIS_MAX_PASSWD_SIZE);
	FIL_DBG(("read passwd:<%s>\n", schemap->passwd));

	/*
	**	GRANTEES
	*/
	if ((buffer = read_next_line()) == NULL)
		LONGJMP(RIS_E_UNEXPECTED_EOF);

	if (strncmp(buffer, BEGIN_GRANTEES, BEGIN_GRANTEES_SIZE))
		READ_ERROR(RIS_E_READ_NO_BEGIN_GRANTEES);
	FIL_DBG(("read begin grantees\n"));
	
	while(1)
	{
		if ((buffer = read_next_line()) == NULL)
			LONGJMP(RIS_E_UNEXPECTED_EOF);

		if (!strncmp(buffer, END_GRANTEES, END_GRANTEES_SIZE))
			break;

		if (!strncmp(buffer, DBID, DBID_SIZE))
			READ_ERROR(RIS_E_READ_NO_END_GRANTEES);

		get_grantees_from_buffer(schemap, buffer);
	}
	FIL_DBG(("read end grantees\n"));

	/*
	**	DBID
	*/
	if ((buffer = read_next_line()) == NULL)
		LONGJMP(RIS_E_UNEXPECTED_EOF);

	if (strncmp(buffer, DBID, DBID_SIZE))
		READ_ERROR(RIS_E_READ_NO_DBID);

	if ((dbid = (unsigned short)atoi(buffer + DBID_SIZE)) == 0)
		READ_ERROR(RIS_E_READ_INV_DBID);

	schemap->dbid = dbid;
	FIL_DBG(("read dbid:%d\n", schemap->dbid));

}

/******************************************************************************/

static void read_db(
	risdb	*dbp)
{
	int		i;
	int		len;
	int		prot_count;
	char	*ptr;
	char	*portnum;
	char	*buffer;


	FIL_DBG(("read_db(dbp:0x%x)\n", dbp));
	/*
	**	DTYPE
	*/
	if ((buffer = read_next_line()) == NULL)
	{
		LONGJMP(RIS_E_UNEXPECTED_EOF);
	}

	if (strncmp(buffer, DTYPE, DTYPE_SIZE))
	{
		READ_ERROR(RIS_E_READ_NO_DTYPE);
	}

	ptr = buffer + DTYPE_SIZE;
	if (strlen(ptr) != 1)
	{
		READ_ERROR(RIS_E_READ_INV_DTYPE);
	}

	dbp->dtype = *ptr;
	if (dbp->dtype != 'X' &&
		dbp->dtype != 'I' &&
		dbp->dtype != 'O' &&
		dbp->dtype != 'D' &&
		dbp->dtype != '4' &&
		dbp->dtype != 'Y' &&
		dbp->dtype != 'M' &&
		dbp->dtype != 'R')
	{
		FIL_DBG(("dbid:%d has an invalid dtype\n", dbp->dbid));
		READ_ERROR(RIS_E_READ_INV_DTYPE);
	}
	FIL_DBG(("read dtype:<%c>\n", dbp->dtype));

	/*
	**	DBNAME
	*/
	if ((buffer = read_next_line()) == NULL)
		LONGJMP(RIS_E_UNEXPECTED_EOF);

	if (strncmp(buffer, DBNAME, DBNAME_SIZE))
		READ_ERROR(RIS_E_READ_NO_DBNAME);

	ptr = buffer + DBNAME_SIZE;
	if ((len = strlen(ptr) + 1) == 1 || len > RIS_MAX_PATH_SIZE)
		READ_ERROR(RIS_E_READ_INV_DBNAME);

	memcpy(dbp->dbname, ptr,len);
	FIL_DBG(("read dbname:<%s>\n", dbp->dbname));

	if ((buffer = read_next_line()) == NULL)
		LONGJMP(RIS_E_UNEXPECTED_EOF);

	/*
	**  OSTYPE
	*/
	if (strncmp(buffer, OSTYPE, OSTYPE_SIZE))
#ifdef REPORT_VERSION3_SCHEMA_FILE
		READ_ERROR(RIS_E_VERSION_3_SCHEMA_FILE);
#else
		READ_ERROR(RIS_E_READ_NO_OSTYPE);
#endif

	ptr = buffer + OSTYPE_SIZE;
	if ((len = strlen(ptr)) != 1)
		READ_ERROR(RIS_E_READ_INV_OSTYPE);

	dbp->ostype = *ptr;
	FIL_DBG(("read ostype:<%c>\n", dbp->ostype));

	if ((buffer = read_next_line()) == NULL)
		LONGJMP(RIS_E_UNEXPECTED_EOF);

	/*
	**	PATHWAYS
	*/
	prot_count = 0;
	for (i = 0; i < RIS_MAX_PROTOCOLS; i++)
	{
		/*
		**	PROTOCOL
		*/
		if (i > 0)
		{
			/*
			**  The first time through, we've already read a line to determine
			**  if we are reading an old schema file.
			*/

			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
		}

		if (strncmp(buffer, PROTOCOL, PROTOCOL_SIZE))
			READ_ERROR(RIS_E_READ_NO_PROTOCOL);

		ptr = buffer + PROTOCOL_SIZE;

		if (strlen(ptr) > 1)
			READ_ERROR(RIS_E_READ_INV_PROTOCOL);
		
		dbp->pathways[prot_count].protocol = *ptr;
		FIL_DBG(("read pathway[%d].protocol:<%c>\n", prot_count,
			dbp->pathways[prot_count].protocol));

		/*
		**	NETADDR
		*/
		if ((buffer = read_next_line()) == NULL)
			LONGJMP(RIS_E_UNEXPECTED_EOF);

		if (strncmp(buffer, NETADDR, NETADDR_SIZE))
			READ_ERROR(RIS_E_READ_NO_NETADDR);

		ptr = buffer + NETADDR_SIZE;

		if ((len = strlen(ptr) + 1) > RIS_MAX_NODE_SIZE)
			READ_ERROR(RIS_E_READ_INV_NETADDR);

		memcpy(dbp->pathways[prot_count].netaddr , ptr,len);
		FIL_DBG(("read pathway[%d].netaddr:<%s>\n", prot_count,
			dbp->pathways[prot_count].netaddr));

		prot_count++;
	}

	/*
	**	PARMS
	*/
	switch (dbp->dtype)
	{
		case 'X':
			/*
			**	DIR
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
	
#if defined(WIN32) || defined(vms)
			if (strncmp(buffer, DIR, DIR_SIZE))
#elif defined(unix)
			if (strncmp(buffer, SCHFILE_DIR, DIR_SIZE))
#else
ERROR -- NO CODE
#endif
				READ_ERROR(RIS_E_READ_NO_DIR);
	
			ptr = buffer + DIR_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_PATH_SIZE)
				READ_ERROR(RIS_E_READ_INV_DIR);
				
			memcpy(dbp->parms.ifx.dir , ptr,len);
			FIL_DBG(("read dir:<%s>\n", dbp->parms.ifx.dir));

			/*
			**	SQLEXEC
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
	
			if (strncmp(buffer, SQLEXEC, SQLEXEC_SIZE))
				READ_ERROR(RIS_E_READ_NO_SQLEXEC);
	
			ptr = buffer + SQLEXEC_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_PATH_SIZE)
				READ_ERROR(RIS_E_READ_INV_SQLEXEC);
				
			memcpy(dbp->parms.ifx.sqlexec , ptr,len);
			FIL_DBG(("read sqlexec:<%s>\n", dbp->parms.ifx.sqlexec));

			/*
			**	DBTEMP
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
	
			if (strncmp(buffer, DBTEMP, DBTEMP_SIZE))
				READ_ERROR(RIS_E_READ_NO_DBTEMP);
	
			ptr = buffer + DBTEMP_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_PATH_SIZE)
				READ_ERROR(RIS_E_READ_INV_DBTEMP);
				
			memcpy(dbp->parms.ifx.dbtemp , ptr,len );
			FIL_DBG(("read dbtemp:<%s>\n", dbp->parms.ifx.dbtemp));

			/*
			**	TBCONFIG
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
	
			if (strncmp(buffer, TBCONFIG, TBCONFIG_SIZE))
				READ_ERROR(RIS_E_READ_NO_TBCONFIG);
	
			ptr = buffer + TBCONFIG_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_PATH_SIZE)
				READ_ERROR(RIS_E_READ_INV_TBCONFIG);
				
			memcpy(dbp->parms.ifx.tbconfig , ptr,len);
			FIL_DBG(("read tbconfig:<%s>\n", dbp->parms.ifx.tbconfig));

			break;

		case 'Y':
			/*
			**	OSUSER 
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
			if (strncmp(buffer, OSUSER, OSUSER_SIZE))
				READ_ERROR(RIS_E_READ_NO_OSUSER);

			ptr = buffer + OSUSER_SIZE;
			if ((len = strlen(ptr)) == 0 || len > RIS_MAX_ID_SIZE - 1)
				READ_ERROR(RIS_E_READ_INV_OSUSER);

			memcpy(dbp->parms.syb.osuser, ptr,len + 1);
			FIL_DBG(("read usr:<%s>\n", dbp->parms.syb.osuser));

			/*
			**	OSPASS
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, OSPASS, OSPASS_SIZE))
				READ_ERROR(RIS_E_READ_NO_OSPASS);

			ptr = buffer + OSPASS_SIZE;
			if (*ptr)
			{
				len = strlen(ptr);
				if (len != RIS_MAX_PASSWD_SIZE - 1) 
					READ_ERROR(RIS_E_READ_INV_OSPASS);
			}
			memcpy(dbp->parms.syb.ospass, ptr, RIS_MAX_PASSWD_SIZE);
			FIL_DBG(("read ospass:<%s>\n", dbp->parms.syb.ospass));

			/*
			** DIR
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
#if defined(WIN32) || defined(vms)
			if (strncmp(buffer, DIR, DIR_SIZE))
#elif defined(unix) 
			if (strncmp(buffer, SCHFILE_DIR, DIR_SIZE))
#else
ERROR -- NO CODE
#endif
			{
				if (dbp->ostype != 'N')
				{
					READ_ERROR(RIS_E_READ_NO_DIR);
				}
			}	

			ptr = buffer + DIR_SIZE;
			len = strlen(ptr) + 1;

			if (dbp->ostype != 'N')
			{
				if ((len == 1) || (len > RIS_MAX_PATH_SIZE))
				{	
					READ_ERROR(RIS_E_READ_INV_DIR);
				}
				else	
				{
					memcpy(dbp->parms.syb.dir , ptr,len );
				}
			}
			else
			{
				if ((len = strlen(ptr) + 1) > RIS_MAX_PATH_SIZE)
				{
					READ_ERROR(RIS_E_READ_INV_DIR);
				}
				else if(len == 1)
				{
					dbp->parms.syb.dir[0] = 0;
				}
				else
				{
					memcpy(dbp->parms.syb.dir , ptr,len );
				}
			}
			FIL_DBG(("read dir:<%s>\n", STRING(dbp->parms.syb.dir)));

			/*
			**	DSQUERY
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
	
			if (strncmp(buffer, DSQUERY, DSQUERY_SIZE))
				READ_ERROR(RIS_E_READ_NO_DSQUERY);
	
			ptr = buffer + DSQUERY_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_ID_SIZE)
				READ_ERROR(RIS_E_READ_INV_DSQUERY);
				
			memcpy(dbp->parms.syb.dsquery , ptr,len);
			FIL_DBG(("read dsquery:<%s>\n", dbp->parms.syb.dsquery));

            /*
			**  FILENAME
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, FILENAME, FILENAME_SIZE))
				READ_ERROR(RIS_E_READ_NO_FILENAME);

			ptr = buffer + FILENAME_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_ID_SIZE)
				READ_ERROR(RIS_E_READ_INV_FILENAME);

			memcpy(dbp->parms.syb.sybifile , ptr,len);
			FIL_DBG(("read sybifile:<%s>\n", dbp->parms.syb.sybifile));

			break;
		case 'M':
			/*
			**	OSUSER 
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
			if (strncmp(buffer, OSUSER, OSUSER_SIZE))
				READ_ERROR(RIS_E_READ_NO_OSUSER);

			ptr = buffer + OSUSER_SIZE;
			if ((len = strlen(ptr)) == 0 || len > RIS_MAX_ID_SIZE - 1)
				READ_ERROR(RIS_E_READ_INV_OSUSER);

			memcpy(dbp->parms.mssql.osuser, ptr,len + 1);
			FIL_DBG(("read usr:<%s>\n", dbp->parms.mssql.osuser));

			/*
			**	OSPASS
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, OSPASS, OSPASS_SIZE))
				READ_ERROR(RIS_E_READ_NO_OSPASS);

			ptr = buffer + OSPASS_SIZE;
			if (*ptr)
			{
				len = strlen(ptr);
				if (len != RIS_MAX_PASSWD_SIZE - 1) 
					READ_ERROR(RIS_E_READ_INV_OSPASS);
			}
			memcpy(dbp->parms.mssql.ospass, ptr, RIS_MAX_PASSWD_SIZE);
			FIL_DBG(("read ospass:<%s>\n", dbp->parms.mssql.ospass));

			/*
			** DIR
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
#if defined(WIN32) || defined(vms)
			if (strncmp(buffer, DIR, DIR_SIZE))
#elif defined(unix)
			if (strncmp(buffer, SCHFILE_DIR, DIR_SIZE))
#else
ERROR -- NO CODE
#endif
			{
				if (dbp->ostype != 'N')
				{
					READ_ERROR(RIS_E_READ_NO_DIR);
				}
			}	

			ptr = buffer + DIR_SIZE;
			len = strlen(ptr) + 1;

			if (dbp->ostype != 'N')
			{
				if ((len == 1) || (len > RIS_MAX_PATH_SIZE))
				{	
					READ_ERROR(RIS_E_READ_INV_DIR);
				}
				else	
				{
					memcpy(dbp->parms.mssql.dir , ptr,len );
				}
			}
			else
			{
				if ((len = strlen(ptr) + 1) > RIS_MAX_PATH_SIZE)
				{
					READ_ERROR(RIS_E_READ_INV_DIR);
				}
				else if(len == 1)
				{
					dbp->parms.mssql.dir[0] = 0;
				}
				else
				{
					memcpy(dbp->parms.mssql.dir , ptr,len );
				}
			}
			FIL_DBG(("read dir:<%s>\n", STRING(dbp->parms.mssql.dir)));

			/*
			**	DSQUERY
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
	
			if (strncmp(buffer, DSQUERY, DSQUERY_SIZE))
				READ_ERROR(RIS_E_READ_NO_DSQUERY);
	
			ptr = buffer + DSQUERY_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_ID_SIZE)
				READ_ERROR(RIS_E_READ_INV_DSQUERY);
				
			memcpy(dbp->parms.mssql.dsquery , ptr,len);
			FIL_DBG(("read dsquery:<%s>\n", dbp->parms.mssql.dsquery));

            /*
			**  FILENAME
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, FILENAME, FILENAME_SIZE))
				READ_ERROR(RIS_E_READ_NO_FILENAME);

			ptr = buffer + FILENAME_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_ID_SIZE)
				READ_ERROR(RIS_E_READ_INV_FILENAME);

			memcpy(dbp->parms.mssql.mssqlifile , ptr,len);
			FIL_DBG(("read mssqlifile:<%s>\n", dbp->parms.mssql.mssqlifile));
			break;

		case 'I':
			/*
			**	DIR
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
	
#if defined(WIN32) || defined(vms)
			if (strncmp(buffer, DIR, DIR_SIZE))
#elif defined(unix)
			if (strncmp(buffer, SCHFILE_DIR, DIR_SIZE))
#else
ERROR -- NO CODE
#endif
				READ_ERROR(RIS_E_READ_NO_DIR);
	
			ptr = buffer + DIR_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_PATH_SIZE)
				READ_ERROR(RIS_E_READ_INV_DIR);
				
			memcpy(dbp->parms.igs.dir , ptr,len );
			FIL_DBG(("read dir:<%s>\n", dbp->parms.igs.dir));

			break;

		case 'O':
			/*
			**	OSUSER 
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
			if (strncmp(buffer, OSUSER, OSUSER_SIZE))
				READ_ERROR(RIS_E_READ_NO_OSUSER);

			ptr = buffer + OSUSER_SIZE;
			if ((len = strlen(ptr)) == 0 || len > RIS_MAX_ID_SIZE - 1)
				READ_ERROR(RIS_E_READ_INV_OSUSER);

			memcpy(dbp->parms.ora.osuser, ptr,len + 1);
			FIL_DBG(("read usr:<%s>\n", dbp->parms.ora.osuser));

			/*
			**	OSPASS
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, OSPASS, OSPASS_SIZE))
				READ_ERROR(RIS_E_READ_NO_OSPASS);

			ptr = buffer + OSPASS_SIZE;
			if (*ptr)
			{
				len = strlen(ptr);
				if (len != RIS_MAX_PASSWD_SIZE - 1) 
					READ_ERROR(RIS_E_READ_INV_OSPASS);
			}
			memcpy(dbp->parms.ora.ospass, ptr, RIS_MAX_PASSWD_SIZE);
			FIL_DBG(("read ospass:<%s>\n", dbp->parms.ora.ospass));

			/*
			**	DIR
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
#if defined(WIN32) || defined(vms)
			if (strncmp(buffer, DIR, DIR_SIZE))
#elif defined(unix)
			if (strncmp(buffer, SCHFILE_DIR, DIR_SIZE))
#else
ERROR -- NO CODE
#endif
				READ_ERROR(RIS_E_READ_NO_DIR);
	
			ptr = buffer + DIR_SIZE;
			if ((len = strlen(ptr) + 1) == 1 || len > RIS_MAX_PATH_SIZE)
				READ_ERROR(RIS_E_READ_INV_DIR);
				
			memcpy(dbp->parms.ora.dir , ptr,len );
			FIL_DBG(("read dir:<%s>\n", dbp->parms.ora.dir));
			break;

		case 'D':
			/*
			**	OSUSER 
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
			if (strncmp(buffer, OSUSER, OSUSER_SIZE))
				READ_ERROR(RIS_E_READ_NO_OSUSER);

			ptr = buffer + OSUSER_SIZE;
			if ((len = strlen(ptr)) == 0 || len > RIS_MAX_ID_SIZE - 1)
				READ_ERROR(RIS_E_READ_INV_OSUSER);

			memcpy(dbp->parms.db2.osuser, ptr,len + 1);
			FIL_DBG(("read usr:<%s>\n", dbp->parms.db2.osuser));

			/*
			**	OSPASS
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, OSPASS, OSPASS_SIZE))
				READ_ERROR(RIS_E_READ_NO_OSPASS);

			ptr = buffer + OSPASS_SIZE;
			if (*ptr)
			{
				len = strlen(ptr);
				if (len != RIS_MAX_PASSWD_SIZE - 1) 
					READ_ERROR(RIS_E_READ_INV_OSPASS);
			}
			memcpy(dbp->parms.db2.ospass, ptr, RIS_MAX_PASSWD_SIZE);
			FIL_DBG(("read ospass:<%s>\n", dbp->parms.db2.ospass));

			/*
			**	ARCH
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, ARCH, ARCH_SIZE))
				READ_ERROR(RIS_E_READ_NO_ARCH);

			ptr = buffer + ARCH_SIZE;
			if (!RIScco_valid_db2_arch(ptr))
				READ_ERROR(RIS_E_READ_INV_ARCH);
			
			strcpy(dbp->parms.db2.arch, ptr);
			FIL_DBG(("read arch:<%s>\n", dbp->parms.db2.arch));

			/*
			**	OS
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, OS, OS_SIZE))
				READ_ERROR(RIS_E_READ_NO_OS);

			ptr = buffer + OS_SIZE;
			if (!RIScco_valid_db2_os(ptr))
				READ_ERROR(RIS_E_READ_INV_OS);
			
			strcpy(dbp->parms.db2.os, ptr);
			FIL_DBG(("read os:<%s>\n", dbp->parms.db2.os));

			/*
			**	NET_PROTOCOL
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, NET_PROTOCOL, NET_PROTOCOL_SIZE))
				READ_ERROR(RIS_E_READ_NO_NET_PROTOCOL);

			ptr = buffer + NET_PROTOCOL_SIZE;
			if (!RIScco_valid_db2_net_protocol(ptr))
				READ_ERROR(RIS_E_READ_INV_NET_PROTOCOL);
			
			strcpy(dbp->parms.db2.net_protocol, ptr);
			FIL_DBG(("read net_protocol:<%s>\n", dbp->parms.db2.net_protocol));

			/*
			**	ENV
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, ENV, ENV_SIZE))
				READ_ERROR(RIS_E_READ_NO_ENV);

			ptr = buffer + ENV_SIZE;
			if (!RIScco_valid_db2_env(ptr,  dbp->parms.db2.net_protocol))
				READ_ERROR(RIS_E_READ_INV_ENV);
			
			strcpy(dbp->parms.db2.env, ptr);
			FIL_DBG(("read env:<%s>\n", dbp->parms.db2.env));

			/*
			**	HOST_PROGRAM
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, HOST_PROGRAM, HOST_PROGRAM_SIZE))
				READ_ERROR(RIS_E_READ_NO_HOST_PROGRAM);

			ptr = buffer + HOST_PROGRAM_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_HOST_PROGRAM_SIZE)
			{
				READ_ERROR(RIS_E_READ_INV_HOST_PROGRAM);
			}
			else if (len == 1)
			{
				if (!strcmp(dbp->parms.db2.net_protocol,PROTOCOL_DEF_LU))
				{
					READ_ERROR(RIS_E_READ_INV_HOST_PROGRAM);
				}
				dbp->parms.db2.host_program[0] = '\0';
			}
			else
			{
				memcpy(dbp->parms.db2.host_program, ptr,len );
			}
			FIL_DBG(("read host_program:<%s>\n",
				STRING(dbp->parms.db2.host_program)));

			/*
			**	RIS_LU
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, RIS_LU, RIS_LU_SIZE))
				READ_ERROR(RIS_E_READ_NO_RIS_LU);

			ptr = buffer + RIS_LU_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_LU_NAME_SIZE)
			{

				READ_ERROR(RIS_E_READ_INV_RIS_LU);
			}
			else if (len == 1)
			{
				if (!strcmp(dbp->parms.db2.net_protocol,PROTOCOL_DEF_LU))
				{
					READ_ERROR(RIS_E_READ_INV_RIS_LU);
				}
				dbp->parms.db2.ris_lu[0] = '\0';
			}
			else
			{
				memcpy(dbp->parms.db2.ris_lu, ptr,len );
			}
			FIL_DBG(("read ris lu:<%s>\n", STRING(dbp->parms.db2.ris_lu)));

			/*
			**	HOST_LU
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, HOST_LU, HOST_LU_SIZE))
				READ_ERROR(RIS_E_READ_NO_HOST_LU);

			ptr = buffer + HOST_LU_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_LU_NAME_SIZE)
			{
				READ_ERROR(RIS_E_READ_INV_HOST_LU);
			}
			else if (len == 1)
			{
				if (!strcmp(dbp->parms.db2.net_protocol,PROTOCOL_DEF_LU))
				{
					READ_ERROR(RIS_E_READ_INV_HOST_LU);
				}
				dbp->parms.db2.host_lu[0] = '\0';
			}
			else
			{
				memcpy(dbp->parms.db2.host_lu, ptr,len );
			}
			FIL_DBG(("read host lu:<%s>\n", STRING(dbp->parms.db2.host_lu)));

			/*
			**	MODE
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, MODE, MODE_SIZE))
				READ_ERROR(RIS_E_READ_NO_MODE);

			ptr = buffer + MODE_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_MODE_NAME_SIZE)
			{
				READ_ERROR(RIS_E_READ_INV_MODE);
			}
			else if (len == 1)
			{
				if (!strcmp(dbp->parms.db2.net_protocol,PROTOCOL_DEF_LU))
				{
					READ_ERROR(RIS_E_READ_INV_MODE);
				}
				dbp->parms.db2.mode[0] = '\0';
			}
			else
			{
				memcpy(dbp->parms.db2.mode, ptr,len );
			}
			FIL_DBG(("read mode:<%s>\n", STRING(dbp->parms.db2.mode)));

			/*
			**	GROUP
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, GROUP, GROUP_SIZE))
				READ_ERROR(RIS_E_READ_NO_GROUP);

			ptr = buffer + GROUP_SIZE;
			if ((len = strlen(ptr)) > RIS_MAX_GROUP_SIZE)
			{
				READ_ERROR(RIS_E_READ_INV_GROUP);
			}
			else if (!len)
			{
				dbp->parms.db2.group[0] = '\0';
			}
			else
			{
				memcpy(dbp->parms.db2.group, ptr, len);
			}
			FIL_DBG(("read group:<%s>\n", STRING(dbp->parms.db2.group)));

            /*
            **  NODE
            */
            if ((buffer = read_next_line()) == NULL)
                LONGJMP(RIS_E_UNEXPECTED_EOF);

            if (strncmp(buffer, NODE, NODE_SIZE))
                READ_ERROR(RIS_E_READ_NO_NODE);

            ptr = buffer + NODE_SIZE;
            if ((len = strlen(ptr) +1) > RIS_MAX_ID_SIZE)
            {
                READ_ERROR(RIS_E_READ_INV_NODE);
            }
            else if (len == 1)
            {
                if (!strcmp(dbp->parms.db2.net_protocol,PROTOCOL_DEF_TCP))
                {
                    READ_ERROR(RIS_E_READ_INV_NODE);
                }
                dbp->parms.db2.node[0] = '\0';
            }
            else
            {
                memcpy(dbp->parms.db2.node, ptr, len);
            }
            FIL_DBG(("read node:<%s>\n", STRING(dbp->parms.db2.node)));

            /*
            **  PORT
            */
            if ((buffer = read_next_line()) == NULL)
                LONGJMP(RIS_E_UNEXPECTED_EOF);

            if (strncmp(buffer, PORT, PORT_SIZE))
                READ_ERROR(RIS_E_READ_NO_PORT);

            ptr = buffer + PORT_SIZE;

            if (strlen(ptr) > 0)
            {
                portnum = ptr ;
                while (*portnum && RIScom_isdigit(*portnum)) portnum++;
                if (*portnum)
                    READ_ERROR(RIS_E_READ_INV_PORT);

                dbp->parms.db2.port = (unsigned short)atoi(ptr);
            }
            FIL_DBG(("read port:%d\n", dbp->parms.db2.port));

			break;
	
		case '4':
			/*
			**	DICT_DBNAME	
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, RIS_DICT_DBNAME, RIS_DICT_DBNAME_SIZE))
				READ_ERROR(RIS_E_READ_NO_DICT_DBNAME);

			ptr = buffer + RIS_DICT_DBNAME_SIZE;
			if ((len = strlen(ptr) + 1) == 1 || len 
						> RIS_MAX_OS400_DIC_DBNAME_SIZE)
				READ_ERROR(RIS_E_READ_INV_DICT_DBNAME);

			strcpy(dbp->parms.os400.ris_dict_dbname, ptr);
			FIL_DBG(("read ris_dict_dbname:<%s>\n", dbp->parms.os400.ris_dict_dbname));

			/*
			**	OSUSER 
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);
			if (strncmp(buffer, OSUSER, OSUSER_SIZE))
				READ_ERROR(RIS_E_READ_NO_OSUSER);

			ptr = buffer + OSUSER_SIZE;
			if ((len = strlen(ptr)) == 0 || len > RIS_MAX_ID_SIZE - 1)
				READ_ERROR(RIS_E_READ_INV_OSUSER);

			memcpy(dbp->parms.os400.osuser, ptr,len + 1);
			FIL_DBG(("read osusr:<%s>\n", dbp->parms.os400.osuser));

			/*
			**	OSPASS
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, OSPASS, OSPASS_SIZE))
				READ_ERROR(RIS_E_READ_NO_OSPASS);

			ptr = buffer + OSPASS_SIZE;
			if (*ptr)
			{
				len = strlen(ptr);
				if (len != RIS_MAX_PASSWD_SIZE - 1) 
					READ_ERROR(RIS_E_READ_INV_OSPASS);
			}
			memcpy(dbp->parms.os400.ospass, ptr, RIS_MAX_PASSWD_SIZE);
			FIL_DBG(("read ospass:<%s>\n", dbp->parms.os400.ospass));

			/*
			**	NET_PROTOCOL
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, NET_PROTOCOL, NET_PROTOCOL_SIZE))
				READ_ERROR(RIS_E_READ_NO_NET_PROTOCOL);

			ptr = buffer + NET_PROTOCOL_SIZE;
			if (!RIScco_valid_os400_net_protocol(ptr))
				READ_ERROR(RIS_E_READ_INV_NET_PROTOCOL);
			
			strcpy(dbp->parms.os400.net_protocol, ptr);
			FIL_DBG(("read net_protocol:<%s>\n", dbp->parms.os400.net_protocol));


			/*
			**	HOST_PROGRAM
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, HOST_PROGRAM, HOST_PROGRAM_SIZE))
				READ_ERROR(RIS_E_READ_NO_HOST_PROGRAM);

			ptr = buffer + HOST_PROGRAM_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_OS400_HOST_PROGRAM_SIZE)
			{
				READ_ERROR(RIS_E_READ_INV_HOST_PROGRAM);
			}
			else if (len == 1)
			{
				if (!strcmp(dbp->parms.os400.net_protocol,PROTOCOL_DEF_LU))
				{
					READ_ERROR(RIS_E_READ_INV_HOST_PROGRAM);
				}
				dbp->parms.os400.host_program[0] = '\0';
			}
			else
			{
				memcpy(dbp->parms.os400.host_program, ptr,len );
			}
			FIL_DBG(("read host_program:<%s>\n",
				STRING(dbp->parms.os400.host_program)));

			/*
			**	RIS_LU
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, RIS_LU, RIS_LU_SIZE))
				READ_ERROR(RIS_E_READ_NO_RIS_LU);

			ptr = buffer + RIS_LU_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_LU_NAME_SIZE)
			{
				READ_ERROR(RIS_E_READ_INV_RIS_LU);
			}
			else if (len == 1)
			{
				if (!strcmp(dbp->parms.os400.net_protocol,PROTOCOL_DEF_LU))
				{
					READ_ERROR(RIS_E_READ_INV_RIS_LU);
				}
				dbp->parms.os400.ris_lu[0] = '\0';
			}
			else
			{
				memcpy(dbp->parms.os400.ris_lu, ptr,len );
			}
			FIL_DBG(("read ris lu:<%s>\n", STRING(dbp->parms.os400.ris_lu)));

			/*
			**	HOST_LU
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, HOST_LU, HOST_LU_SIZE))
				READ_ERROR(RIS_E_READ_NO_HOST_LU);

			ptr = buffer + HOST_LU_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_LU_NAME_SIZE)
			{
				READ_ERROR(RIS_E_READ_INV_HOST_LU);
			}
			else if (len == 1)
			{
				if (!strcmp(dbp->parms.os400.net_protocol,PROTOCOL_DEF_LU))
				{
					READ_ERROR(RIS_E_READ_INV_HOST_LU);
				}
				dbp->parms.os400.host_lu[0] = '\0';
			}
			else
			{
				memcpy(dbp->parms.os400.host_lu, ptr,len );
			}
			FIL_DBG(("read host lu:<%s>\n", STRING(dbp->parms.os400.host_lu)));

			/*
			**	MODE
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, MODE, MODE_SIZE))
				READ_ERROR(RIS_E_READ_NO_MODE);

			ptr = buffer + MODE_SIZE;
			if ((len = strlen(ptr) + 1) > RIS_MAX_MODE_NAME_SIZE)
			{
				READ_ERROR(RIS_E_READ_INV_MODE);
			}
			else if (len == 1)
			{
				if (!strcmp(dbp->parms.os400.net_protocol,PROTOCOL_DEF_LU))
				{
					READ_ERROR(RIS_E_READ_INV_MODE);
				}
				dbp->parms.os400.mode[0] = '\0';
			}
			else
			{
				memcpy(dbp->parms.os400.mode, ptr,len );
			}
			FIL_DBG(("read mode:<%s>\n", STRING(dbp->parms.os400.mode)));

			/*
			**	GROUP
			*/
			if ((buffer = read_next_line()) == NULL)
				LONGJMP(RIS_E_UNEXPECTED_EOF);

			if (strncmp(buffer, GROUP, GROUP_SIZE))
				READ_ERROR(RIS_E_READ_NO_GROUP);

			ptr = buffer + GROUP_SIZE;
			if ((len = strlen(ptr)) > RIS_MAX_GROUP_SIZE)
			{
				READ_ERROR(RIS_E_READ_INV_GROUP);
			}
			else if (!len)
			{
				dbp->parms.os400.group[0] = '\0';
			}
			else
			{
				memcpy(dbp->parms.os400.group, ptr, len);
			}
			FIL_DBG(("read group:<%s>\n", STRING(dbp->parms.os400.group)));

            /*
            **  NODE
	    */
            if ((buffer = read_next_line()) == NULL)
                LONGJMP(RIS_E_UNEXPECTED_EOF);

            if (strncmp(buffer, NODE, NODE_SIZE))
                READ_ERROR(RIS_E_READ_NO_NODE);

            ptr = buffer + NODE_SIZE;
            if ((len = strlen(ptr) +1) > RIS_MAX_ID_SIZE)
            {
                READ_ERROR(RIS_E_READ_INV_NODE);
            }
            else if (len == 1)
            {
                if (!strcmp(dbp->parms.os400.net_protocol,PROTOCOL_DEF_TCP))
                {
                    READ_ERROR(RIS_E_READ_INV_NODE);
                }
                dbp->parms.os400.node[0] = '\0';
            }
            else
            {
                memcpy(dbp->parms.os400.node, ptr, len);
            }
            FIL_DBG(("read node:<%s>\n", STRING(dbp->parms.os400.node)));

            /*
            **  PORT
	    */
            if ((buffer = read_next_line()) == NULL)
                LONGJMP(RIS_E_UNEXPECTED_EOF);

            if (strncmp(buffer, PORT, PORT_SIZE))
                READ_ERROR(RIS_E_READ_NO_PORT);

            ptr = buffer + PORT_SIZE;

            if (strlen(ptr) > 0)
            {
                portnum = ptr ;
                while (*portnum && RIScom_isdigit(*portnum)) portnum++;

                if (*portnum)
                    READ_ERROR(RIS_E_READ_INV_PORT);

                dbp->parms.os400.port = (unsigned short)atoi(ptr);
            }
            FIL_DBG(("read port:%d\n", dbp->parms.os400.port));

			break;
		case 'R':
			break;
	}
}

/******************************************************************************/

extern void RISfil_read_schema_file(
	char			*filename,
	int				checksum_flag)
{
	int				sts;
	int				len;
	char			*buffer;
	char			*schname;
	unsigned short	dbid;
	fildb_list			**db_listp; 
	fildb_list			*dbp;
	filsch_list		**schema_listp; 
	filsch_list		*schemap;

	FIL_DBG(("RISfil_read_schema_file(filename:<%s> checksum_flag:%d)\n",
		filename, checksum_flag));

	RISfil_timestamp = 0;
	RISfil_schema_list = NULL;
	RISfil_db_list = NULL;

	if ((RISfil_fp = RIScom_fopen(filename, "r")) == NULL)
	{
		sprintf(RIS_ERRMSGC, "\nCannot open '%s' ", filename);
		LONGJMP(RIS_E_CANT_OPEN_SCHEMA_FILE_READ);
	}
	
	sts = SETJMP();
	if (sts)
	{
		RESETJMP();
		RIScom_fclose(RISfil_fp);
		LONGJMP(sts);
	}

	if (checksum_flag)
	{
		RISfil_verify_checksum();
	}

	schema_listp = &RISfil_schema_list;
	db_listp = &RISfil_db_list;
	RISfil_linenum = 0;

	if ((buffer = read_next_line()) == NULL)
	{
		/*
		**	Empty file, that's ok.
		*/
		RESETJMP();

		RIScom_fclose(RISfil_fp);
		return;
	}

	/*
	**	CHECKSUM
	*/
	if (strncmp(buffer, CHECKSUM, CHECKSUM_SIZE))
	{
		if (checksum_flag)
		{
			READ_ERROR(RIS_E_READ_NO_CHECKSUM);
		}
	}
	else
	{
		/*
		**	Skip over checksum entry, get the next line.
		*/
		if ((buffer = read_next_line()) == NULL)
			LONGJMP(RIS_E_UNEXPECTED_EOF);
	}

	/*
	**	TIMESTAMP
	*/
	if (strncmp(buffer, TIMESTAMP, TIMESTAMP_SIZE))
		READ_ERROR(RIS_E_READ_NO_TIMESTAMP);
	RISfil_timestamp = atoi(buffer + TIMESTAMP_SIZE);

	while ((buffer = read_next_line()) != NULL)
	{
		/*
		**	Separator line
		*/
		if (buffer[0] != '-')
			READ_ERROR(RIS_E_READ_NO_SEPARATOR);

		/*
		**	ID - Is it a schema or a db
		*/
		if ((buffer = read_next_line()) == NULL)
			LONGJMP(RIS_E_UNEXPECTED_EOF);

		if (strncmp(buffer, SCHNAME, SCHNAME_SIZE) == 0)
		{
			schname = buffer + SCHNAME_SIZE;
			if ((len = strlen(schname) + 1) == 1 || len > RIS_MAX_ID_SIZE)
				READ_ERROR(RIS_E_READ_INV_SCHNAME);

			schemap = ALLOCT(filsch_list);
			schemap->schemap = ALLOCT(risschema);
			memcpy(schemap->schemap->schname, schname,len );
			FIL_DBG(("\nread schname:<%s>\n", schemap->schemap->schname));
			read_schema(schemap->schemap);
			
			(*schema_listp) = schemap;
			schema_listp = &(schemap->next);
		}
		else if (strncmp(buffer, DBID, DBID_SIZE) == 0)
		{
			if ((dbid = (unsigned short)atoi(buffer + DBID_SIZE)) == 0)
				READ_ERROR(RIS_E_READ_INV_DBID);

			dbp = ALLOCT(fildb_list);
			dbp->dbp = ALLOCT(risdb);
			dbp->dbp->dbid = dbid;
			FIL_DBG(("\nread dbid:%d\n", dbp->dbp->dbid));
			read_db(dbp->dbp);

			(*db_listp) = dbp;
			db_listp = &(dbp->next);
		}
		else
		{
			READ_ERROR(RIS_E_READ_NO_SCHNAME_DBID);
		}
	}

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		strcpy(RIS_ERRMSGC, "The error occured while reading the schema file.");
		LONGJMP(sts);
	}
	RISfil_verify_db_list();
	RISfil_verify_schema_list();

    RISfil_reset_master_db_ptrs();
    RISfil_reset_master_sch_ptrs();

	RESETJMP();

	RESETJMP();

	RIScom_fclose(RISfil_fp);
}

/******************************************************************************/

/* Do not alter this SPC information: $Revision: 1.3.45.1 $ */
/*
**	NAME:							appgetfl.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	Changed 'usr' to 'schowner' in ris_schema_info  structure
**  -- Shiva 11/11/93
**
**	Modified get_schema() for v5 fields in ris_schema_info structure
**  -- Jin Jing 12/15/93
**
**	Added ris_dict_dbname to  get_db() for os400
**  --  Linda Wang 03/31/94
**  
**  Changes made to add MSSQL data server 
**  --  Radha Shivakumar 10/24/94
**
**	Added support for INTERNATIONALIZATION
**	--	Mark Boswell 10/94
**
**	Changed location of debug statement.  Causing core dump.  
**	--	Paula Blohm	01/95
*/

#include "risapp.h"
#include "risasync.h"
#include "riscom.h"
#include "rismem.h"
#include "riscom_macro.h"
#include "risdebug.h"
#include "ris_err.h"

static  char	*buf_ptr;
static  char	end_of_buffer;
static  int	  alloc_mode;

/*
**	FUNCTIONS
*/

static void *alloc(int size)
{
	void *ptr = 0;

	switch (alloc_mode)
	{
		case USE_ALLOCB:
			ptr = ALLOCB(size);
			break;

		case USE_MALLOC:
			ptr = calloc(1, size);
			if (!ptr)
			{
				LONGJMP(RIS_E_MALLOC_FAILED);
			}
			break;

		default:
			LONGJMP(RIS_E_INTERNAL_ERROR);
	}

	return ptr;
}

/******************************************************************************/

static char *get_next_string()
{
	char		*return_ptr;

#ifdef WIN32
	wchar_t	*tmp_buf;
#else
	char	*tmp_buf;
	tmp_buf = buf_ptr;
#endif
	APP_DBG(("get_next_string()\n"));

#ifdef WIN32
	RIScom_multiwide(&RISwide_ptr, &buf_ptr, &RISwide_size, MULTITOWIDE, 0);
	tmp_buf = RISwide_ptr;
#endif
	if ( *tmp_buf == WIDECHAR('\0') )
	{
		if (RIS_read->buf.string.more_to_follow)
		{
			RISapp_opcode_to_buf(RISCLI_GET_SCHEMA_FILE_CODE, SYNC_MODE);
			RISapp_send_rec();
			buf_ptr = RIS_read->buf.string.data;
#ifdef WIN32
	        RIScom_multiwide(&tmp_buf, &buf_ptr, &RISwide_size,
		                         MULTITOWIDE, 0);
#else
			tmp_buf = buf_ptr;
#endif
		}
		else
		{
			end_of_buffer = 1;
			APP_DBG(("get_next_string: returning 0\n"));
			return buf_ptr;
		}
	}

	return_ptr = buf_ptr;

	while(*tmp_buf && *tmp_buf != WIDECHAR('\n'))
	{
		tmp_buf++;
		buf_ptr = RIScom_charnext ( buf_ptr );
	}

	if (*tmp_buf == WIDECHAR('\n'))
	{
		*buf_ptr = WIDECHAR('\0');
		buf_ptr++;
	}

	APP_DBG(("get_next_string: returning <%s>\n", return_ptr));
	return return_ptr;
}

/******************************************************************************/

static char *get_filename(
	char	**filenamep)
{
	int		len;
	char	*str;

	APP_DBG(("get_filename(filenamep:0x%x)\n", filenamep));

	len = strlen((str = get_next_string())) + 1;
	(*filenamep) = alloc(len);
	memcpy((*filenamep), str, len);

	str = get_next_string();
	APP_DBG(("get_filename: returning <%s>\n", str));
	return str; 
}

/******************************************************************************/

static char *get_db(
	ris_db_info	**dbp,
	int			dbid)
{
	int		i;
	int		file_dbid;
	char	*str;

	APP_DBG(("get_db(dbp:0x%x dbid:%d)\n", dbp, dbid));
	file_dbid = atoi(get_next_string());
	if (dbid != -1 && dbid != file_dbid)
	{
		/*
		**	If a valid dbid was passed in and it doesn't match,
		**	skip the db.
		*/
		(*dbp) = 0;
		while(1)
		{
			str = get_next_string();
			if (end_of_buffer || !strcmp(str, "DB") || !strcmp(str, "SCHEMA"))
				break;
		}
	}
	else
	{
		(*dbp) = alloc(sizeof(ris_db_info));
		(*dbp)->dbid = (unsigned short)file_dbid;
		(*dbp)->dtype = *get_next_string();
		strcpy((*dbp)->dbname, get_next_string());
		(*dbp)->ostype = *get_next_string();

		for(i = 0; i < RIS_MAX_PROTOCOLS; i++)
		{
			str = get_next_string();
			(*dbp)->pathways[i].protocol = *str;
			strcpy((*dbp)->pathways[i].netaddr, get_next_string());
		}

		switch((*dbp)->dtype)
		{
			case 'X':
				strcpy((*dbp)->info.ifx.dir, get_next_string());
				strcpy((*dbp)->info.ifx.sqlexec, get_next_string());
				strcpy((*dbp)->info.ifx.dbtemp, get_next_string());
				strcpy((*dbp)->info.ifx.tbconfig, get_next_string());
				break;

			case 'O':
				strcpy((*dbp)->info.ora.osuser, get_next_string());
				strcpy((*dbp)->info.ora.ospass, get_next_string());
				strcpy((*dbp)->info.ora.dir, get_next_string());
				break;

			case 'I':
				strcpy((*dbp)->info.igs.dir, get_next_string());
				break;

			case 'D':
				strcpy((*dbp)->info.db2.osuser, get_next_string());
				strcpy((*dbp)->info.db2.ospass, get_next_string());
				strcpy((*dbp)->info.db2.arch, get_next_string());
				strcpy((*dbp)->info.db2.os, get_next_string());
				strcpy((*dbp)->info.db2.env, get_next_string());
				strcpy((*dbp)->info.db2.net_protocol, get_next_string());
				strcpy((*dbp)->info.db2.host_program, get_next_string());
				strcpy((*dbp)->info.db2.ris_lu, get_next_string());
				strcpy((*dbp)->info.db2.host_lu, get_next_string());
				strcpy((*dbp)->info.db2.mode, get_next_string());
				strcpy((*dbp)->info.db2.group, get_next_string());
				strcpy((*dbp)->info.db2.node, get_next_string());
				(*dbp)->info.db2.port = (unsigned short)atoi(get_next_string());
				break;

			case '4':
				strcpy((*dbp)->info.os400.osuser, get_next_string());
				strcpy((*dbp)->info.os400.ospass, get_next_string());
				/*
				strcpy((*dbp)->info.os400.os, get_next_string());
				*/
				strcpy((*dbp)->info.os400.net_protocol, get_next_string());
				strcpy((*dbp)->info.os400.host_program, get_next_string());
				strcpy((*dbp)->info.os400.ris_lu, get_next_string());
				strcpy((*dbp)->info.os400.host_lu, get_next_string());
				strcpy((*dbp)->info.os400.mode, get_next_string());
				strcpy((*dbp)->info.os400.group, get_next_string());
				strcpy((*dbp)->info.os400.node, get_next_string());
				strcpy((*dbp)->info.os400.ris_dict_dbname, get_next_string());
				(*dbp)->info.os400.port = (unsigned short)atoi(get_next_string());
				break;

			case 'R':
				break;

			case 'Y':
				strcpy((*dbp)->info.syb.osuser, get_next_string());
				strcpy((*dbp)->info.syb.ospass, get_next_string());
				strcpy((*dbp)->info.syb.dir, get_next_string());
				strcpy((*dbp)->info.syb.dsquery, get_next_string());
				strcpy((*dbp)->info.syb.sybifile, get_next_string());
				break;

            case 'M':
                strcpy((*dbp)->info.mssql.osuser, get_next_string());
                strcpy((*dbp)->info.mssql.ospass, get_next_string());
                strcpy((*dbp)->info.mssql.dir, get_next_string());
                strcpy((*dbp)->info.mssql.dsquery, get_next_string());
                strcpy((*dbp)->info.mssql.mssqlifile, get_next_string());
		break;

		}
		str = get_next_string();
	}

	APP_DBG(("get_db: returning <%s>\n", str));
	return str;
}

/******************************************************************************/

static char *get_schema(
	ris_schema_info		**schemap,
	ris_grantee_info	**granteep,
	char				*schname)
{
	char	*str;
	char	*schname_from_file;

	APP_DBG(("get_schema(schemap:0x%x granteep:0x%x schname:<%s>)\n",
		schemap, granteep, schname ? schname : "NULL"));
	schname_from_file = get_next_string();
	if (schname && strcmp(schname, schname_from_file))
	{
		/*
		**	If a schema name was passed in and it doesn't match,
		**	skip the schema.
		*/
		if (schemap)
		{
			(*schemap) = 0;
		}
		if (granteep)
		{
			(*granteep) = 0;
		}

		while(1)
		{
			str = get_next_string();
			if (end_of_buffer || !strcmp(str, "DB") || !strcmp(str, "SCHEMA"))
				break;
		}
	}
	else
	{
		if (schemap)
		{
			(*schemap) = alloc(sizeof(ris_schema_info));
			strcpy((*schemap)->schname, schname_from_file);
			strcpy((*schemap)->schowner, get_next_string());
			strcpy((*schemap)->schownpass, get_next_string());
			strcpy((*schemap)->dictowner, get_next_string());
			(*schemap)->secure = (unsigned short)atoi(get_next_string());
			(*schemap)->server_version_major =
				(unsigned short)atoi(get_next_string());
			(*schemap)->server_version_feature =
				(unsigned short)atoi(get_next_string());
			(*schemap)->dbid = (unsigned short)atoi(get_next_string());

			APP_DBG(("get_schema: (*schemap)->dictowner: <%s>\n",
				(*schemap)->dictowner));
		}
		else
		{
			/* we've read the name */

			/* skip the schowner */
			get_next_string();

			/* skip the schownpass */
			get_next_string();

			/* skip the dictowner */
			get_next_string();

			/* skip the secure */
			get_next_string();

			/* skip the major */
			get_next_string();

			/* skip the feature */
			get_next_string();

			/* skip the dbid */
			get_next_string();
		}


		if (granteep)
		{
			while(1)
			{
				str = get_next_string();
				if (end_of_buffer || !strcmp(str,"SCHEMA") || !strcmp(str,"DB"))
					break;

				(*granteep) = alloc(sizeof(ris_grantee_info));
				strcpy((*granteep)->schname, schname_from_file);
				strcpy((*granteep)->grantee, str);
				granteep = &((*granteep)->next);
			}
		}
		else
		{
			while(1)
			{
				str = get_next_string();
				if (end_of_buffer || !strcmp(str,"SCHEMA") || !strcmp(str,"DB"))
					break;
			}
		}
	}

	APP_DBG(("get_schema: returning <%s>\n", str));
	return str;
}

/******************************************************************************/

extern void RISapp_get_schfile(char **filenamep, ris_db_info **dbp, ris_schema_info **schemap, ris_grantee_info **granteep, int mem_mode)
{
	char			*str;

	APP_DBG(("RISapp_get_schfile(filename:0x%x dbp:0x%x schemap:0x%x "
		"granteep:0x%x mem_mode:%s)\n", filenamep, dbp, schemap, granteep,
		(mem_mode == USE_ALLOCB) ? "USE_ALLOCB" :
			((mem_mode == USE_MALLOC) ? "USE_MALLOC" : "UNKNOWN")));

	if (filenamep)
	{
		*filenamep = NULL;
	}
	if (dbp)
	{
		*dbp = NULL;
	}
	if (schemap)
	{
		*schemap = NULL;
	}
	if (granteep)
	{
		*granteep = NULL;
	}
	alloc_mode = mem_mode;

	RISapp_opcode_to_buf(RISCLI_GET_SCHEMA_FILE_CODE, SYNC_MODE);
	RISapp_send_rec();

	buf_ptr = RIS_read->buf.string.data;
	end_of_buffer = 0;

	str = get_next_string();
	while(!end_of_buffer)
	{
		if (filenamep && !strcmp(str, "FILENAME"))
		{
			str = get_filename(filenamep);
		}
		else if ((schemap || granteep) && !strcmp(str, "SCHEMA"))
		{
			str = get_schema(schemap, granteep, NULL);
			if (schemap)
			{
				schemap = &((*schemap)->next);
			}
			if (granteep)
			{
				while(*granteep)
				{
					granteep = &((*granteep)->next);
				}
			}
		}
		else if (dbp && !strcmp(str, "DB"))
		{
			str = get_db(dbp, -1);
			dbp = &((*dbp)->next);
		}
		else /* skipping */
		{
			str = get_next_string();
		}
	}
	APP_DBG(("RISapp_get_schfile: complete\n"));
}

/******************************************************************************/

extern void RISapp_get_schema(char *schname, ris_schema_info **schemap, ris_db_info **dbp, ris_grantee_info **granteep, int mem_mode)
{
	char				*str;
	ris_schema_info		*schema;
	ris_db_info			*db;

	APP_DBG(("RISapp_get_schema(schname:<%s> schemap:0x%x dbp:0x%x "
		"granteep:0x%xmem_mode:%s)\n", schname, schemap, dbp, granteep,
		(mem_mode == USE_ALLOCB) ? "USE_ALLOCB" :
		((mem_mode == USE_MALLOC) ? "USE_MALLOC" : "UNKNOWN")));

	if (schemap)
	{
		*schemap = NULL;
	}
	if (dbp)
	{
		*dbp = NULL;
	}
	if (granteep)
	{
		*granteep = NULL;
	}
	alloc_mode = mem_mode;

	RISapp_opcode_to_buf(RISCLI_GET_SCHEMA_FILE_CODE, SYNC_MODE);
	RISapp_send_rec();

	schema = NULL;
	db = NULL;
	buf_ptr = RIS_read->buf.string.data;
	end_of_buffer = 0;
	str = get_next_string();
	while(!end_of_buffer)
	{
		if (!strcmp(str, "SCHEMA"))
		{
			str = get_schema(&schema, granteep, schname);
			if (schema)
			{
				/*
				**	We got the schema
				*/
				break;
			}
		}
		else if (!strcmp(str, "DB"))
		{
			break;
		}
		else /* skipping */
		{
			str = get_next_string();
		}
	}

	if (schema == NULL)
	{
		APP_DBG(("RISapp_get_schema: Could not find the schema.\n"));
		LONGJMP(RIS_E_UNKNOWN_SCHEMA);
	}

	/*
	**	if we found the schema and we want the db info
	*/
	if (schema && dbp)
	{
		while(!end_of_buffer)
		{
			if (!strcmp(str, "DB"))
			{
				str = get_db(&db, schema->dbid);
				if (db) break;
			}
			else /* skipping */
			{
				str = get_next_string();
			}
		}
	}

	if (schemap)
	{
		*schemap = schema;
	}
	else if (schema && alloc_mode == USE_MALLOC)
	{
		free(schema);
	}

	if (dbp)
	{
		*dbp = db;
	}
	else if (db && alloc_mode == USE_MALLOC)
	{
		free(db);
	}

	APP_DBG(("RISapp_get_schema: complete\n"));
}

/******************************************************************************/

extern void RISapp_get_db(int dbid, ris_db_info **dbp, int mem_mode)
{
	char		*str;
	ris_db_info	*db;

	APP_DBG(("RISapp_get_db(dbid:%d dbp:0x%x mem_mode:%s)\n",
		dbid, dbp, (mem_mode == USE_ALLOCB) ? "USE_ALLOCB" :
		((mem_mode == USE_MALLOC) ? "USE_MALLOC" : "UNKNOWN")));

	alloc_mode = mem_mode;

	if (dbp)
	{
		*dbp = NULL;
	}

	RISapp_opcode_to_buf(RISCLI_GET_SCHEMA_FILE_CODE, SYNC_MODE);
	RISapp_send_rec();

	db = NULL;
	buf_ptr = RIS_read->buf.string.data;
	end_of_buffer = 0;
	str = get_next_string();
	while(!end_of_buffer)
	{
		if (!strcmp(str, "DB"))
		{
			str = get_db(&db, dbid);
			if (db) break;
		}
		else /* skipping */
		{
			str = get_next_string();
		}
	}

	if (db == NULL)
	{
		APP_DBG(("RISapp_get_schema: Could not find the db.\n"));
		LONGJMP(RIS_E_UNKNOWN_DB);
	}

	if (dbp)
	{
		*dbp = db;
	}
	else if (db && alloc_mode == USE_MALLOC)
	{
		free(db);
	}

	APP_DBG(("RISapp_get_db: complete\n"));
}

/******************************************************************************/

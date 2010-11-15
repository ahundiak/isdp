/* Do not alter this SPC information: $Revision: 1.5.3.1 $ */
/*
**	NAME:							intgtfil.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					9/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	01/95:	Changed the argument for RISapp_initialize from RIS_DEFAULT_LANGUAGE
**			to getenv("RIS_LANGUAGE").  Paula Blohm
*/

/*
**	INCLUDES
*/
#include <stdarg.h>
#include "intrface.h"
#include "risasync.h"
#include "risflags.h"
#if defined(__Sol2__) || defined(Soli)
#include "ris.h"
#endif

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define intgtfil_c
#include "appclear.prt"
#include "appcli.prt"
#include "appgetfl.prt"
#include "appid.prt"
#include "appinit.prt"
#include "comdebug.prt"
#include "comjmp.prt"
#include "comalloc.prt"
#include "interror.prt"
#include "intgtfil.prt"
#include "intrap.prt"
#include "sys.prt"
#include "sysalloc.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern void RISAPI RISXget_schema_info(
	char				*schname,
	ris_schema_info		**schemap,
	ris_db_info			**dbp,
	ris_grantee_info	**granteep)
{
	int				sts;
	static  short	stmt_id;

	INT_DBG(("RISget_schema_info(schname:<%s> schemap:0x%x dbp:0x%x "
		"granteep:0x%x)\n", schname?schname:"NULL", schemap, dbp, granteep));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "GET SCHEMA INFO\n");
		fprintf(RIS_RAP, "schname:0x%x\n", schname);
		if (schname)
		{
			fprintf(RIS_RAP, "*schname:%s\n", schname);
		}
		fprintf(RIS_RAP, "schemap:0x%x\n", schemap);
		fprintf(RIS_RAP, "dbp:0x%x\n", dbp);
		fprintf(RIS_RAP, "granteep:0x%x\n", granteep);
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	stmt_id = -1;

	if (RIS_client_died)
	{
		SET_RISCA(RIS_E_CLIENT_DIED);
		RISrap_return();
		RIS_RETURN();
	}

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		if (stmt_id != -1)
		{
			RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT, 
				SYNC_MODE);
		}
		SET_RISCA(sts);
		RISrap_return();
		RIS_RETURN();
	}

	if (!RIS_mem)
	{
		RISapp_initialize(getenv("RIS_LANGUAGE"));
	}
	if (!RIS_net)
	{
		RISapp_start_client();
	}

	stmt_id = RISapp_new_stmt(RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);

	RISapp_get_schema(schname, schemap, dbp, granteep, USE_MALLOC);

	RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT, SYNC_MODE);

	RESETJMP();

	INT_DBG(("RISget_schema_info: complete\n"));
	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/

extern void RISAPI RISXget_db_info(
	int			dbid,
	ris_db_info	**dbp)
{
	int				sts;
	static  short	stmt_id;

	INT_DBG(("RISget_db_info(dbid:%d dbp:0x%x)\n", dbid, dbp));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "GET DB INFO\n");
		fprintf(RIS_RAP, "dbid:%d\n", dbid);
		fprintf(RIS_RAP, "dbp:0x%x\n", dbp);
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	stmt_id = -1;

	if (RIS_client_died)
	{
		SET_RISCA(RIS_E_CLIENT_DIED);
		RISrap_return();
		RIS_RETURN();
	}

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		if (stmt_id != -1)
		{
			RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT, 
				SYNC_MODE);
		}
		SET_RISCA(sts);
		RISrap_return();
		RIS_RETURN();
	}

	if (!RIS_mem)
	{
		RISapp_initialize(getenv("RIS_LANGUAGE"));	
	}
	if (!RIS_net)
	{
		RISapp_start_client();
	}

	stmt_id = RISapp_new_stmt(RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);

	RISapp_get_db(dbid, dbp, USE_MALLOC);

	RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT, SYNC_MODE);

	RESETJMP();

	INT_DBG(("RISget_db_info: complete\n"));
	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/******************************************************************************/

extern void RISAPI RISXget_schema_file(
	char				**schema_filenamep,
	ris_db_info			**dblistp,
	ris_schema_info		**schlistp,
	ris_grantee_info	**granteep)
{
	int				sts;
	static  short	stmt_id;

	INT_DBG(("RISget_schema_file(schema_filenamep:0x%x dblistp:0x%x schlistp:0x%x granteep:0x%x\n", schema_filenamep, dblistp, schlistp, granteep));

	RIS_ENTER();

	RISrap_enter_BEGIN();
		fprintf(RIS_RAP, "GET SCHEMA FILE\n");
		fprintf(RIS_RAP, "schema_filenamep:0x%x\n", schema_filenamep);
		fprintf(RIS_RAP, "dblistp:0x%x\n", dblistp);
		fprintf(RIS_RAP, "schlistp:0x%x\n", schlistp);
		fprintf(RIS_RAP, "granteep:0x%x\n", granteep);
	RISrap_enter_END();

	RIS_CLEAR_ERROR();

	stmt_id = -1;

	if (RIS_client_died)
	{
		SET_RISCA(RIS_E_CLIENT_DIED);
		RISrap_return();
		RIS_RETURN();
	}

	if ((sts = SETJMP()) != 0)
	{
		RESETJMP();
		if (stmt_id != -1)
		{
			RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT, 
				SYNC_MODE);
		}
		SET_RISCA(sts);
		RISrap_return();
		RIS_RETURN();
	}

	if (!RIS_mem)
	{
		RISapp_initialize(getenv("RIS_LANGUAGE"));		
	}
	if (!RIS_net)
	{
		RISapp_start_client();
	}

	stmt_id = RISapp_new_stmt(RIS_DONT_CLEAR_FLAG, RIS_DYNAMIC_STMT);

	RISapp_get_schfile(schema_filenamep,dblistp,schlistp,granteep,USE_MALLOC);

	RISapp_clear(&stmt_id, DONT_SET_SQLCODE, DONT_CLEAR_CLIENT, SYNC_MODE);

	RESETJMP();

	INT_DBG(("RISget_schema_file: complete\n"));
	SET_RISCA(RIS_SUCCESS);
	RISrap_return();
	RIS_RETURN();
}

/*****************************************************************************

	SYNOPSIS 

	static void RISAPI RISfree_memory_extended(
		int	type,
		int	iMemoryMode,
		va_list	args)
        
    PARAMETERS

        NAME            ACCESS/DESCRIPTION (ACCESS: I=input, O=output, I/O=both)
        ----            --------------------------------------------------------

        type		(I)	Type of RIS structure to free:
					RIS_FREE_SCHEMA_INFO_MEMORY (from RISget_schema_info)
					RIS_FREE_DB_INFO_MEMORY (from RISget_db_info)
					RIS_FREE_SCHEMA_FILE_MEMORY (from RISget_schema_file)
					RIS_FREE_REPORT_ERROR_MEMORY
        iMemoryMode	(I)	How to free.  If USE_ALLOCB, SYS_FREE(); if
				USE_MALLOC, free().
        va_list		(I)	Variable list of thing[s] to free.  Pass NULL
				if the structure or string was not allocated.
					RIS_FREE_SCHEMA_INFO_MEMORY:
						ris_schema_info*
						ris_db_info*
						ris_grantee_info*
					RIS_FREE_DB_INFO_MEMORY:
						ris_db_info*
					RIS_FREE_SCHEMA_FILE_MEMORY:
						char*
						ris_db_info*
						ris_schema_info*
						ris_grantee_info*
					RIS_FREE_REPORT_ERROR_MEMORY:
						char*
        
    RETURN VALUE

	void
        
    DESCRIPTION

	This function frees several different types of RIS structures and
	strings.
        
    CHANGE HISTORY

        1996.09.17	Modified from the original version of RISXfree_memory.
			This function needs better error handling for out of
			range parameters.  (TR439601965)  (Alan Barksdale)

******************************************************************************/

static void RISAPI RISfree_memory_extended(
	int	type,
	int	iMemoryMode,
	va_list	args)
{
	INT_DBG(("%s,%d:begin RISfree_memory_extended\n", __FILE__, __LINE__));
	INT_DBG(("%s,%d:RISfree_memory_extended:type = %d, iMemoryMode = %d = %s\n",
		__FILE__, __LINE__, type, iMemoryMode,
		(iMemoryMode == USE_ALLOCB) ? "USE_ALLOCB" :
		((iMemoryMode == USE_MALLOC) ? "USE_MALLOC" : "UNKNOWN")));

	switch (type)
	{
		case RIS_FREE_SCHEMA_INFO_MEMORY:
		{
			ris_schema_info *tmp1=0,*tmp2=0,*tmp3=0;
			ris_db_info	*db1=0,*db2=0,*db3=0;
			ris_grantee_info	*g1=0,*g2=0,*g3=0;

			INT_DBG(("%s,%d:RISfree_memory_extended: ** RIS_FREE_SCHEMA_INFO_MEMORY **\n", __FILE__, __LINE__));
			INT_DBG(("%s,%d:RISfree_memory_extended: freeing ris_schema_info\n", __FILE__, __LINE__));
			tmp1 = va_arg(args,ris_schema_info *);
			if (tmp1 != 0)
			{
				for(tmp2=tmp1;tmp2;tmp2=tmp3)
				{
					tmp3 = tmp2->next;
					INT_DBG(("%s,%d:RISfree_memory_extended: 0x%x  ", __FILE__, __LINE__, tmp2));
					if(USE_ALLOCB == iMemoryMode) {
						SYS_FREE((char *)tmp2);
					} else if (USE_MALLOC == iMemoryMode) {
						free((char *)tmp2);
					}
					INT_DBG(("%s,%d:RISfree_memory_extended:freed 0x%x\n", __FILE__, __LINE__, tmp2));
				}
			}

			INT_DBG(("%s,%d:RISfree_memory_extended: freeing ris_db_info\n", __FILE__, __LINE__));
			db1 = va_arg(args,ris_db_info *);
			if (db1 != 0)
			{
				for(db2=db1;db2;db2=db3)
				{
					db3 = db2->next;
					INT_DBG(("%s,%d:RISfree_memory_extended: 0x%x  ", __FILE__, __LINE__, db2));
					if(USE_ALLOCB == iMemoryMode) {
						SYS_FREE((char *)db2);
					} else if (USE_MALLOC == iMemoryMode) {
						free((char *)db2);
					}
					INT_DBG(("%s,%d:RISfree_memory_extended:freed 0x%x\n", __FILE__, __LINE__, db2));
				}
			}

			INT_DBG(("%s,%d:RISfree_memory_extended: freeing ris_grantee_info\n", __FILE__, __LINE__));
			g1 = va_arg(args,ris_grantee_info *);
			if (g1 != 0)
			{
				for(g2=g1;g2;g2=g3)
				{
					g3 = g2->next;
					INT_DBG(("%s,%d:RISfree_memory_extended: 0x%x  ", __FILE__, __LINE__, g2));
					if(USE_ALLOCB == iMemoryMode) {
						SYS_FREE((char *)g2);
					} else if (USE_MALLOC == iMemoryMode) {
						free((char *)g2);
					}
					INT_DBG(("%s,%d:RISfree_memory_extended:freed 0x%x\n", __FILE__, __LINE__, g2));
				}
			}		
		}
		break;

		case RIS_FREE_DB_INFO_MEMORY:
		{
			ris_db_info	*db1=0,*db2=0,*db3=0;

			INT_DBG(("%s,%d:RISfree_memory_extended: ** RIS_FREE_DB_INFO_MEMORY **\n", __FILE__, __LINE__));
			INT_DBG(("%s,%d:RISfree_memory_extended: freeing ris_db_info\n", __FILE__, __LINE__));
			db1 = va_arg(args,ris_db_info *);
			if (db1 != 0)
			{
				for(db2=db1;db2;db2=db3)
				{
					db3 = db2->next;
					INT_DBG(("%s,%d:RISfree_memory_extended: 0x%x  ", __FILE__, __LINE__, db2));
					if(USE_ALLOCB == iMemoryMode) {
						SYS_FREE((char *)db2);
					} else if (USE_MALLOC == iMemoryMode) {
						free((char *)db2);
					}
					INT_DBG(("%s,%d:RISfree_memory_extended:freed 0x%x\n", __FILE__, __LINE__, db2));
				}
			}
		}
		break;

		case RIS_FREE_SCHEMA_FILE_MEMORY:
		{
			ris_schema_info *tmp1=0,*tmp2=0,*tmp3=0;
			ris_db_info	*db1=0,*db2=0,*db3=0;
			ris_grantee_info	*g1=0,*g2=0,*g3=0;
			char *c1 = 0;

			INT_DBG(("%s,%d:RISfree_memory_extended: ** RIS_FREE_SCHEMA_FILE_MEMORY **\n", __FILE__, __LINE__));
			INT_DBG(("%s,%d:RISfree_memory_extended: freeing schname\n", __FILE__, __LINE__));
			c1 = va_arg(args,char *);
			if (c1 != 0)
			{
					INT_DBG(("%s,%d:RISfree_memory_extended: 0x%x  ", __FILE__, __LINE__, c1));
					if(USE_ALLOCB == iMemoryMode) {
						SYS_FREE(c1);
					} else if (USE_MALLOC == iMemoryMode) {
						free(c1);
					}
					INT_DBG(("%s,%d:RISfree_memory_extended:freed 0x%x\n", __FILE__, __LINE__, c1));
			}

			INT_DBG(("%s,%d:RISfree_memory_extended: freeing ris_db_info\n", __FILE__, __LINE__));
			db1 = va_arg(args,ris_db_info *);
			if (db1 != 0)
			{
				for(db2=db1;db2;db2=db3)
				{
					db3 = db2->next;
					INT_DBG(("%s,%d:RISfree_memory_extended: 0x%x  ", __FILE__, __LINE__, db2));
					if(USE_ALLOCB == iMemoryMode) {
						SYS_FREE((char *)db2);
					} else if (USE_MALLOC == iMemoryMode) {
						free((char *)db2);
					}
					INT_DBG(("%s,%d:RISfree_memory_extended:freed 0x%x\n", __FILE__, __LINE__, db2));
				}
			}

			INT_DBG(("%s,%d:RISfree_memory_extended: freeing ris_schema_info\n", __FILE__, __LINE__));
			tmp1 = va_arg(args,ris_schema_info *);
			if (tmp1 != 0)
			{
				for(tmp2=tmp1;tmp2;tmp2=tmp3)
				{
					tmp3 = tmp2->next;
					INT_DBG(("%s,%d:RISfree_memory_extended: 0x%x  ", __FILE__, __LINE__, tmp2));
					if(USE_ALLOCB == iMemoryMode) {
						SYS_FREE((char *)tmp2);
					} else if (USE_MALLOC == iMemoryMode) {
						free((char *)tmp2);
					}
					INT_DBG(("%s,%d:RISfree_memory_extended:freed 0x%x\n", __FILE__, __LINE__, tmp2));
				}
			}


			INT_DBG(("%s,%d:RISfree_memory_extended: freeing ris_grantee_info\n", __FILE__, __LINE__));
			g1 = va_arg(args,ris_grantee_info *);
			if (g1 != 0)
			{
				for(g2=g1;g2;g2=g3)
				{
					g3 = g2->next;
					INT_DBG(("%s,%d:RISfree_memory_extended: 0x%x  ", __FILE__, __LINE__, g2));
					if(USE_ALLOCB == iMemoryMode) {
						SYS_FREE((char *)g2);
					} else if (USE_MALLOC == iMemoryMode) {
						free((char *)g2);
					}
					INT_DBG(("%s,%d:RISfree_memory_extended:freed 0x%x\n", __FILE__, __LINE__, g2));
				}
			}
		}
		break;

		case RIS_FREE_REPORT_ERROR_MEMORY:
		{
			char *tmp1=0;

			INT_DBG(("%s,%d:RISfree_memory_extended: ** RIS_FREE_REPORT_ERROR_MEMORY **\n", __FILE__, __LINE__));
			INT_DBG(("%s,%d:RISfree_memory_extended: freeing ris_report_error\n", __FILE__, __LINE__));
			tmp1 = va_arg(args,char *);
			if (tmp1 != 0)
			{
					INT_DBG(("%s,%d:RISfree_memory_extended: 0x%x  ", __FILE__, __LINE__, tmp1));
					if(USE_ALLOCB == iMemoryMode) {
						SYS_FREE(tmp1);
					} else if (USE_MALLOC == iMemoryMode) {
						free(tmp1);
					}
					INT_DBG(("%s,%d:RISfree_memory_extended:freed 0x%x\n", __FILE__, __LINE__, tmp1));
			}
		}
	  	break;
	}

	INT_DBG(("%s,%d:RISfree_memory_extended returns void\n", __FILE__, __LINE__));
}

/******************************************************************************/

extern void RISAPI RISXfree_memory(
	int type,
	va_list args)
{
	RISfree_memory_extended(type, USE_ALLOCB, args);
}

/******************************************************************************/

extern void RISAPI RISXfree_memory_malloc(
	int type,
	va_list args)
{
	RISfree_memory_extended(type, USE_MALLOC, args);
}

/******************************************************************************/

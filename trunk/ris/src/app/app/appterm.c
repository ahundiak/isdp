/* Do not alter this SPC information: $Revision: 1.1.59.1 $ */
/*
**	NAME:							appterm.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/

#include "riscom.h"
#include "rismem.h"
#include "risapp.h"
#include "risdebug.h"
#include "ris_err.h"

/******************************************************************************/

extern void RISapp_terminate(void)
{
	unsigned int i;

	APP_DBG(("RISapp_terminate()\n"));

	if (!RIS_mem)
	{
		APP_DBG(("RISapp_terminate: complete\n"));
		return;
	}

	/*
	**	Free any space in the risca_dbca_stack
	*/
	RISapp_empty_risca_dbca_stack();

	/*
	**	Free any space in the superschema_error  structure
	*/
	if (RISsuperschema_error.primary.schrisca.sqlstmt)
	{
		SYS_FREE(RISsuperschema_error.primary.schrisca.sqlstmt);
	}
	if (RISsuperschema_error.primary.schdbca.sqlstmt)
	{
		SYS_FREE(RISsuperschema_error.primary.schdbca.sqlstmt);
	}
	for (i = 0; i < 9; i++)
	{
		if (RISsuperschema_error.secondary[i].schrisca.sqlstmt)
		{
			SYS_FREE(RISsuperschema_error.secondary[i].schrisca.sqlstmt);
		}
		if (RISsuperschema_error.secondary[i].schdbca.sqlstmt)
		{
			SYS_FREE(RISsuperschema_error.secondary[i].schdbca.sqlstmt);
		}
	}

    /*
    **  Reset the *stmt_id_addr to -1
    */
    for (i = 0; i < RIS_max_stmts; i++)
    {
        if (RIS_stmts[i] && RIS_stmts[i]->stmt_id_addr)
        {
            *(RIS_stmts[i]->stmt_id_addr) = -1;
        }
    }

	/* 
	**	free memory
	*/
	if (!SETJMP()) if(RIS_mem) RIScom_remove_mem();
	RESETJMP();

	/*
	**	clear global ris language variables
	*/
	RIScom_term_langs();

    /*
    ** setting the language code to -1 (means no language)
    */
    RIS_language_code = -1;

    /*
    **  clear global pointers
    */
	RIS_mem = 0;
	RIS_client_died = 0;

	APP_DBG(("RISapp_terminate: complete\n"));
}

/******************************************************************************/

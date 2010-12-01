/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							comsqlca.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					5/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
**			Added RIScom_copy_sqlca() routine -- Hitesh on 8/92
*/
#include <stdlib.h>
#include <string.h>

#include "risdebug.h"
#include "rislimit.h"
#include "ris.h"
#include "riscom.h"

/******************************************************************************/

extern void RIScom_copy_sqlca(rissqlca *dest, rissqlca *src)
{
	char *save_sqlstmt;
	int len;

	COM_DBG(("RIScom_copy_sqlca(dest:0x%x src:0x%x)\n", dest, src));

	save_sqlstmt = dest->sqlstmt;
	memcpy(dest, src, sizeof (rissqlca));
	dest->sqlstmt = save_sqlstmt;

	if (dest->sqlstmt)
	{
		if (src->sqlstmt)
		{
			len = strlen(src->sqlstmt);
			if (len > RIS_MAX_STMT_LEN - 1)
			{
				len = RIS_MAX_STMT_LEN - 1;
			}
			memcpy(dest->sqlstmt, src->sqlstmt, len);
		}
		else
		{
			len = 0;
		}
		dest->sqlstmt[len] = '\0';
	}

	COM_DBG(("RIScom_copy_sqlca:returning\n"));
}

/******************************************************************************/

extern void RIScom_clear_sqlca(rissqlca *sqlca)
{
	char *save_sqlstmt;
	COM_DBG(("RIScom_clear_sqlca(sqlca:0x%x)\n", sqlca));

	save_sqlstmt = sqlca->sqlstmt;
	memset(sqlca, 0, sizeof (rissqlca));

	if (save_sqlstmt)
	{
		*save_sqlstmt = '\0';
		sqlca->sqlstmt = save_sqlstmt;
	}

	COM_DBG(("RIScom_clear_sqlca:returning\n"));
}

/******************************************************************************/

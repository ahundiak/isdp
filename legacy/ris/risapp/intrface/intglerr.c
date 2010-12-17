/* Do not alter this SPC information: $Revision: 1.2.3.1 $ */
/*
**	NAME:							intglerr.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					5/93
**	ABSTRACT:
**			Functions to access global variables.	
**
**	REVISION HISTORY:
**		
**		
*/
 
/*
**	INCLUDES
*/
#include "intrface.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define intglerr_c
#include "comdebug.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

/*
** Global variable: SQLCODE
*/
extern void RISAPI RISXint_set_sqlcode(
	int status)
{
	INT_DBG(("RISint_set_sqlcode(status:%d)\n", status));
	SQLCODE = status;
	INT_DBG(("RISint_set_sqlcode:returning\n"));
}

/******************************************************************************/

/*
** Global variable: SQLCODE
*/
extern int RISAPI RISXget_sqlcode()
{
	INT_DBG(("RISget_sqlcode()\n"));
	INT_DBG(("RISget_sqlcode:returning %d\n", SQLCODE));
	return(SQLCODE);
}

/******************************************************************************/

/*
** Global variable: risca
*/
extern rissqlca * RISAPI RISXget_risca()
{
	INT_DBG(("RISget_risca()\n"));
	INT_DBG(("RISget_risca:returning\n"));
	return(risca);
}

/******************************************************************************/

/*
** Global variable: dbca
*/
extern rissqlca * RISAPI RISXget_dbca()
{
	INT_DBG(("RISget_dbca()\n"));
	INT_DBG(("RISget_dbca:returning\n"));
	return(dbca);
}

/******************************************************************************/

/*
** Global variable: superschema_error
*/
extern ris_superschema_error_info * RISAPI RISXget_superschema_error()
{
	INT_DBG(("RISget_superschema_error()\n"));
	INT_DBG(("RISget_superschema_error:returning %d\n", superschema_error));
	return(superschema_error);
}

/******************************************************************************/

/*
** Global variable: superschema_warning
*/
extern int RISAPI RISXget_superschema_warning()
{
	auto int old_superschema_warning = superschema_warning;

	superschema_warning = 0x0; /* 1996.06.11:Alan Barksdale:TR439601290:here at request of Sarah Byram in E911 (Dispatch Management) */
	INT_DBG(("RISget_superschema_warning()\n"));
	INT_DBG(("RISget_superschema_warning:returning %d\n", old_superschema_warning));
	return(old_superschema_warning);
}

/******************************************************************************/

/* Do not alter this SPC information: $Revision: 1.1.55.1 $ */
/*
**	NAME:							comsqlms.c
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		Miscellaneous functions for sql sub-project
**	
**	REVISION HISTORY:
*/

/*
**	DEFINES
*/
#define MAX_PREC 7
 
/*
**	INCLUDES
*/
#include "ris_err.h"
#include "risstjmp.h"
#include "ristoken.h"


/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define comsqlms_c
#include "comsqlms.prt"
#include "comjmp.prt"



/******************************************************************************/

extern int RIScom_need_parens(
	int par,
	int child,
	char side)
{
	int par_prec;
	char par_assoc;
	int child_prec;
	char child_assoc;

	RIScom_get_prec_assoc(par,&par_prec,&par_assoc);
	if (par_prec == MAX_PREC)
	{
		LONGJMP(RIS_E_INTERNAL_ERROR);
	}
	RIScom_get_prec_assoc(child,&child_prec,&child_assoc);
	return( (par_prec > child_prec) ||
	 (par_prec == child_prec && par_assoc != side));
}

/******************************************************************************/

static void RIScom_get_prec_assoc(
	int tok,
	int * prec,
	char * assoc)
{
	switch(tok)
	{
    	case RIS_TOK_UNARYMINUS:
			*prec = 6;
			*assoc = 'X';
		break;
    	case RIS_TOK_MUL:
    	case RIS_TOK_DIV:
			*prec = 5;
			*assoc = 'L';
		break;
    	case RIS_TOK_PLUS:
    	case RIS_TOK_SUB:
			*prec = 4;
			*assoc = 'L';
		break;
    	case RIS_TOK_NOT:
			*prec = 3;
			*assoc = 'X';
		break;
    	case RIS_TOK_AND:
			*prec = 2;
			*assoc = 'L';
		break;
    	case RIS_TOK_OR:
			*prec = 1;
			*assoc = 'L';
		break;
		default:
			*prec = MAX_PREC;
			*assoc = 'X';
		break;
	}
}

/******************************************************************************/

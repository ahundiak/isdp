/* Do not alter this SPC information: $Revision: 1.1.59.1 $ */
/*
**	NAME:							appdtype.c
**	AUTHORS:						Hitesh Patel
**	CREATION DATE:					12/93
**	ABSTRACT:
**		Functions to return precision, scale, length and display size given
**		a RIS SQL data type.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "limits.h"
#include "float.h"
#include "app.h"
#include "ristypes.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define appdtype_c
#include "appdtype.prt"
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

extern short RISapp_get_precision(
	short	rissqltype,
	short	rissqllen)
{
	short precision = -1;
	char  dummy[32];

	APP_DBG(("RISapp_get_precision(rissqltype:%d rissqllen:%d)\n", 
			rissqltype, rissqllen));

	switch(rissqltype)
	{
		case RIS_CHARACTER:
			precision = rissqllen;
		break;

		case RIS_DECIMAL:
		case RIS_NUMERIC:
			precision = rissqllen;
		break;

		case RIS_SMALLINT:
			/* By default, RIS_SMALLINT is signed */
			precision = sprintf(dummy,"%d", SHRT_MAX);
		break;

		case RIS_INTEGER:
			/* By default, RIS_INTEGER is signed */
			precision = sprintf(dummy,"%d", INT_MAX);
		break;

		case RIS_REAL:
			/*Document says 7; this macro says 6 Verify */
			/*Need to verify why?? */
			precision = FLT_DIG + 1; 
		break;
		
		case RIS_DOUBLE:
		case RIS_FLOAT:
			precision = DBL_DIG;
		break;

		default:
			APP_DBG(("RISapp_get_precision: INV_TYPE\n"));
			LONGJMP(RIS_E_INV_TYPE);
		break;
	}

	APP_DBG(("RISapp_get_precision: returning %d\n", precision));
	return(precision);

}

/******************************************************************************/

extern short RISapp_get_length(
	short	rissqltype,
	short	rissqllen)
{
	short length = -1;

	APP_DBG(("RISapp_get_length(rissqltype:%d rissqllen:%d)\n", 
			rissqltype, rissqllen));

	switch(rissqltype)
	{
		case RIS_CHARACTER:
		case RIS_SMALLINT:
		case RIS_INTEGER:
		case RIS_REAL:
		case RIS_DOUBLE:
		case RIS_FLOAT:
			length = rissqllen;
		break;

		case RIS_DECIMAL:
		case RIS_NUMERIC:
			length = rissqllen + 2; /* digits + sign + decimal point */
		break;

		default:
			APP_DBG(("RISapp_get_length: INV_TYPE\n"));
			LONGJMP(RIS_E_INV_TYPE);
		break;
	}

	APP_DBG(("RISapp_get_length: returning %d\n", length));
	return(length);

}

/******************************************************************************/

extern short RISapp_get_display_size(
	short	rissqltype)
{
	short displaysize = -1;
	char  display[32];

	APP_DBG(("RISapp_get_display_size(rissqltype:%d)\n", rissqltype));

	switch(rissqltype)
	{
		case RIS_SMALLINT:
			/* By default, RIS_SMALLINT is signed */
			displaysize = sprintf(display,"%d", SHRT_MAX);
			displaysize += 2; /* sign + null byte */
		break;

		case RIS_INTEGER:
			/* By default, RIS_INTEGER is signed */
			displaysize = sprintf(display,"%d", INT_MAX);
			displaysize += 2; /* sign + null byte */
		break;

		case RIS_DOUBLE:
		case RIS_FLOAT:
			displaysize = sprintf(display,"%+1.*e", DBL_DIG, DBL_MAX);
			displaysize++; /* null byte */
		break;

		case RIS_REAL:
			displaysize = sprintf(display,"%+1.*e", FLT_DIG, FLT_MAX);
			displaysize++; /* null byte */
		break;
		
		default:
			APP_DBG(("RISapp_get_display_size: INV_TYPE\n"));
			LONGJMP(RIS_E_INV_TYPE);
		break;
	}

	APP_DBG(("RISapp_get_display_size: returning %d\n", displaysize));
	return(displaysize);

}

/******************************************************************************/


/* Do not alter this SPC information: $Revision: 1.1.59.1 $ */
/*
**	NAME:							appnmric.c
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					12/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	10/94:	Added support for INTERNATIONALIZATION.  Mark Boswell
*/
 
/*
**	INCLUDES
*/
#if defined(WIN32)
#include "limits.h"
#include "float.h"
#endif
#include "errno.h"
#include "app.h"
#include "commacro.h"
#include "riscom.h"
#include "ristypes.h"



/*
**	DEFINES
*/
#define DATA_NUMERIC_LITERAL		0
#define DATA_DECIMAL_FOUND			1
#define DATA_NOT_NUMERIC_LITERAL	2	


/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define appnmric_c
#include "appnmric.prt"
#include "appdtype.prt"
#include "comdebug.prt"
#include "comisfn.prt"
#include "comjmp.prt"
#include "comoutpt.prt"
#include "comuni.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/******************************************************************************/

#if defined(WIN32)
extern void RISapp_string_to_int(
	char 	*srcdata,
	short 	srclen,
	void    *destdata,
	short	destsqltype,
	long	*destsqlind)
{
	char	s[80]; /* This would be more than enuff */
	short	new_len = 0;
	short	retn_int;

	switch(destsqltype)
	{
		case RIS_SMALLINT:
		case RIS_INTEGER:
			memcpy(s, srcdata, srclen);

			retn_int = check_str_to_int_truncation(s, srclen, &new_len);
			if (retn_int == DATA_NOT_NUMERIC_LITERAL)
			{
				APP_DBG(("RISapp_process_parms:Not a numeric-literal\n"));
				/* SqlState "22005" */
				LONGJMP(RIS_E_ERROR_IN_ASSIGNMENT);
			}
			if (new_len >= RISapp_get_display_size(destsqltype))
			{
				APP_DBG(("RISapp_process_parms:Loss of signi digits\n"));
				/* SqlState "22003" */
				LONGJMP(RIS_E_NUM_OUT_OF_RANGE);
			}

			if (destsqltype == RIS_SMALLINT)
			{
				*(short *)destdata = (short)atoi(s);
				APP_DBG(("RISapp_process_parms: dest sqldata value:%d\n",
					*(short *)destdata));
			} 
			else if (destsqltype == RIS_INTEGER)
			{
				*(int *)destdata = (int)atoi(s);
				APP_DBG(("RISapp_process_parms: dest sqldata value:%d\n",
					*(int *)destdata));
			}

			if (retn_int == DATA_DECIMAL_FOUND)
			{
				/* SqlState "01004" */
				/* Data truncated */
				/* Set destsqlind to indicate the data was truncated */
				if (destsqltype == RIS_SMALLINT)
				{
					*destsqlind = (long)sizeof(short);
				}	 
				else if (destsqltype == RIS_INTEGER)
				{
					*destsqlind = (long)sizeof(int);
				}
			}
		break;

		default:
			APP_DBG(("RISapp_process_parms: INV_TYPE\n"));
			LONGJMP(RIS_E_INV_TYPE);
		break;
	}
}
#endif

/******************************************************************************/

#if defined(WIN32)
extern void RISapp_string_to_double(
	char 	*srcdata,
	short 	srclen,
	void    *destdata,
	short	destsqltype,
	long	*destsqlind)
{
	double	retn_dbl;
	char	*term_ptr;

	switch(destsqltype)
	{
		case RIS_DOUBLE:
		case RIS_FLOAT:
		case RIS_REAL:
			errno = 0;
			retn_dbl = strtod(srcdata, &term_ptr);
			if (*term_ptr != '\0')
			{
				/* strtod sets term_ptr to first not valid float-char */
				APP_DBG(("RISapp_process_parms:Not a float-literal\n"));
				/* SqlState "22005" */
				LONGJMP(RIS_E_ERROR_IN_ASSIGNMENT);
			}
			if (errno == ERANGE)
			{
				APP_DBG(("RISapp_process_parms:Out of Range(double)\n"));
				/* SqlState "22003" */
				LONGJMP(RIS_E_NUM_OUT_OF_RANGE);
			}

			if (destsqltype == RIS_FLOAT || destsqltype == RIS_DOUBLE)
			{
				*(double *)destdata = retn_dbl;
				APP_DBG(("RISapp_process_parms: dest sqldata value:%.15e\n",
					*(double *)destdata));
			} 
			else if (destsqltype == RIS_REAL)
			{
				if (retn_dbl > (double)FLT_MAX || retn_dbl < -(double)FLT_MAX)
				{
					APP_DBG(("RISapp_process_parms:Out of Range(float)\n"));
					/* SqlState "22003" */
					LONGJMP(RIS_E_NUM_OUT_OF_RANGE);
				}
				/* This would always fail 'cuz value will be rounded.
				   Actually, check not required as it is with float's range.
				check_float_to_int_truncation(&retn_dbl, RIS_DOUBLE, dest->sqltype, 
					dest->sqlind);
				*/
				*(float *)destdata = (float)retn_dbl;
				APP_DBG(("RISapp_process_parms: dest sqldata value:%.7e\n",
					*(float *)destdata));
			}

		break;
		
		default:
			APP_DBG(("RISapp_process_parms: INV_TYPE\n"));
			LONGJMP(RIS_E_INV_TYPE);
		break;
	}
}
#endif

/******************************************************************************/

#if defined(WIN32)
static short check_str_to_int_truncation(
	char 	*s,
	short	s_len,
	short	*new_len)
{ 
	char *ptr = s;
	wchar_t *ws;
	wchar_t *wptr;
	int numchars; 
	int char_count;


	// skip white space
	RIScom_skipwhitespace(ptr);

	//
	// INTERNATIONALIZATION CHANGE. convert mb str to wide char str,
	// however, this function must return the length of the resulting
	// string in bytes.
	//
	RIScom_multiwide(&RISwide_ptr, &ptr, &RISwide_size, MULTITOWIDE, 0);
	ws = RISwide_ptr;
	wptr = ws;


	// check for + or - sign
	if ( *wptr == WIDECHAR('-') || *wptr == WIDECHAR('+') ) 
		wptr++;

	numchars = RIScom_wstrlen(wptr);

	// if first char is . error out
	if (*ptr == WIDECHAR('.')) 
		return(DATA_NOT_NUMERIC_LITERAL);


	for (char_count=0; *wptr && char_count < numchars-1; wptr++,char_count++)
	{
		if ( ISDIGIT(*wptr) )
			continue;

		else if ( *wptr == WIDECHAR('.') )
		{
			*wptr = WIDECHAR('\0');
			RIScom_multiwide(&ws, 
					 &RISmulti_ptr, 
					 &RISmulti_size,
					 WIDETOMULTI,
					 0); 
			s = RISmulti_ptr;
			*new_len = strlen(s);
			return(DATA_DECIMAL_FOUND);
		}
		else
			return(DATA_NOT_NUMERIC_LITERAL);

	}
	return(DATA_NUMERIC_LITERAL);
}
#endif

/******************************************************************************/

#if defined(WIN32)
extern void RISapp_int_to_string( 
	void    *srcdata,
	short	srcsqltype,
	char 	*destdata,
	short 	destlen)
{
	switch(srcsqltype)
	{
		case RIS_SMALLINT:
			if (destlen <= RISapp_get_display_size(srcsqltype))
			{
				/*	
				**	Truncation is not valid for short as there will be
				**	loss of significant digits (shorts donot have fractions)
				*/
				/* Set SqlState = "01004" */
				APP_DBG(("RISapp_process_parms: C Variable too small\n"));
				LONGJMP(RIS_E_DATA_TRUNCATED);
			}
			sprintf(destdata, "%d", *(short *)srcdata);
		break;

		case RIS_INTEGER:
			if (destlen <= RISapp_get_display_size(srcsqltype))
			{
				/*	
				**	Truncation is not valid for int as there will be
				**	loss of significant digits (ints donot have fractions)
				*/
				/* Set SqlState = "01004" */
				APP_DBG(("RISapp_process_parms: C Variable too small\n"));
				LONGJMP(RIS_E_DATA_TRUNCATED);
			}
			sprintf(destdata, "%d", *(int *)srcdata);
		break;

		default:
			APP_DBG(("RISapp_process_parms: INV_TYPE\n"));
			LONGJMP(RIS_E_INV_TYPE);
		break;
	}
}
#endif

/******************************************************************************/

#if defined(WIN32)
extern void RISapp_double_to_string( 
	void    *srcdata,
	short	srcsqltype,
	char 	*destdata,
	short 	destlen)
{
	switch(srcsqltype)
	{
		case RIS_DOUBLE:
		case RIS_FLOAT:
			if (destlen <= RISapp_get_display_size(srcsqltype))
			{
				/*	
				** Approx. numeric values will cause loss of significant
				** digits. Therefore, if not enuff space, error out.
				*/
				APP_DBG(("RISapp_process_parms: C Variable too small\n"));
				LONGJMP(RIS_E_INV_TYPE);
			}
			/*
			sprintf(destdata, "%+1.*e", DBL_DIG, *(double *)srcdata);
			*/
			sprintf(destdata, "%.*g", DBL_DIG, *(double *)srcdata);
		break;

		case RIS_REAL:
			if (destlen <= RISapp_get_display_size(srcsqltype))
			{
				/*	
				** Approx. numeric values will cause loss of significant
				** digits. Therefore, if not enuff space, error out.
				*/
				APP_DBG(("RISapp_process_parms: C Variable too small\n"));
				LONGJMP(RIS_E_INV_TYPE);
			}
			/*
			sprintf(destdata, "%+1.*e", FLT_DIG, *(float *)srcdata);
			*/
			sprintf(destdata, "%.*g", FLT_DIG, *(float *)srcdata);
		break;
		
		default:
			APP_DBG(("RISapp_process_parms: INV_TYPE\n"));
			LONGJMP(RIS_E_INV_TYPE);
		break;
	}
}
#endif

/******************************************************************************/

#if defined(WIN32)
extern void check_double_to_int_truncation(
	void    *srcdata,	/* double or float */
	short	srcsqltype,
	short 	destsqltype,
	long	*destsqlind)
{
	short  shortvalue;
	int    intvalue;
	float  floatvalue;
	double doublevalue;

	switch(srcsqltype)
	{
		case RIS_FLOAT:
		case RIS_DOUBLE:
			doublevalue = *(double *)srcdata;
			switch(destsqltype)
			{
				case RIS_INTEGER:
					intvalue = (int)doublevalue;
					if ((double)intvalue != doublevalue)
					{
						/* Truncation */
						*destsqlind = (long)sizeof(int);
						APP_DBG(("RISapp_process_parms:DOUBLE->INT truncated\n"));
					}
					break;
				case RIS_SMALLINT:
					shortvalue = (short)doublevalue;
					if ((double)shortvalue != doublevalue)
					{
						/* Truncation */
						*destsqlind = (long)sizeof(short);
						APP_DBG(("RISapp_process_parms:DOUBLE->SHORT truncated\n"));
					}
					break;
			} /* inner switch */
			break;
		case RIS_REAL:
			floatvalue = *(float *)srcdata;
			if (destsqltype == RIS_INTEGER)
			{
				intvalue = (int)floatvalue;
				if ((float)intvalue != floatvalue)
				{
					/* Truncation */
					/* Set SqlState = "01004" by ODBC layer */
					*destsqlind = (long)sizeof(int);
					APP_DBG(("RISapp_process_parms:FLOAT->INT truncated\n"));
				}
			} 
			else if (destsqltype == RIS_SMALLINT)
			{
				shortvalue = (short)floatvalue;
				if ((float)shortvalue != floatvalue)
				{
					/* Truncation */
					/* Set SqlState = "01004" by ODBC layer */
					*destsqlind = (long)sizeof(short);
					APP_DBG(("RISapp_process_parms:FLOAT->SHORT truncated\n"));
				}
			}
			break;
	} /* outer switch */
}
#endif

/******************************************************************************/

#if defined(WIN32)
extern void check_double_to_float_truncation(
	double  d,
	short	srcsqltype,
	short 	destsqltype,
	long	*destsqlind)
{
	float  floatvalue;

	floatvalue = (float)d;
	if ((double)floatvalue != d)
	{
		/* Truncation */
		*destsqlind = (long)sizeof(float);
		APP_DBG(("RISapp_process_parms:DOUBLE->REAL truncated\n"));
	}
}
#endif

/******************************************************************************/

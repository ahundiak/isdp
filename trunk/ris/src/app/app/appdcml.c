/* Do not alter this SPC information: $Revision: 1.3.35.1 $ */
/*
**	NAME:							appdcml.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					12/91
**	ABSTRACT:
**	
**	REVISION HISTORY:
**
**	10/94:	Added support for INTERNATIONALIZATION.  Mark Boswell
*/
#include <ctype.h>

#include "risapp.h"
#include "riscom.h"
#include "riscom_macro.h"

/******************************************************************************/

static int valid_number(char *s, int s_len)
{
/*
**	returns length of string if valid decimal
**	returns 0 if invalid string
*/
	int dec_pt_seen = 0;
#ifdef WIN32
	wchar_t *tmp_s, *ptr, *end;
#else
	char *tmp_s, *ptr, *end;
	tmp_s = s;
#endif 

#ifdef WIN32
	/*
	** convert multi-byte string to wide char string
	*/
	RIScom_multiwide(&RISwide_ptr, &s, &RISwide_size, MULTITOWIDE, 0);
	tmp_s = RISwide_ptr;

	/* recompute length of wide char string which is != input param */
	s_len = RIScom_wstrlen(tmp_s);        
#endif

	ptr = tmp_s;
	end = tmp_s + s_len;

	APP_DBG(("valid_number: s:<%s> s_len: %d\n",s,s_len));

	if (*ptr == WIDECHAR('-') || *ptr == WIDECHAR('+') )
		ptr++;

	APP_DBG(("*ptr = '%c'\n",*ptr));
	if ( !(ISDIGIT(*ptr) || *ptr == WIDECHAR('.')) )
	{
		return(0);
	}

	for (;*ptr && ptr < end; ptr++)
	{
		APP_DBG(("*ptr = %c\n",*ptr));

		if ( ISDIGIT(*ptr) )
			continue;

		if (*ptr == WIDECHAR('.') && !dec_pt_seen)
		{
			dec_pt_seen = 1;
			continue;
		}

		if ( ISSPACE(*ptr) )
		{

#ifdef WIN32 
			wchar_t *space_ptr;
#else
			char *space_ptr;
#endif

			space_ptr = ptr;
			for (;*ptr && ptr < end; ptr++)
			{
				if ( !ISSPACE(*ptr) )
					return(0);
			}
#ifdef WIN32
			/*
                        ** need to terminate this string with a L'\0'
                        */
                        *space_ptr = WIDECHAR('\0');
                        return ( RIScom_wstrlen(tmp_s) );
 
#else
			return(space_ptr - tmp_s);
#endif

		}
		return(0);
	}
#ifdef WIN32
	/* 
	** need to terminate string with a L'\0' in order 
	** to use RIScom_wstrlen
	*/
	*ptr = WIDECHAR('\0');
	return ( RIScom_wstrlen(tmp_s) );
#else
	return(ptr - tmp_s);
#endif
}

/******************************************************************************/

extern void RISapp_char_to_decimal(char s[], int s_len, char d[], int d_len, int d_scale)
{
	int len;
	int d_prec;

	if ((len = valid_number(s,s_len)) == 0)
		LONGJMP(RIS_E_INCOMPATIBLE_TYPE);

	if (d_scale == RIS_ANY_SCALE) /* wildcard_scale */
	{
		if (len > d_len)
	 		LONGJMP(RIS_E_DECIMAL_EXCEEDS_PREC);
		memcpy(d,s,len);
		d[len] = '\0';
	}
	else
	{
		d_prec = d_len - 3;

		if (RIScom_set_prec_scale(s,len,d,d_len,d_prec,d_scale))
	 		LONGJMP(RIS_E_DECIMAL_EXCEEDS_PREC);
	}
}

/******************************************************************************/

extern void RISapp_int_to_decimal(int s, char d[], int d_len, int d_scale)
{
	int i;
	int len;
	int limit;
	int d_prec;
	int lead_digits;
	char temp[16];

	if (d_scale == RIS_ANY_SCALE) /* wildcard_scale */
	{
		/* For ODBC, this means loss of significant digits - "22003" */
		if ((len = sprintf(temp,"%d",s)) > d_len)
		{
#if defined(WIN32)
			if (ODBCDLL)
			{
				LONGJMP(RIS_E_NUM_OUT_OF_RANGE); 
			}
			else
#endif
			{
				LONGJMP(RIS_E_DECIMAL_EXCEEDS_PREC); 
			}
		}
		memcpy(d,temp,len);
		d[len] = '\0';
	}
	else
	{
		d_prec = d_len - 3;

		lead_digits = d_prec - d_scale;
		
		limit = 1;
		for (i = 0; i < lead_digits; i++)
			limit *= 10;


		/* For ODBC, this means loss of significant digits - "22003" */
		if (s >= limit || s <= -limit)
		{
#if defined(WIN32)
			if (ODBCDLL)
			{
				LONGJMP(RIS_E_NUM_OUT_OF_RANGE); 
			}
			else
#endif
			{
				LONGJMP(RIS_E_DECIMAL_EXCEEDS_PREC); 
			}
		}

		sprintf(d, "%d", s);
	}
}

/******************************************************************************/

extern void RISapp_double_to_decimal(double s, char *d, int d_len, int d_scale)
{
	int len;
	int d_prec;
	char temp[RIS_MAX_PRECISION + 3];

	len = sprintf(temp,"%.*g",RIS_MAX_PRECISION,s);
	/* For ODBC, this means loss of significant digits - "22003" */
	if (strchr(temp,'e')) /* itbokic - numerical string */
	{
#if defined(WIN32)
		if (ODBCDLL)
		{
			LONGJMP(RIS_E_NUM_OUT_OF_RANGE); 
		}
		else
#endif
		{
			LONGJMP(RIS_E_DECIMAL_EXCEEDS_PREC); 
		}
	}

	if (d_scale == RIS_ANY_SCALE)
	{
		/* For ODBC, this means loss of significant digits - "22003" */
		if (len > d_len)
		{
#if defined(WIN32)
			if (ODBCDLL)
			{
				LONGJMP(RIS_E_NUM_OUT_OF_RANGE); 
			}
			else
#endif
			{
				LONGJMP(RIS_E_DECIMAL_EXCEEDS_PREC); 
			}
		}
		memcpy(d,temp,len);
		d[len] = '\0';
	}
	else
	{
		d_prec = d_len - 3;
		/* For ODBC, this means loss of significant digits - "22003" */
		if (RIScom_set_prec_scale(temp,sizeof(temp)-1,d,d_len,d_prec,d_scale))
		{
#if defined(WIN32)
			if (ODBCDLL)
			{
				LONGJMP(RIS_E_NUM_OUT_OF_RANGE); 
			}
			else
#endif
			{
				LONGJMP(RIS_E_DECIMAL_EXCEEDS_PREC); 
			}
		}
	}
}

/******************************************************************************/

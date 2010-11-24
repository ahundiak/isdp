/*
**      NAME:                       comuni.c
**      AUTHORS:                    Dianne Ferrans
**      CREATION DATE:              8/94
**      ABSTRACT:  Wrappers for all basic wide-char and unicode functions
**                 for easy translation if things change in the future.
**                 or future swapping out for faster functions when available.
**      REVISION HISTORY:
*/
/*
#define NO_COM_DBG
*/
#define _UNICODE
 
/*
**      INCLUDES
*/
#include <errno.h>
#include <string.h>

#include "riscom.h" 
#include "risdebug.h"
#include "riscom_macro.h"
#include "rismem.h"


/*--------------------------------------------------------------------------
 *  RIScom_isleadbyte:  Determines we are dealing with the first byte   
 *                      of a multi-byte character
--------------------------------------------------------------------------*/
extern int RIScom_isleadbyte(
    int leadbyte)
{
#ifdef WIN32
    return(isleadbyte(leadbyte));
#else
	leadbyte = leadbyte; /* shut up the compiler */
    return(0);
#endif
}

/*******************************************************************/
/* Function: RIScom_strrchr
   Author:  DD Ferrans               Date:    10/94
   Purpose:  To do a "strrchr" type function on a multibyte string
             and return a char * to the correct place in the orig.
             string.

   CAVEATS:  Because of translation time do not use this in a loop or
             where used frequently since it will be significantly slower
             than a regular "strrchr".  

              Input must be null-terminated.

   HOW IT WORKS:  The logic is a bit convoluted, so let me explain:

		1.  input_string is converted to wide (RISwide_ptr);
		2.  wide_ptr = "strrchr" (wide version) RISwide_ptr;
		3.  wide_ptr is converted to multi_byte (RISmulti_ptr)
		4.  So now we have input_string, the original, and RISmulti_ptr,
		    which is a separate string which looks like the 
                    part of input_string after the "char_to_match" character.
		5.  in_ctr = strlen(input_string)
		6.  mid_ctr = strlen(RISmulti_ptr)
		7.  c_ptr is set to the end of input_string 
		8.  c_ptr is backed up the distance equal to the length of 
                    RISmulti_ptr (mid_ctr)
		9.  c_ptr is now pointing to the correct place in the original
	            input_string, and returned. 
*/
/*********************************************************************/
extern char * RIScom_strrchr(
	char *input_string,
#if defined(WIN32)
	wint_t  char_to_match)   /* converted to unsigned short see below*/
#else
	int  char_to_match)   /* converted to unsigned short see below*/
#endif
{

/* note that RISwide_ptr ,RISwide_size  and RISmulti_ptr are globals def'd 
in commacro.h*/

#if defined(WIN32)
wchar_t *wide_ptr;
char * c_ptr;
int in_ctr,mid_ctr;

        COM_DBG(("RIScom_strrchr  -- input %s %d\n",input_string,char_to_match));

	RIScom_multiwide(&RISwide_ptr,&input_string,&RISwide_size,MULTITOWIDE,0);

/* online documentation is wrong see wchar.h char_to_match had to be typecast*/

        wide_ptr = wcsrchr(RISwide_ptr,char_to_match);
	if (!wide_ptr)
		return(NULL);
	RIScom_multiwide(&wide_ptr,&RISmulti_ptr,&RISmulti_size,WIDETOMULTI,0);

	in_ctr  = strlen(input_string);
	mid_ctr = strlen(RISmulti_ptr);
	if ((mid_ctr  <= 0)  || (in_ctr < mid_ctr))
		return(NULL);

	c_ptr = input_string + in_ctr; /* sitting at end of string */
	c_ptr = c_ptr - mid_ctr;
	return(c_ptr);
#else
	return(strrchr(input_string,char_to_match));
#endif
}
/************************************************************************/

/*******************************************************************/
/* Function: RIScom_strchr
   Author:  DD Ferrans               Date:    10/94
   Purpose:  To do a "strchr" type function on a multibyte string
             and return a char * to the correct place in the orig.
             string.

   CAVEATS:  Because of translation time do not use this in a loop or
             where used frequently since it will be significantly slower
             than a regular "strchr".   Do not use in a function which
	     also uses these globals.

              Input must be null-terminated.
   HOW IT WORKS:  The logic is a bit convoluted, so let me explain:

		1.  input_string is converted to wide (RISwide_ptr);
		2.  wide_ptr = "strchr" (wide version) RISwide_ptr;
		3.  wide_ptr is converted to multi_byte (RISmulti_ptr)
		4.  So now we have input_string, the original, and RISmulti_ptr,
		    which is a separate string which looks like the 
                    part of input_string after the "char_to_match" character.
		5.  in_ctr = strlen(input_string)
		6.  mid_ctr = strlen(RISmulti_ptr)
		7.  c_ptr is set to the end of input_string 
		8.  c_ptr is backed up the distance equal to the length of 
                    RISmulti_ptr (mid_ctr)
		9.  c_ptr is now pointing to the correct place in the original
*/
/*********************************************************************/
extern char * RIScom_strchr(
	char *input_string,
#if defined(WIN32)
	wint_t  char_to_match) /* converted to unsigned short see below*/
#else
	int  char_to_match)   /* converted to unsigned short see below*/
#endif
{

/* note that RISwide_ptr ,RISwide_size  and RISmulti_ptr are globals def'd 
in commacro.h*/

#if defined(WIN32)
wchar_t *wide_ptr;
char * c_ptr;
int in_ctr,mid_ctr;

        COM_DBG(("RIScom_strchr  -- input %s %d \n",input_string,char_to_match));

	RIScom_multiwide(&RISwide_ptr,&input_string,&RISwide_size,MULTITOWIDE,0);

/* online documentation is wrong see wchar.h char_to_match had to be typecast*/

        wide_ptr = wcschr(RISwide_ptr,char_to_match);
	if (!wide_ptr) 
		return(NULL);
	RIScom_multiwide(&wide_ptr,&RISmulti_ptr,&RISmulti_size,WIDETOMULTI,0);

	in_ctr  = strlen(input_string);
	mid_ctr = strlen(RISmulti_ptr);
	if ((mid_ctr  <= 0)  || (in_ctr < mid_ctr))
		return(NULL);

	c_ptr = input_string + in_ctr; /* sitting at end of string */
	c_ptr = c_ptr - mid_ctr;
	return(c_ptr);
#else
	return(strchr(input_string,char_to_match));
#endif
}

/*******************************************************************
*	FUNCTION:  	RIScom_charnext()
*		    	find the next char in a string whether multibyte or not.  
*	RETURNS:    pointer to next char
*******************************************************************/
extern char *RIScom_charnext(
	char *ptr)
{
#if defined(WIN32)
	return(CharNext(ptr));
#else
	return(++ptr);
#endif 
}
/*******************************************************************
*	FUNCTION:  	RIScom_charprev()
*			find the previous char in a string whether multibyte
			or not.  
*	RETURNS:  pointer to previous char
*******************************************************************/
extern char *RIScom_charprev(
	char *start_ptr,
	char *curr_ptr)
{
#if defined(WIN32)
	return(CharPrev(start_ptr,curr_ptr));
#else
	if (curr_ptr > start_ptr)
		return(curr_ptr--);
	else
		return('\0');
#endif 
}

/*--------------------------------------------------------------------
* RIScom_skipwhitespace : Strips any white spaces from the end of a
*			  string.
--------------------------------------------------------------------*/
extern char *RIScom_skipwhitespace(   
    char *string)
{
#ifdef WIN32
    wchar_t *tmp_data;
    
    RIScom_multiwide(&RISwide_ptr, &string, &RISwide_size, MULTITOWIDE, 0);
    tmp_data = RISwide_ptr;
#else
    char    *tmp_data;
    tmp_data = string;
#endif

    while ( ISSPACE(*tmp_data))
    {
        tmp_data++;
        string = RIScom_charnext( string );
    }
    return ( string );
}


/******************************************************************
  RIScom_strstr:  wrapper for strstr
		  strings must be null-terminated.
*******************************************************************/
extern char *RIScom_strstr(
char *in_string,
char *match_string)
{
	return(strstr(in_string,match_string));
}

/*--------------------------------------------------------------------------------------
*  RIScom_unpad:	This function strips the trailing blanks a string.
*					
*					Special note:
*						With risdbms_tables, the size we declare (31)
*						is larger than the size known by the database
*						( ingres - 24 ).  Ingres does not pad beyond
*						its max size with blanks.  Beyond the max size
*						it pads with nulls.  this was seen when selecting
*						table_name/view_name/index_name from 
*						risdbms_tables/views/etc.  ( This note is taken
*						directly from rissrv/internal/dbms.h for the
*						macro UNPAD.  At this time this function is only
*						called with oracle and sybase.  I am keeping the
*						logic from the UNPAD macro since it will mess
*						up INGRES when we call this function from 
*						INGRES.   Paula 11/94.
*
*
*					Arguments:
*						arg1:	string
*						arg2:	size of string
*
*						Function returns string with the trailing blanks removed
*
--------------------------------------------------------------------------------------*/
extern char *RIScom_unpad( 
	char	*string,
	int		len)
{
	int		i;
	int		numchars;
#ifdef WIN32
	wchar_t	*tp;
	int		snum;
	int		mnum;
#else
	char	*tp;
	tp = string;
	numchars = len;
#endif
	
#ifdef WIN32
	RIScom_multiwide(&RISwide_ptr, &string, &RISwide_size, MULTITOWIDE, len );
	tp = RISwide_ptr;
	RIScom_numchars ( string, &mnum, &snum, len);
	numchars = mnum + snum;
#endif
		i = numchars - 1;
		while ( i >= 0 && ((tp[i] == WIDECHAR(' ')) || (tp[i] == WIDECHAR('\0'))))
		{
			tp[i--] = WIDECHAR('\0');
		}
#ifdef WIN32
	RIScom_wcstombs(string, tp, len);
#endif
	return(string);
}

/*--------------------------------------------------------------------------------------
**	RIScom_strpbrk: This function returns a pointer to the first occurance
**					of a character from the compare_string located in
**					the string. 
**
**	Note:
**		Under WIN32 this returns the pointer into the wide character string.
**		The only time this function is called is to determine if one of
**		of the characters in compare_string exists in the string.  We do
**	 	not care where the pointer is in the string.  It was not worth the
**		extra time to convert back and determine where the character was
**		actually located inside the original multibyte string.  This function
**		is only called from rissrv/dd/ddexists.c.  Paula 11/16/94
--------------------------------------------------------------------------------------*/

extern char *RIScom_strpbrk(
	char *string,
	char *compare_string)
{
#ifdef WIN32
	RIScom_multiwide ( &RISwide_ptr, &string, &RISwide_size, MULTITOWIDE, 0);
	RIScom_multiwide ( &RISwide_ptr2, &compare_string, &RISwide_size2, MULTITOWIDE, 0);
	
	return((char *) wcspbrk(RISwide_ptr, RISwide_ptr2));
#else
	return ( strpbrk(string, compare_string));
#endif
}

/** Melania Stewart - Strip a trailing slash **/
extern void RIScom_StripSlash (
        char *sz1)
{
#ifdef WIN32
    wchar_t *wsz1;
#endif
    int last;

#ifdef WIN32    
    wsz1 = (wchar_t *) malloc ((lstrlen (sz1) + 1) * sizeof (wchar_t));
    mbstowcs (wsz1, sz1, lstrlen (sz1) + 1);

    last = wcslen (wsz1) - 1;
    if (wsz1[last] == '\\') {
        wsz1[last] = L'\0';
    }

    wcstombs (sz1, wsz1, wcslen (wsz1) + 1);
    free ((char *) wsz1);
#else
    last = strlen (sz1) - 1;
    if (sz1[last] == '/') {
        sz1[last] = L'\0';
    }
#endif    
}


/******************************************************************************/


/*=======================================================================
the current end of the non-WIN32 specific functions.  Please
add all new functions above this line
==========================================================================*/


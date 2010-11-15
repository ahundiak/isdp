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
#if defined(WIN32)
#include <windows.h>
#include <tchar.h>
#endif
#include "riscom.h" 
#include "risdebug.h"
#include "commacro.h"
#include "rismem.h"
/*
**      DEFINES
*/

/*
**      TYPES
*/

/*
**      FUNCTION PROTOTYPES
*/
#define comuni_c
#include "sys.prt"
#include "comuni.prt"


#if defined(WIN32) 
#include "wrap.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#else
#include "comisfn.prt"
#endif

/*
**      VARIABLES
*/

/*
**      FUNCTIONS
*/

#if defined(WIN32)
/*================================================================
  THIS IS THE BEGINNING OF WIN32 ONLY FUNCTIONS, there are two large
  blocks of functions here, those win32 specific, and those 
  multiplatform.  When adding a new function, add it to the
  bottom of the correct section 
===================================================================*/

/*--------------------------------------------------------------------------
*   RIScom_mbstowcs - Takes a multi-byte string, converts it to
*                     a wide character string ( unicode ) and
*                     returns the number of wide characters.
--------------------------------------------------------------------------*/
extern size_t RIScom_mbstowcs(
        wchar_t *wide_string,
        char    *multi_string,
        int     size)
{
    return(mbstowcs(wide_string, multi_string, size));
}

/*--------------------------------------------------------------------------
*   RIScom_wcstombs - Takes a wide character string (unicode), converts it
*                     to a multi-byte string and returns the number of 
*                     bytes.
--------------------------------------------------------------------------*/
extern size_t RIScom_wcstombs(
        char    *multi_string,
        wchar_t *wide_string,
        int     size)
{
    return(wcstombs(multi_string, wide_string,size));
}

/*--------------------------------------------------------------------------
* RIScom_alloc_wcstombs - Takes a wide character string (unicode), 
*    Allocates space for a multibyte string converts wide char string 
*    to new multi-byte string . 
************************************************************************
*   (We need to allocate
*    space each time to create new tree nodes.  Using the ALLOCB funct.
*    guarantees that the memory gets cleared up once the statement is
*    finished.  It associates the memory with a perticular statement ID.
*    This function was written to fix a memory leak whereby the swap file
*    would get huge due to memory not being free'd.) Used in parlex.c
*
* multi_string is output
* wide_string is input
*
*    Dianne Ferrans - September 1995.
--------------------------------------------------------------------------*/
extern int RIScom_alloc_wcstombs(
        char    **multi_string,          
        wchar_t *wide_string)           
{
int size;
	if (wide_string) 
	{
		size = wcslen(wide_string) + 1; /* # chars, plus a null */
		size = size * 2; /* assuming 2 bytes/char for wide chars */
                /* fix for TR 439503752 */
	}
	else	 
	{
		return(-1);
	}
	/*
	** Fix for TR's 439503451, 439503450       -Goverdhan 9/15
	*/
	size += 2; /* wide nulls */
	*multi_string = ( char * ) ALLOCB ( size);
       	if ( ! multi_string )
		return ( -1 );
    return(wcstombs(*multi_string, wide_string,size));

}
/*****************************************************************************
* the following are the wide-char (unicode) versions of all functions found
* in comisfn.c 
******************************************************************************/

/******************************************************************************/
extern int RIScom_iswspace(
	wint_t c)
{
	return(iswspace(c));
}
/******************************************************************************/

extern int RIScom_iswdigit(
	wint_t c)
{
	return(iswdigit(c));
}
/******************************************************************************/

extern int RIScom_iswxdigit(
	wint_t c)
{
	return(iswxdigit(c));
}
/******************************************************************************/
extern int RIScom_iswlower(
	wint_t c)
{
	return(iswlower(c));
}

/******************************************************************************/

extern int RIScom_iswupper(
	wint_t c)
{
	return(iswupper(c));
}

/******************************************************************************/

extern int RIScom_iswalpha(
	wint_t c)
{
	return(iswalpha(c));
}

/******************************************************************************/

extern int RIScom_iswalnum(
	wint_t c)
{
	return(iswalnum(c));
}

/******************************************************************************/

extern int RIScom_iswcntrl(
	wint_t c)
{
	return(iswcntrl(c));
}

/******************************************************************************/

extern int RIScom_iswpunct(
	wint_t c)
{
	return(iswpunct(c));
}

/******************************************************************************/
extern int RIScom_iswprint( wint_t c)
{
    return(iswprint(c));
}
/******************************************************************************/
extern int RIScom_iswgraph( wint_t c)
{
    return(iswgraph(c));
}
/******************************************************************************/
extern int RIScom_iswascii( wint_t c)
{
    return(iswascii(c));
}
/******************************************************************************/
extern int RIScom_towlower( wint_t c)
{
    return(towlower(c));
}
/******************************************************************************/
extern int RIScom_towupper( wint_t c)
{
    return(towupper(c));
}


/************************************************************************/
/* RIScom_wcstok:  just a wrapper for wcstok (wide char strtok)         */
/************************************************************************/
extern wchar_t * RIScom_wcstok(
	wchar_t *wide_input,
	wchar_t *wide_tokens)
{
	return(wcstok(wide_input,wide_tokens));
}

/************************************************************************/
/* RIScom_wcsrchr:  just a wrapper for wcsrchr (wide char strrchr)      */
/************************************************************************/
extern wchar_t * RIScom_wcsrchr(
	wchar_t * wide_input,
	wint_t match_char)
{
	return(wcsrchr(wide_input,match_char));
}


/******************************************************************************/
extern int RIScom_towascii(
	wint_t c)
{
         COM_DBG(("RIScom_towascii  WARNING!! There is no wide TOASCII function!\n"));
         return(c); 
}

/*-------------------------------------------------------------------------------------*/
/*		Function: RIScom_numchars
 *                  finds number of multibyte and single chars in a string.
 *
 *
 *		ARGUMENTS:
 *                   1) Pointer containing a multibyte string - string
 *                   2) Address of an integer to contain the number of
 *                      multibyte characters. ( output parameter ) - numwide
 *                   3) Address of an integer to containt the number of
 *                      8-bit characters. ( output parameter ) - numshort
 *                   4) Integer flag to indicate number of bytes to count.  The
 *						parameter ( num ) is set to zero if the string is null 
 *						terminated and the entire string is to be counted.
 *
--------------------------------------------------------------------------------------*/

extern void RIScom_numchars(
	char *string, 
	int  *numwide,
	int  *numshort,
	int  num )
{
	int		len;
	int		wide_flag;
	char	*ptr;

	*numwide = 0;
	*numshort = 0;

	if ( ! num )
		len = strlen(string);
	else
		len = num;

	ptr = string; 
	ptr += len;

	while (( string < ptr ) && ( *string ))
	{
		if ( RIScom_isleadbyte(*string))
			wide_flag = 1;
		else
			wide_flag = 0;
		
		string = RIScom_charnext(string);
		
		switch ( wide_flag )
		{
			case 0:
				*numshort = *numshort + 1;
				break;
			case 1:
				if ( string <= ptr )
					*numwide = *numwide + 1;
				break;
		} /* end switch */
	} /* end while */
}


/******************************************************************************/
/*         Function: RIScom_numbytes
 *                   finds number of bytes in a multi-byte character string
 *
 *         Arguments:
 *              input:
 *                  char * pointing to a multi-byte string
 *                  int    how many characters to count
 *              output:
 *                  returns a int containing the byte count.
 *
 ******************************************************************************/

extern int RIScom_numbytes(
	char *string, 
	int  numchar)
{
	int		i;
	char	*ptr;

	ptr = string;

	for ( i = 0; i < numchar && *ptr; i++ )
	{
		ptr = RIScom_charnext ( ptr );
	}
	return ( ptr - string );
}

/*******************************************************************
*	FUNCTION:  	RIScom_wstrlen()
*			wide char string length - returns # of
*                       wide characters ( not number of bytes )
*
*       Appears to be a bug in wcslen when passing a null string.
*         IT CORE DUMPS..... Had to go the the extra step of
*                            checking for a null and returning 0.
*                            Reported to caplab - October 10, 1994
*******************************************************************/
extern int RIScom_wstrlen(
	wchar_t *string)
{
        if ( ! string )
            return ( 0 );
	return(wcslen(string));
}

/*******************************************************************
*	FUNCTION:  	RIScom_wcsncmp()
*			compares a certain number of characters of
*                       two wide character strings.
*       arg1:           wide character string
*       arg2:           wide character string
*       arg3:           Number of CHARACTERS to compare
*
*       returns:        <0  string1 less than string2
*                       0   string is equal to string2
*                       >0  string1 is greater that string2
*                       
*******************************************************************/
extern int RIScom_wcsncmp(
        wchar_t *s1,
        wchar_t *s2,
        size_t  size)
{
	return(wcsncmp(s1, s2, size));
}

/*------------------------------------------------------------------------
*	FUNCTION:  	RIScom_wcscmp()
*			compares two wide character strings.
*       arg1:           wide character string
*       arg2:           wide character string
*
*       returns:        <0  string1 less than string2
*                       0   string is equal to string2
*                       >0  string1 is greater that string2
*                       
-----------------------------------------------------------------------*/
extern int RIScom_wcscmp(
        wchar_t *s1,
        wchar_t *s2)
{
	return(wcscmp(s1, s2));
}

/*-----------------------------------------------------------------------
 *  FUNCTION:   RIScom_multiwide()
 *  
 *              This function converts wide to multi and multi to wide.
 *              It determines if the pointer to hold the converted string
 *              is large enough and if not, reallocs space for the pointer.  
 *              Returns -1 on failure or 0 on success.
 *
 *  Arguments:  address of a wide character pointer
 *              address of a character pointer
 *              current size of the pointer that will receive the data
 *              flag to indicate which operation to do: MULTITOWIDE
 *                                                      WIDETOMULTI
 *              an integer that represents the number of BYTES when using
 *              the flag WIDETOMULTI and the number of CHARACTERS when
 *              using the flag MULTITOWIDE.  If the string is null terminated
 *              This value is set to 0.
 *
 *
 *  NOTE:       The string to be converted ( either multi-byte or unicode )
 *              must be null terminated if the 5th argument is set to 0.
-----------------------------------------------------------------------*/
extern int RIScom_multiwide(
    wchar_t **wide,
    char    **multi,
    int     *current_size,
    int     flag,
    int     num)
{
    int size, cursize;

    switch ( flag )
    {
        case WIDETOMULTI:
            if ( *current_size == 0 )
            {
                *multi = ( char * ) SYS_MALLOC ( RIS_DEFAULT_SIZE);
                if ( ! multi )
                    return ( -1 );
                *current_size = RIS_DEFAULT_SIZE;
            }
            /*-------------------------------------------------------------------- 
             * if ! num indicates that the string is null terminated, else num
             * indicates the number of bytes.  RIScom_wstrlen returns the number
             * of characters not the number of bytes.  Since we are calculating
             * this number to determine if we have enough storage space in
             * bytes to hold the converted string, we must calculate the
             * number of bytes. We find out the number of characters, add one
             * for null and multiply by the sizeof (wchar_t ) to get the number
             * of bytes.
            --------------------------------------------------------------------*/
            if ( ! num )
                size = (RIScom_wstrlen(*wide) + 1) * sizeof( wchar_t );
            else
                size = num;               /* set size to number of bytes */

            cursize = *current_size;

            /*-------------------------------------------------------------------
             *  Determines if the pointer to hold the converted string contains
             *  enough memory.
            -------------------------------------------------------------------*/
            while ( size > *current_size )
                *current_size = *current_size * 2;

            /*-------------------------------------------------------------------
             *  If the current_size has been changed, this indicates that the
             *  buffer was not big enough to hold the converted string.  Need
             *  to increase the size of the buffer.
            -------------------------------------------------------------------*/
            if ( cursize != *current_size )
            {
                *multi = SYS_REALLOC((char *)*multi, *current_size );
                if ( ! *multi )
                    return ( -1 );
            }

            /*-------------------------------------------------------------------------
             * Since !num indicates a null terminated string, we pass the total size of
             * the buffer to hold the multi-byte string.  It will stop converting when
             * the null characters is encountered.
             *
             * If the string is not null terminated, the functions needs to know
             * how many bytes to convert.  Size is set to the number of bytes.
             * It is important that we only convert the number of bytes if the string 
             * is not null terminated.  If then number of bytes is not correct, the 
             * function will continue to convert until it has converted the number 
             * passed in.  If more bytes are indicated then needed, garbage could 
             * be placed in the multi buffer.
            -------------------------------------------------------------------------*/
            if ( ! num )
                size = *current_size;

            RIScom_wcstombs ( *multi, *wide, size );
            break;

        case MULTITOWIDE:
            if ( *current_size == 0 )
            {
                *wide = ( wchar_t * ) SYS_MALLOC(RIS_DEFAULT_SIZE);
                if ( ! *wide )
                    return ( -1 );
                *current_size = RIS_DEFAULT_SIZE;
            }
            /*-------------------------------------------------------------------- 
             * if ! num indicates that the string is null terminated.  Else
             * num indicates the number of characters.  We have to convert the
             * number of characters to a byte representation.  Multiply by 2
             * for 2 bytes per characters ( unicode ), will give us the largest
             * possible number of bytes the string will need. 
            --------------------------------------------------------------------*/
            if ( ! num )
                size = (strlen(*multi) + 1 ) * 2;   /* add one for null * 2 for unicode */
            else
                size = num * 2;                     /* calculate the number of bytes */

            cursize = *current_size;
            
            while ( size > *current_size )
                *current_size = *current_size * 2;

            if ( cursize != *current_size )
            {
                *wide =(wchar_t *) SYS_REALLOC((char *)*wide, *current_size );
		if ( ! *wide )
                    return ( -1 );
            }
            /*-------------------------------------------------------------------------
             * Since !num indicates a null terminated string, we pass the total size of
             * the buffer to hold the multi-byte string.  It will stop converting when
             * the null characters is encountered.
             *
             * The conversion routine for multi-byte to wide-character needs to know
             * the number of characters to convert (not the number of bytes) if the
             * string is not null terminated.  Num contains the number of characters.
            -------------------------------------------------------------------------*/
            if ( ! num )
                size = *current_size;
            else
                size = num;
	    
            RIScom_mbstowcs ( *wide, *multi, size );
            break;
    } /* end switch */
    return ( 0 ); /* for success */
}



/*******************************************************************/
/* RIScom_truncate 
   Author:  Dianne Ferrans      October 1994
   Purpose:  To truncate a possibly multibyte string after "N" bytes without
             leaving a half-charater at the end of the string, treating
	     all double-tics like single-tics, and null-terminating string

	CAVEATS:  in_string must be null-terminated and begin and 
                  end with a tic.
*/
/*******************************************************************/
extern int RIScom_truncate(
	char *in_string, /*string to be truncated */
	int maxbytes)    /* max bytes to allow, not including end_char */
{
int skip=0, strsize,size2=0;
wchar_t *begw, *curw, *endw;
char *beg, *cur, *end;
     COM_DBG(("RIScom_truncate begin string (%s) size %d\n",in_string,maxbytes));

	strsize = strlen(in_string);
	if (strsize <= maxbytes) return(strsize);

	RIScom_multiwide(&RISwide_ptr,&in_string,&RISwide_size,MULTITOWIDE,0);

	beg = in_string;
	cur = in_string;
	end = in_string + strsize ;
	begw = RISwide_ptr;
	curw = RISwide_ptr;
	endw = RIScom_wcsrchr(RISwide_ptr,'\'');
	if ((*begw != WIDECHAR('\'') || (*endw != WIDECHAR('\'')))) /* beginning /ending tics */
		return(-1);
	while (( cur < end) && (curw < endw) && (size2 < maxbytes))
	{
		curw++;
		cur = RIScom_charnext(cur);
		if ((*curw == WIDECHAR('\'')) && (curw < endw) && (cur  < end))
		{
			skip++;
			curw++;
			cur = RIScom_charnext(cur);
		}
		size2 = (cur - beg) - skip ;
	}
	if ((size2 == maxbytes) && (!RIScom_isleadbyte(*cur)))
	{
     		COM_DBG(("RIScom_truncate EQUALS  and no leadbyte\n"));
		curw++;
	}
	*curw = WIDECHAR('\'');
	curw++;
	*curw = WIDECHAR('\0');
	 RIScom_wcstombs(in_string,begw,strsize);

     COM_DBG(("RIScom_truncate end string %s \n",in_string));

}

/*******************************************************************/
/* RIScom_getticsize 
   Author:  Dianne Ferrans      October 1994
   Purpose:  To find the size of a multibyte string ending with a
             tic mark, treating all double-tics like single-tics, 

	CAVEATS:  in_string must be null-terminated and end with a tic.
*/
/*******************************************************************/
extern int RIScom_getticsize(
	char *in_string) /*string to be truncated */
{
int skip=0, size2=0;
wchar_t *begw, *curw, *endw;
char *beg, *cur, *end;
     COM_DBG(("RIScom_getticsize begin string (%s) size %d\n",in_string));

	RIScom_multiwide(&RISwide_ptr,&in_string,&RISwide_size,MULTITOWIDE,0);

	beg = in_string;
	cur = in_string;
	end = in_string + strlen(in_string);
	begw = RISwide_ptr;
	curw = RISwide_ptr;
	endw = RIScom_wcsrchr(RISwide_ptr,'\'');
	if ((!beg) || (*begw != WIDECHAR('\'')) || 
            (!end) || (*endw != WIDECHAR('\'')))
		return(strlen(in_string));
	while (( cur < end) && (curw < endw))
	{
		curw++;
		cur = RIScom_charnext(cur);
		if ((*curw == WIDECHAR('\'')) 
			&& (curw < endw) && (cur  < end))
		{
			skip++;
			curw++;
			cur = RIScom_charnext(cur);
		}
		size2 = (cur - beg) - skip;
	}

     COM_DBG(("RIScom_getticsize end %d \n",size2));
     return(size2) ;

}
/******************************************************************
  RIScom_wcsstr:  wrapper for wide-char version of strstr
		  strings must be null-terminated.
*******************************************************************/
extern wchar_t *RIScom_wcsstr(
wchar_t *in_string,
wchar_t *match_string)
{
	return(wcsstr(in_string,match_string));
}

/*****************************************************************
  Melania Stewart - This functions were added for internationalization
  of NT utilities. TR#439503878
*******************************************************************/

extern int RIScom_uisspace(   
    char *string)
{
    
    wchar_t *tmp_data;

    RIScom_multiwide(&RISwide_ptr, &string, &RISwide_size, MULTITOWIDE, 1);
    tmp_data = RISwide_ptr;
    return (iswspace(*tmp_data)) ;
}


extern int RIScom_uislower(   
    char *string)
{
    
    wchar_t *tmp_data;

    RIScom_multiwide(&RISwide_ptr, &string, &RISwide_size, MULTITOWIDE, 1);
    tmp_data = RISwide_ptr;
    return ( iswlower(*tmp_data)) ;
}


extern int RIScom_uisupper(   
    char *string)
{
    
    wchar_t *tmp_data;

    RIScom_multiwide(&RISwide_ptr, &string, &RISwide_size, MULTITOWIDE, 1);
    tmp_data = RISwide_ptr;
    return (iswupper(*tmp_data)) ;
}


extern int RIScom_utolower(   
    char *string)
{
    
    wchar_t *tmp_data;

    RIScom_multiwide(&RISwide_ptr, &string, &RISwide_size, MULTITOWIDE, 1);
    tmp_data = RISwide_ptr;
    *tmp_data = towlower (*tmp_data) ;
    RIScom_multiwide (&RISwide_ptr, &RISmulti_ptr, &RISmulti_size, WIDETOMULTI, 1) ;
    return (*RISmulti_ptr) ;

}

extern int RIScom_utoupper(   
    char *string)
{
    
    wchar_t *tmp_data;

    RIScom_multiwide(&RISwide_ptr, &string, &RISwide_size, MULTITOWIDE, 1);
    tmp_data = RISwide_ptr;
    *tmp_data = towupper (*tmp_data) ;
    RIScom_multiwide (&RISwide_ptr, &RISmulti_ptr, &RISmulti_size, WIDETOMULTI, 1) ;
    return (*RISmulti_ptr);

}
#endif

/*================================================================
THIS IS THE GREAT DIVIDING LINE BETWEEN WIN32 ONLY FUNCTIONS
AND THOSE THAT WORK ON MULTIPLE PLATFORMS.
=================================================================*/
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


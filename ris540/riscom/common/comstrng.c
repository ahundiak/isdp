/* Do not alter this PINNACLE information: $Revision: 1.3.28.1 $ */
/*
**	NAME:					comstrng.c
**	AUTHORS:				Dan Karier
**	CREATION DATE:				11/90
**	ABSTRACT:
**	String handling functions.
**
**	RIScom_uppercase((int)length,(uchar *)data)
**
**	RIScom_lowercase((int)length,(uchar *)data)
**
**	Routines for conversion from uppercase to lowercase and vice versa.
**	This will be available in assembler at some point.
**
**	RIScom_fix_space((char *)data)
**		
**	
**	REVISION HISTORY:	Made INTERNATIONALIZATION compliant 8/94 DD Ferrans.
** 						Changed function calls to Macros 9/94 Paula Blohm
*/
 
/*
**	INCLUDES
*/

#include <ctype.h>
#if defined (WIN32)
#include <wchar.h>
#include <rismem.h>
#endif
#include "risdebug.h"
#include <commacro.h>

/*
**	DEFINES
*/

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/

/*
**      FUNCTION PROTOTYPES
*/
#define comstrng_c
#include "comisfn.prt"
#include "comdebug.prt"
#include "comstrng.prt"

#if defined (WIN32)
#include "comuni.prt"
#include "comalloc.prt"
#include "sys.prt"
#endif

extern void RIScom_uppercase(
	int length,
	unsigned char *data)
{
	int		numchars;
#if defined (WIN32)
    wchar_t *tmp_data;
    int     numbytes;
	int		snum;
	int		mnum;
	
	if ( length > 0 )
	{
		RIScom_numchars ( data, &mnum, &snum, length );
		numchars = mnum + snum;
	}
	else
		numchars = 0;

    /* call with length to indicate number of characters */
    RIScom_multiwide ( &RISwide_ptr, &data, &RISwide_size, MULTITOWIDE, numchars );
    tmp_data = RISwide_ptr;
	numbytes = RIScom_numbytes ( data, numchars );
#else
    unsigned char *tmp_data;
	tmp_data = data;
	numchars = length;
#endif
    while (numchars --)
    {
        if (ISLOWER(*tmp_data))
        {
            *tmp_data = (TOUPPER(*tmp_data));
        }
        ++tmp_data;
    }
#ifdef WIN32
    RIScom_wcstombs(data, RISwide_ptr, numbytes);
#endif            
}

/******************************************************************************/
extern void RIScom_lowercase(
	int length,
	unsigned char *data)
{
	int		numchars;
#if defined (WIN32)
    wchar_t *tmp_data;
    int     numbytes;
	int		snum;
	int		mnum;
	
	if ( length > 0 )
	{
		RIScom_numchars ( data, &mnum, &snum, length );
		numchars = mnum + snum;
	}
	else
		numchars = 0;

    /* call with length to indicate number of characters */
    RIScom_multiwide ( &RISwide_ptr, &data, &RISwide_size, MULTITOWIDE, numchars );
    tmp_data = RISwide_ptr;
	numbytes = RIScom_numbytes ( data, numchars );
#else
    unsigned char *tmp_data;
	tmp_data = data;
	numchars = length;
#endif
    while (numchars --)
    {
        if (ISUPPER(*tmp_data))
        {
            *tmp_data = (TOLOWER(*tmp_data));
        }
        ++tmp_data;
    }
#ifdef WIN32
    RIScom_wcstombs(data, RISwide_ptr, numbytes);
#endif            
}


/******************************************************************************/

/* replace all white space characters with spaces */
/* white space == space, tabs, <CR>, newline, or formfeed chars*/

extern void RIScom_fix_space(
	char * data)
{
#if defined (WIN32)
    wchar_t         *tmp_data;
    wchar_t         *c;
    int             length;
#else
    char    *tmp_data = data;
    char    *c;    
#endif


#ifdef WIN32
    length = strlen(data);

    /* pass 0 to indicate null terminated string */
    RIScom_multiwide ( &RISwide_ptr, &data, &RISwide_size, MULTITOWIDE, 0 );
    tmp_data = RISwide_ptr;
#endif

    for (c=tmp_data ; *c != WIDECHAR('\0'); c++)
    {
       	if (ISSPACE(*c))
	{
		*c = WIDECHAR(' ');
	}
    }

#ifdef WIN32
    RIScom_wcstombs(data, RISwide_ptr, (length+1 ));
#endif
}
/******************************************************************************/

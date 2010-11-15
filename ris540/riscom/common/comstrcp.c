/* Do not alter this PINNACLE information: $Revision: 1.3.28.1 $ */
/*
**	NAME:							comstrcp.c
**	AUTHORS:						Terry McIntyre
**	CREATION DATE:					8/89
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
**
**          Paula Blohm - 9/94
**              Added INTERNATIONALIZATION support.
**				
**				The strncpy functions are still passed the number of bytes.  The functions
**				will return the number of bytes copied.  This number could be smaller from
**				the number of bytes passed in.  This is because the byte count passed in
**				could fall within a multibyte character and not allow for the entire
**				character to be copied.  If this is the case, the function will not 
**				copy the character in question, and will calculate the actual number of
**				bytes that it copied without chopping a multibyte character.
**
*/
 
/*
**	INCLUDES
*/
#include <ctype.h>
#include <rismem.h>
#include <risdebug.h>
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
#define comstrcp_c
#include "comisfn.prt"
#include "comdebug.prt"
#include "comstrcp.prt"

#ifdef WIN32
#include "sys.prt"
#include "comalloc.prt"
#include "comuni.prt"
#endif



/*
**	This routine is used to copy null-terminated bytes of memory.
**
**	Input Arguments:
**
**		dst - Destination pointer
**		src - Source pointer
**
**	Output:
**
**		returns # of bytes copied
*/

extern int RIScom_strcpy(
	char *dst,
	char *src)
{
	int i;

	for (i = 0; src[i]; dst[i] = src[i], i++);

	dst[i] = '\0';

	return(i);
}

/*
**	This routine is used to copy characters of memory. They will be null-terminated
**	if there is room
**
**	Input Arguments:
**
**		dst - Destination pointer
**		src - Source pointer
**		n   - maximum number of bytes to copy
**
**	Output:
**
**		returns # of bytes copied.  Refer to the top of the file for more details.
**
**					
*/

extern int RIScom_strncpy(
	char *dst,
	char *src,
	int n)
{
	int i;

#ifdef WIN32
	int numchars;
	int	snum;
	int	mnum;
	int numbytes;

	/* Calculate the number of characters to convert based on the number of bytes */
	if ( n > 0 )
	{

		RIScom_numchars ( src, &mnum, &snum, n );
		numchars = mnum + snum;
	}
	else
		numchars = 0;

	/*------------------------------------------------------------------------------------	
	  numchars indicates the number of characters to convert from multi to wide 
	  Adding the sizeof(wchar_t) for the null character to append to the end 
	-------------------------------------------------------------------------------------*/
	RIScom_multiwide(&RISwide_ptr, &src, &RISwide_size, MULTITOWIDE, (numchars + 1));

	/* Determine the number of characters until n or null */
	for ( i = 0; i < numchars && RISwide_ptr[i]; i++ );

	RISwide_ptr[i] = WIDECHAR('\0');
	RIScom_wcstombs(dst, RISwide_ptr, n);

	/*------------------------------------------------------------------------------------
		Calculate the number of bytes that dst actually contains.  
		i indicates the number of characters
	-------------------------------------------------------------------------------------*/
	numbytes = RIScom_numbytes ( dst, i );
	if ( numbytes < n )
		dst[numbytes] = '\0';

	return(numbytes);
#else
	for (i = 0; src[i] && i < n; dst[i] = src[i], i++);

	if (i < n) dst[i] = '\0';
	return(i);
#endif
}

/*
**	This routine is used to copy null-terminated bytes of memory,
**      changing everything to uppercase if necessary.
**
**	Input Arguments:
**
**		dst - Destination pointer
**		src - Source pointer
**
**	Output:
**
**		returns # of bytes copied
*/

extern RIScom_upper_strcpy(
	char *dst, 
	char *src)
{
 	int i;
#ifdef WIN32
        int     str_size;
        wchar_t *tmp_src;
        wchar_t *tmp_dst;	

        str_size = strlen(src) + 1;

        /* sending 0 to indicate null terminated string */
        RIScom_multiwide(&RISwide_ptr, &src, &RISwide_size, MULTITOWIDE, 0 );
        tmp_src = RISwide_ptr;
	tmp_dst = tmp_src;
#else
        char    *tmp_src;
        char    *tmp_dst;
        tmp_src = src;
	tmp_dst = dst;		
#endif
        for ( i = 0; tmp_src[i]; i++ )
        {
            if ( ISLOWER(tmp_src[i]))
            {   
                tmp_dst[i] = TOUPPER(tmp_src[i]);
            }
			else
			{
				tmp_dst[i] = tmp_src[i];
			}
        }
        tmp_dst[i] = WIDECHAR('\0');
#ifdef WIN32
        RIScom_wcstombs(dst, tmp_dst, str_size);
        return(sizeof(dst));
#else
	return(i);
#endif	
}

/*
**	This routine is used to copy null-terminated bytes of memory,
**      changing everything to lowercase if necessary.
**
**	Input Arguments:
**
**		dst - Destination pointer
**		src - Source pointer
**
**	Output:
**
**		returns # of bytes copied
*/

extern RIScom_lower_strcpy(
	char * dst, 
	char * src)
{
	int i;
#ifdef WIN32
        int     str_size;
        wchar_t *tmp_src;
        wchar_t *tmp_dst;

        /* sending 0 to indicate null terminated string */
        RIScom_multiwide(&RISwide_ptr, &src, &RISwide_size, MULTITOWIDE, 0 );

        str_size = strlen(src) + 1;
        tmp_src = RISwide_ptr;
        tmp_dst = tmp_src;
#else
        char    *tmp_src;
        char    *tmp_dst;

        tmp_src = src;
        tmp_dst = dst;
#endif
        for ( i = 0; tmp_src[i]; i++ )
        {
            if ( ISUPPER(tmp_src[i]))
            {
                    tmp_dst[i] = TOLOWER(tmp_src[i]);
            }
			else
			{
                    tmp_dst[i] = tmp_src[i];
			}
       }
       tmp_dst[i] = WIDECHAR('\0');
#ifdef WIN32
       RIScom_wcstombs(dst, tmp_dst, str_size);
       return(strlen(dst));
#else
	return(i);
#endif
}

/*
**	This is strncpy except that characters are changed to uppercase 
**      if necessary.
**
**	Input Arguments:
**
**		dst - Destination pointer
**		src - Source pointer
** 		n   - Max # bytes to copy
**
**	Output:
**
**		returns # of bytes copied
*/

extern RIScom_upper_strncpy(
	char * dst, 
	char * src,
	int    n)
{
	int 	i;
	int     numchars;
#ifdef WIN32
	int		numbytes;
	int		mnum;
	int		snum;
	wchar_t *tmp_src;
	wchar_t *tmp_dst;	

	/* calculate the number of characters in the string based on the number of bytes */
	
	if ( n > 0 )
	{
		RIScom_numchars ( src, &mnum, &snum, n );
		numchars = mnum + snum;
	}
	else
		numchars = 0;

	/*numchars indicates the number of characters to convert from multi to wide */
	RIScom_multiwide(&RISwide_ptr, &src, &RISwide_size, MULTITOWIDE, numchars );

	tmp_src = RISwide_ptr;
	tmp_dst = tmp_src;
#else
	char    *tmp_src;
	char	*tmp_dst;

	tmp_src = src;
	tmp_dst = dst;
	numchars = n;
#endif
	for ( i = 0; i < numchars && tmp_src[i]; i++ )
	{
		if ( ISLOWER(tmp_src[i]))
		{
			tmp_dst[i] = TOUPPER(tmp_src[i]);
		}
		else
		{
			tmp_dst[i] = tmp_src[i];
		}
	}

#ifdef WIN32
	tmp_dst[i] = WIDECHAR('\0');
	RIScom_wcstombs(dst, tmp_dst, n);
	
	/* Calculate  number of bytes actually copied into dst */
	numbytes = RIScom_numbytes ( dst, i );
	
	if ( numbytes < n )
		dst[numbytes] = '\0';
	return( numbytes );
#else
	if ( i < n )
		tmp_dst[i] = WIDECHAR('\0');
	return(i);
#endif	
}

/*
**	This is strncpy with characters changed to lowercase if necessary.
**
**	Input Arguments:
**
**		dst - Destination pointer
**		src - Source pointer
**      n   - max # of bytes
**
**	Output:
**
**		returns # of bytes copied
*/
extern RIScom_lower_strncpy(
	char * dst, 
	char * src,
	int    n)
{
	int 	i;
	int     numchars;
#ifdef WIN32
	int		numbytes;
	int		mnum;
	int		snum;
	wchar_t *tmp_src;
	wchar_t *tmp_dst;	

	/* calculate the number of characters in the string based on the number of bytes */
	RIScom_numchars ( src, &mnum, &snum, n );
	numchars = mnum + snum;

	/*numchars indicates the number of characters to convert from multi to wide */
	RIScom_multiwide(&RISwide_ptr, &src, &RISwide_size, MULTITOWIDE, numchars );

	tmp_src = RISwide_ptr;
	tmp_dst = tmp_src;
#else
	char    *tmp_src;
	char	*tmp_dst;

	tmp_src = src;
	tmp_dst = dst;
	numchars = n;
#endif
	for ( i = 0; i < numchars && tmp_src[i]; i++ )
	{
		if ( ISUPPER(tmp_src[i]))
		{
			tmp_dst[i] = TOLOWER(tmp_src[i]);
		}
		else
		{
			tmp_dst[i] = tmp_src[i];
		}
	}

#ifdef WIN32
	tmp_dst[i] = WIDECHAR('\0');
	RIScom_wcstombs(dst, tmp_dst, n);
	
	/* Calculate  number of bytes actually copied into dst */
	numbytes = RIScom_numbytes ( dst, i );
	
	if ( numbytes < n )
		dst[numbytes] = '\0';

	return( numbytes );
#else
	if ( i < n )
		tmp_dst[i] = WIDECHAR('\0');
	return(i);
#endif	
}

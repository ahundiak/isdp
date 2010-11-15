/* Do not alter this PINNACLE information: $Revision: 1.2.28.1 $ */
/*
**	NAME:							comsusti.c
**	AUTHORS:						Hitesh Patel
**	CREATION DATE:					5/91
**	ABSTRACT:
**		It searches for a substring either in upper or
**		lower case.
**		
**	
**	REVISION HISTORY:
**		9/94:	Added support for INTERNATIONALIZATION. Paula Blohm
**
**				Fixed a problem where if the word you were looking for was the last word 
**				of the string, it would always return null.  Paula Blohm
*/
 
/*
**	INCLUDES
*/
#include <riscom.h>
#include <commacro.h>
#include <risdebug.h>
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
#define comsusti_c
#include "comsusti.prt"
#include "sys.prt"
#include "comstcmi.prt"
#include "comuni.prt"
#include "comdebug.prt"


/*
**	Input : first argument  => string
			second argument => substring

**	Output:	if found pointer to take substring in the string is returned
			else NULL is returned
*/

extern char *RIScom_substr_ic(
	char *string, 
	char *substring)
{
	int         retn;
        int         char_count;
        char        *ptr1;
        char        *hold_ptr;
	


#ifdef WIN32	
        /* send 0 to indicate null terminated string */
        wchar_t     *tmp_data;
        RIScom_multiwide (&RISwide_ptr, &string, &RISwide_size, MULTITOWIDE, 0 );
        tmp_data = RISwide_ptr;
#else
        char *tmp_data;
        tmp_data = string;
#endif
        /* pointer to step through the string, this is need for UNICODE */	
	ptr1 = string;
        COM_DBG(("RIScom_substr_ic: string <%s>\n", string ));
        COM_DBG(("RIScom_substr_ic: substring <%s>\n", substring ));

	while( *tmp_data != WIDECHAR('\0'))
	{
                char_count = 0;

		while( (*tmp_data == WIDECHAR(' ')) || (*tmp_data == WIDECHAR('\n')))
                {
                    tmp_data++;
                    ptr1 = RIScom_charnext(ptr1);
                }
                /* set a pointer to the beginning of the word in the string */
                hold_ptr = ptr1;

		while(( *tmp_data != WIDECHAR(' ')) && (*tmp_data != WIDECHAR('\0')))
		{
                    tmp_data++;
                    char_count++;
                    ptr1 = RIScom_charnext(ptr1);
		}

		retn = RIScom_strncmp_ic( hold_ptr, substring, char_count);
		
		if( !retn )
                {
                    COM_DBG(("RIScom_substr_ic: ptr into string <%s>\n", hold_ptr ));		
                    return ( hold_ptr );
                }
	}
	return ((char *) NULL);
}

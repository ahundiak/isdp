/*
******************************************************************************
** $Id: myctype.c 1.3.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Source: myctype.c
**
** This module implement data testing and conversion routines not supported
** by the standard C libraries.
******************************************************************************
*/

static char appl_version_id[] = "$Id: myctype.c 1.3.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $";

#include <ctype.h>
#include "myctype.h"

/*
==============================================================================
Function: allnumeric

Parameters:
    str - (IN) - String to be validated.

Description:
    This function scans the string "str" to see if all of the characters are
    digits.

Routines: none

Return Values:
    This function returns a boolean value: 0 -> "str" contains characters
    other than digits, 1 -> "str" contains only digits.
==============================================================================
*/

#if defined(_STD_C_)
int allnumeric (str)
    char *str;
#else
int allnumeric (char *str)
#endif
{
    int bool = 1;

    for (; *str; ++str) {
	if (!isdigit(*str)) {
	    bool = 0;
	    break;
	}
    }

    return bool;
}

/*
==============================================================================
Function: allhex

Parameters:
    str - (IN) - String to be validated.

Description:
    This function scans the string "str" to see if all of the characters are
    hexadecimal digits.

Routines: none

Return Values:
    This function returns a boolean value: 0 -> "str" contains characters
    other than digits, 1 -> "str" contains only digits.
==============================================================================
*/

#if defined(_STD_C_)
int allhex (str)
    char *str;
#else
int allhex (char *str)
#endif
{
    int bool = 1;

    for (; *str; ++str) {
	if (!isxdigit(*str)) {
	    bool = 0;
	    break;
	}
    }

    return bool;
}

/*
==============================================================================
Function: allalnum

Parameters:
    str - (IN) - String to be validated.

Description:
    This function determines whether or not the specified string contains
    ONLY alhpanumeric characters.

Routines: none

Return Values:
    This function returns a boolean value: 0 -> "str" contains nonaplhanumeric
    characters, 1 -> "str" contains only alphanumeric characters.
==============================================================================
*/

#if defined(_STD_C_)
int allalnum (str)
    char *str;
#else
int allalnum (char *str)
#endif
{
    int bool = 1;

    for (; *str; ++str) {
	if (!isalnum(*str)) {
	    bool = 0;
	    break;
	}
    }

    return bool;
}

/*
==============================================================================
Function: allprintable

Parameters:
    str - (IN) - String to be validated.

Description:
    This function determines whether or not the specified string contains
    ONLY printable ASCII characters.  No control character characters are
    permitted.

Routines: none

Return Values:
    This function returns a boolean value: 0 -> "str" contains non-printable
    characters, 1 -> "str" contains only printable characters.
==============================================================================
*/

#if defined(_STD_C_)
int allprintable (str)
    char *str;
#else
int allprintable (char *str)
#endif
{
    int bool = 1;

    for (; *str; ++str) {
	if ((*str < 0x20) || (*str >= 0x7f)) {
	    bool = 0;
	    break;
	}
    }

    return bool;
}

/*
==============================================================================
Function: ltoa

Parameters:

Description:

Routines:

Return Values:

==============================================================================
*/

#if defined(_STD_C_)
char *ltoa (lval, str)
    long lval;
    char *str;
#else
char *ltoa (long lval, char *str)
#endif
{
    long sign;              /* Used to remember the sign of the integer. */
    char *left = str;       /* Use temporary pointer to 's' when converting. */
    
    if (str) {
	if ((sign = lval) < 0) lval = -lval;
	
	do {                            /* Generate digits in reverse order. */
	    *left++ = lval % 10 + '0'; 
	} while ((lval /= 10) > 0);
	
	if (sign < 0) *left++ = '-';       /* If value was neg., insert '-'. */
	*left = '\0';                      /* Don't forget NULL terminator. */
	
	{
	    int  c;         /* Temporary holder for character being swapped. */
	    char *right;    /* Pointer to right portion of string. */
	    
	    for (right = str; *right; ++right) ;
	    for (left = str; left < --right; ++left) {
		c = *left;
		*left = *right;
		*right = c;
	    }
	}
    }
    
    return str;                         /* Return pointer to string. */
}


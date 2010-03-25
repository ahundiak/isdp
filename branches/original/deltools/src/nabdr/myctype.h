/*
******************************************************************************
** $Id: myctype.h 1.2.1.1.1.1 1997/09/08 21:48:36 pinnacle Exp $
******************************************************************************
** Header: myctype.h
**
** This module implement data testing and conversion routines not supported
** by the standard C libraries.
******************************************************************************
** Build Requirements
**
** Compilation Directives:
**
**     _STD_C_	       - Change Ansi code.
**
** Additional compilation requirements may be imposed by dependency sources.
** Consult these files for a description of their individual requirements.
******************************************************************************
*/

#if !defined(_MYCTYPE_H_)
#define _MYCTYPE_H_

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
int allnumeric ();
    char *str;
#else
int allnumeric (char *str);
#endif

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
int allhex ();
#else
int allhex (char *str);
#endif

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
int allalnum ();
#else
int allalnum (char *str);
#endif

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
int allprintable ();
#else
int allprintable (char *str);
#endif

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
char *ltoa ();
#else
char *ltoa (long lval, char *str);
#endif

#endif /* _MYCTYPE_H_ */

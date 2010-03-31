/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
NAME

    EFwhence -- ksh-whence-like function for one argument

SYNOPSIS

    # include "bstypes.h"
    # include "EMSerrordef.h"

    BSrc EFwhence (find, found)
    char find[];
    char found[];

DESCRIPTION

    EFwhence a takes the first string in the character array find
    and completely dereferences it as a command like whence of
    ksh (1).

    It places the dereferenced command in found.

RETURN VALUES

    If EFwhence is successful at dereferencing the string,
    EMS_S_Success is the returned value.

    If EFwhence cannot read one string from find,
    EMS_E_InvalidArg is returned.

    If EFwhence finds no dereferenced command for the string,
    EMS_I_NotFound is returned.

    If EFwhence encounters a warning, error or fatal error from
    EFmnyWhence, EMS_W_NotFound, EMS_E_NotFound or
    EMS_F_NotFound, respectively, will be the returned value.

HISTORY

    25-Nov-1986  Creation by J. Brooke King
*/

# include <stdio.h>
                    /* we do string i/o */
                    /* has BUFSIZ */
# include "bstypes.h"
                    /* has BSrc typedef */
# include "EMSerrordef.h"
                    /* EMS message codes */
# include "EMSjbklogic.h"
                    /* has IS and OR etc. */

BSrc EFwhence (find, found)
char find[], found[];
{
    char inBuffer[BUFSIZ];
    char *haveFound;
    int howMany;
    BSrc value;

    haveFound = found;
    howMany = sscanf (find, "%s", inBuffer);

    if (howMany != 1)
    {
        value = EMS_E_InvalidArg;
    }
    else
    {
        BSrc EFmnyWhence ();

        value = EFmnyWhence (inBuffer, &haveFound);
        if (value != EMS_S_Success)
        {
            value = (EMS_m_NotFound << 3) | EMS_SeverityLevel (value);
        }
        else
        {
            if (strlen (found) IS 0)
            {
                value = EMS_I_NotFound;
            }
        }
    }
    return value;
}

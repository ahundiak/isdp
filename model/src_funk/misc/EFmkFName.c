/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/*
NAME

    EFmkFName -- make a file name

SYNOPSIS

    # include "bstypes.h"

    BSrc EFmkFName (prototype, generated)
    char *prototype;
    char generated[];

DESCRIPTION

    Based upon the input variable prototype, EFmkFName generates
    a file name that is hopefully unique.

    If prototype is NULL or points to a string of length five or
    less which contains no "/"'s, then EFmkFName will use tempnam
    (3S).

    If prototype points to a string containing "/"'s (presumably
    a directory path) and having no more than 4 non-"/"
    characters after the final "/", then EFmkFName uses it's own
    rendition of mktmp (3C).

RETURN VALUES

    If EFmkFName is utterly successful, it returns EMS_S_Success.

    If it cannot make up a name with tempnam (3S), it returns
    EMS_E_Fail.

    If it cannot make up a name with EMS_E_MakeName.

NOTE

    If EFmkFName uses mktemp (3C), it is much less likely to run
    out of names, but it is theoretically possible to recurse
    very deeply to do so.  This should not be the case very
    often, however.

HISTORY

    25-Nov-1986  Creation by J. Brooke King

SEE ALSO

    mktemp (3C), tempnam (3S)
*/

# include <stdio.h>
                        /* we do string i/o */
# include <string.h>
                        /* we do string operations */
# include "EMSerrordef.h"
                        /* has EMS message codes */
# include "bstypes.h"
                        /* has BSrc typedef */
# include "EMSjbklogic.h"
                        /* has things like NOT and IS */

static BSrc incr4c (cc)
char cc[4];
{
    BSrc value = EMS_S_Success;

    if (++cc[3] > 'Z')
    {
        cc[3] = 'A';
        if (++cc[2] > 'Z')
        {
            cc[2] = 'A';
            if (++cc[1] > 'Z')
            {
                cc[1] = 'A';
                if (++cc[0] > 'Z')
                {
                    value = EMS_E_MakeName;
                }
            }
        }
    }
    return value;
}

BSrc EFmkFName (prototype, generated)
char prototype[], generated[];
{
    BSrc value = EMS_S_Success, incr4c ();
    static char cc[4] = {'A', 'A', 'A', 'A'};
 extern  char  *mktemp ();
    char *ptr;
    IGRboolean useMktemp = FALSE;

    if (prototype != NULL)
    {
        if (strchr (prototype, '/') != NULL)
        {
            useMktemp = TRUE;
        }
    }

    if (useMktemp)
    {
        (void)sprintf (generated, "%s%c%c%c%cXXXXXX",
            prototype, cc[0], cc[1], cc[2], cc[3]);

        ptr = mktemp (generated);
        if (NOT ptr)
        {
            value = incr4c (cc);

            if (value IS EMS_S_Success)
            {
                value = EFmkFName (prototype, generated);
            }
        }
    }
    else
    {
        char *name;

        name = (char *)tempnam (NULL, prototype);
        if (name)
        {
  extern             void free ();

            (void)strcpy (generated, name);
            free (name);
        }
        else
        {
            value = EMS_E_Fail;
        }
    }

    return value;
}

/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
NAME

    EFpathFrNam -- directory name and base name of a file name

SYNOPSIS

    # include "bstypes.h"
    # include "EMSerrordef.h"

    BSrc EFpathFrNam (filename, dirname, basename)
    char filename[];
    char dirname[];
    char basename[];

DESCRIPTION

    EFpathFrNam accepts an arbitrary UNIX style path name in
    filename and separates it into directory name (dirname) and
    base name (basename) parts.

RETURN VALUES

    If EFpathFrNam finds both the directory name and base name,
    it returns EMS_S_Success.

    If a non-null string cannot be read from filename,
    EMS_E_InvalidArg is returned.

    If only the base name is found, EMS_I_BaseName is the
    returned value.

    If only the directory name is found, EMS_I_DirName is the
    returned value.

    If neither is found, EMS_E_NotFound is returned.  This should
    not happen.

HISTORY

    25-Nov-1986  Creation by J. Brooke King
*/

# include <stdio.h>
                    /* we do string i/o */
                    /* has BUFSIZ */
# include <string.h>
                    /* we do string operations */
# include "bstypes.h"
                    /* has BSrc typedef */
# include "EMSerrordef.h"
                    /* has EMS message codes */
# include "EMSjbklogic.h"
                    /* has fun logical definitions */

BSrc EFpathFrNam (filename, dirname, basename)
char filename[], dirname[], basename[];
{
    char buffer[BUFSIZ];
    int howMany;
    BSrc value = EMS_S_Success;

    howMany = sscanf (filename, "%s", buffer);
    if (howMany != 1)
    {
        value = EMS_E_InvalidArg;
    }
    else
    {
        int len;

        len = strlen (buffer);
        if (len IS 0)
        {
            value = EMS_E_InvalidArg;
        }
        else
        {
            IGRboolean dir = FALSE, name = FALSE;
            char *slash;

            slash = strrchr (buffer, '/');
            if (slash)
            {
                slash++;
                (void)strcpy (basename, slash);
                slash--;
            }
            else
            {
                (void)strcpy (basename, buffer);
            }
            name = (strlen (basename) > 0);

            if (slash)
            {
                if (slash IS buffer)
                {
                    dirname[0] = '/';
                    dirname[1] = '\0';
                }
                else
                {
                    char *to, *from = NULL;

                    to = dirname;
                    from = buffer;
                    do
                    {
                        *to++ = *from++;
                    } while (from != slash);
                    *to = '\0';
                }
                dir = TRUE;
            }
            else
            {
                dirname = '\0';
            }
            
            if (name AND NOT dir)
            {
                value = EMS_I_BaseName;
            }
            else if (NOT name AND NOT dir)
            {
                value = EMS_E_NotFound;
            }
            else if (dir AND NOT name)
            {
                value = EMS_I_DirName;
            }
        }
    }

    return value;
}

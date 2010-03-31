/* ###################   APOGEE COMPILED   ################## */

#include "EMS.h"

/*
NAME

    EFmnyWhence -- ksh-whence-like function for many arguments

SYNOPSIS

    # include "bstypes.h"
    # include "EMSerrordef.h"

    BSrc EFmnyWhence (find, found)
    char find[];
    char *found[];

DESCRIPTION

    EFmnyWhence accepts one or more arguments concatenated
    together in the string in the array find.

    It fills in each of the strings pointed to by the array of
    pointers in found with the paths to and arguments of the
    corresponding command in the argument list.  If the command
    is not dereferenced, it will have a corresponding null
    string.

RETURN VALUES

    If EFmnyWhence is successful, EMS_S_Success is the returned
    value.

    If the string in find is of zero length, EMS_E_InvalidArg is
    returned.

    If it is not possible to find a temporary file name,
    EMS_E_MakeName is returned.

    If it is not possible to open a temporary file for write
    access, EMS_E_FileOpen is returned.

    If BSstackalloc fails, EFmnyWhence returns
    EMS_F_NoStackMemory.

    If EFmnyWhence was unable to open a pipe for reading from a
    subprocess, EMS_E_PipeOpen is the returned value.

    EMS_E_PipeRead is returned if either EFgetln from the pipe
    returns a NULL pointer or an fscanf on the pipe does not work
    as expected.  This indicates problems reading from the pipe.

    If there is a problem unlinking the temporary file,
    EMS_W_Unlink is returned.

HISTORY

    25-Nov-1986  Creation by J. Brooke King
    17-Nov-1992  Added the #define for _INGR_EXTENSIONS so that file compiles
                 in ANSI mode on clipper. See comments below.
    09-jul-1993  Sudha  Modified for BSprototypes anisfication

*/

#define _INGR_EXTENSIONS /* for "popen" (on CLIPPER), which in NOT ANSI 
                          * standard. However, "popen" IS currently defined 
                          * on SUN and SGI. But this issue has to be resolved 
                          * when we move to NT. We dont need something non-ANSI.
                          */

# include <stdio.h>
                            /* we do string and pipe i/o */
                            /* has BUFSIZ */
# include <string.h>
                            /* do string operations */
# include "EMSerrordef.h"
                            /* has EMS message codes */
# include "bstypes.h"
                            /* has BSrc typedef */
# include "bsstackalloc.h"
                            /* has BSstackalloc, etc. */
# include "EMSjbklogic.h"
                            /* has things like NOT and IS */

#include "bserr.h"
#include "bsdbgsfree.h"
#include "bsdbgsalloc.h"

BSrc EFmnyWhence (find, found)
char find[], *found[];
{
    BSrc value = EMS_S_Success;
    char filename[BUFSIZ];
    FILE *fp=NULL;

    if (strlen (find) IS 0)
    {
        value = EMS_E_InvalidArg;
    }

    if (value IS EMS_S_Success)
    {
        BSrc EFmkFName ();

/*        value = EFmkFName ("/usr/tmp/EFwh", filename);*/
        value = EFmkFName ("EFwhn", filename);
        if (value IS EMS_E_Fail)
        {
            value = EMS_E_MakeName;
        }
    }

    if (value IS EMS_S_Success)
    {
        BSrc EFmkWhenceK ();

        value = EFmkWhenceK (filename);
    }

    if (value IS EMS_S_Success)
    {
        char buffer[BUFSIZ];
        char *command = buffer;
        char *mallocbuf = NULL;
        int len;

        len = (strlen (find) + strlen (filename) + 6);

        if (len > BUFSIZ)
        {
            mallocbuf = BSstackalloc ((unsigned)len);
            command = mallocbuf;
            if (NOT mallocbuf)
            {
                value = EMS_F_NoStackMemory;
            }
        }
        
        if (value IS EMS_S_Success)
        {
            (void)sprintf (command, "ksh %s %s", filename, find);

            fp = (FILE *)popen (command, "r");
            if (NOT fp)
            {
                value = EMS_E_PipeOpen;
            }

            if (mallocbuf) BSstackdealloc (mallocbuf);
        }
    }

    if (value IS EMS_S_Success)
    {
        int dq, num;

        dq = fscanf (fp, "%d", &num);
        if (dq IS 1 AND num > 0)
        {
            BSrc EFreadln ();
            int ii;

            for (ii = 0; ii < num; ii++)
            {
                BSrc EFgetln ();
                char buffer[BUFSIZ];

                (void)EFreadln (fp);

                if
                  (EFgetln (fp, BUFSIZ, buffer) IS EMS_S_Success)
                {
                    (void)strcpy (found[ii], buffer);
                }
                else value = EMS_E_PipeRead;
            }

            (void)pclose (fp);
        }
        else value = EMS_E_PipeRead;
    }

    if (value IS EMS_S_Success)
    {
        int dq;

        dq = unlink (filename);
        if (dq)
        {
            value = EMS_W_Unlink;
        }
    }

    return value;
}

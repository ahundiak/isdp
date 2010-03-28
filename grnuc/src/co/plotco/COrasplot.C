/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COrasplot

Description
        This file contains fuctions used to create and read the 
        auxiliary plot file containing raster data.

History
        mrm     12/20/89    creation
        scw     07/17/92    ansi conversion
*/

#ifndef STANDALONE
#include "coimport.h"
#endif
#include <stdio.h>
#include <limits.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "msdef.h"


static FILE *rasfileptr = NULL;
static char *rasfilespec = NULL;
static char *rasfilename = NULL;
static char *rasext = ".ras";


/*
Name
        COinitraspf

Description
        This function creates a filename for the raster file which will
        be created along with an IGDS plotfile when raster elements in a
        design file are to be plotted.  The filename will be the
        plotfile name with a ".r" appended, truncating the plotfile name
        if necessary.  The file will be in the same directory as the
        plotfile.  The raster file is NOT opened here; it is opened on
        first reference by the raster plotting methods. 
*/

IGRint COinitraspf (msg, plotfile)
IGRlong *msg;
IGRchar *plotfile;
{
    IGRint i,j, k;
    IGRchar *c;

    *msg = MSSUCC;

    /* build the full pathname of the raster file */

    i = strlen (plotfile);
    if (rasfilespec = om$malloc (size = i + 16))    /* room to fiddle in */
    {
        strcpy (rasfilespec, plotfile);
        if (rasfilename = strrchr (rasfilespec, '/'))
        {
            rasfilename++;
        }
        else
        {
            rasfilename = rasfilespec;
        }

        /* get a filename for the raster file - existing file will be */
        /* overwritten (user is warned about overwriting plotfile, so */
        /* the raster file is included in that warning) */

        if (c = strrchr (rasfilespec, '.'))
        {
            *c = NULL;
        }

        j = GRFILENAME_SIZE - strlen (rasext);
        if (strlen (rasfilename) > j)
        {
            for (k = j, i = 0; k < GRFILENAME_SIZE; k++, i++)
                rasfilename[k] = rasext[i];
            rasfilename[GRFILENAME_SIZE] = NULL;
        }
        else
        {
            strcat (rasfilename, rasext);
        }
    }
    else
    {
        *msg = MSFAIL;
    }

    return (*msg & 1);
}


/*
Name
        COcloseraspf

Description
        This function will close the raster plotting file, if it has been
        referenced during the creation of a plotfile.
*/

IGRint COcloseraspf (msg)
IGRlong *msg;
{
    *msg = MSSUCC;

    if (rasfileptr)
    {
        fclose (rasfileptr);
        rasfileptr = NULL;
    }

    if (rasfilespec)
    {
        om$dealloc (ptr = rasfilespec);
    }

    rasfilename = NULL;

    return (1);
}


/*
Name
        COgetraspf

Description
        This function will return the name and file pointer of a
        raster file to be associated with a plotfile.  The return
        of either value may be suppressed with a NULL pointer.

Synopsis
        IGRint COgetraspf (msg, filename, fileptr)

        IGRlong *msg;       O   return code
        IGRchar *filename;  O   name of raster file (no directory info)
        FILE **fileptr;     O   open file pointer

Return Values
        IGRint ()           TRUE - success; FALSE - failure
        msg                 MSSUCC - success; MSFAIL - failure
*/

IGRint COgetraspf (msg, filename, fileptr)
IGRlong *msg;
IGRchar *filename;
FILE **fileptr;
{
    *msg = MSFAIL;

    if (rasfileptr == NULL)
    {
        rasfileptr = fopen (rasfilespec, "w");
    }
    if (rasfileptr)
    {
        *msg = MSSUCC;
        if (fileptr) *fileptr = rasfileptr;
        if (filename) strcpy (filename, rasfilename);
    }
    return (*msg & 1);
}

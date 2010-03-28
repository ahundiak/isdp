/*
Name
        GRLocInfo

Description
        This file contains routines that are used to produce information about
        the locate process.

History
        mrm     05/01/92    creation
        scw     07/10/92    ansi conversion
*/

class implementation GRvg;

#include <stdio.h>
#include "UMS.h"

%safe
static IGRchar filebuffer[128] = {0};
static IGRint LocateInfoStdout = TRUE;
static IGRint LocateInfoFlags = 0;
static FILE *outfile = NULL;
%endsafe

IGRint GRPutLocateInfoFlags(flags)
IGRint flags;
{
    LocateInfoFlags = flags;
    return(LocateInfoFlags);
}

IGRint GRGetLocateInfoFlags(flags)
IGRint *flags;
{
    if (flags) *flags = LocateInfoFlags;
    return(LocateInfoFlags);
}

IGRint GRPutLocateInfoOutput(to_stdout, filename)
IGRint to_stdout;
IGRchar *filename;
{
    if (!LocateInfoStdout)
    {
        fclose(outfile);
    }

    if (LocateInfoStdout = to_stdout)
    {
        outfile = (FILE *)stdout;
    }
    else
    {
        if (outfile = (FILE *)fopen(filename, "a"))
        {
            strcpy(filebuffer, filename);
        }
        else
        {
            outfile = (FILE *)stdout;
            LocateInfoStdout = TRUE;
            return(FALSE);
        }
    }
    return(TRUE);
}


IGRint GRGetLocateInfoOutput(to_stdout, filename)
IGRint *to_stdout;
IGRchar *filename;
{
    *to_stdout = LocateInfoStdout;
    strcpy(filename, filebuffer);
    return(TRUE);
}

IGRint GRLocInfo(flags, msgnum, osnum, objid)
IGRint flags, msgnum;
OMuword osnum;
OM_S_OBJID objid;
{
    if (LocateInfoFlags)
    {
        if (LocateInfoFlags & flags)
        {
            IGRint sts;
            IGRchar buf[128];

            sts = UMSGetByNum(buf, msgnum, "%d%d", osnum, objid);
            if (sts != UMS_S_SUCCESS)  
                sprintf(buf, "Failed to find message number %#x", msgnum); /* Debug message */
            fprintf(outfile, "%s\n", buf);
            if ((LocateInfoFlags & GRVerboseLocateInfo) &&
                (objid != NULL_OBJID))
            {
                *buf = NULL;
                om$get_classname(objid = objid,
                                 osnum = osnum,
                                 classname = buf);
                sprintf(&buf[strlen(buf)], " - ");
                LCget_info(objid, osnum, &buf[strlen(buf)]);
                fprintf(outfile, "\t%s\n", buf);
            }
        }
    }
    return(TRUE);
}

end implementation GRvg;

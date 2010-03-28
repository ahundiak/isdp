/*
Name
        COspexecute

Description
        This function handles the execute request from the Submit Plot
        form.

Notes
        This file uses direct UMS calls for messages, rather than ex$message,
        so that standalone compilation of a Submit Plot executable is
        possible.  Use ex$message in here and I will kick your butt.

History
        mrm     03/22/89    creation
	sampath 06/30/92    added rotation
*/

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "msdef.h"
#include "msmacros.h"
#include "plotmsg.h"
#include "FI.h"
#include "pidef.h"
#include "pi.h"

extern char *strrchr();

static int rotate_via_iplot = -1;

int COspexecute (pd, result)
PIplotdata *pd;
char *result;
{
    int sts;
    char *c;

    sts = PI_F_FAIL;

    /* verify that enough information is present to submit a plot */

    if (strlen (pd->file) == 0)
    {
        UMSGetByNum(result, PI_P_EntFlNme, 0);
        FIfld_set_text (pd->submit_form, FI_MSG_FIELD, 0, 0, result, 0);
        goto finish;
    }

    if (strlen (pd->queue) == 0)
    {
        UMSGetByNum(result, PI_P_SpecifyQ, 0);
        FIfld_set_text (pd->submit_form, FI_MSG_FIELD, 0, 0, result, 0);
        goto finish;
    }

    /* check for an accompanying raster file */

    COfindrastype90 (&sts, pd->file, pd->raster, pd->shvar);

    if (sts == PI_F_NORASFILE)
    {
        UMSGetByNum(result, PI_E_NoRasterFile, "%s", pd->raster);
        FIfld_set_text (pd->submit_form, FI_MSG_FIELD, 0, 0, result, 0);
        goto finish;
    }

    /* check whether to rotate the plot via IPLOT */

    if (rotate_via_iplot == -1)
        rotate_via_iplot = getenv("ROTATE_VIA_IPLOT") ? TRUE : FALSE;

    if ((pd->iplot[0] && (pd->filetype == PI_IGDS_FILE)) ||
	(pd->rotate_90 && (rotate_via_iplot == TRUE)))
    {
        /* submit the plot through InterPlot */

        sts = COiplot (pd, result);
    }
    else
    {
        /* submit the plot through NQS */

        sts = COqprreq (pd, result);
        result[64] = NULL;
        FIfld_set_text (pd->submit_form, FI_MSG_FIELD, 0, 0, result, 0);
    }

    if (sts & 1)
    {
        /* save the job information */

        strncpy (pd->lastjobqueue, pd->queue, 32);
        if (c = strrchr (pd->file, '/'))
            c++;
        else
            c = pd->file;
        sprintf (pd->lastjobname, c, 16);
        if (pd->iplot[0] && (pd->filetype == PI_IGDS_FILE))
        {
            sscanf (result, "%*s %*s %s", pd->lastjobid);
        }
        else
        {
            sscanf (result, "%*s %s", pd->lastjobid);
        }
    }

finish:

    return (sts);
}

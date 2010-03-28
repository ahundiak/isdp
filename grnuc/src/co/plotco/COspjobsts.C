/*
Name
        COspjobsts

Description
        This function finds out the status of the last job submitted
        to NQS for plotting.  The last job specification information
        is required as input to this routine; a buffer is filled in
        with the requested information on exit.

Notes
        This file uses direct UMS calls for messages, rather than ex$message,
        so that standalone compilation of a Submit Plot executable is
        possible.  Use ex$message in here and I will kick your butt.

History
        mrm     03/30/89    creation
                11/02/89    check local and destination queue
        scw     07/17/92    ansi conversion
*/

#include <stdio.h>
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

extern FILE *popen();
extern int strcmp();
extern char *strchr();


int COspjobsts (jobq, jobid, jobname, outbuf)
char *jobq, *jobid, *jobname, *outbuf;
{
    int sts;
    char qtype, dset[128];

    sts = PI_F_FAIL;
    outbuf[0] = NULL;

    if (jobq[0] == NULL || jobid[0] == NULL || jobname == NULL)
    {
        UMSGetByNum(outbuf, PI_I_NoJobInfo, 0);
    }
    else
    {
        qtype = NULL;
        dset[0] = NULL;

        /* check for the job in the specified queue */

        sts = COspckjobsts (jobq, jobid, jobname, outbuf, &qtype, dset);

        if (!(sts & 1) && qtype == 'P')
        {
            sts = COspckjobsts (jobq, jobid, jobname, outbuf, &qtype, dset);
        }
    }

    return (sts);
}


#argsused
int COspckjobsts (jobq, jobid, jobname, outbuf, qtype, dset)
char *jobq, *jobid, *jobname, *outbuf, *qtype, *dset;
{
    int sts, i, looking;
    char buf[128], buf1[128], buf2[128], *c, *q;
    char jobnum[128], reqname[128], reqid[128], state[128];
    FILE *pp = NULL;

    sts = PI_F_FAIL;

    /* decide which queue to check; either local pipe or remote device */

    q = (dset[0] == NULL) ? jobq : dset;

    sprintf (buf, "qstat -ax %s 2>&1", q);

    COplotlog(buf);

    pp = popen (buf, "r");

    if (pp == NULL ||
        ! fgets (buf, sizeof (buf), pp) ||
        !(c = strchr (buf, '=')))
    {
        sts = PI_F_QSTAT;
        goto finish;
    }

    COplotlog(buf);

    /* grab the queue type while it is handy */

    *qtype = ( *(++c) == 'D') ? 'D' : 'P';

    /* look for the Destset or Devset line */

    i = 0;
    while ((fgets (buf, sizeof (buf), pp) != NULL) && (i++ < 20))
    {
        COplotlog(buf);
        sscanf (buf, "%s %*s %s", buf1, buf2);
        if (strcmp (buf1, "Destset") == 0 || strcmp (buf1, "Devset") == 0)
        {
            if (dset[0] == NULL)
            {
                c = buf2;
                while (*c != '}') c++;
                *c = NULL;
                c = buf2 + sizeof (char);
                strncpy (dset, c, 128);
            }
            break;
        }
    }

    /* ignore next two lines */

    for (i = 0; i < 2; i++)
    {
        if (fgets (buf, sizeof (buf), pp) == NULL && buf[0] != '\n')
        {
            COplotlog(buf);
            UMSGetByNum(outbuf, PI_I_NoJobsInQ, 0);
            goto finish;
        }
    }

    /* look for the specified job */

    i = 0;
    looking = 1;
    while ((fgets (buf, sizeof (buf), pp) != NULL) && (i++ < 1000))
    {
        COplotlog(buf);
        sscanf (buf, "%s %s %s %*s %*s %s", jobnum, reqname, reqid, state);

        if (looking && (strcmp (reqid, jobid) == 0))
        {
            sprintf (outbuf, "%s: Job %s %s %s %s",
                     q, jobnum, reqname, reqid, state);
            sts = PI_S_SUCCESS;
            looking = 0;
        }
    }

    if (sts != PI_S_SUCCESS)
    {
        sprintf (outbuf, "%s: %s %s unknown", q, reqname, reqid);
    }

finish:

    if (pp)
        pclose (pp);

    return (sts);
}

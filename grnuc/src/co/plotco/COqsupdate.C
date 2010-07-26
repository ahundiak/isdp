/*
Name
        COqsupdate

Description
        This function updates the queue status information on the Plot
        Queue Status form.

Notes
        This file uses direct UMS calls for messages, rather than ex$message,
        so that standalone compilation of a Submit Plot executable is
        possible.  Use ex$message in here and I will kick your butt.

History
        mrm     03/23/89    creation
        scw     07/17/92    ansi conversion
        Carlos M. Diaz
                03/01/93    header and message system compliance for the
                            entries where STANDALONE is defined. This
                            pre-processor directive had been used in the past
                            to build a separate executable. This executable
                            may not link with the ex$message macro. I left the
                            old lines just in case somebody needs to build
                            that executable...
        mrm     11/15/93    Full UMS conversion to fix the mess Carlos made of
                            the STANDALONE utility 
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
#include "pilabel.h"
#include "pidef.h"
#include "pi.h"

extern FILE *popen();
extern char *fgets(), *strchr();
extern int strncmp();
extern int FIfld_set_text ();
extern int FIg_display ();
extern int FIg_erase ();
extern int FIg_reset ();
extern int FIg_set_text ();

#argsused
int COqsupdate (pd, form_label, gadget_label, value, form)
PIplotdata *pd;
int form_label;
int gadget_label;
double value;
Form form;
{
    int sts = 0, i, row, sel;
    char buf[128];
    FILE *pp = NULL;

    /* clear the job list field */

    FIg_reset (form, QSTATUS_JOB_LIST);
    FIg_display (form, QSTATUS_JOB_LIST);

    /* get the command to run from the field on the form (allows the */
    /* user to alter the command, added options, ... ) */

    FIfld_get_text (form, QSTATUS_QUEUE, 0, 0, 128, buf, &sel, &row);

    if (strlen (buf) == 0)
    {
        sts = PI_F_NOQUEUE;
        UMSGetByNum(buf, PI_E_SpecifyQ, 0);
        goto finish;
    }

    /* command line must be a qstat command (prevent user self-mutiliation) */

    if (strncmp (buf, "qstat", 5))
    {
        UMSGetByNum(buf, PI_E_InvInp, 0);
        goto finish;
    }

    /* open a pipe to the command output */
    COplotlog(buf);
    pp = popen (buf, "r");

    if (pp == NULL)
    {
        sts = PI_F_QSTAT;
        UMSGetByNum(buf, PI_E_CantExe, "%s", "qstat");
        goto finish;
    }

    /* copy the command output to the form */

    i = -1;
    while ((fgets (buf, sizeof (buf), pp) != NULL) && (i++ < 1000))
    {
        COplotlog(buf);
        FIfld_set_text (form, QSTATUS_JOB_LIST, i, 0, buf, 0);
    }

    buf[0] = NULL;

    sts = PI_S_SUCCESS;

finish:

    if (pp)
        pclose (pp);

    FIfld_set_text (form, FI_MSG_FIELD, 0, 0, buf, 0);

    return (sts);
}


/*
Name
        COqsgetq

Description
        This function returns a command line suitable for use as a
        command line to show the status of the device queue pointed
        to by the input queue name.
*/

IGRint COqsgetq (queue, cmdline)
IGRchar *queue, *cmdline;
{
    int sts, i;
    char buf[128], *c, qatnode[128], buf1[128], buf2[128];
    FILE *pp = NULL;

    sts = PI_S_SUCCESS;

    /* format a command line to figure out what queue@node to display */

    sprintf (buf, "qstat -x %s 2>&1", queue);
    COplotlog(buf);
    if ((pp = popen (buf, "r")) == NULL)
    {
        sts = PI_F_QSTAT;
        goto finish;
    }

    /* look for the Destset or Devset line */

    i = 0;
    qatnode[0] = NULL;
    while ((fgets (buf, sizeof (buf), pp) != NULL) && (i++ < 20))
    {
        COplotlog(buf);
        sscanf (buf, "%s %*s %s", buf1, buf2);
        if (strcmp (buf1, "Destset") == 0 || strcmp (buf1, "Devset") == 0)
        {
            c = buf2;
            while (*c != '}') c++;
            *c = NULL;
            c = buf2 + sizeof (char);
            strncpy (qatnode, c, 128);
            break;
        }
    }

    pclose (pp);

    c = (qatnode[0]) ? qatnode : queue;

    /* format a command line to get the desired queue status */

    sprintf (cmdline, "qstat -a %s 2>&1 ", c);

finish:

    return (sts);
}

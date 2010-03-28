/*
Name
        COqscancel

Description
        This function handles a cancel job request from the Plot
        Queue Status form.

Notes
        This file uses direct UMS calls for messages, rather than ex$message,
        so that standalone compilation of a Submit Plot executable is
        possible.  Use ex$message in here and I will kick your butt.

History
        mrm     03/24/89    creation
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
#include "pilabel.h"
#include "pidef.h"
#include "pi.h"

extern FILE *popen();
extern char *fgets(), *strchr();
extern int FIfld_get_num_rows ();
extern int FIfld_get_text ();
extern int FIfld_set_select ();
extern int FIfld_set_text ();
extern int FIg_display ();


#argsused
int COqscancel (form_label, gadget_label, value, form)
int form_label;
int gadget_label;
double value;
Form form;
{
    char buf[128], buf1[128], *c, *c2, *j, jobid[128];
    int sts, i, rpos, sel;
    FILE *pp;
    PIplotdata *pd;

    sts = PI_F_FAIL;

    /* get a pointer to the current plot data */

    PIgetplotdata (&pd);

    if (strlen (pd->jobtocan) == 0)
    {
        UMSGetByNum(buf, PI_P_IdJob, 0);
        FIfld_set_text (form, FI_MSG_FIELD, 0, 0, buf, 0);
        FIg_display (form, FI_MSG_FIELD);
    }
    else
    {
        /* get the nodename of the job to cancel from the job list field */

        FIfld_get_text (form, QSTATUS_JOB_LIST, 0, 0, 30, buf1, &sel, &rpos);
        if (c = strchr (buf1, '@'))
        {
            if (c2 = strchr(c, ';'))
            {
                *c2 = NULL;
            }
        }
        else
        {
            buf1[0] = NULL;
            c = buf1;
        }

        /* strip the domain from the job spec */
        strcpy(jobid, pd->jobtocan);
        if (j = strchr(jobid, (int)'.'))
            if (j = strchr(j + 1, (int)'.'))
                *j = NULL;

        /* open a pipe to the qdel command */

        sprintf (buf, "qdel -k %s%s 2>&1", jobid, c);

        COplotlog(buf);

        pp = popen (buf, "r");

        if (pp == NULL)
        {
            UMSGetByNum(buf, PI_E_CantExe, "%s", "qdel");
            FIfld_set_text (form, FI_MSG_FIELD, 0, 0, buf, 0);
            FIg_display (form, FI_MSG_FIELD);
        }
        else
        {
            /* get the results of the job deletion */

            if (fgets (buf, sizeof (buf), pp) == NULL)
            {
                UMSGetByNum(buf, PI_E_CantCanJob, "%s", pd->jobtocan);
            }

            /* display the qdel results */

            COplotlog(buf);
            FIfld_set_text (form, FI_MSG_FIELD, 0, 0, buf, 0);
            FIg_display (form, FI_MSG_FIELD);

            /* close the pipe */

            pclose (pp);

            /* figure out whether a job was deleted */

            if (sscanf (buf, "%*s %*s %*s %*s %s", buf1))
            {
                if (strncmp (buf1, "deleted.", 8) == 0)
                {
                    sts = PI_S_SUCCESS;
                }
            }

            /* find the row on the form which lists the deleted job */

            FIfld_get_num_rows (form, QSTATUS_JOB_LIST, &i);

	    i--;
            while (i >= 0)
            {
                FIfld_get_text (form, QSTATUS_JOB_LIST, i, 0, 128,
                                buf, &sel, &rpos);
                sscanf (buf, "%*s %*s %s", buf1);
                if (strcmp (pd->jobtocan, buf1) == 0)
                {
                    /* erase/unhilite the entry in question */

                    if (sts == PI_S_SUCCESS)
                    {
                        FIfld_set_text (form, QSTATUS_JOB_LIST, i, 0, "", 0);
                        FIg_display (form, QSTATUS_JOB_LIST);
                    }
                    else
                    {
                        FIfld_set_select (form, QSTATUS_JOB_LIST, i, 0, 0);
                    }
                    break;
                }
                i--;
            }

            pd->jobtocan[0] = NULL;
        }
    }
    return (sts);
}

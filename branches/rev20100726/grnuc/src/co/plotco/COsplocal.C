/*
Name
        COsplocal

Description
        This function handles the local execute request from the Submit Plot
        form.

Notes
        The igds2hpgl command line uses the -f input_file_name option.  This
	is an undocumented, and therefore unsupported, switch.  It is used
	since the <input_file_name construct does not return an error if
	the file name specified is invalid.

        This file uses direct UMS calls for messages, rather than ex$message,
        so that standalone compilation of a Submit Plot executable is
        possible.  Use ex$message in here and I will kick your butt.

History
        madhu     /  /90    creation
        mrm	10/17/90    modified to popen igds2hpgl directly
	madhu   11/27/90    added local plot scaling function
        mrm     03/14/91    added DEV_ATT and IGDSPATH env variables
	Carlos  03/02/93    message system compliance
        mrm     11/15/93    INGRHOME changes, ex$message to UMS
*/

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
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
#include "pilabel.h"
#include "exmacros.h"
#include "griodef.h"
#include "griomacros.h"

extern char *strrchr(), *getenv();
extern FILE *popen();

static char odi_errmsgfile[128] = {" "};
static char dev_att[128];
static char igdspath[128];

int COsplocal (pd, result)
PIplotdata *pd;
char *result;
{
    int sts, i;
    char *tmpdir, cmd[256], buf[128], bin[128];
    char hpglfile[128], errfile[128];
    double x, y;
#ifndef STANDALONE
    double one_wu;
    OMuword osnum;
#endif
    struct stat statbuf;
    FILE *pp = NULL;

    sts = PI_S_SUCCESS;
    *result = NULL;

    /* verify that enough information is present to submit a plot */

    if (strlen (pd->file) == 0)
    {
        UMSGetByNum(result, PI_P_EntFlNme, 0);
        FIfld_set_text (pd->submit_form, FI_MSG_FIELD, 0, 0, result, 0);
        goto finish;
    }

    if (strlen (pd->port) == 0)
    {
        UMSGetByNum(result, PI_I_EnterPortName, 0);
        FIfld_set_text (pd->submit_form, FI_MSG_FIELD, 0, 0, result, 0);
        goto finish;
    }

#ifdef STANDALONE

    /* do nothing to the sizes, assume inches (for testing only) */

    x = pd->lplot_x;
    y = pd->lplot_y;

#else	

    /* convert the plot size to inches */

    ex$get_cur_mod (osnum = &osnum);

    co$cvt_exp_to_wrk (msg = &sts, 
                       unit_type = "UOM_DISTANCE",
                       osnum = osnum,
                       units = 1.0,
                       alias = "in",
                       result = &one_wu);

    x = pd->lplot_x / one_wu;
    y = pd->lplot_y / one_wu;

#endif

    /* find the path to GRNUC */

    buf[0] = NULL;
#ifdef STANDALONE
    GRget_product_data("Grnuc", NULL, NULL, NULL, NULL, buf);
#else
    get_modtype_data("Grnuc", NULL, NULL, NULL, NULL, buf);
#endif
    if (buf[0] == NULL)
    {
        /* Cannot find grnuc, and therefore igds2hpgl */
	UMSGetByNum(result, PI_E_CantFindGrnuc, 0);
        goto finish;
    }

    sprintf (bin, "%sbin/", buf);

    if (odi_errmsgfile[0] == ' ')
    {
        /* Export the path to the ODI error message file - this file
           contains messages that will be printed to stderr if igds2hpgl
           runs into problems.  Note that this string must be static
	   since the call to putenv will cause environ to point to
	   this string rather than making a local copy. */

	sprintf (odi_errmsgfile, "ODI_ERRMSGFILE=%sploterr.msg", bin);
	putenv (odi_errmsgfile);

        /* Export the path to the message files igdserr.msg and stroke.msg */

        sprintf(igdspath,"IGDSPATH=%s",bin);
        putenv(igdspath);

        /* Export the path to the HPGL device attributes file */

        sprintf(dev_att,"DEV_ATT=%shpglof.db",bin);
        putenv(dev_att);
    }

    /* get a temporary filename for the error file */

    if (!(tmpdir = getenv("TMPDIR")) || 
        stat(tmpdir,&statbuf) || (strlen(tmpdir) > 112))
    {
        tmpdir = "/usr/tmp";
    }
    sprintf (errfile, "%s/hpglerrXXXXXX", tmpdir);
    mktemp (errfile);

    /* build a command line for igds2hpgl */    

    sprintf (cmd,
             "%sigds2hpgl -d %sHPGLOF.b -l %sconfig/fontlib -e %lfx%lf -f %s",
             bin, bin, buf, x, y, pd->file);

    if (pd->lcopies > 1)
    {
        /* store hpgl in a temporary file */

	sprintf (hpglfile, "%s/hpglXXXXXX", tmpdir);
        mktemp (hpglfile);
        sprintf (buf, " -o %s >%s 2>&1", hpglfile, errfile);
    }
    else
    {
        /* pipe hpgl directly out the port */

        sprintf (buf, " -o %s >%s 2>&1", pd->port, errfile);
    }

    strcat (cmd, buf);

    COplotlog(cmd);

    /* open a pipe to the igds2hpgl command */

    if (pp = popen (cmd, "r"))
    {
        while (fgets (buf, sizeof (buf), pp) != NULL)
            COplotlog(buf);
        pclose (pp);
    }
    else
    {
        sts = PI_F_FAIL;
        UMSGetByNum(result, PI_E_CantExe, "%s", cmd);
    }

    /* if multiple copies were requested... */

    if (pd->lcopies > 1)
    {
        /* ...format a command... */

        sprintf (cmd, "cat %s >%s 2>%s", hpglfile, pd->port, errfile);

        /* ...and run that command for each copy requested */

        for (i = 0; i < pd->lcopies; i++)
        {
            COplotlog(cmd);
            if (pp = popen (cmd, "r"))
            {
                while (fgets (buf, sizeof (buf), pp) != NULL)
                    COplotlog(buf);
                pclose (pp);
            }
            else
            {
                sts = PI_F_FAIL;
                UMSGetByNum(result, PI_E_CantExe, "%s", cmd);
            }
        }

        /* remove the hpgl file */

        unlink (hpglfile);
    }

    /* check for errors in the errfile */

    if (pp = fopen (errfile, "r"))
    {
        while (fgets (buf, sizeof (buf), pp) != NULL)
        {
            FIfld_set_text (pd->submit_form, FI_MSG_FIELD, 0, 0, buf, 0);

            if ((strlen (buf) + strlen (result)) < 128)
            {
                strcat (result, buf);
            }
        }
        fclose (pp);

        if (*result == NULL)
        {
            /* the file was empty, so remove it */

            unlink (errfile);

	    /* assume success and tell user */

            UMSGetByNum(result, PI_I_JobComplete, 0);
        }
    }

finish:

    return (sts);
}


/*
Name
        COpqinfo

Description
        This file contains functions which deal with the plotter queues
        available on the workstation.

History
        mrm     04/14/89    creation
        scw     07/17/92    ansi conversion
*/

#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "exmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "FI.h"
#include "pi.h"
#include "pidef.h"
#include "pilabel.h"

extern char *GRget_ingrhome();

static char *dir = NULL;
static char *subdir = "ip/cnuc/render/subscribed";

static void COsetup_ip_dir()
{
    dir = malloc(strlen(GRget_ingrhome(NULL)) + strlen(subdir) + 4);
    sprintf(dir, "%s/%s", GRget_ingrhome(NULL), subdir);
}

/*
Name
        COpqinfo

Description
        This function retrieves the maximum plotter limits associated
        with the specifed plotter queue.

History
        mrm     04/14/89    creation
*/

int COpqinfo (plotter_queue, x, y, plotter_unit)
char *plotter_queue;
double *x, *y;
char *plotter_unit;
{
    int sts;
    char *c, buf[32], filename[128];
    FILE *fp;

    sts = PI_F_FAIL;

    if (strlen (plotter_queue))
    {
        strncpy (buf, plotter_queue, 32);
        if (c = strchr (buf, '@'))
        {
            *c = NULL;
        }

        if (dir == NULL)
            COsetup_ip_dir();

        sprintf (filename, "%s/%s.pd", dir, buf);
        if (fp = fopen (filename, "r"))
        {
            sts = fscanf (fp, "%*s %lf %lf", x, y);

            if (sts < 2)
            {
                *x = *y = 1.0;
            }
            else
            {
                sts = PI_S_SUCCESS;
                plotter_unit[0] = 'm';
                plotter_unit[1] = NULL;
                COcvtsize (x, y, plotter_unit);
            }
            fclose (fp);
        }
    }
    return (sts);
}

/*
Name
        COspqlist

Description
        This function initializes the plotter queue list on the
        Submit Plot form.

History
        mrm     04/14/89    creation
                04/17/90    changed to fork a qstat
*/

int COspqlist (form, qcount)
Form form;
int *qcount;
{
    int sts;
    char buf[128], *c, queue[128], fmtbuf[64], unit[16];
    double x, y;
    struct stat statbuf;
    FILE *pp = NULL;

    sts = PI_F_NOQUEUE;
    *qcount = 0;
    if (dir == NULL)
        COsetup_ip_dir();

    /* open a pipe to qstat */
    COplotlog("qstat");
    if (pp = (FILE *)popen ("qstat", "r"))
    {
        while (fgets (buf, sizeof (buf), pp) != NULL)
        {
            COplotlog(buf);
            if (c = strchr (buf, '@')) /* look for queue@node string */
            {
                *c = NULL;
                sprintf (queue, "%s/%s.pd", dir, buf);
                if (stat (queue, &statbuf) == 0)
                {
                    if (COpqinfo (buf, &x, &y, unit))
                    {
                        COspformatqinfo (buf, x, y, unit, fmtbuf);
                        if (FIfld_set_list_text (form,
                                                 SUBMIT_PLOT_SELECT_PLOTTER,
                                                 *qcount, 0, fmtbuf, 0) == 0)
                        {
                            sts = PI_S_SUCCESS;
                            *qcount = *qcount + 1;
                        }
                    }                    
                }
            }
        }
        pclose (pp);
    }
    return (sts);
}


/*
Name
        COspformatqinfo

Description
        This function formats a plotter queue name and its limits for
        display on the Submit Plot form.  The active output units are
        used for the limit display.
*/

#argsused
int COspformatqinfo (queue, x, y, unit, buf)
char *queue;
double x, y;
char *unit, *buf;
{
    char active_units[3][32];
    double v[2];

#ifdef STANDALONE

    v[0] = x;
    v[1] = y;
    sprintf (active_units[0], "in");

#else

    OMuword osnum;
    int sts, i, j;

    /* get the current module space number */

    ex$get_cur_mod (osnum = &osnum);

    /* get the active output unit to display plotter limits */

    i = 0;

    co$get_default_units (msg = &sts,
                          table_name = "UOM_DISTANCE",
                          osnum = osnum,
                          flag = &i,
                          num_defaults = &j,
                          default_units = active_units);

    if (!(sts & 1))
    {
        sprintf (active_units[0], "in");    /* take a guess */
    }

    /* convert the plotter limits to default output units */

    v[0] = x;
    v[1] = y;

    co$cvt_value_to_value (msg = &sts, 
                           unit_type = "UOM_DISTANCE",
                           osnum = osnum,
                           alias_to_cvt_from = unit,
                           alias_to_cvt_to = active_units[0],
                           num_vals = 2,
                           values_in = v,
                           values_out = v);

#endif

    sprintf (buf, "%-23s %7.3f x %7.3f %s", queue, v[0], v[1], active_units[0]);

    return (PI_S_SUCCESS);
}

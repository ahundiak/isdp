/*
Name
        COqprreq

Description
        This function executes a qpr request according to the specified
        inputs.  The success of the request is indicated by the return
        value and the character string returned.  The character string
        returned will be no more than 256 characters.

Notes
        This file uses direct UMS calls for messages, rather than ex$message,
        so that standalone compilation of a Submit Plot executable is
        possible.  Use ex$message in here and I will kick your butt.

History
        mrm     03/21/89    creation
	Satish  08/02/95    Added Pen Table option
*/

#include <stdio.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "msdef.h"
#include "msmacros.h"
#include "exmacros.h"
#include "griomacros.h"
#include "plotmsg.h"
#include "FI.h"
#include "pidef.h"
#include "pi.h"


extern FILE *popen();

int COqprreq (pd, result)
PIplotdata *pd;
char *result;
{
#ifndef STANDALONE
    OMuword osnum;
#endif
    int sts;
    char cmd[512], buf[128], *c;
    double v[2];
    FILE *pp = NULL;

    sts = PI_S_SUCCESS;

    if (!strlen (pd->file))
    {
        sts = PI_F_FAIL;
        UMSGetByNum(result, PI_P_EntFlNme, 0);
    }
    else
    {
        strcpy (cmd, "qpr 2>&1 ");

        if (strlen (pd->queue))
        {
            sprintf (buf, " -q %s ", pd->queue);
            strcat (cmd, buf);
        }

        if (strlen (pd->date))
        {
            sprintf (buf, " -a \"%s\" ", pd->date);
            strcat (cmd, buf);
        }

        if (pd->mail & PI_MAIL_BEGIN)
        {
            strcat (cmd, " -mb ");
        }

        if (pd->mail & PI_MAIL_END)
        {
            strcat (cmd, " -me ");
        }

        if (pd->copies > 1)
        {
            sprintf (buf, " -n %d ", pd->copies);
            strcat (cmd, buf);
        }

        if (pd->filetype == PI_IGDS_FILE)
        {
            strcat (cmd, " -t IGDS ");
        }
        else if (pd->filetype == PI_IGM_FILE)
        {
            strcat (cmd, " -t iscrpt ");
        }
        else
        {
            UMSGetByNum(result, PI_E_InvFile, 0);
            sts = PI_F_FAIL;
            goto finish;
        }

        /* convert the size to units that the mfi likes */

        if (pd->rotate_90)
            v[1] = pd->plot_x, v[0] = pd->plot_y;
        else
            v[0] = pd->plot_x, v[1] = pd->plot_y;

#ifndef STANDALONE

        ex$get_cur_mod (osnum = &osnum);

        co$cvt_value_to_value (msg = &sts, 
                               unit_type = "UOM_DISTANCE",
                               osnum = osnum,
                               alias_to_cvt_from = NULL,
                               alias_to_cvt_to = "in",
                               num_vals = 2,
                               values_in = v,
                               values_out = v);
#endif

        sprintf (buf, " -o \" -e %.3fx%.3f \" ", v[0], v[1]);
        strcat (cmd, buf);

        if (pd->rendattr[0])
        {
            sprintf (buf, " -e REND_ATT=%s ", pd->rendattr);
            strcat (cmd, buf);
        }
        
	if (pd->pentable[0])
        {
            sprintf (buf, " -e IPLOTSRV_DEFAULT_PEN_TABLE=%s ", pd->pentable);
            strcat (cmd, buf);
        }

        if (pd->raster[0])
        {
            c = (pd->shvar[0]) ? pd->shvar : "DEM_RASTER";
            sprintf (buf, " -e %s=%s ", c, pd->raster);
            strcat (cmd, buf);
        }

        if (pd->rotate_90)
            GRset_plotfile_orientation(pd->file, 1);

        strcat (cmd, pd->file);

#ifdef DEBUG
        printf ("%s\n", cmd);
#endif
        COplotlog(cmd);

        pp = popen (cmd, "r");

        if (pp == NULL)
        {
            sts = PI_F_FAIL;
            UMSGetByNum(result, PI_E_CantExe, "%s","qpr");
        }
        else
        {
            cmd[0] = NULL;

            while (fgets (buf, sizeof (buf), pp) != NULL)
            {
#ifdef DEBUG
                printf ("%s\n", buf);
#endif
                COplotlog(buf);
                if ((strlen (cmd) + strlen (buf)) < 128)
                {
                    strcat (cmd, buf);
                }
            }

            sts = PI_S_SUCCESS;
            strncpy (result, cmd, 128);
            pclose (pp);
        }

        if (pd->rotate_90)
            GRset_plotfile_orientation(pd->file, 0);
    }

finish:

    return (sts);
}

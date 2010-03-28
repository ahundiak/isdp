/*
Name
        COsppfname

Description
        This function processes a new plotfile name when entered on the
        Submit Plot form.

Synopsis
        int COsppfname(pd, form_label, gadget_label, value, form, name)

        PIplotdata    *pd           I
        int           form_label    I
        int           gadget_label  I
        double        value         I
        Form          form          I
        char          *name         I

Notes
        This file uses direct UMS calls for messages, rather than ex$message,
        so that standalone compilation of a Submit Plot executable is
        possible.  Use ex$message in here and I will kick your butt.

Keywords
        plot, function, file

History
        03/14/89 : mrm : creation
        07/17/92 : scw : ansi conversion
        02/18/93 : dhm : UMS compliance
        06/09/93 : mrm : check for 90 degree rotation
*/

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
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

extern char *strrchr();
extern int strcmp();
extern int FIfld_set_text();
extern int FIg_display();

#argsused
int COsppfname(pd, form_label, gadget_label, value, form, name)
PIplotdata *pd;
int form_label;
int gadget_label;
double value;
Form form;
char *name;
{
    int sts, i, sel, file_count;
    int have_dir, have_file;
    char buf[128], unit[16], dirname[128];
    double x, y, t;
    DIR *dp;
#ifndef NT
    struct stat statbuf;
#else
    struct _stat statbuf;
#endif
    struct dirent *p_dirent;

    have_dir = FALSE;
    have_file = FALSE;

    /* check the name length */

    sts = COcknamln(name);

    if (sts == PI_W_NULLNAME)
    {
        strcpy(dirname, ".");
        have_dir = TRUE;
    }
    else
    {
        if (sts == PI_I_NAMETRUNC)
        {
            /* tell the user about the truncated name */

            UMSGetByNum(buf, PI_I_TruncName, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
        }

        /* check whether name is a valid plotfile */

        sts = COpftype(name, &i);

        if (sts & 1)
        {
            have_file = TRUE;
        }
        else
        {
            /* check whether the string is a directory name */

#ifndef NT
            sts = stat(name, &statbuf);
#else
            sts = _stat(name, &statbuf);
#endif
            if (sts == 0)
            {
                if ((statbuf.st_mode & S_IFDIR) == S_IFDIR)
                {
                    strcpy(dirname, name);
                    have_dir = TRUE;
                }
            }
            else
            {
                /* the string is not a plotfile or a directory */
                UMSGetByNum(buf, PI_E_NotPF, 0);
                FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);

                COspclearsize(form, pd);
            }
        }
    }

    if (have_dir)
    {
        UMSGetByNum(buf, PI_I_Scanning, "%s", dirname);
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
        FIfld_set_list_num_rows(form, SUBMIT_PLOT_FILE_NAME, 0, 0);
        file_count = 0;
        if (dp = opendir(dirname))
        {
            while ((p_dirent = readdir(dp)) != NULL)
            {
                sprintf(buf, "%s/%s", dirname, p_dirent->d_name);

                /* make sure the entry is a regular file (FIFO would hang) */
#ifndef NT
                if (stat(buf, &statbuf) == 0)
#else
                if (_stat(buf, &statbuf) == 0)
#endif
                {
                    if ((statbuf.st_mode & S_IFREG) == S_IFREG)
                    {
                        /* check whether name is a valid plotfile */

                        sts = COpftype(buf, &i);

                        if (sts & 1)
                        {
                            /* add file to list */

                            FIfld_set_list_text(form, SUBMIT_PLOT_FILE_NAME,
                                                file_count, 0, buf, 0);
                            file_count++;
                        }
                    }
                }
            }
            closedir(dp);
        }
        if (file_count)
        {
            buf[0] = NULL;

            if (!have_file)
            {
                /* grab the first in the list */

                if (FIfld_get_list_text(form, SUBMIT_PLOT_FILE_NAME, 0, 0,
                                        64, name, &sel) == 0)
                {
                    have_file = TRUE;
                }
            }
        }
        else
        {
            UMSGetByNum(buf, PI_I_DirHasNoPltFiles, "%s", dirname);
        }
        FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
    }

    if (have_file)
    {
        /* display the file name */

        FIfld_set_text(form, gadget_label, 0, 0, name, 0);

        /* NULL the raster name; will check at submit time for raster file */

        pd->raster[0] = NULL;

        /* get the extents */

        sts = COget_plotfile_extents(name, &x, &y, unit, &pd->filetype,
                                     pd->clipbox);

        if (!(sts & 1))
        {
            UMSGetByNum(buf, PI_E_NotPF, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
            goto finish;
        }

        /* convert the size to internal units */

        sts = COcvtsize(&x, &y, unit);

        if (!(sts & 1))
        {
            UMSGetByNum(buf, PI_I_UnkUnit, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
            goto finish;
        }

        pd->file_x = x;
        pd->file_y = y;
        strcpy(pd->file, name);

        strncpy(pd->file_unit, unit, 8);

        // Check whether the xy dimensions need to be swapped to handle
        // rotating the plot.  This allows the user to accurately size the
        // plot.
        if (pd->rotate_90)
        {
            t = pd->file_x;
            pd->file_x = pd->file_y;
            pd->file_y = t;

            if ((pd->last_value == PI_X_SIZE))
                pd->last_value = PI_Y_SIZE;
            else if ((pd->last_value == PI_Y_SIZE))
                pd->last_value = PI_X_SIZE;
        }

        /* check whether the file will fit the plotter */

        sts = COsizeplot(pd);

        if (!(sts & 1))
        {
            UMSGetByNum(buf, PI_I_PlotScaled, 0);
            FIfld_set_text(form, FI_MSG_FIELD, 0, 0, buf, 0);
        }

        /* display the plot size and scale */

        sts = COspshosize(pd);
    }

finish:

    if (!(sts & 1))
    {
        FIfld_set_text(form, SUBMIT_PLOT_FILE_NAME, 0, 0, "", 0);
        COspclearsize(form, pd);
        pd->file[0] = NULL;
    }

    return(sts);
}


#argsused
int COspclearsize(form, pd)
Form form;
PIplotdata *pd;
{
    pd->file_x = pd->plot_x = 1.0;
    pd->file_y = pd->plot_y = 1.0;
    pd->scale = 1.0;
    COspshosize(pd);
    return(PI_S_SUCCESS);
}

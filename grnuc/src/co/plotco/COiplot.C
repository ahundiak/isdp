/*
Name
        COiplot

Description
        This function handles the submission of a plot through I/PLOT.

Notes
        The exit codes for iplot command lines are 0 for success, non-zero for
        failure as of IPLOT 7.0.  Previous releases used 1 for success and 3
        for failure.  A call to iplot with no arguments is made once in this
        function to determine which version is being used.  That keeps EMS
        functioning normally for either IPLOT version.

        The wait(2) call in pclose(3S) shifts the return values 8 bits to the
        left.

History
        mrm     05/25/89    creation
        mrm     01/04/90    changed from simple pen table option to allow
                            user to specify arbitrary options
        mrm     01/26/90    check for /usr/bin/iplot
        sampath 06/10/92    added rotation
        mrm     08/05/93    changed to handle IPLOT 7.0 exit codes
        mrm     11/22/93    use whence to find iplot
        Sudha   08/11/94    Send cwd to whence. Whence() aborts when a ratser 
			    canvas is placed. use EXgetcwd to get current 
			    working diretory and send it to whence instead of
			    NULL.  - fix for TR# 119420217
*/

#include <stdlib.h>
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

#define OLD_IPLOT_SUCCESS       (0x1 << 8)
#define OLD_IPLOT_FAIL          (0x3 << 8)
#define NEW_IPLOT_SUCCESS       (0x0 << 8)

extern FILE *popen();
extern char *whence();

static int iplot_success_code = -1;
static char *iplot_path = NULL;

int COiplot(pd, result)
PIplotdata *pd;
char *result;
{
    int sts;
    char cmd[512], buf[128], tmpfile[128], *c, *ch, current_dir[256];
    struct stat statbuf;
    double x, y;
    char units[16];
    FILE *pp = NULL;

    /* make sure iplot is available */

    if (iplot_path == NULL)
    {
	/* get the current working directory */
        EXgetcwd(current_dir, 256);

        if (c = whence("iplot", current_dir))
            strcpy(iplot_path = (char *)malloc(strlen(c) + 2), c);
        else
            iplot_path = "iplot"; // fall through & let stat error out

        if (stat(iplot_path, &statbuf))
        {
            sts = PI_F_FAIL;
            UMSGetByNum(result, PI_F_NoIPLOT, 0);
            FIfld_set_text(pd->submit_form, FI_MSG_FIELD, 0, 0, result, 0);
            goto finish;
        }    
    }

    sts = PI_F_FAIL;

    /* check what return code means success from iplot (see notes above) */

    if (iplot_success_code == -1)
    {
        if (pp = popen(iplot_path, "r"))
        {
            while (fgets(buf, sizeof(buf), pp) != NULL)
                ;
            sts = pclose(pp);
            if (sts == OLD_IPLOT_FAIL)
                iplot_success_code = OLD_IPLOT_SUCCESS;
            else
                iplot_success_code = NEW_IPLOT_SUCCESS;
        }
    }

    /* get a temporary filename for the IPARM */

    if (!(c = getenv("TMPDIR")) || stat(c,&statbuf) || (strlen(c) > 112))
        c = "/usr/tmp";

    sprintf(tmpfile, "%s/iplotXXXXXX", c);

    mktemp(tmpfile);

    /* kludge for scale precision problem with iplot */
    if (pd->scale != 1.0)
        pd->scale = pd->scale - 0.00001;

    /* create the IPARM file */
    sprintf(cmd, "iplot 2>&1 create -design=%s -view=1 ", pd->file);
    sprintf(buf, "-scale=1:%.5f -queue=%s ", pd->scale, pd->queue);
    strcat(cmd, buf);

    /*** TR# 91N0956 ***/
    sts = COget_plotfile_extents(pd->file, &x, &y, units, &pd->filetype,
                                 pd->clipbox);
    if (tolower(units[0]) == 'i')
        sprintf(units, "inches");
    else if (tolower(units[0]) == 'c')
        sprintf(units, "cm");
    else if ((tolower(units[0]) == 'm') && (tolower(units[1]) == 'm'))
        sprintf(units, "mm");
    else
        sprintf(units, "meters");
    sprintf(buf, " -units=%s ", units);
    strcat(cmd, buf);

    /* check for the Rotate 90 box */
    if (pd->rotate_90)
        if (strstr(pd->iplot, "-rot") == NULL)
            strcat(cmd, " -rot=90 ");

    strcat(cmd, pd->iplot);
    strcat(cmd, " ");
    strcat(cmd, tmpfile);

#ifdef DEBUG
    printf("%s\n", cmd);
#endif

    COplotlog(cmd);

    if (pp = popen(cmd, "r"))
    {
        cmd[0] = NULL;

        while (fgets(buf, sizeof(buf), pp) != NULL)
        {
#ifdef DEBUG
            printf("%s\n", buf);
#endif
            COplotlog(buf);
            if ((strlen(cmd) + strlen(buf)) < 512)
            {
                strcat(cmd, buf);
            }
        }

        sts = pclose(pp);

        if (sts == iplot_success_code)
        {
            /* display the iplot create exit message */

            FIfld_set_text(pd->submit_form, FI_MSG_FIELD, 0, 0, cmd, 0);

            /* generate the I/PLOT metafile */

            sprintf(cmd, "iplot 2>&1 generate %s", tmpfile);
#ifdef DEBUG
            printf("%s\n", cmd);
#endif
            COplotlog(cmd);
            if (pp = popen(cmd, "r"))
            {
                cmd[0] = NULL;

                while (fgets(buf, sizeof(buf), pp) != NULL)
                {
#ifdef DEBUG
                    printf("%s\n", buf);
#endif
                    COplotlog(buf);
                    FIfld_set_text(pd->submit_form, FI_MSG_FIELD,
                                   0, 0, buf, 0);

                    if ((strlen(cmd) + strlen(buf)) < 512)
                    {
                        strcat(cmd, buf);
                    }
                }

                sts = pclose(pp);
                if (sts == iplot_success_code)
                {
                    /* submit the plot request */

                    sprintf(cmd, "iplot 2>&1 submit ");
                    buf[0] = NULL;
                    if (pd->date[0])
                    {
                        sprintf(buf, " -a \"%s\" ", pd->date);
                    }
                    if (pd->mail & PI_MAIL_BEGIN)
                    {
                        strcat(buf, " -mb ");
                    }
                    if (pd->mail & PI_MAIL_END)
                    {
                        strcat(buf, " -me ");
                    }
                    if (pd->rendattr[0])
                    {
                        c = buf;
                        while (*c != NULL) c++;
                        sprintf(c, " -e REND_ATT=%s ", pd->rendattr);
                    }
                    if (pd->raster[0])
                    {
                        c = buf;
                        while (*c != NULL) c++;
                        ch = (pd->shvar[0]) ? pd->shvar : "DEM_RASTER";
                        sprintf(c, " -e %s=%s ", ch, pd->raster);
                    }
                    if (strlen(buf))
                    {
                        strcat(cmd, " -qpr_options={ ");
                        strcat(cmd, buf);
                        strcat(cmd, " } ");
                    }
                    if (pd->copies > 1)
                    {
                        sprintf(buf, " -copies=%d ", pd->copies);
                        strcat(cmd, buf);
                    }
                    sprintf(buf, " %s", tmpfile);
                    strcat(cmd, buf);
#ifdef DEBUG
                    printf("%s\n", cmd);
#endif
                    COplotlog(cmd);
                    if (pp = popen(cmd, "r"))
                    {
                        cmd[0] = NULL;

                        while (fgets(buf, sizeof(buf), pp) != NULL)
                        {
#ifdef DEBUG
                            printf("%s\n", buf);
#endif
                            COplotlog(buf);
                            FIfld_set_text(pd->submit_form, FI_MSG_FIELD,
                                           0, 0, buf, 0);

                            if ((strlen(cmd) + strlen(buf)) < 512)
                            {
                                strcat(cmd, buf);
                            }
                        }

                        sts = pclose(pp);

                        if (sts == iplot_success_code)
                        {
                            sts = PI_S_SUCCESS;

                            /* make sure that subsequent iplot submissions */
                            /* use unique filenames */

                            sprintf(buf, "touch %s", tmpfile);
                            if (pp = popen(buf, "r"))
                            {
                                pclose(pp);
                            }
                        }
                    }
                }
            }
        }
    }

    /* check success and fill in output buffer */

    if (sts != PI_S_SUCCESS)
    {
#ifdef STANDALONE
        fprintf(stderr, "I/PLOT error:\n");
        fprintf(stderr, cmd);
        fprintf(stderr, "\n");
#else
        UI_error(cmd);
#endif
    }

    strncpy(result, cmd, 128);
    result[127] = NULL;

    /* clean up I/PLOT files */
/*
    sprintf(cmd, "rm -f %s*", tmpfile);
    if (pp = popen(cmd, "r"))
    {
        pclose(pp);
    }
*/

finish:

    return(sts);
}



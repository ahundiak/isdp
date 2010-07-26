/*
Name
        COchcmd

Description
        This function erases the active form and displays the indicated
        form, performing whatever actions are necessary to make the
        new form "active."

Notes
        This file uses direct UMS calls for messages, rather than ex$message,
        so that standalone compilation of a Submit Plot executable is
        possible.  Use ex$message in here without hiding it in 
        ifndef STANDALONE and I will kick your butt.

History
        mrm     03/20/89    creation
                11/08/89    display default color table
        dhm     02/07/92    disenable select_plotter toggle on the SUN until
                            iplot is working on the SUN.
        mrm     10/03/92    added Submit Local Plot option
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
#include "pilabel.h"
#include "pi.h"


extern int FIf_display ();
extern int FIf_erase ();
extern int FIfld_get_list_text ();
extern int FIfld_set_text ();
extern int FIg_disable();
extern int FIg_display ();
extern int FIg_erase ();
extern int COplot_set_help_topic ();

#argsused
int COchcmd (from, to, pd, cd)
int from, to;
PIplotdata *pd;
PIcreate *cd;
{
    int qcount, i, j, sel, state=0;
    char buf[64];

    /* erase the old form */

    switch (from)
    {
#ifndef STANDALONE
        case PI_CREATE_IGM_FORM:
        case PI_CREATE_FORM:
            FIg_disable (pd->create_form, FI_FORM_GROUP);
            break;
#endif
        case PI_SUBMIT_FORM:
            FIf_erase (pd->submit_form);
            break;

        case PI_QUEUE_FORM:
            FIf_erase (pd->qstat_form);
            break;

        default:
            break;
    }

    /* set the new help topic */

#ifndef STANDALONE
    COplot_set_help_topic (to);
#endif

    /* set up the new form */

    switch (to)
    {
#ifndef STANDALONE
        case PI_CREATE_IGM_FORM:
        case PI_CREATE_FORM:
            ex$message (msgnumb = PC_M_CrPf);

#ifdef INTERSCRIPT
            /* adjust according to the file type being created */
            if (pd->filetype == PI_IGDS_FILE)
            {
                FIfld_set_text (pd->create_form, CREATE_PLOT_COLOR_TABLE,
                                0, 0, cd->ctable, 0);
                ex$message(msgnum = PI_I_ColorTable,buff = buf);
            }
            else
            {
                if (cd->flood_index >= 0)
                {
                    sprintf (buf, "%d", cd->flood_index);
                }
                else
                {
                    buf[0] = NULL;
                }
                FIfld_set_text (pd->create_form, CREATE_PLOT_COLOR_TABLE,
                                0, 0, buf, 0);
                ex$message(msgnum = PI_I_FloodIndex, buff = buf);
            }
            FIg_erase (pd->create_form, CREATE_PLOT_CT_TEXT);
            FIg_set_text (pd->create_form, CREATE_PLOT_CT_TEXT, buf);
            FIg_display (pd->create_form, CREATE_PLOT_CT_TEXT);
#else
            FIg_erase (pd->create_form, CREATE_PLOT_FILE_TYPE);
#endif

            /* enable and display the form */
            FIg_enable (pd->create_form, FI_FORM_GROUP);
            FIf_display (pd->create_form);
            pd->displayed_form = pd->create_form;
            pd->command = to;

            if (pd->file[0])
            {
                /* notify the form that it has a plotfile name */

                FIfld_set_text (pd->create_form, CREATE_PLOT_FILE_NAME,
                                0, 0, pd->file, 0);

                COcpnotify (PI_CREATE_FORM, CREATE_PLOT_FILE_NAME, 1.0,
                            pd->create_form);
            }

            if (cd->ctable[0])
            {
                /* notify the form that it has a color table name */

                FIfld_set_text (pd->create_form, CREATE_PLOT_COLOR_TABLE,
                                0, 0, cd->ctable, 0);

                COcpnotify (PI_CREATE_FORM, CREATE_PLOT_COLOR_TABLE, 1.0,
                            pd->create_form);
            }

            /* grab the active fence or prompt for a window */
            if (cd->wftoggle == PI_TOGGLE_WINDOW)
                cd->wftoggle = PI_TOGGLE_FENCE;
            else
                cd->wftoggle = PI_TOGGLE_WINDOW;
            COcpnotify (PI_CREATE_FORM, CREATE_PLOT_WINDOW_FENCE, 1.0,
                        pd->create_form);
            break;
#endif

        case PI_SUBMIT_FORM:
        case PI_SUBMIT_LOCAL_FORM:
#ifndef STANDALONE
            ex$message (msgnumb = PC_M_SubPlot);
#endif
            /*
                The igds2hpgl local plotting solution is only supported for
                CLIX.  There is a special keyin command (Submit Local Plot) to
                access that solution, in case the new direct hpgl output goes
                flakey.  The igds2hpgl support should probably be removed once
                the direct hpgl output has been proven in the 2.1 release.
            */
#ifdef CLIX
            if (to != PI_SUBMIT_LOCAL_FORM)
            {
                FIg_disable(pd->submit_form, SUBMIT_PLOT_TYPE);
                FIg_erase(pd->submit_form, SUBMIT_PLOT_TYPE);
            }
#else
            FIg_disable(pd->submit_form, SUBMIT_PLOT_TYPE);
            FIg_erase(pd->submit_form, SUBMIT_PLOT_TYPE);
#endif

            FIf_display (pd->submit_form);
            pd->displayed_form = pd->submit_form;
            pd->command = to;

#if !defined ( SUNOS ) && !defined ( SUNOS5 )
            FIg_get_state(pd->submit_form, SUBMIT_PLOT_TYPE, &state);

            if(state)           /* Local plotting.... */
              break;
#endif

            /* fill in the plotter list */
            if (COspqlist (pd->submit_form, &qcount) == PI_F_NOQUEUE)
            {
                /* no queues defined */
                UMSGetByNum(buf, PI_E_NoPlotQ, 0);
/*
TR 90N2005      FIfld_set_text (pd->submit_form, SUBMIT_PLOT_SELECT_PLOTTER,
                                0, 0, buf, 0);
*/
                FIfld_set_text (pd->submit_form, FI_MSG_FIELD, 0, 0, buf, 0);
            }
            else
            {
                if (pd->queue[0] == NULL)
                {
                    /* grab the first plotter in the list */

                    FIfld_get_list_text (pd->submit_form,
                                         SUBMIT_PLOT_SELECT_PLOTTER,
                                         0, 0, 64, buf, &sel);
                    sscanf (buf, "%s", pd->queue);
                }
                else
                {
                    /* make sure the default is in the list of valid queues */

                    for (i = qcount; i > 0; i--)
                    {
                        FIfld_get_list_text (pd->submit_form,
                                             SUBMIT_PLOT_SELECT_PLOTTER,
                                             i - 1, 0, 64, buf, &sel);
                        for (j = 0; buf[j] != ' ' && j < strlen(buf); j++);
                        if (!strncmp(pd->queue,buf,j)) break;
                    }
                    if (i == 0) sscanf (buf, "%s", pd->queue);
                }

                /* display the default plotter, filename, and iplot options */

                COpqinfo (pd->queue, pd->plotter_max, &pd->plotter_max[1],
                          pd->plotter_unit);
                COspformatqinfo (pd->queue, pd->plotter_max[0],
                                 pd->plotter_max[1], pd->plotter_unit, buf);
                FIfld_set_text (pd->submit_form, SUBMIT_PLOT_SELECT_PLOTTER,
                                0, 0, buf, 0);
                FIfld_set_text (pd->submit_form, SUBMIT_PLOT_FILE_NAME,
                                0, 0, pd->file, 0);

                FIfld_set_text (pd->submit_form, SUBMIT_PLOT_IPLOT_OPTIONS,
                                0, 0, pd->iplot, 0);

                FIfld_set_text (pd->submit_form, SUBMIT_PLOT_REND_ATTR,
                                0, 0, pd->rendattr, 0);

/*  put last pen_table file  */

                FIfld_set_text (pd->submit_form, SUBMIT_PLOT_PEN_TABLE,
                                0, 0, pd->pentable, 0); 


                /* calculate the plot size */
                COspnotify (PI_SUBMIT_FORM, SUBMIT_PLOT_FILE_NAME, 1.0,
                            pd->submit_form);

                /* highlight the filename field */
/*
                This gives journaling fits.  Can it.  TR119221597.

                FIg_start_seq (pd->submit_form, SUBMIT_PLOT_FILE_NAME);
*/
            }
            break;

        case PI_QUEUE_FORM:
#ifndef STANDALONE
            ex$message (msgnumb = PC_M_QueSts);
#endif
            COqsgetq (pd->queue, buf);
            FIfld_set_text (pd->qstat_form, QSTATUS_QUEUE, 0, 0, buf, 0);
            FIf_display (pd->qstat_form);
            pd->displayed_form = pd->qstat_form;
            COqsnotify (PI_QUEUE_FORM, QSTATUS_UPDATE, 1.0, pd->qstat_form);
            pd->command = to;
            break;

        default:
            break;
    }

    return (PI_S_SUCCESS);
}
